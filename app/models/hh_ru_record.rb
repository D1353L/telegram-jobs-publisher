# frozen_string_literal: true

class HhRuRecord < ActiveRecord::Base
  before_create :only_one_row

  validates_presence_of :title, :company_name

  def update_last_or_create!
    last_record = HhRuRecord.last

    if last_record
      last_record.update(attributes)
    else
      HhRuRecord.create!(attributes)
    end
  end

  private

  def only_one_row
    raise 'You can create only one row of this table' if HhRuRecord.count > 0
  end
end
