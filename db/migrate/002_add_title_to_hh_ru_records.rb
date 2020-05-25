# frozen_string_literal: true

class AddTitleToHhRuRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :hh_ru_records, :title, :string
  end
end
