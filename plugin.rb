# name: discourse-jwt
# about: JSON Web Tokens Auth Provider
# version: 0.1
# author: Robin Ward

require_dependency 'auth/oauth2_authenticator'

gem "omniauth-jwt", "0.0.2", require: false

require 'omniauth/jwt'

class JWTAuthenticator < ::Auth::OAuth2Authenticator
  def register_middleware(omniauth)
    omniauth.provider :jwt,
                      :name => 'jwt',
                      :secret => GlobalSetting.jwt_secret,
                      :auth_url => GlobalSetting.jwt_auth_url
  end

  def after_authenticate(auth)
    raise auth.inspect
    result = Auth::Result.new

    uid = auth[:uid]
    result.name = auth[:info].name
    result.username = uid
    result.email = auth[:info].email
    result.email_valid = true

    raise result.inspect

    current_info = ::PluginStore.get("jwt", "jwt_user_#{uid}")
    if current_info
      result.user = User.where(id: current_info[:user_id]).first
    end
    result.extra_data = { jwt_user_id: uid }
    result
  end

  def after_create_account(user, auth)
    ::PluginStore.set("jwt", "jwt_user_#{auth[:extra_data][:jwt_user_id]}", {user_id: user.id })
  end

end

title = GlobalSetting.try(:jwt_title) || "JWT"
button_title = GlobalSetting.try(:jwt_title) || "with JWT"

auth_provider :title => button_title,
              :authenticator => JWTAuthenticator.new('jwt'),
              :message => "Authorizing with #{title} (make sure pop up blockers are not enabled)",
              :frame_width => 600,
              :frame_height => 380,
              :background_color => '#003366'
