require 'optparse'
require_relative 'db/document_datastore'
require_relative 'db/sample_document_datastore'
require_relative 'indexer'

options = {}
OptionParser.new do |opt|
  opt.on('--env ENV', 'PROD or DEV') { |o| options[:env] = o }
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

Indexer.new(db).start_indexing()
