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
    @date  = Date.civil(year, month)
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

