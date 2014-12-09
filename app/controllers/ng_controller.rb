class NgController < ApplicationController
  skip_before_filter :authenticate_user!, only: :template

  def template
    render template: File.join("ng", "templates", params[:path]), layout: false
  end
end
