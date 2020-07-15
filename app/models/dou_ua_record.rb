# frozen_string_literal: true

class DouUaRecord < ActiveRecord::Base
  validates_presence_of :title, :company_name
end
