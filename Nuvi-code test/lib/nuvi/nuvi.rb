require 'logger'
require 'redis'
require 'unzip'
require 'zip_download'
require 'zip_index'

module Test
  extend self
  def start(base_url)
    index = ZipIndex.new(base_url)
    zip_urls = index.zip_urls
    logger.debug("Found #{zip_urls.count} zip files")

    zip_urls.each { 
      
      |zip| process(zip) 
      
      }
  end

  def process(zip)
    zip_file = downloader.download(zip)
    xml_files_directory = unzipper.unzip(zip_file)

    xmls = Dir[File.join(xml_files_directory, '*.xml')]

    new_items = xmls.map { |xml_file| process_xml(xml_file) }.compact.inject(:+)
    logger.info("Added #{new_items} new items to the NEWS_XML list")

    FileUtils.rm_rf(xml_files_directory)

  end

  def process_xml(xml_file)
    hash = File.basename(xml_file, '.xml')

    if redis.sadd('NEWS_HASHES', hash)
      content = File.read(xml_file)
      redis.rpush('NEWS_XML', content)
      true
    end
  end

  def redis
    @redis ||= Redis.new(host: redis_host, port: redis_port)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def downloader
    @downloader ||= ZipDownloader.new
  end

  def unzipper
    @unzipper ||= Unzipper.new
  end

  attr_writer :redis_host, :redis_port

  def redis_host
    @redis_host ||= 'localhost'
  end

  def redis_port
    @redis_port ||= 6379
  end
end
