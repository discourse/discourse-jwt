### discourse-jwt

A Discourse Plugin to enable authentication via JSON Web Tokens (JWT)

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

