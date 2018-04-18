require 'benchmark'
require 'optparse'
require_relative 'db/document_datastore'
require_relative 'db/sample_document_datastore'
require_relative 'indexer'
require_relative 'log/log'

options = {:batch => 100}
OptionParser.new do |opt|
  opt.on('--env ENV', 'PROD or DEV') { |o| options[:env] = o }
  opt.on('-b', '--batch_size BATCH', 'Datastore retrieval batch size, defaults to 100') { |o| options[:batch] = Integer(o) }
end.parse!

if options[:env] == nil
  db = SampleDocumentDatastore.new('db/sample_document_datastore.txt')
else
  if ['PROD', 'DEV'].include? options[:env]
    db = DocumentDatastore.new(options[:env])
  else
    raise OptionParser::InvalidArgument
  end
end

begin
  benchmark = Benchmark.measure {
    Indexer.new(db, options[:batch]).start_indexing()
  }
  Log.benchmark("#{Time.now.to_i}\t#{options[:batch]}\t#{benchmark}")
  Log::LOGGER.debug('Done!')
rescue Exception => e
  Log::LOGGER.fatal(e.message)
  Log::LOGGER.fatal(e.backtrace.inspect)
  Log::LOGGER.debug('Failed!')
  raise e
end
