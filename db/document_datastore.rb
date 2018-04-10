require 'google/cloud/datastore'
require_relative 'document_entity'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  def each_document
    raise NotImplementedError
  end

end
