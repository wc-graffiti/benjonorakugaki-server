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

      params :coord do
        requires :lon, type: String
        requires :lat, type: String
        optional :acc, type: String, default: "50"
      end

    end

    desc 'GET /api/v1/spot/?lat=xxx&lon=yyy&acc=zzz'
    params do
      use :coord
    end
    get do
      if list = search_coord
        list
      else
        not_found_error
      end
    end

    desc 'GET /api/v1/spot/:lat/:lon/:acc'
    params do
      use :coord
    end
    get ":lon/:lat/:acc" do
      if list = search_coord
        list
      else
        not_found_error
      end
    end

  end

  resource :board do
    helpers do
      def not_found_error
        error!("404 Not Found", 404)
      end

    end

    desc 'GET /api/v1/board/?id=xx'
    params do
      requires :id, type: Integer
    end
    get do
      board = Board.find_by(spot_id: params[:id])
      if board
        board
      else
        not_found_error
      end
    end

    desc 'GET /api/v1/board/:id'
    params do
      requires :id, type: Integer
    end
    get ":id" do
      board = Board.find_by(spot_id: params[:id])
      if board
        posts = Post.find_by(board_id: params[:id])
        posts
      else
        not_found_error
      end
    end



  end
end
