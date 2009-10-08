
require('aurita')
require('aurita-gui')
Aurita.import_module :gui, :erb_helpers
Aurita.import_module :gui, :i18n_helpers

module Aurita
module Plugins
module Calendar
module GUI

  class Event_Repetition_Field < Aurita::GUI::Form_Field
  include Aurita::GUI
  include Aurita::GUI::I18N_Helpers
    
    attr_accessor :weekly, :monthly, :annual

    def initialize(params, &block)
      params[:value] = :no_repeat unless params[:value]
      super(params, &block)
    end

    def element

      return HTML.div { 
        Radio_Field.new(:id => dom_id, 
                        :name => @attrib[:name], 
                        :value => @value, 
                        :option_values => [ :no_repeat, :weekly, :monthly, :annual ], 
                        :option_labels => [ tl(:no_repeat), tl(:repeat_weekly), tl(:repeat_monthly), tl(:repeat_annual) ])
      }

      HTML.div { 
        Checkbox_Field.new(:id   => "#{dom_id()}_weekly", 
                           :name => "#{@attrib[:name]}_weekly",  
                           :option_values => ['t'], :value => @value[:weekly],  :option_labels => [ tl(:repeat_weekly) ] ) + 
        Checkbox_Field.new(:id   => "#{dom_id()}_monthly", 
                           :name => "#{@attrib[:name]}_monthly", 
                           :option_values => ['t'], :value => @value[:monthly], :option_labels => [ tl(:repeat_monthly) ] ) + 
        Checkbox_Field.new(:id   => "#{dom_id()}_annual",  
                           :name => "#{@attrib[:name]}_annual",  
                           :option_values => ['t'], :value => @value[:annual],  :option_labels => [ tl(:repeat_annual) ] ) 
      }
    end

  end # class Picture_Asset_Field

end
end
end
end

