class WcgAPI < Grape::API
  # ex)http://localhost:3939/api
  prefix 'api' #ルートのプレフィックスをつける

  # ex)http://localhost:3939/api/v1
  version 'v1', using: :path

  format :json #これでJSONをやり取りできるようにする

  resource :spot do
    helpers do
      def search_coord
        lon = params[:lon].to_f
        lat = params[:lat].to_f
        acc = params[:acc].to_f
        degree = acc / (60 * 31)
        Spot.where(lat: (lat-degree)..(lat+degree), lon:(lon-degree)..(lon+degree))
      end
      def not_found_error
        error!("404 Not Found", 404)
      end
    end

    params do
      requires :lon, type: String
      requires :lat, type: String
      requires :acc, type: String
    end

    get do
      if list = search_coord
        list.to_json
      else
        not_found_error
      end
    end

    get ":lon/:lat/:acc" do
      if list = search_coord
        list.to_json
      else
        not_found_error
      end
    end

  end

  resource :board do

  end
end
