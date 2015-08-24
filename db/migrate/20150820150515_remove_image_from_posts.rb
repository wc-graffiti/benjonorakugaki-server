class RemoveImageFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :image, :binary
  end
end
