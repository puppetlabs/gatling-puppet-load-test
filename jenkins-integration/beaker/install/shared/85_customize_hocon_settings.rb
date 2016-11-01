require 'json'
require 'beaker/dsl/helpers/hocon_helpers'


def set_hocon_setting(file_path, setting_path, value)
  step "Set #{setting_path} in #{file_path}"
  hocon_file_edit_in_place_on([master], file_path) do |host, doc|
    doc.set_value(setting_path, value)
  end
end

def unset_hocon_setting(file_path, setting_path)
  step "Unset #{setting_path} in #{file_path}"
  hocon_file_edit_in_place_on([master], file_path) do |host, doc|
    doc.remove_value(setting_path, value)
  end
end

test_name 'Configure hocon settings on SUT'

hocon_settings = JSON.parse(ENV['PUPPET_GATLING_HOCON_SETTINGS'])

hocon_settings.each do |setting|
  case setting['action']
    when 'set', nil
      set_hocon_setting(setting['file'], setting['path'], setting['value'])
    when 'unset'
      unset_hocon_setting(setting['file'], setting['path'])
    else
      raise Exception.new("Invalid hocon action '#{setting['action']}'. Must be 'set', 'unset', or omitted (defaults to 'set')")
  end
end

