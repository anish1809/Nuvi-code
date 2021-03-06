require 'net/http'

module Test
  class ZipDownloader
    attr_accessor :directory
    def initialize
      self.directory = File.join(Dir.pwd, '.tmp', 'zips')
      FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
    end

    def download(zip_uri)
      uri = URI(zip_uri)
      destination = File.join(directory, File.basename(uri.path))

      if File.exist?(destination)
        Nuvi.logger.info("Skipping the download of #{zip_uri} as it has already been saved")
      else
        Nuvi.logger.info("Downloading #{zip_uri} to #{destination}")

        tmp_file = "#{destination}.downloading"
        http = Net::HTTP.new(uri.host, uri.port)
        http.request(Net::HTTP::Get.new(uri)) do |response|
          save_response(response, tmp_file)
        end

        FileUtils.mv(tmp_file, destination)
      end

      destination
    end

    private

    def save_response(response, destination)
      open(destination, 'w+') do |file|
        response.read_body do |trash|
          file.write(trash)
        end
      end
    rescue StandardError, Interrupt
      File.delete(destination) 
      if
       File.exist?(destination)
      raise
    end
  end
end
