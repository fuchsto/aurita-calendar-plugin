require 'date'

class Date

  def is_proxy(bool)
    @is_proxy = bool
  end

  def is_proxy?
    @is_proxy
  end

  def is_weekend?
    cwday == 6 or cwday == 7
  end

  def today? 
    self.strftime("%Y%m%d") === Time.now.strftime("%Y%m%d")
  end

end

class Month

  attr_accessor :start_week_day

  def initialize(year, month)
    @date = Date.civil(year, month)
    @month = month
    @start_week_day = 1
  end


  def days
    days = []
    pre_proxies = 0
    if(@date.cwday != @start_week_day) then # first day is not first day of week
      pre_proxies = @date.cwday-@start_week_day
    end
    count = 0
    pre_proxies.times { 
      prox = @date+count
      prox.is_proxy(true)
      days << prox
      count += 1
    }
    count = 0
    (42-pre_proxies).times { 
      if((@date + count).month == @month) then
        days << @date + count 
      else 
        # ignore last proxy day
        if count < 42-pre_proxies then 
          prox = @date + count
          prox.is_proxy(true)
          days << prox
        end
      end
      count += 1
    }
    days
  end
end

#
# cal = Calendar.new(:year => 2007, :month => 1
class Calendar

  def self.lang_weekday
  { 
    'Mon' => 'Mo',
    'Tue' => 'Di',
    'Wed' => 'Mi',
    'Thu' => 'Do',
    'Fri' => 'Fr',
    'Sat' => 'Sa',
    'Sun' => 'So',
  }
  end

  def self.weekdays
    ['Mo',
     'Di',
     'Mi',
     'Do',
     'Fr',
     'Sa',
     'So']
  end

  def self.weekday(date)
    dayname = date.strftime("%a")
    date.strftime("%d").gsub(dayname, Calendar.lang_weekday[dayname]) 
  end

  def initialize(args={})
    # e.g. 2007-11-1 for Nov. 2007
    raise ArgumentException unless (args[:year])
    @year = args[:year]
    @base_date = Date.civil(args[:year])
    
  end

end

=begin
(5..12).each { |month| 
  puts Date.civil(2007,month).strftime("%B 2007")
  puts Calendar.weekdays.join(' ')
  puts '--------------------'
  count = 1
  Month.new(2007,month).days.each { |date|
    if date.is_proxy? then
      STDOUT << ' - '
    else
      if date.is_weekend? then
        STDOUT << Calendar.weekday(date) + '-'
      elsif date.today? then
        STDOUT << ' ! '
      else
        STDOUT << Calendar.weekday(date) + ' '
      end
    end
    if count > 0 and (count % 7) == 0 then
      puts ''
    end
    count += 1
  }
  puts "\n\n"
}
=end
