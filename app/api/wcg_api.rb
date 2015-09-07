class WcgAPI < Grape::API
  # ex)http://localhost:3939/api
  prefix 'api' #ルートのプレフィックスをつける

  # ex)http://localhost:3939/api/v1
  version 'v1', using: :path

  format :json #これでJSONをやり取りできるようにする
  
  BOARD_WIDTH = 480
  BOARD_HEIGHT = 640

  # 例外ハンドル 404
  rescue_from ActiveRecord::RecordNotFound do |e|
    rack_response({ message: e.message, status: 404 }.to_json, 404)
  end

  # 例外ハンドル 400
  rescue_from Grape::Exceptions::ValidationErrors do |e|
    rack_response e.to_json, 400
  end

  # 例外ハンドル 500
  rescue_from :all do |e|
    if Rails.env.development?
      raise e
    else
      error_response(message: "Internal server error", status: 500)
    end
  end

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
          if param.nil?
            nil
          else
            Spot.where(id: param.id)
          end
        else
          spots
        end
      end

      def create_board(id)
        board = Board.create({
          width: BOARD_WIDTH,
          height: BOARD_HEIGHT,
          spot_id: id,
        })
        if board
          num = rand(6) + 1
          path = Rails.root.join("app", "assets", "images", "wall", num.to_s + ".png")
          board.board_image.store! File.open(path)
          board.save
        end
        board
      end

      def not_found_error
        error!("404 Not Found", 404)
      end

      params :coord do
        requires :lon, type: BigDecimal
        requires :lat, type: BigDecimal
      end
    end

    desc 'GET /api/v1/spot/?lat=xxx&lon=yyy&acc=zzz'
    params do
      use :coord
      optional :acc, type: String, default: 50.0
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
    get ":lat/:lon", requirements: { lat: /[^\/]+/, lon: /[^\/]+/,} do
      if list = search_coord
        list
      else
        not_found_error
      end
    end


    desc 'GET /api/v1/spot/:lat/:lon/:acc'
    params do
      use :coord
      optional :acc, type: String, default: 50.0
    end
    get ":lat/:lon/:acc", requirements: { lat: /[^\/]+/, lon: /[^\/]+/, acc: /[^\/]+/ } do
      if list = search_coord
        list
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/spot/'
    params do
      use :coord
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

      def composition_image(board, post)
        if post
          imgpath = File.join(Rails.root, board.board_image.url)
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
          ret_image.write(imgpath)
          board.board_image.store! File.open(imgpath)
          board.save!
        end
        post
      end

      def draw_path
        num = params[:pathnum].to_i if params[:pathnum].present?
        i = 0
        width = params[:width]
        height = params[:height]
        canvas = Magick::Image.new(width, height){self.background_color = 'none'}
        dr = Magick::Draw.new
        dr.stroke_antialias(true)   # アンチエイリアスON
        dr.stroke_width(6)          # ストローク幅6pt
        dr.stroke_linecap('round')  # 線の両端を丸める 
        dr.stroke_linejoin('round') # 角も丸める
        dr.fill_opacity(0)
        loop do
          p = ("path" + i.to_s).to_sym
          break if i == num or params[p].blank?
          array = params[p].gsub(/[\[\]]/,"").split(",")
          color = "#" + (array.shift.to_i&"FFFFFF".hex).to_s(16).rjust(6, '0')
          STDOUT.puts color
          dr.stroke(color)
          a = array.shift.split(" ")
          array.each do |elem|
            b = elem.split(" ")
            dr.line(a[0].to_f, a[1].to_f, b[0].to_f, b[1].to_f)
            a = b
          end
          i += 1
        end
        dr.draw(canvas)
        canvas.resize(BOARD_WIDTH, BOARD_HEIGHT).write('tmp/post.png')
      end

      def create_post
        board = Board.find_by(spot_id: params[:id])
        post = Post.create!({
          board_id:   board.id,
          xcoord:     0,
          ycoord:     0
        })
        post.image.store! File.open('tmp/post.png')
        composition_image(board, post)
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
        filepath = board.board_image.current_path
        content_type "application/octet-stream"
        header['Content-Disposition'] = "attachment; filename=board_img.png"
        env['api.format'] = :binary
        File.open(filepath).read
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
        filepath = board.board_image.current_path
        content_type "application/octet-stream"
        header['Content-Disposition'] = "attachment; filename=board_img.png"
        env['api.format'] = :binary
        File.open(filepath).read
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/board/'
    params do
      requires :id, type: Integer
      requires :width, type: Integer
      requires :height, type: Integer
      optional :pathnum, type: Integer
    end
    post do
      board = Board.find_by(spot_id: params[:id])
      if board
        begin
          draw_path
          create_post
          return "succeed"
        rescue => e
          STDOUT.puts "failed: " + e.message
          return "failed: " + e.message
        end
      else
        not_found_error
      end
    end

    desc 'POST /api/v1/board/:id'
    params do
      requires :id, type: Integer
      requires :width, type: Integer
      requires :height, type: Integer
      optional :pathnum, type: Integer
    end
    post ':id' do
      board = Board.find_by(spot_id: params[:id])
      if board
        begin
          draw_path
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
