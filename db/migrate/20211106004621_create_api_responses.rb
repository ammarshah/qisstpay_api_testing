class CreateApiResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :api_responses do |t|
      t.string :body
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
