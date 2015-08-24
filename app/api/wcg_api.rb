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
        degree = acc / (60 * 60 * 31)
        spots = Spot.where(lat: (lat-degree)..(lat+degree), lon:(lon-degree)..(lon+degree))
        if spots.empty?
          param = Spot.select("id, ((lat-#{lat})*(lat-#{lat}) + (lon-#{lon})*(lon-#{lon})) AS dis").order("dis").first
          Spot.where(id: param.id)
        else
          spots
        end
      end

      def create_board(id)
        board = Board.create({
          width: 480,
          height: 640,
          spot_id: id,
        })
        if board
          width = board.width
          height = board.height
          image = Magick::Image.new(width, height){
            self.background_color = "#ffffff"
          }
          savepath = File.join(Rails.root, "public", "uploads", "board", "board_image", board.id.to_s)
          imgpath  = File.join(savepath, "board_img.png")
          FileUtils.mkdir_p(savepath) unless FileTest.exist?(savepath)
          image.write(imgpath)
          board.board_image.store! File.open(imgpath)
          board.save
        end
        board
      end

      def not_found_error
        error!("404 Not Found", 404)
      end

      params :coord do
        requires :lon, type: String
        requires :lat, type: String
        optional :acc, type: String, default: 50.0
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

    desc 'GET /api/v1/spot/:lat/:lon'
    params do
      use :coord
    end
    get ":lat/:lon" do
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
    get ":lat/:lon/:acc" do
      if list = search_coord
        list
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/spot/'
    params do
      requires :lon, type: String
      requires :lat, type: String
      requires :name, type: String
    end
    post do
      name = params[:name]
      spot = Spot.create({
        lat: params[:lat].to_f,
        lon: params[:lon].to_f,
        name: name.force_encoding("UTF-8"),
      })
      create_board(spot.id)
      spot
    end

  end # :spot

  resource :board do
    helpers do
      def not_found_error
        error!("404 Not Found", 404)
      end

      def composition_image(post_id)
        post = Post.find(post_id)
        if post
          savepath = File.join(Rails.root, "public", "uploads", "board", "board_image", post.board_id.to_s)
          imgpath  = File.join(savepath, "board_img.png")
          ret_image = Magick::Image.from_blob(File.read(imgpath)).first
          # 画像データを読み込む
          filename = File.join(Rails.root, post.image.url)
          blob = File.read(filename)
          tmp_image = Magick::Image.from_blob(blob).first
          # imageがnilの場合はimageに代入
          # imageにすでにobjectが代入されている場合はcompositeを呼び出し画像を重ねる  
          if (ret_image.nil?)  
            ret_image = tmp_image
          else 
            ret_image = ret_image.composite(tmp_image, 0, 0, Magick::OverCompositeOp)
          end
          FileUtils.mkdir_p(savepath) unless FileTest.exist?(savepath)
          ret_image.write(imgpath)
          board = Board.find(post.board_id)
          board.board_image.store! File.open(imgpath)
          board.save
        end
        post
      end

      def create_post
        board = Board.find_by(spot_id: params[:id])
        post = Post.create!({
          board_id:   board.id,
          xcoord:     0,
          ycoord:     0,
          image:  params[:image]
        })
        composition_image(post.id)
        post.save
        post
      end
    end

    desc 'GET /api/v1/board/?id=xx'
    params do
      requires :id, type: Integer
    end
    get do
      if board = Board.find_by(spot_id: params[:id])
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
      if board = Board.find_by(spot_id: params[:id])
        board
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/board/'
    params do
      requires :id, type: Integer
      requires :image, type: Hash
    end
    post do
      board = Board.find_by(spot_id: params[:id])
      if board
        begin
          create_post
          return "succeed"
        rescue => e
          return "failed: " + e.message
        end
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/board/:id'
    params do
      requires :id, type: Integer
      requires :image, type: Hash
    end
    post ':id' do
      board = Board.find_by(spot_id: params[:id])
      if board
        begin
          create_post
          return "suceeed"
        rescue => e
          return "failed: " + e.message
        end
      else
        not_found_error
      end
    end

  end
end
