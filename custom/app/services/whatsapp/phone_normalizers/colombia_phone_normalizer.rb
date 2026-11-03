# frozen_string_literal: true

# Handles Colombia phone number normalization.
#
# Colombian numbers have no historical length variants (always 57 + 10 digits), so
# there is nothing to add or remove. Like the other normalizers, this returns the
# stored WAID format (digits only, no "+"): Whatsapp::WebhookChannelFinderService
# prepends the "+" itself when looking up the channel.
class Whatsapp::PhoneNormalizers::ColombiaPhoneNormalizer < Whatsapp::PhoneNormalizers::BasePhoneNormalizer
  def normalize(waid)
    return waid unless handles_country?(waid)

    waid.delete('+')
  end

  private

  def country_code_pattern
    /^57/
  end
end
