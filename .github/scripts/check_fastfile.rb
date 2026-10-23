# Checks that every fastlane action a Fastfile calls exists and accepts the
# options it is given. `fastlane lanes` only loads lane definitions, so a
# renamed action or option would otherwise go unnoticed until a lane runs.
#
# Usage, from the directory with the Gemfile:
#   bundle exec ruby check_fastfile.rb fastlane/Fastfile

require "fastlane"
require "ripper"

# Fastfile DSL methods, not actions.
DSL_METHODS = %w[desc lane lane_context platform private_lane require].freeze

fastfile = ARGV.fetch(0)
sexp = Ripper.sexp(File.read(fastfile)) || abort("Could not parse #{fastfile}")

calls = Hash.new { |hash, name| hash[name] = [] }
lane_names = []

# Records the keyword option names (`key: value`) in a call's arguments,
# leaving out those of calls nested inside them.
option_names = lambda do |node|
  next [] unless node.is_a?(Array)
  next [] if %i[method_add_arg command].include?(node[0])
  if node[0] == :assoc_new && node[1].is_a?(Array) && node[1][0] == :@label
    [node[1][1].delete_suffix(":")]
  else
    node.flat_map { |child| option_names.call(child) }
  end
end

walk = lambda do |node|
  next unless node.is_a?(Array)
  case node[0]
  when :method_add_arg
    # name(args)
    if node[1].is_a?(Array) && node[1][0] == :fcall
      calls[node[1][1][1]] << option_names.call(node[2])
    end
  when :command
    # name args, e.g. `lane :release do`
    name = node[1][1]
    calls[name] << option_names.call(node[2])
    if %w[lane private_lane].include?(name)
      symbol = node[2].flatten.each_cons(2).find { |kind, _| kind == :@ident }
      lane_names << symbol[1] if symbol
    end
  when :vcall
    # A bare call with no arguments, e.g. `setup_ci`.
    calls[node[1][1]] << []
  end
  node.each { |child| walk.call(child) }
end
walk.call(sexp)

Fastlane.load_actions
Fastlane.plugin_manager.load_plugins

errors = []
checked = 0
calls.each do |name, option_lists|
  next if DSL_METHODS.include?(name) || lane_names.include?(name)
  # Ruby built-ins such as __dir__ and puts.
  next if Kernel.respond_to?(name, true)

  action = Fastlane::Actions.action_class_ref(name)
  unless action
    errors << "#{name}: no such action"
    next
  end
  checked += 1

  known = Array(action.available_options).compact.map { |option| option.key.to_s }
  option_lists.flatten.uniq.each do |option|
    errors << "#{name}: unknown option #{option}" unless known.include?(option)
  end
end

abort(errors.map { |error| "#{fastfile}: #{error}" }.join("\n")) unless errors.empty?
puts "#{fastfile}: #{checked} actions and their options are valid"
