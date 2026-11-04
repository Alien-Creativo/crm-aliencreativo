require 'rails_helper'

RSpec.describe 'custom/branding/_favicon', type: :view do
  it 'renders the stock favicons when no custom favicon is set' do
    render partial: 'custom/branding/favicon'

    expect(rendered).to include('/favicon-32x32.png', '/favicon-96x96.png', '/favicon-16x16.png')
  end

  it 'renders a single link to ALIEN_FAVICON_URL, outside the badge switcher, when set' do
    InstallationConfig.create!(name: 'ALIEN_FAVICON_URL', value: 'https://crm.example.com/fav.png')
    GlobalConfig.clear_cache

    render partial: 'custom/branding/favicon'

    expect(rendered).to include('href="https://crm.example.com/fav.png"')
    expect(rendered).not_to include('/favicon-32x32.png', 'class="favicon"')
  end
end
