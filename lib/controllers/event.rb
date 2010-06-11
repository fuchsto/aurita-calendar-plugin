
require('aurita/plugin_controller')
Aurita.import_plugin_module :calendar, 'gui/custom_form_elements'

module Aurita
module Plugins
module Calendar

  class Event_Controller < Plugin_Controller

 #  use_cache Cache::Simple
 #  cache_actions :show, :list

    def form_groups
      [
        Event.name, 
        Category.category_id,
        Event.tags, 
        Event.description, 
        Event.date_begin, 
        Event.date_end, 
        :repeat, 
        :time
      ]
    end

    def upcoming_events
      return unless Aurita.user.is_registered? 
      events  = Event.events_for(Time.now, Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24), Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24*2), Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24*3), Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24*4), Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24*5), Aurita.user.categories.map { |c| c.category_id })
      events += Event.events_for(Time.now+(60*60*24*6), Aurita.user.categories.map { |c| c.category_id })
      return unless events.length > 0
      box = Box.new(:class => :topic_inline, :id => :event_list)
      box.header = tl(:upcoming_events)
      box.body = view_string(:event_list, 
                             :events => events, 
                             :date => Time.now)
      return box
    end
    
    def add
      form = add_form()
      form[Event.date_begin].required! 
      form[Event.date_begin].value = param(:date_begin) if param(:date_begin)
      form.add(Category_Selection_List_Field.new())
      form.add(Timespan_Field.new(:name => :time, 
                                  :value => ['00:00', '23:45'], 
                                  :label => tl(:timespan), 
                                  :minute_range => [0, 15, 30, 45] ))
      form.add(GUI::Event_Repetition_Field.new(:name => :repeat))
      form[Content.tags] = Tag_Autocomplete_Field.new(:name => Content.tags.to_s, :label => tl(:tags))
      form[Content.tags].required!
      exec_js('Aurita.Main.init_autocomplete_tags();')
      
      Page.new(:header => tl(:add_event)) { decorate_form(form) }
    end

    def update
      instance = load_instance()
      repetition = :annual if  instance.repeat_annual == 't' 
      repetition = :monthly if instance.repeat_monthly.to_s != '' 
      repetition = :weekly if  instance.repeat_weekly.to_s != '' 
      form = update_form()
      form[Event.date_begin].required! 
      form.add(Category_Selection_List_Field.new(:value => instance.category_ids))
      form.add(Timespan_Field.new(:name => :time, 
                                  :value => [ instance.time_begin, instance.time_end ], 
                                  :label => tl(:timespan), 
                                  :minute_range => [0, 15, 30, 45] ))
      form.add(GUI::Event_Repetition_Field.new(:name => :repeat, :value => repetition))
      form[Content.tags] = Tag_Autocomplete_Field.new(:name => Content.tags.to_s, :label => tl(:tags), :value => instance.tags)
      form[Content.tags].required!

      exec_js('Aurita.Main.init_autocomplete_tags();')

      Page.new(:header => tl(:edit_event)) { decorate_form(form) }
    end

    def perform_add

      @params.set(:user_group_id, Aurita.user.user_group_id)
      @params.set(:date_end, param(:date_begin)) unless param(:date_end).to_s != ''

      @params.set(:repeat_monthly_day, nil)

      @params.set(:time_begin, "#{param(:time_begin_hour)}:#{param(:time_begin_minute)}")
      @params.set(:time_end,   "#{param(:time_end_hour)}:#{param(:time_end_minute)}")

      if param(:date_begin).to_s.include?('.')
        d = param(:date_begin).to_s.split('.').map { |x| x.to_i } 
        date_begin = Date.civil(d[2], d[1], d[0])
      elsif param(:date_begin).to_s.include?('-')
        d = param(:date_begin).to_s.split('-').map { |x| x.to_i } 
        date_begin = Date.civil(d[0], d[1], d[2])
      end

      case param(:repeat) 
        when 'no_repeat' # no repeat 
         # nothing to adjust
        when 'monthly' # monthly by date
          @params.set(:repeat_monthly, date_begin.mday)
        when 'monthly_day' # monthly by day
         # nothing to adjust
        when 'weekly' # weekly by day
          @params.set(:repeat_weekly, date_begin.wday)
        when 'annual' # annual repetition
          @params.set(:repeat_annual, 't')
      end

      event = super()
      Content_Category.create_for(event, param(:category_ids))

      redirect_date = param(:date_begin).split('.').reverse.join('.')
      exec_js("Aurita.load({ action: 'Calendar::Calendar/day/date=#{redirect_date}' });")

      invalidate_cache()
    end

    def perform_update
      # TODO: Implement a real update procedure
      event = load_instance
      event.delete
      perform_add

      invalidate_cache()
    end

    def perform_delete
      date = load_instance().date_begin
      super()
      exec_js("Aurita.load({ action: 'Calendar::Calendar/day/date=#{date}' });")

      invalidate_cache()
    end

    def added
      puts tl(:event_has_been_added)
    end

    # Collects plugin responses for hook calendar.event.list
    #
    def list(params={})
      date_str  = params[:date_str]
      user_cats = Aurita.user.categories.map { |c| c.category_id }
      date_str  = param(:day) unless date_str
      date      = Date.civil(date_str[0..3].to_i, 
                             date_str[5..6].to_i, 
                             date_str[8..9].to_i)

      plugin_get(Hook.calendar.event.list_day, :date => date)
    end

    def month(params={})
      month_str   = params[:month]
      month_str ||= param(:month)

      y = month_str[0..3].to_i
      m = month_str[5..6].to_i
      month = Date.civil(y, m)
      if m < 12 then
        month_end = Date.civil(y, m+1)-1
      else # year overlap
        month_end = Date.civil(y+1, 1)-1
      end

      plugin_get(Hook.calendar.event.list_month, :from_date => month, :to_date => month_end)
    end

    def week(params={})
      cweek   = params[:cweek]
      cweek ||= param(:cweek)
      
      y = month_str[0..3].to_i
      w = month_str[5..6].to_i
      week = Date.commercial(y, w)
      week_end = week+7

      plugin_get(Hook.calendar.event.list_week, :from_date => week, :to_date => week_end)
    end

    def events_on_day(date)
      render_view(:event_list_day, 
                  :events => Event.events_for(date, user_cats), 
                  :date   => date)
    end

    def invalidate_cache
      Calendar_Controller.invalidate_cache()
      super()
    end

  end

end
end
end

