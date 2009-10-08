
require('aurita/plugin_controller')
Aurita.import_plugin_controller :calendar, :event
Aurita.import_plugin_model :calendar, :event
Aurita.import_plugin_module :calendar, :calendar

module Aurita
module Plugins
module Calendar

  class Calendar_Controller < Plugin_Controller

    use_cache Cache::Simple
    cache_actions :show, :show_string, :calendar_box, :day

    def calendar_box
      return unless Aurita.user.may(:see_calendar)
      body = []

      if Aurita.user.may(:create_events) then
        add_event = HTML.a(:class => :icon, 
                           :onclick => "Aurita.load({ action: 'Calendar::Event/add/'});") { 
          HTML.img(:src => '/aurita/images/icons/event_add.gif') + 
          tl(:add_event) 
        } 
        body << add_event
      end
      body << HTML.div(:id => :calendar_box_month) { show_string }

      box        = Box.new(:type => 'Calendar::calendar', :class => :topic, :id => 'calendar_box')
      box.header = tl(:calendar)
      box.body   = body 
      return box
    end
    
    def show_string(year=nil, month=nil)
      if month.nil? or year.nil? then
        d = Time.now
        year = d.year
        month = d.month
      end
      view_string(:calendar, 
                  :year => year.to_i, 
                  :month => month.to_i, 
                  :date => Date.civil(year.to_i, month.to_i))
    end

    def show
      year  = param(:year)
      month = param(:month)
      puts show_string(year, month)
    end

    def day
      render_controller(Event_Controller, :list, :day => param(:date))
    end

  end

end
end
end

