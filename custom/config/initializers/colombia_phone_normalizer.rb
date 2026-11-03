# frozen_string_literal: true

# Registers the Colombia normalizer without editing the upstream service.
# NORMALIZERS is read as a constant by Whatsapp::WebhookChannelFinderService, so a prepended
# module cannot change it; the constant is replaced instead. to_prepare re-runs after every
# code reload, when the upstream class (and its constant) is loaded again.
Rails.application.config.to_prepare do
  service = Whatsapp::PhoneNumberNormalizationService
  normalizer = Whatsapp::PhoneNormalizers::ColombiaPhoneNormalizer

  unless service::NORMALIZERS.include?(normalizer)
    normalizers = [*service::NORMALIZERS, normalizer].freeze
    service.send(:remove_const, :NORMALIZERS)
    service.const_set(:NORMALIZERS, normalizers)
  end
end
