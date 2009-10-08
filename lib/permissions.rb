
require('aurita/plugin')

module Aurita
module Plugins
module Calendar


  # Usage: 
  #
  #  plugin_get(Hook.right_column)
  #
  class Permissions < Aurita::Plugin::Manifest

    register_permission(:create_events, 
                        :type    => :bool, 
                        :default => true)
    register_permission(:edit_foreign_events, 
                        :type    => :bool, 
                        :default => true)
    register_permission(:see_calendar, 
                        :type    => :bool, 
                        :default => true)
  end

end
end
end

