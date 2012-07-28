class CreateCounters < ActiveRecord::Migration
  def change
    create_table :counters do |t|
      t.string :stream
      t.string :sentiment
      t.string :gender
      t.date :date
      t.integer :hour
      t.integer :minute
      t.integer :count

      t.timestamps
    end
  end
end
