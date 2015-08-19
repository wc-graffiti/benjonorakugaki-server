class WcgAPI < Grape::API
  # ex)http://localhost:3939/api
  prefix 'api' #ルートのプレフィックスをつける
  
  # ex)http://localhost:3939/api/v1
  version 'v1', using: :path

  format :json #これでJSONをやり取りできるようにする
  
  resource :spot do
  #  params do
  #    requires :lon, type: BigDecimal
  #    requires :lat, type: BigDecimal
  #    requires :acc, type: Float
  #  end
    get ":lon/:lat/:acc" do
      lon = params[:lon].to_f
      lat = params[:lat].to_f
      acc = params[:acc].to_f
      degree = acc / (60 * 31)
      list = Spot.where(lat: (lat-degree)..(lat+degree), lon:(lon-degree)..(lon+degree))
      if list
        list.to_json
      else
        not_found_error
      end
    end
  end

  resource :board do

  end
end
