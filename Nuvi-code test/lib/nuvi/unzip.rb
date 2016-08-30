require 'zip'

module Test
  class Unzipper
    attr_accessor :directory

    def initialize
      self.directory = File.join(Dir.pwd, '.tmp', 'xmls')
    end

    def unzip(file)
      destination = File.join(directory, File.basename(file, '.zip'))
      FileUtils.rm_rf(destination)
      FileUtils.mkdir_p(destination)
      Test.logger.info("Unzipping #{file} to #{destination}")
      begin
        Zip::File.open(file) do |zip_file|
          zip_file.each do |entry|
            entry.extract(File.join(destination, entry.name))
          end
        end
      rescue StandardError, Interrupt
        FileUtils.rm_rf(destination)
        raise
      end

      destination
    end
  end
end
