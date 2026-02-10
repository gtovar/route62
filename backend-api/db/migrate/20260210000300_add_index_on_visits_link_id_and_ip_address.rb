class AddIndexOnVisitsLinkIdAndIpAddress < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :visits, [:link_id, :ip_address], algorithm: :concurrently
  end
end
