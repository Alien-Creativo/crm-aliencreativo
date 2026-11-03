# frozen_string_literal: true

# CE ships the Custom Branding card locked behind a paid plan. This unlocks it, because the
# branding form is provided by Custom::SuperAdmin::AppConfigsController.
module Custom::SuperAdmin::FeaturesOverride
  def available_features
    features = super
    features[:custom_branding] = features[:custom_branding].merge(enabled: true, enterprise: false) if features[:custom_branding]
    features
  end
end
