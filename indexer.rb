require_relative 'db/document_datastore'

class Indexer

  def initialize(doc_datastore)
    @doc_datastore = doc_datastore
  end

  def start_indexing
    raise NotImplementedError
  end

end
