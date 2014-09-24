require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  protect_from_dos_attacks true
  secret "b12d74a7fa0951d52ad1b2ba18a149341a965ac832eccd29f08d86f8b6452e4d"

  url_format "/media/:job/:name"

  if Rails.env.production?
    datastore :s3,
      bucket_name: 'fabrium',
      access_key_id: ENV['FABRIUM_ACCESS_KEY_ID'],
      secret_access_key: ENV['FABRIUM_SECRET_ACCESS_KEY']
  else
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  end

  fetch_file_whitelist [
    /app\/assets\/images/
  ]
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
