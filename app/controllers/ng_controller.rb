class NgController < ApplicationController
  def template
    render template: File.join("ng", "templates", params[:path]), layout: false
  end
end
