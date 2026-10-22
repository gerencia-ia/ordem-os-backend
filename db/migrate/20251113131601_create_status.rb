# frozen_string_literal: true

class CreateStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :status do |t|
        t.string :nome
      
      t.timestamps
    end
  end
end
