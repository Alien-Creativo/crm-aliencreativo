# frozen_string_literal: true

class Custom::Health
  def self.status
    { extension: 'custom', status: 'ok' }
  end
end
