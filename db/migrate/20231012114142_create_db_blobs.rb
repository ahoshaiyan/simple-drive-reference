# frozen_string_literal: true

class CreateDbBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :db_blobs do |t|
      t.string :identifier, index: true
      t.binary :data
      t.timestamps
    end
  end
end
