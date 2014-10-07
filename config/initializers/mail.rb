if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address:        'smtp.mandrillapp.com',
    port:           '465',
    authentication: :plain,
    user_name:      ENV['MANDRILL_USERNAME'],
    password:       ENV['MANDRILL_APIKEY'],
    domain:         'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
end

if Rails.env.development?
  ActionMailer::Base.smtp_settings = {
    address:        'smtp.free.fr',
    port:           '25',
    domain:         'free.fr'
  }
  ActionMailer::Base.delivery_method = :smtp
end