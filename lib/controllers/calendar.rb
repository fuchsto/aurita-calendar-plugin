
require('aurita/plugin_controller')
Aurita.import_plugin_controller :calendar, :event
Aurita.import_plugin_model :calendar, :event

module Aurita
module Plugins
module Calendar

  class Calendar_Controller < Plugin_Controller

    use_cache Cache::Simple
    cache_actions :show, :show_string, :day

    def calendar_box
    # return unless Aurita.user.may(:see_calendar)
      

      box        = Box.new(:type  => 'Calendar::calendar', 
                           :class => :topic, 
                           :id    => 'calendar_box')
      body       = []
      box.header = tl(:calendar)

      if Aurita.user.may(:create_events) then
        body << Toolbar_Button.new(:icon => :add_event, 
                                   :action => 'Calendar::Event/add') {
          tl(:add_event) 
        } 
      end
      body    << HTML.div(:id => :calendar_box_month) { calendar_box_body }
      box.body = body
      
      return box
    end
    
    def calendar_box_body(year=nil, month=nil)
    # return unless Aurita.user.may(:see_calendar)

      if month.nil? or year.nil? then
        d     = Time.now
        year  = d.year
        month = d.month
      end

      HTML.div { 
        view_string(:calendar, 
                    :year  => year.to_i, 
                    :month => month.to_i, 
                    :date  => Date.civil(year.to_i, month.to_i))
      }
    end

    def show
    # return unless Aurita.user.may(:see_calendar)

      year  = param(:year)
      month = param(:month)
      calendar_box_body(year, month)
    end

    def day
      render_controller(Event_Controller, :list, :day => param(:date))
    end

  end

end
end
end

