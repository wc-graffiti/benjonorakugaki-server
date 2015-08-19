class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.integer :width
      t.integer :height
      t.belongs_to :spot, index: true

      t.timestamps
    end
  end
end
