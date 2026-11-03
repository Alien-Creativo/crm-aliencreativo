# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Whatsapp::PhoneNormalizers::ColombiaPhoneNormalizer do
  subject(:normalizer) { described_class.new }

  describe '#handles_country?' do
    it 'matches the 57 country code only' do
      expect(normalizer.handles_country?('573001234567')).to be_present
      expect(normalizer.handles_country?('5511999998888')).to be_blank
    end
  end

  describe '#normalize' do
    it 'keeps the digits-only WAID untouched' do
      expect(normalizer.normalize('573001234567')).to eq('573001234567')
    end

    it 'never adds a "+" (the channel finder prepends it)' do
      expect(normalizer.normalize('573001234567')).not_to start_with('+')
    end

    it 'returns other countries unchanged' do
      expect(normalizer.normalize('5511999998888')).to eq('5511999998888')
    end
  end

  describe '#variants' do
    it 'has a single canonical form' do
      expect(normalizer.variants('573001234567')).to eq(['573001234567'])
    end
  end
end
