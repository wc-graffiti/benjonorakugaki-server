class AddBgNumToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :bg_num, :integer
  end
end
