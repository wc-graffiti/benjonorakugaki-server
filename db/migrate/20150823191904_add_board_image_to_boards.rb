class AddBoardImageToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :board_image, :string, :after => :height
  end
end
