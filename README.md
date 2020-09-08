### discourse-jwt

A Discourse Plugin to enable authentication via JSON Web Tokens (JWT).

In the first instance, consider using Discourse's [OpenID Connect](https://meta.discourse.org/t/openid-connect-authentication-plugin/103632) or [OAuth2](https://meta.discourse.org/t/oauth2-basic-support/33879) plugins. These authentication standards are more mature, and include more security features.

### Shared secret vs public keys

JWT tokens can be verified using a shared secret or a public key. When in shared secret mode, the token consumer needs to know the secret used to sign the token by token issuer. Set this token using `jwt_secret` option.
In public key mode, verification step will use a public keys in JWKS format, wich are published by the issuer (eg. under https://example.com/.well-known/jwks.json address). Set this url in `jwt_jwks_url** option.

### Configuration

This plugin provides three site settings for configuration. You must provide either three in your admin panel for the authentication to work correctly:

Shared secret mode:

- `jwt_enabled`
- `jwt_secret`
- `jwt_auth_url`

Public key (JWKS) mode:

- `jwt_enabled`
- `jwt_jwks_url`
- `jwt_auth_url`

Alternatively, you can supply values for these settings via environment variables. Add the following settings to your `app.yml` file in the `env` section:

- `DISCOURSE_JWT_SECRET`
- `DISCOURSE_JWKS_URL`
- `DISCOURSE_JWT_AUTH_URL`

### License

MIT

