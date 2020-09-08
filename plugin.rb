# frozen_string_literal: true
# name: discourse-jwt
# about: JSON Web Tokens Auth Provider
# version: 0.1
# author: Robin Ward

gem "discourse-omniauth-jwt", "0.0.2", require: false

require 'omniauth/jwt'
require 'net/http'
require 'json'

class JWTAuthenticator < Auth::ManagedAuthenticator
  def name
    'jwt'
  end

  def register_middleware(omniauth)
    omniauth.provider :jwt,
                      name: 'jwt',
                      uid_claim: 'id',
                      required_claims: ['email', 'first_name', 'last_name'],
                      setup: lambda { |env|
                        opts = env['omniauth.strategy'].options
                        opts[:secret] = SiteSetting.jwt_secret
                        opts[:auth_url] = SiteSetting.jwt_auth_url
                        opts[:jwks_loader] = make_jwks_loader
                      }
  end

  def enabled?
    # Check the global setting for backwards-compatibility.
    # When this plugin used only global settings, there was no separate enable setting
    SiteSetting.jwt_enabled || GlobalSetting.try(:jwt_auth_url)
  end

  private

  def make_jwks_loader
    if SiteSetting.jwt_jwks_url
      jwks_loader = ->(options) do
        @cached_keys = nil if options[:invalidate] # need to reload the keys
        if not @cached_keys
          begin
            jwks = JSON.parse(Net::HTTP.get(URI(SiteSetting.jwt_jwks_url)), symbolize_names: true)
          rescue JSON::ParserError => e
            Rails.logger.error("Cannot parse JWKS.json from #{SiteSetting.jwt_jwks_url}: #{e}")
            jwks = nil
          end
          @cached_keys ||= jwks
        end
        @cached_keys
      end
    else
      jwks_loader = nil
    end

  end
end

auth_provider authenticator: JWTAuthenticator.new
