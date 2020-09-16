### discourse-jwt

A Discourse Plugin to enable authentication via JSON Web Tokens (JWT).

In the first instance, consider using Discourse's [OpenID Connect](https://meta.discourse.org/t/openid-connect-authentication-plugin/103632) or [OAuth2](https://meta.discourse.org/t/oauth2-basic-support/33879) plugins. These authentication standards are more mature, and include more security features.

### Configuration

This plugin provides three site settings for configuration. You must provide all three in your admin panel for the authentication to work correctly:

- `jwt_enabled`
- `jwt_secret`
- `jwt_auth_url`

Alternatively, you can supply values for these settings via environment variables. Add the following settings to your `app.yml` file in the `env` section:

- `DISCOURSE_JWT_SECRET`
- `DISCOURSE_JWT_AUTH_URL`

### License

MIT

