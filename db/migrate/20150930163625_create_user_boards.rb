class CreateUserBoards < ActiveRecord::Migration
  def change
    create_table :user_boards do |t|
      t.belongs_to :board, index: true
      t.belongs_to :user, index: true
      t.string     :image
      t.timestamps
    end
  end
end
