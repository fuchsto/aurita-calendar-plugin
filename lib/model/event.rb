
require('aurita/model')
Aurita::Main.import_model :content
Aurita::Main.import_model :category
Aurita::Main.import_model :user_group
Aurita.import_plugin_model :calendar, :event

module Aurita
module Plugins
module Calendar

  class Event < Aurita::Main::Content

    table :event, :public
    primary_key :event_id, :event_id_seq

    is_a Aurita::Main::Content, :content_id
    
    explicit :max_participants, :repeat_monthly, :repeat_monthly_day

    validates :time_begin, :format => /\d\d?:\d\d/
    validates :time_end, :format => /\d\d?:\d\d/

    expects :name

    html_escape_values_of :name

    add_output_filter(:name) { |n|
      n.gsub('"','&quot;')
    }

    def self.events_for(date, category_ids=nil)

      wday = date.wday
      mday = date.mday
      date = date.strftime("%Y-%m-%d")
      events = []
      # Immediate hits without repetition
      events +=  Event.select { |e|
        e.where((e.date_begin == date) & (e.date_end >= e.date_begin) & (Event.accessible))
        e.order_by(:time_begin, :asc)
      }.to_a

      # Annual repetition
      Event.select { |e| 
        e.where((Event.accessible) & (((e.date_begin <= date) & (e.date_end == e.date_begin) & (e.repeat_annual == 't')) | 
                                     ((e.date_begin <= date) & (e.date_end >= date) & (e.repeat_annual == 't'))))
        e.order_by(:time_begin, :asc)
      }.each { |evt|
        events << evt 
      }
      # Monthly repetition by date
      Event.select { |e|
        e.where((Event.accessible) & (((e.date_begin <= date) & (e.date_end == e.date_begin) & (e.repeat_monthly == mday)) | 
                                     ((e.date_begin <= date) & (e.date_end >= date) & (e.repeat_monthly == mday))))
        e.order_by(:time_begin, :asc)
      }.each { |evt|
        events << evt 
      }
      # Weekly repetition by day
      Event.select { |e|
        e.where((Event.accessible) & (((e.date_begin <= date) & (e.date_end == e.date_begin) & (e.repeat_weekly == wday)) | 
                                     ((e.date_begin <= date) & (e.date_end >= date) & (e.repeat_weekly == wday))))
        e.order_by(:time_begin, :asc)
      }.each { |evt|
        events << evt 
      }
      return events

    end

    def no_repeat? 
      repeat_weekly.to_s == '' and repeat_annual == 'f' and repeat_monthly == '0' and repeat_monthly_day == 'f'
    end

  end 

end # module
end # module
end # module

