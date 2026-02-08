class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.string :long_url, null: false
      t.string :slug

      t.timestamps
    end

    add_index :links, :slug, unique: true
  end
end
