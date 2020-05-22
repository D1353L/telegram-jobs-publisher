# frozen_string_literal: true

class HhRuRecord < ActiveRecord::Base
  before_create :only_one_row

  private

  def only_one_row
    raise 'You can create only one row of this table' if HhRuRecord.count > 0
  end
end
