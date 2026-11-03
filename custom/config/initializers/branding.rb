# frozen_string_literal: true

# - InstallationConfig gets one attachment, used to keep the uploaded branding images.
# - The Custom Branding card is unlocked in Super Admin -> Settings.
# Both are class-level calls, so they are re-applied after every code reload.
Rails.application.config.to_prepare do
  InstallationConfig.has_one_attached :branding_file unless InstallationConfig.reflect_on_attachment(:branding_file)

  features = SuperAdmin::FeaturesHelper.singleton_class
  features.prepend(Custom::SuperAdmin::FeaturesOverride) unless features < Custom::SuperAdmin::FeaturesOverride
end
