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

  end # :spot

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
        posts = Post.where(board_id: board.id).order(:updated_at)
        ret_image = nil
        posts.each do |post|
          STDOUT.puts "url = #{post.image.url}"
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
        end
        STDOUT.puts savepath = File.join(Rails.root, "public", "uploads", "board", "board_image", board.id.to_s)
        STDOUT.puts imgpath  = File.join(savepath, "board_img.png")
        FileUtils.mkdir_p(savepath) unless FileTest.exist?(savepath)
        ret_image.write(imgpath)
        board.board_image.store! File.open(imgpath) 
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
        posts = Post.where(board_id: board.id).order(:updated_at)
        ret_image = nil
        STDOUT.puts posts
        posts.each do |post|
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
        end
        savepath = File.join(Rails.root, "public", "uploads", "board", "board_image", board.id.to_s)
        imgpath  = File.join(savepath, "board_img.png")
        FileUtils.mkdir_p(savepath) unless FileTest.exist?(savepath)
        ret_image.write(imgpath)
        board.board_image.store! File.open(imgpath) 
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
          Post.create!({
            board_id:   board.id,
            xcoord:     0,
            ycoord:     0,
            image:  params[:image]
          })
          return "suceeed"
        rescue #=> e
          return "failed"
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
          Post.create!({
            board_id:   board.id,
            xcoord:     0,
            ycoord:     0,
            image:  params[:image]
          })
          return "suceeed"
        rescue #=> e
          return "failed"
        end
      else
        not_found_error
      end
    end

  end
end
