# Runs every lane in a Fastfile without running its actions or shell commands.
# fastlane dispatches each action call as usual, parsing and validating its
# options, and only the action's own `run` is skipped. Required options with
# no default must also come from the call, a config file or a set environment
# variable. So a missing action, an unknown option, a bad value or a missing
# required option fails, as does any error in the Ruby around the calls. `fastlane lanes`
# only loads lane definitions, so these mistakes would otherwise surface only
# when a lane runs for real.
#
# Usage, from the directory with the Gemfile:
#   bundle exec ruby dry_run_fastfile.rb fastlane/Fastfile [lane key=value,...]
#
# Every public lane runs with no options, except lanes given as extra
# `lane key=value,...` arguments, which run with those options instead (once
# per argument). Values can't contain commas. Each run happens twice: once as
# on CI and once as on a developer's machine.

require "fastlane"
require "json"

fastfile_path = File.expand_path(ARGV.fetch(0))
Fastlane.load_actions
Fastlane.plugin_manager.load_plugins

# Actions that only read state, so they are safe and needed to run for real.
PASSTHROUGH = [Fastlane::Actions::LaneContextAction].freeze

# Config files that actions load at the start of their `run`, which is skipped
# here, keyed by action name.
CONFIG_FILES = {
  "sync_code_signing" => "Matchfile",
  "match" => "Matchfile",
  "match_nuke" => "Matchfile",
  "upload_to_app_store" => "Deliverfile",
  "deliver" => "Deliverfile",
  "build_app" => "Gymfile",
  "gym" => "Gymfile",
  "run_tests" => "Scanfile",
  "scan" => "Scanfile"
}.freeze

# What the skipped actions return, for those whose results the Fastfile uses.
# Values are shaped like the real ones; App Store Connect build numbers can be
# strings.
FAKE_RETURN_VALUES = {
  "latest_testflight_build_number" => "12"
}.freeze

# Replaces an action's `run`, which fastlane calls after parsing its options.
module DryRunAction
  def run(params)
    params.load_configuration_file(CONFIG_FILES[action_name]) if CONFIG_FILES.key?(action_name)
    # A required option must get a value from the call, its environment
    # variable, a config file or its default, looked up as fastlane does but
    # without prompting. CI sets the sample's documented variables.
    # Options whose default is worked out at runtime (default_value_dynamic)
    # may only get a value inside `run`, so they aren't checked.
    missing = Array(available_options).compact.select do |option|
      !option.optional && !option.default_value_dynamic && params.fetch(option.key, ask: false).nil?
    end
    unless missing.empty?
      FastlaneCore::UI.user_error!("#{action_name} is missing required options: #{missing.map(&:key).join(', ')}")
    end
    puts("  #{action_name}")
    fake_results(params)
    FAKE_RETURN_VALUES[action_name]
  end

  # Leaves what the skipped action would have left in lane_context, so the
  # code that reads it runs too.
  def fake_results(params)
    # `match` is the same action under another name.
    return unless self <= Fastlane::Actions::SyncCodeSigningAction

    app_identifiers = params._values[:app_identifier] ||
                      CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    mapping = (Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING] ||= {})
    Array(app_identifiers).each do |app_identifier|
      mapping[app_identifier] = "match dry run #{app_identifier}"
    end
  end
end
Fastlane::Actions.constants.each do |name|
  action = Fastlane::Actions.const_get(name)
  next unless action.is_a?(Class) && action < Fastlane::Action
  next if PASSTHROUGH.include?(action)

  action.singleton_class.prepend(DryRunAction)
end

# Every `sh` in a Fastfile ends up here. Commands this script knows return
# canned output; any other command fails, so that nothing runs for real and no
# lane gets output it didn't expect.
SHELL_OUTPUTS = {
  # What `shorebird releases list --json` prints (a success envelope around
  # Release.toJson from shorebird_code_push_protocol), with a few releases, so
  # the code that reads it runs too.
  /\bshorebird releases list\b.*--json/ => {
    status: "success",
    data: {
      releases: [["1.0.0+11", 1], ["1.0.0+12", 2], ["1.0.1+3", 3]].map do |version, id|
        { id: id, app_id: "dry-run", version: version, flutter_revision: "dry-run", platform_statuses: { ios: "active" } }
      end
    },
    meta: { version: "dry-run", command: "releases list" }
  }.to_json
}.freeze
module DryRunShell
  def sh_control_output(*command, **)
    command_line = command.join(" ")
    _, output = SHELL_OUTPUTS.find { |pattern, _| pattern.match?(command_line) }
    FastlaneCore::UI.user_error!("The dry run has no output for this command; add it to SHELL_OUTPUTS: #{command_line}") unless output
    puts("  sh #{command_line}")
    output
  end
end
Fastlane::Actions.singleton_class.prepend(DryRunShell)

# Lets each run choose whether fastlane thinks it's on CI. The CI runs unset
# the variables named in DRY_RUN_LOCAL_ONLY_ENV and the local runs unset those
# in DRY_RUN_CI_ONLY_ENV (both comma-separated), so each runs with only the
# credentials it would really have.
env_list = ->(name) { ENV.fetch(name, "").split(",").map(&:strip).reject(&:empty?) }
CI_ONLY_ENV = env_list.call("DRY_RUN_CI_ONLY_ENV").freeze
LOCAL_ONLY_ENV = env_list.call("DRY_RUN_LOCAL_ONLY_ENV").freeze
module DryRunCI
  attr_accessor :dry_run_ci

  def ci?
    dry_run_ci.nil? ? super : dry_run_ci
  end
end
FastlaneCore::Helper.singleton_class.prepend(DryRunCI)

fastfile = Fastlane::FastFile.new(fastfile_path)

lane_arguments = ARGV.drop(1)
abort("Expected `lane key=value,...` pairs, got an odd number of arguments") if lane_arguments.size.odd?

runs = []
lanes_with_options = lane_arguments.each_slice(2).map(&:first)
fastfile.runner.lanes.each do |platform, lanes|
  lanes.each_value do |lane|
    next if lane.is_private || lanes_with_options.include?(lane.name.to_s)

    runs << [platform, lane.name, {}]
  end
end
lane_arguments.each_slice(2) do |name, options|
  platform, = fastfile.runner.lanes.find { |_, lanes| lanes.key?(name.to_sym) } ||
               abort("No lane named #{name}")
  options = options.split(",").to_h do |pair|
    key, value = pair.split("=", 2)
    abort("Expected key=value for lane #{name}, got #{pair.inspect}") if value.nil? || key.empty?
    [key.to_sym, value]
  end
  runs << [platform, name.to_sym, options]
end

ci_env = CI_ONLY_ENV.to_h { |name| [name, ENV.fetch(name, nil)] }
local_env = LOCAL_ONLY_ENV.to_h { |name| [name, ENV.fetch(name, nil)] }
[true, false].each do |ci|
  FastlaneCore::Helper.dry_run_ci = ci
  ci_env.each { |name, value| ENV[name] = ci ? value : nil }
  local_env.each { |name, value| ENV[name] = ci ? nil : value }
  runs.each do |platform, name, options|
    # Start each run as fastlane would, with nothing left by the previous one.
    Fastlane::Actions.lane_context.clear
    puts("#{[platform, name].compact.join(' ')} #{options}#{ci ? ' (CI)' : ''}:")
    fastfile.runner.execute(name, platform, options)
  end
end
puts("All lanes ran")
