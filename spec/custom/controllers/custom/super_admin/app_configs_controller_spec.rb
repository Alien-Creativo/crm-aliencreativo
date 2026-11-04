require 'rails_helper'

RSpec.describe Custom::SuperAdmin::AppConfigsController, type: :request do
  let(:super_admin) { create(:super_admin) }
  let(:png_bytes) do
    Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==')
  end

  def upload(bytes, name:, type:)
    file = Tempfile.new([File.basename(name, '.*'), File.extname(name)], binmode: true)
    file.write(bytes)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, type, true, original_filename: name)
  end

  before do
    allow(ChatwootHub).to receive(:pricing_plan).and_return('community')
    sign_in(super_admin, scope: :super_admin)
  end

  describe 'GET custom_branding' do
    it 'renders the branding form with upload inputs and the favicon field' do
      get '/super_admin/app_config?config=custom_branding'

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Favicon URL', 'branding_files[LOGO]', 'branding_files[ALIEN_FAVICON_URL]', 'Brand Name')
    end

    it 'leaves the other config pages on the stock form' do
      get '/super_admin/app_config?config=general'

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('branding_files[LOGO]')
    end
  end

  describe 'POST custom_branding' do
    it 'saves only the branding keys' do
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { BRAND_NAME: 'Alien', INSTALLATION_NAME: 'Alien CRM', WEBHOOK_TIMEOUT: '99' } }

      expect(response).to redirect_to(super_admin_app_config_path(config: 'custom_branding'))
      expect(GlobalConfig.get_value('BRAND_NAME')).to eq('Alien')
      expect(GlobalConfig.get_value('INSTALLATION_NAME')).to eq('Alien CRM')
      expect(GlobalConfig.get_value('WEBHOOK_TIMEOUT')).not_to eq('99')
    end

    it 'stores an uploaded PNG and writes a permanent URL that serves the image' do
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { LOGO: 'https://old.example/logo.png' },
                     branding_files: { LOGO: upload(png_bytes, name: 'mi logo.png', type: 'image/png') } }

      url = GlobalConfig.get_value('LOGO')
      expect(url).to include('/rails/active_storage/blobs/proxy/')
      expect(url).not_to include('old.example')

      get URI.parse(url).request_uri
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('image/png')
    end

    it 'stores an uploaded ICO as the favicon' do
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { ALIEN_FAVICON_URL: '' },
                     branding_files: { ALIEN_FAVICON_URL: upload(png_bytes, name: 'favicon.ico', type: 'image/x-icon') } }

      expect(GlobalConfig.get_value('ALIEN_FAVICON_URL')).to include('/rails/active_storage/blobs/proxy/')
    end

    it 'rejects a file that is not an image and saves nothing' do
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { BRAND_NAME: 'Should not save' },
                     branding_files: { LOGO: upload('hello', name: 'logo.png', type: 'image/png') } }

      expect(response).to redirect_to(super_admin_app_config_path(config: 'custom_branding'))
      expect(flash[:alert]).to include('LOGO: only PNG or ICO')
      expect(GlobalConfig.get_value('BRAND_NAME')).not_to eq('Should not save')
    end

    it 'rejects SVG files' do
      svg = '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>'
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { BRAND_NAME: 'x' }, branding_files: { LOGO_DARK: upload(svg, name: 'logo.svg', type: 'image/svg+xml') } }

      expect(flash[:alert]).to include('LOGO_DARK: only PNG or ICO')
    end

    it 'rejects files larger than 1 MB' do
      big = png_bytes + ('0' * 1.megabyte)
      post '/super_admin/app_config?config=custom_branding',
           params: { app_config: { BRAND_NAME: 'x' }, branding_files: { LOGO_THUMBNAIL: upload(big, name: 'big.png', type: 'image/png') } }

      expect(flash[:alert]).to include('LOGO_THUMBNAIL: the file is larger than 1 MB')
    end

    it 'accepts a post that only carries a file' do
      post '/super_admin/app_config?config=custom_branding',
           params: { branding_files: { LOGO: upload(png_bytes, name: 'logo.png', type: 'image/png') } }

      expect(response).to redirect_to(super_admin_app_config_path(config: 'custom_branding'))
      expect(GlobalConfig.get_value('LOGO')).to include('/rails/active_storage/')
    end
  end
end
