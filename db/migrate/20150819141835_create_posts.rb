class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :xcoord
      t.integer :ycoord
      t.binary :image
      t.belongs_to :board, index: true

      t.timestamps
    end
  end
end
