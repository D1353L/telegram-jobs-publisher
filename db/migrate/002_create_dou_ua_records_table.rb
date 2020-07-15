# frozen_string_literal: true

class CreateDouUaRecordsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :dou_ua_records, force: true do |t|
      t.string :title
      t.string :company_name
      t.timestamps
    end
  end
end
