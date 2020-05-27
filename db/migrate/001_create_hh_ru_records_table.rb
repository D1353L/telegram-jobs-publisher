# frozen_string_literal: true

class CreateHhRuRecordsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :hh_ru_records, force: true do |t|
      t.string :title
      t.string :company_name
      t.timestamps
    end
  end
end
