# frozen_string_literal: true

class MoveJwtToManagedAuthenticator < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
    INSERT INTO user_associated_accounts (
      provider_name,
      provider_uid,
      user_id,
      created_at,
      updated_at
    ) SELECT
      'jwt',
      replace(key, 'jwt_user_', ''),
      (value::json->>'user_id')::integer,
      CURRENT_TIMESTAMP,
      CURRENT_TIMESTAMP
    FROM plugin_store_rows
    WHERE plugin_name = 'jwt'
    AND value::json->>'user_id' ~ '^[0-9]+$'
    ON CONFLICT (provider_name, user_id)
    DO NOTHING
    SQL
  end
end
