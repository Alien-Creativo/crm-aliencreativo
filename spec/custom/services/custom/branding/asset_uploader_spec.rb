require 'rails_helper'

RSpec.describe Custom::Branding::AssetUploader do
  let(:png) { Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==') }
  let(:file) do
    Tempfile.new(['logo', '.png'], binmode: true).tap do |f|
      f.write(png)
      f.rewind
    end
  end
  let(:upload) { Rack::Test::UploadedFile.new(file.path, 'image/png', true, original_filename: 'logo.png') }

  it 'refuses keys that are not file keys' do
    expect { described_class.new('BRAND_NAME', upload) }.to raise_error(ArgumentError)
  end

  it 'returns a URL built from the signed blob id, without an expiry' do
    url = described_class.new('LOGO', upload).perform
    blob = InstallationConfig.find_by(name: 'LOGO').branding_file.blob

    expect(url).to include(blob.signed_id)
    expect(url).not_to match(/expires|X-Amz/)
    expect(ActiveStorage::Blob.find_signed!(blob.signed_id)).to eq(blob)
  end

  it 'builds the URL from FRONTEND_URL' do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('FRONTEND_URL', anything).and_return('https://crm.example.com')

    expect(described_class.new('LOGO', upload).perform).to start_with('https://crm.example.com/rails/active_storage/blobs/proxy/')
  end

  it 'replaces the previous file when uploading again' do
    described_class.new('LOGO', upload).perform
    first_blob = InstallationConfig.find_by(name: 'LOGO').branding_file.blob
    file.rewind
    described_class.new('LOGO', upload).perform

    expect(InstallationConfig.find_by(name: 'LOGO').branding_file.blob).not_to eq(first_blob)
    expect(InstallationConfig.where(name: 'LOGO').count).to eq(1)
  end
end
