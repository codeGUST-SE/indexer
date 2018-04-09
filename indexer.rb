require_relative 'db/document_datastore'

class Indexer

  def initialize(doc_datastore)
    @doc_datastore = doc_datastore
  end

  def start_indexing
    @doc_datastore.each_document do |doc|
      puts doc.url
    end
  end

end
