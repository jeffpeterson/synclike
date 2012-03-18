Rails.application.config.middleware.use OmniAuth::Builder do
  provider :rdio, ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']
end