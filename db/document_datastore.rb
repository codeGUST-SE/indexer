require 'google/cloud/datastore'
require_relative 'document_entity'

class DocumentDatastore

  def each_document
    raise NotImplementedError
  end

end
