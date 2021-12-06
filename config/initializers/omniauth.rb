Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'],   ENV['GOOGLE_CLIENT_SECRET'], { skip_jwt: true } 
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET']
end
OmniAuth.config.allowed_request_methods = %i[get]
OmniAuth.config.full_host = ENV["TRANSCRIPT_HOST"]