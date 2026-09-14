# frozen_string_literal: true

RSpec.describe "JWTAuthenticator" do
  subject(:authenticator) { Discourse.authenticators.find { it.name == "jwt" } }

  before do
    SiteSetting.jwt_secret = "secret"
    SiteSetting.jwt_auth_url = "https://sso.example.com/login"
  end

  it "requires the login toggle or a legacy global URL" do
    expect(authenticator.enabled?).to be_falsey

    SiteSetting.jwt_enabled = true
    expect(authenticator.enabled?).to be_truthy

    SiteSetting.jwt_enabled = false
    GlobalSetting.stubs(:jwt_auth_url).returns("https://sso.example.com/login")
    expect(authenticator.enabled?).to be_truthy
  end

  %i[jwt_secret jwt_auth_url].each do |setting|
    it "disables login when #{setting} is cleared" do
      SiteSetting.jwt_enabled = true
      SiteSetting.public_send("#{setting}=", "")

      expect(authenticator.enabled?).to be_falsey
    end

    it "rejects enabling login without #{setting}" do
      SiteSetting.public_send("#{setting}=", "")

      expect { SiteSetting.jwt_enabled = true }.to raise_error(Discourse::InvalidParameters)
    end

    it "requires #{setting} with legacy global enablement" do
      GlobalSetting.stubs(:jwt_auth_url).returns("https://sso.example.com/login")
      SiteSetting.public_send("#{setting}=", "")

      expect(authenticator.enabled?).to be_falsey
    end
  end
end
