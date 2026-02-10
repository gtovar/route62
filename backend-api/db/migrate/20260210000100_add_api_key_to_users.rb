require "digest"
require "securerandom"

class AddApiKeyToUsers < ActiveRecord::Migration[8.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    add_column :users, :api_key_digest, :string
    add_column :users, :api_key_last4, :string
    add_column :users, :api_key_rotated_at, :datetime

    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      raw_key = generate_unique_api_key
      user.update_columns(
        api_key_digest: Digest::SHA256.hexdigest(raw_key),
        api_key_last4: raw_key.last(4),
        api_key_rotated_at: Time.current
      )
    end

    change_column_null :users, :api_key_digest, false
    change_column_null :users, :api_key_last4, false

    add_index :users, :api_key_digest, unique: true
  end

  def down
    remove_index :users, :api_key_digest
    remove_column :users, :api_key_rotated_at
    remove_column :users, :api_key_last4
    remove_column :users, :api_key_digest
  end

  private

  def generate_unique_api_key
    loop do
      candidate = "rk_#{SecureRandom.hex(20)}"
      digest = Digest::SHA256.hexdigest(candidate)
      return candidate unless MigrationUser.exists?(api_key_digest: digest)
    end
  end
end
