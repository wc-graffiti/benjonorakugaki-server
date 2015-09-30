class Post < ActiveRecord::Base
  belongs_to :board
  belongs_to :post
  mount_uploader :image, ImageUploader
end
