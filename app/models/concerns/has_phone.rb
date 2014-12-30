module HasPhone
  extend ActiveSupport::Concern

  included do
    phony_normalize :phone, default_country_code: 'US'

    # skip use of phony_plausible validator because 1, we are never specifying
    # country code (it's expected to either have been added in the normalization
    # for US number, or present in the case of international numbers) and 2,
    # we want to be able to validate the unformatted number by passing `true`
    # to the attribute reader (see `phone` below)
    validate :validate_phone
  end

  def phone(skip_formatting=false)
    number = read_attribute(:phone)
    return number if number.blank? || skip_formatting || !Phony.plausible?(number)
    Phony.format Phony.normalize(number)
  end

  protected

  def validate_phone
    number = phone(true)
    return if number.blank?
    number = Phony.normalize(number)
    errors.add(:phone, :improbable_phone) unless Phony.plausible?(number)
  end
end
