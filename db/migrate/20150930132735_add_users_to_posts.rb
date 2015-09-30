class AddUsersToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :user, index: true, :after => :board_id
  end
end
