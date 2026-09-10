# frozen_string_literal: true

require "jwt"

module OmniAuth
  module Strategies
    class JWT
      class ClaimInvalid < StandardError
      end

      include OmniAuth::Strategy

      option :secret, nil
      option :auth_url, nil
      option :algorithm, "HS256"
      option :uid_claim, "email"
      option :required_claims, %w[name email]
      option :info_map, { name: "name", email: "email" }

      def request_phase
        redirect(options.auth_url)
      end

      def callback_phase
        super
      rescue ::JWT::DecodeError => e
        fail!(:bad_jwt, e)
      rescue ClaimInvalid => e
        fail!(:claim_invalid, e)
      end

      def decoded
        @decoded ||=
          begin
            claims =
              ::JWT.decode(
                request.params["jwt"],
                options.secret,
                true,
                algorithms: [options.algorithm],
              ).first

            Array(options.required_claims).each do |claim|
              raise ClaimInvalid, "Missing required '#{claim}' claim." if !claims.key?(claim.to_s)
            end

            claims
          end
      end

      uid { decoded[options.uid_claim] }

      info { options.info_map.to_h { |key, claim| [key.to_s, decoded[claim.to_s]] } }

      extra { { raw_info: decoded } }
    end
  end
end
