class CreateCommunities < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.string :name
      t.text :description
      t.boolean :approved
      t.boolean :archived, :default => false
      t.boolean :votable, :default => true

      t.timestamps
    end
  end
end
