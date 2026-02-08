class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.references :link, null: false, foreign_key: true
      t.string :ip_address, null: false
      t.string :user_agent, null: false
      t.datetime :visited_at, null: false

      t.timestamps
    end

    add_index :visits, :visited_at
  end
end
