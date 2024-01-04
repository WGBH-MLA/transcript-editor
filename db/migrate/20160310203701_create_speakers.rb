class CreateSpeakers < ActiveRecord::Migration[4.2]
  def change
    create_table :speakers do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
