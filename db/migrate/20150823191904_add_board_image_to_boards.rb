class AddBoardImageToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :board_image, :string
  end
end
