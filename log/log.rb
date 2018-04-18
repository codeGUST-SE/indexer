require 'logger'

module Log

  PATH = File.dirname(__FILE__)
  LOGGER = Logger.new("#{PATH}/indexer.log")

  def self.benchmark(line)
    File.open("#{PATH}/benchmark.log", 'a') do |file|
      file.write(line)
    end
  end

end
