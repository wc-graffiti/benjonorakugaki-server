class UserBoard < ActiveRecord::Base
  belongs_to :board
  belongs_to :user
  mount_uploader :image, UserBoardImageUploader
end
