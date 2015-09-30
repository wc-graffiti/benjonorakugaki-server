Rails.logger.debug @userboard.inspect
json.array! @userboards do |userboard|
  json.(userboard, :id)
end
