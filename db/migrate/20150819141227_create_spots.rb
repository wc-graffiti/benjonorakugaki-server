class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.decimal :lat, :precision => 9, :scale => 6
      t.decimal :lon, :precision => 9, :scale => 6
      t.string :name

      t.timestamps
    end
  end
end
