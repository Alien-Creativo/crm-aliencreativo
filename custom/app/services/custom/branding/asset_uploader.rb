# frozen_string_literal: true

# Stores an uploaded branding image with ActiveStorage and returns a permanent URL for it.
# The URL uses the signed blob id (no expiry) through the proxy route, so it keeps working
# in emails and the widget and does not redirect to a short-lived storage URL.
class Custom::Branding::AssetUploader
  FILE_KEYS = %w[LOGO LOGO_DARK LOGO_THUMBNAIL ALIEN_FAVICON_URL].freeze
  MAX_SIZE = 1.megabyte
  # SVG is rejected on purpose: ActiveStorage serves it as a download, so <img> cannot render it.
  EXTENSIONS = {
    'image/png' => 'png',
    'image/x-icon' => 'ico',
    'image/vnd.microsoft.icon' => 'ico'
  }.freeze

  class InvalidFile < StandardError; end

  def initialize(key, file)
    raise ArgumentError, "#{key} does not accept uploads" unless FILE_KEYS.include?(key)

    @key = key
    @file = file
  end

  def perform
    content_type = validated_content_type
    config = InstallationConfig.find_or_initialize_by(name: @key)
    config.locked = false if config.new_record?
    config.value = config.value.to_s
    config.save!
    attach(config, content_type)
    config.update!(value: permanent_url(config.branding_file.blob))
    config.value
  end

  private

  def validated_content_type
    raise InvalidFile, "#{@key}: no file received" unless @file.respond_to?(:tempfile)
    raise InvalidFile, "#{@key}: the file is larger than 1 MB" if @file.size > MAX_SIZE

    detected = Marcel::MimeType.for(@file.tempfile)
    raise InvalidFile, "#{@key}: only PNG or ICO files are accepted" unless EXTENSIONS.key?(detected)

    detected
  end

  def attach(config, content_type)
    config.branding_file.attach(io: @file.tempfile, filename: "#{@key.downcase}.#{EXTENSIONS.fetch(content_type)}",
                                content_type: content_type)
  end

  def permanent_url(blob)
    frontend = URI.parse(ENV.fetch('FRONTEND_URL', 'http://localhost:3000'))
    Rails.application.routes.url_helpers.rails_storage_proxy_url(blob, host: frontend.host, port: frontend.port, protocol: frontend.scheme)
  end
end
