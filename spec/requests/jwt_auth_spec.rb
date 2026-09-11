# frozen_string_literal: true

RSpec.describe "JWT authentication" do
  let(:secret) { "a-shared-secret" }
  let(:claims) { { "id" => "user-42", "email" => "jwt@example.com", "name" => "JWT User" } }

  def token_for(payload, key: secret)
    JWT.encode(payload, key, "HS256")
  end

  before do
    enable_current_plugin
    SiteSetting.jwt_secret = secret
    SiteSetting.jwt_auth_url = "https://sso.example.com/login"
    SiteSetting.jwt_enabled = true
  end

  it "sends the user to the configured auth URL" do
    post "/auth/jwt"

    expect(response.status).to eq(302)
    expect(response.location).to eq("https://sso.example.com/login")
  end

  it "accepts a token signed with the site secret" do
    post "/auth/jwt/callback", params: { jwt: token_for(claims) }

    expect(response.status).to eq(302)
    expect(response.location).to eq("http://test.localhost/")

    data = JSON.parse(cookies[:authentication_data])
    expect(data["auth_provider"]).to eq("jwt")
    expect(data["email"]).to eq("jwt@example.com")
    expect(data["name"]).to eq("JWT User")
  end

  it "rejects a token signed with another secret" do
    post "/auth/jwt/callback", params: { jwt: token_for(claims, key: "wrong") }

    expect(response.location).to eq("/auth/failure?message=bad_jwt&strategy=jwt")
  end

  it "rejects an expired token" do
    post "/auth/jwt/callback", params: { jwt: token_for(claims.merge("exp" => 1.hour.ago.to_i)) }

    expect(response.location).to eq("/auth/failure?message=bad_jwt&strategy=jwt")
  end

  it "rejects a token that is missing a required claim" do
    post "/auth/jwt/callback", params: { jwt: token_for(claims.except("email")) }

    expect(response.location).to eq("/auth/failure?message=claim_invalid&strategy=jwt")
  end

  it "rejects an unsigned token" do
    unsigned = JWT.encode(claims, nil, "none")

    post "/auth/jwt/callback", params: { jwt: unsigned }

    expect(response.location).to eq("/auth/failure?message=bad_jwt&strategy=jwt")
  end
end
