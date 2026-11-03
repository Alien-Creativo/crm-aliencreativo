# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Custom::Health do
  it 'reports the custom extension as ok' do
    expect(described_class.status).to eq(extension: 'custom', status: 'ok')
  end

  it 'registers custom after enterprise in the extensions list' do
    expect(ChatwootApp.extensions).to eq(%w[enterprise custom])
  end

  it 'is not enterprise on the CE image' do
    skip 'enterprise/ present (dev checkout)' if Rails.root.join('enterprise').exist?

    expect(ChatwootApp).not_to be_enterprise
  end
end
