require 'rails_helper'

# CE has no job that resets branding: Internal::ReconcilePlanConfigService lives in enterprise/
# and the boot-time ConfigLoader only fills in missing keys (reconcile_only_new: true).
RSpec.describe InstallationConfig do
  let(:branding) do
    {
      'LOGO' => 'https://crm.example.com/logo.png',
      'LOGO_DARK' => 'https://crm.example.com/logo-dark.png',
      'LOGO_THUMBNAIL' => 'https://crm.example.com/thumb.png',
      'ALIEN_FAVICON_URL' => 'https://crm.example.com/favicon.png',
      'BRAND_NAME' => 'Alien',
      'INSTALLATION_NAME' => 'Alien CRM',
      'BRAND_URL' => 'https://aliencreativo.example',
      'WIDGET_BRAND_URL' => 'https://aliencreativo.example/widget',
      'TERMS_URL' => 'https://aliencreativo.example/terms',
      'PRIVACY_URL' => 'https://aliencreativo.example/privacy'
    }
  end

  before do
    ConfigLoader.new.process
    branding.each do |name, value|
      config = described_class.find_or_initialize_by(name: name)
      config.update!(value: value)
    end
  end

  it 'keeps the branding values across the boot-time ConfigLoader run (restart)' do
    ConfigLoader.new.process

    branding.each { |name, value| expect(described_class.find_by(name: name).value).to eq(value) }
  end

  it 'keeps the branding values after the global config cache is cleared' do
    GlobalConfig.clear_cache

    branding.each { |name, value| expect(GlobalConfig.get_value(name)).to eq(value) }
  end
end
