module FlashToHeaders
  extend ActiveSupport::Concern

  included do
    after_filter :flash_to_headers
  end

  private
 
  def flash_to_headers
    return unless request.xhr?

    if hdrs = get_flash_headers
      response.headers['X-Message'] = hdrs[0]
      response.headers["X-Message-Type"] = hdrs[1]
    end

    flash.discard
  end

  def get_flash_headers
    [:alert, :warning, :notice].each do |type|
      return [flash[type], type.to_s] if flash[type]
    end

    return false
  end
end
