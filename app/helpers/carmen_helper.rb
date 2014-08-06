module CarmenHelper
  def subregions_json country_code
    obj = {}

    if country = Carmen::Country.coded(country_code)
      subregions = country.subregions
      obj[country_code] = subregions.map {|subregion| { text: subregion.name, value: subregion.code } }
    end

    obj.to_json
  end
end
