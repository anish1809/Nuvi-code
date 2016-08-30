require 'open-uri'
require 'nokogiri'

module Test
  class ZipIndex
    attr_accessor :url

    def initialize(url)
      self.url = url
    end

    def zip_urls
      @urls ||= Nokogiri::HTML(open(url).read).css('td a')[1..-1].map { |a| url + a[:href] }
    end
  end
end
