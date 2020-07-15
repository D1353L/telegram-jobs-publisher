# frozen_string_literal: true

module APIClient
  class Helper
    def self.sanitize_html(str)
      str&.gsub(%r{</?[^>]+?>}, '')
    end
  end
end
