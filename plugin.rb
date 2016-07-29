# name: discourse-jwt
# about: JSON Web Tokens Auth Provider
# version: 0.2
# author: Robin Ward, Zach Schneider

require_dependency 'auth/oauth2_authenticator'

enabled_site_setting :jwt_enabled

gem 'discourse-omniauth-jwt', '0.0.2', require: false

require 'omniauth/jwt'

class JWTAuthenticator < ::Auth::OAuth2Authenticator
  def register_middleware(omniauth)
    omniauth.provider :jwt,
                      name: 'jwt',
                      uid_claim: 'id',
                      required_claims: ['id', 'email', 'name'],
                      secret: SiteSetting.jwt_secret,
                      auth_url: SiteSetting.jwt_auth_url
  end

  def after_authenticate(auth)
    result = Auth::Result.new

    uid = auth[:uid]
    result.name = auth[:info].name
    result.username = auth[:info].name.tr(' ', '_')
    result.email = auth[:info].email
    result.email_valid = true

    current_info = ::PluginStore.get('jwt', "jwt_user_#{uid}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    elsif SiteSetting.jwt_email_verified?
      result.user = User.where(email: Email.downcase(result.email)).first
    end
    result.extra_data = { jwt_user_id: uid }
    result
  end

  def after_create_account(user, auth)
    ::PluginStore.set('jwt', "jwt_user_#{auth[:extra_data][:jwt_user_id]}", {user_id: user.id })
  end
end

auth_provider title_setting: 'jwt_button_title',
              enabled_setting: 'jwt_enabled',
              authenticator: JWTAuthenticator.new('jwt'),
              message: 'Authorizing (make sure pop up blockers are not enabled)',
              frame_width: 600,
              frame_height: 380,
              background_color: '#003366'
