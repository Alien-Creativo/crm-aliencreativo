# frozen_string_literal: true

# Branding page for CE. Prepended by SuperAdmin::AppConfigsController through prepend_mod_with;
# it takes over the 'custom_branding' config even when Enterprise::SuperAdmin::AppConfigsController is present.
module Custom::SuperAdmin::AppConfigsController
  BRANDING_CONFIG = 'custom_branding'
  BRANDING_CONFIGS = %w[
    LOGO_THUMBNAIL LOGO LOGO_DARK ALIEN_FAVICON_URL
    BRAND_NAME INSTALLATION_NAME BRAND_URL WIDGET_BRAND_URL TERMS_URL PRIVACY_URL DISPLAY_MANIFEST
  ].freeze
  FAVICON_CONFIG = {
    'display_title' => 'Favicon URL',
    'description' => 'The icon shown in the browser tab (PNG, square, at least 96 px)',
    'locked' => false
  }.freeze

  def show
    super
    return unless @config == BRANDING_CONFIG

    @installation_configs['ALIEN_FAVICON_URL'] = FAVICON_CONFIG
    render :custom_branding
  end

  def create
    return super unless @config == BRANDING_CONFIG

    errors = store_uploaded_files
    return redirect_to super_admin_app_config_path(config: @config), flash: { alert: errors.join(', ') } if errors.any?

    super
  end

  private

  def allowed_configs
    return super unless @config == BRANDING_CONFIG

    @allowed_configs = BRANDING_CONFIGS
  end

  # An uploaded file wins over the URL typed in the form, so that URL is dropped from the params.
  def store_uploaded_files
    params[:app_config] ||= {}
    uploads = params.fetch(:branding_files, {})

    Custom::Branding::AssetUploader::FILE_KEYS.each_with_object([]) do |key, errors|
      file = uploads[key]
      next if file.blank?

      Custom::Branding::AssetUploader.new(key, file).perform
      params[:app_config].delete(key)
    rescue Custom::Branding::AssetUploader::InvalidFile => e
      errors << e.message
    end
  end
end
