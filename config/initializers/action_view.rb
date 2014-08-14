require 'action_view/helpers/tags/base'
require 'active_support/concern'

module StringifiedBooleanTagValue
  extend ActiveSupport::Concern

  included do
    alias_method_chain :add_options, :false_casting
  end

  private

  # "stringify" false values.  This avoids an issue in select tags
  # where the `prompt` will be visible if `false` is the selected value.
  # This happens because `add_options` will add the prompt if the value
  # is `blank?`, which false is.
  #
  # This feels pretty kludgy but it's a fix.  Currently `add_option`
  # *only* uses the value param to test it's "blankness", hopefully that
  # does not change.
  #
  def add_options_with_false_casting(option_tags, options, value=nil)
    if value == false
      value = 'false'
    end
    add_options_without_false_casting(option_tags, options, value)
  end
end

ActionView::Helpers::Tags::Base.send(:include, StringifiedBooleanTagValue)
