# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Whatsapp::WebhookChannelFinderService do
  let!(:channel) do
    create(:channel_whatsapp, provider: 'whatsapp_cloud', phone_number: '+573001234567', sync_templates: false, validate_provider_config: false)
  end
  let(:phone_number_id) { channel.provider_config['phone_number_id'] }

  it 'finds a Colombian channel from the display number without "+"' do
    finder = described_class.new(display_phone_number: '573001234567', phone_number_id: phone_number_id)

    expect(finder.perform).to eq(channel)
  end

  it 'finds it from a formatted display number' do
    finder = described_class.new(display_phone_number: '+57 300 1234567', phone_number_id: phone_number_id)

    expect(finder.perform).to eq(channel)
  end

  it 'rejects a mismatching phone_number_id' do
    expect(described_class.new(display_phone_number: '573001234567', phone_number_id: 'other').perform).to be_nil
  end
end
