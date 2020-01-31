# frozen_string_literal: true
# name: discourse-jwt
# about: JSON Web Tokens Auth Provider
# version: 0.1
# author: Robin Ward

gem "discourse-omniauth-jwt", "0.0.2", require: false

require 'omniauth/jwt'

class JWTAuthenticator < Auth::ManagedAuthenticator
  def name
    'jwt'
  end

  def register_middleware(omniauth)
    omniauth.provider :jwt,
                      name: 'jwt',
                      uid_claim: 'id',
                      required_claims: ['id', 'email', 'name'],
                      setup: lambda { |env|
                        opts = env['omniauth.strategy'].options
                        opts[:secret] = SiteSetting.jwt_secret
                        opts[:auth_url] = SiteSetting.jwt_auth_url
                      }
  end

  def enabled?
    # Check the global setting for backwards-compatibility.
    # When this plugin used only global settings, there was no separate enable setting
    SiteSetting.jwt_enabled || GlobalSetting.try(:jwt_auth_url)
  end
end

auth_provider authenticator: JWTAuthenticator.new
