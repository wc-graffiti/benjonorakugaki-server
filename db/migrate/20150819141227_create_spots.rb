class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.decimal :lat
      t.decimal :lon
      t.string :name

      t.timestamps
    end
  end
end
