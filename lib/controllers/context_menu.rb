
require('aurita/plugin_controller')
Aurita.import_module :context_menu_helpers


module Aurita
module Plugins
module Calendar

  class Context_Menu_Controller < Aurita::Plugin_Controller
  include Aurita::Context_Menu_Helpers

    def event()
      event_id = param(:event_id)
     
      targets = { 'event_index' => 'Calendar/day/date=' << param(:date) }
 
      header(tl(:event))
      entry(:delete_event, 'Calendar::Event/delete/event_id='+event_id, targets)
      switch_to_entry(:edit_event, 'Calendar::Event/update/event_id='+event_id)
    end

    def calendar()
      header(tl(:calendar))
      switch_to_entry(:add_event, 'Calendar::Event/add/')
    end

  end

end
end
end
