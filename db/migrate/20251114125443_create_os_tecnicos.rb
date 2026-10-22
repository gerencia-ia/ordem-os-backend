# frozen_string_literal: true

class CreateOsTecnicos < ActiveRecord::Migration[6.0]
  def change
    create_table :os_tecnicos do |t|
        t.references :ordem_servico
        t.bigint :user_id
        t.timestamps
    end
  end
end
