require 'optparse'
require_relative 'db/document_datastore'
require_relative 'indexer'

options = {:prod => false}
OptionParser.new do |opt|
  opt.on('--prod', 'Production environment, development if not set') { |o| options[:prod] = o }
end.parse!

Indexer.new(DocumentDatastore.new()).start_indexing()
