module DeterminesLayout
  extend ActiveSupport::Concern

  included do
    layout :determine_layout
    class_attribute :layout_name
    self.layout_name = 'application'
  end

  protected

  def determine_layout
    retv = case layout_name
           when String then layout_name
           when Proc then layout_name.call(self)
           when Symbol then self.send(layout_name)
           end

    request.xhr? ? false : retv
  end
end
