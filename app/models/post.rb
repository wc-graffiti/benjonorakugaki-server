class Post < ActiveRecord::Base
  belongs_to :board
  mount_uploader :image, ImageUploader
end
