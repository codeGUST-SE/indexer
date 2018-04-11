require_relative 'db/document_datastore'

class Indexer

  # doc_datastore: DocumentDatastore object
  def initialize(doc_datastore)
    @doc_datastore = doc_datastore
  end

  def start_indexing
    # count = 0 DEBUG
    @doc_datastore.each_document do |doc|
      # count += 1 DEBUG
      # puts count DEBUG
      puts doc.url
    end
  end

  private
  
  def remove_nonalpha(page_html)
    page_html.gsub(/[^a-z ]/i, '')
  end

end
