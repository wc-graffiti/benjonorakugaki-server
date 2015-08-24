class Board < ActiveRecord::Base
  belongs_to :spot
  mount_uploader :board_image, BoardImageUploader
end
