# Runs every lane in a Fastfile without running its actions or shell commands.
# Each action call still goes through fastlane's own option parsing and
# validation, and required options that can't come from a default or an
# environment variable must be given. So a missing action, an unknown option,
# a bad value or a missing option of that kind fails, as does any error in the
# Ruby around the calls. `fastlane lanes` only loads lane definitions, so these
# mistakes would otherwise surface only when a lane runs for real.
#
# Usage, from the directory with the Gemfile:
#   bundle exec ruby dry_run_fastfile.rb fastlane/Fastfile [lane key=value,...]
#
# Every public lane runs once with no options. Each extra `lane key=value,...`
# argument runs that lane again with those options, to cover their branches.

require "fastlane"

module DryRun
  # Actions that only read state, so they are safe and needed to run for real.
  PASSTHROUGH = %i[lane_context].freeze

  # Mirrors Fastlane::Runner#execute_action up to the point where the action
  # would run, then skips it.
  def execute_action(method_sym, class_ref, arguments, custom_dir: nil, from_action: false)
    return super if PASSTHROUGH.include?(method_sym)

    if from_action
      custom_dir = "."
    elsif custom_dir.nil?
      custom_dir = ".."
    end
    verify_supported_os(method_sym, class_ref)

    Dir.chdir(custom_dir) do
      if arguments.count > 1 || (arguments.count == 1 && !arguments.first.kind_of?(Hash))
        # Like fastlane, only actions without an options interface take
        # positional arguments.
        next if class_ref.available_options.nil?

        FastlaneCore::UI.user_error!("You have to call the integration like `#{method_sym}(key: \"value\")`")
      end

      options = arguments.first ? arguments.first.dup : {}
      options.delete(:step_name)
      Fastlane::ConfigurationHelper.parse(class_ref, options)

      # fastlane only enforces required options when the action reads them.
      # Ones that can come from an environment variable may be set at runtime.
      missing = Array(class_ref.available_options).compact.select do |option|
        !option.optional && option.default_value.nil? && option.env_name.to_s.empty? &&
          !options.key?(option.key)
      end
      unless missing.empty?
        FastlaneCore::UI.user_error!("#{method_sym} is missing required options: #{missing.map(&:key).join(', ')}")
      end
    end
    puts("  #{method_sym}")
    fake_results(method_sym, arguments.first || {})
    nil
  end

  # Leaves what the skipped action would have left in lane_context, so the
  # code that reads it runs too.
  def fake_results(method_sym, options)
    return unless method_sym == :sync_code_signing

    Array(options[:app_identifier]).each do |app_identifier|
      mapping = (Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING] ||= {})
      mapping[app_identifier] = "match dry run #{app_identifier}"
    end
  end
end
Fastlane::Runner.prepend(DryRun)

# `sh` doesn't go through the action runner, so skip shell commands here. They
# return what `shorebird ... --json` prints when it succeeds with no results.
module DryRunShell
  def sh(*command, **)
    puts("  sh #{command.join(' ')}")
    '{"status":"success","data":{"releases":[]}}'
  end
end
Fastlane::FastFile.singleton_class.prepend(DryRunShell)

fastfile_path = File.expand_path(ARGV.fetch(0))
Fastlane.load_actions
Fastlane.plugin_manager.load_plugins
fastfile = Fastlane::FastFile.new(fastfile_path)

runs = []
fastfile.runner.lanes.each do |platform, lanes|
  lanes.each_value do |lane|
    runs << [platform, lane.name, {}] unless lane.is_private
  end
end
ARGV.drop(1).each_slice(2) do |name, options|
  platform, = fastfile.runner.lanes.find { |_, lanes| lanes.key?(name.to_sym) } ||
               abort("No lane named #{name}")
  options = options.to_s.split(",").to_h do |pair|
    key, value = pair.split("=", 2)
    abort("Expected key=value for lane #{name}, got #{pair.inspect}") if value.nil? || key.empty?
    [key.to_sym, value]
  end
  runs << [platform, name.to_sym, options]
end

runs.each do |platform, name, options|
  # Start each run as fastlane would, with nothing left by the previous one.
  Fastlane::Actions.lane_context.clear
  puts("#{[platform, name].compact.join(' ')} #{options}:")
  fastfile.runner.execute(name, platform, options)
end
puts("All lanes ran")
