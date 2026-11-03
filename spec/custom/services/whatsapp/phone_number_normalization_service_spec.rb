# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Whatsapp::PhoneNumberNormalizationService do
  it 'registers the Colombia normalizer after the upstream ones' do
    expect(described_class::NORMALIZERS).to eq(
      [
        Whatsapp::PhoneNormalizers::BrazilPhoneNormalizer,
        Whatsapp::PhoneNormalizers::ArgentinaPhoneNormalizer,
        Whatsapp::PhoneNormalizers::MexicoPhoneNormalizer,
        Whatsapp::PhoneNormalizers::ColombiaPhoneNormalizer
      ]
    )
  end

  context 'with existing country normalizers' do
    it 'still adds the Brazilian mobile 9' do
      expect(Whatsapp::PhoneNormalizers::BrazilPhoneNormalizer.new.normalize('554188887777')).to eq('5541988887777')
    end

    it 'still drops the Argentine 9 after the country code' do
      expect(Whatsapp::PhoneNormalizers::ArgentinaPhoneNormalizer.new.normalize('5491123456789')).to eq('541123456789')
    end

    it 'still strips the Mexican mobile 1' do
      expect(Whatsapp::PhoneNormalizers::MexicoPhoneNormalizer.new.normalize('5215512345678')).to eq('525512345678')
    end
  end

  describe '#normalize_and_find_contact_by_provider' do
    let(:inbox) { create(:inbox) }

    it 'returns the existing Colombian contact source id' do
      contact_inbox = create(:contact_inbox, inbox: inbox, source_id: '573001234567')

      expect(described_class.new(inbox).normalize_and_find_contact_by_provider('573001234567', :cloud)).to eq(contact_inbox.source_id)
    end

    it 'returns the raw number when no contact exists' do
      expect(described_class.new(inbox).normalize_and_find_contact_by_provider('573001234567', :cloud)).to eq('573001234567')
    end

    it 'still resolves Brazilian contacts stored with the extra 9' do
      contact_inbox = create(:contact_inbox, inbox: inbox, source_id: '5541988887777')

      expect(described_class.new(inbox).normalize_and_find_contact_by_provider('554188887777', :cloud)).to eq(contact_inbox.source_id)
    end
  end
end
