class SetApiKeyRotatedAtNotNull < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE users
      SET api_key_rotated_at = NOW()
      WHERE api_key_rotated_at IS NULL
    SQL

    change_column_null :users, :api_key_rotated_at, false
  end

  def down
    change_column_null :users, :api_key_rotated_at, true
  end
end
