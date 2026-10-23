# Runs every lane in a Fastfile without running its actions. Each action call
# still goes through fastlane's own option parsing and validation, so a
# missing action, an unknown option or a bad value fails, as does any error in
# the Ruby around the calls. `fastlane lanes` only loads lane definitions, so
# these mistakes would otherwise surface only when a lane runs for real.
#
# Usage, from the directory with the Gemfile:
#   bundle exec ruby dry_run_fastfile.rb fastlane/Fastfile

require "fastlane"

module DryRun
  # Actions that only read state, so they are safe and needed to run for real.
  PASSTHROUGH = %i[is_ci lane_context].freeze

  # Validates the options as fastlane would, then skips the action.
  def execute_action(method_sym, class_ref, arguments, custom_dir: nil, from_action: false)
    return super if PASSTHROUGH.include?(method_sym)

    options = arguments.first.kind_of?(Hash) ? arguments.first.dup : {}
    options.delete(:step_name)
    Fastlane::ConfigurationHelper.parse(class_ref, options)
    puts("  #{method_sym}")
    nil
  end
end
Fastlane::Runner.prepend(DryRun)

fastfile_path = File.expand_path(ARGV.fetch(0))
Fastlane.load_actions
Fastlane.plugin_manager.load_plugins
fastfile = Fastlane::FastFile.new(fastfile_path)

fastfile.runner.lanes.each do |platform, lanes|
  lanes.each_value do |lane|
    next if lane.is_private

    puts("#{[platform, lane.name].compact.join(' ')}:")
    fastfile.runner.execute(lane.name, platform, {})
  end
end
puts("All lanes ran")
