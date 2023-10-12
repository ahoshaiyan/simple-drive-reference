# frozen_string_literal: true

class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs do |t|
      t.string :provider
      t.string :blob_id, index: true
      t.integer :size
      t.timestamps
    end
  end
end
