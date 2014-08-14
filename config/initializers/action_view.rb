require 'action_view/helpers/tags/base'
require 'active_support/concern'

module StringifiedBooleanTagValue
  extend ActiveSupport::Concern

  included do
    alias_method_chain :value, :stringified_booleans
  end

  private

  # "stringify" Boolean values.  This avoids an issue in select tags
  # where the `prompt` will be visible if `false` is the selected value,
  # presumably because `false` is not `present?`
  def value_with_stringified_booleans(object)
    retv = value_without_stringified_booleans(object)
    retv = retv.to_s if retv == !!retv
    retv
  end
end

ActionView::Helpers::Tags::Base.send(:include, StringifiedBooleanTagValue)
