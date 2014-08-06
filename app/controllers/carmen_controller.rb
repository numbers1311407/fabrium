class CarmenController < ApplicationController
  respond_to :json

  def subregions
    if params[:country] && country = Carmen::Country.coded(params[:country])
      subregions = country.subregions

      json = subregions.map do |subregion|
        { text: subregion.name, value: subregion.code }
      end

      respond_with(json)
    else
      respond_with({error: "Not Found"}, status: 404)
    end
  end
end
