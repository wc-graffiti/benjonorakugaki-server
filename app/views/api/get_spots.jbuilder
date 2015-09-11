Rails.logger.debug @spots.inspect
json.array! @spots do |spot|
  json.(spot, :id, :name, :lat, :lon, :created_at, :updated_at)
end
