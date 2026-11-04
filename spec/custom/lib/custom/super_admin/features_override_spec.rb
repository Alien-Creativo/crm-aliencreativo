require 'rails_helper'

RSpec.describe Custom::SuperAdmin::FeaturesOverride do
  before { allow(ChatwootHub).to receive(:pricing_plan).and_return('community') }

  it 'unlocks the Custom Branding card on the community plan' do
    card = SuperAdmin::FeaturesHelper.available_features[:custom_branding]

    expect(card).to include(enabled: true, enterprise: false, config_key: 'custom_branding')
  end

  it 'keeps the other features as upstream defines them' do
    expect(SuperAdmin::FeaturesHelper.available_features[:agent_capacity][:enabled]).to be(false)
  end
end
