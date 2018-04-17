require 'google/cloud/datastore'
require_relative 'document_entity'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  DOCUMENT_KIND = {'DEV' => 'page_dev', 'PROD' => 'page'}
  
  def initialize(env)
    @@datastore ||= Google::Cloud::Datastore.new(project_id: 'codegust')
    @env = env
    @document_kind = DOCUMENT_KIND[@env]

    # TODO remove this check in the future
    raise NotImplementedError if @env == 'PROD'
    @document_kind = DOCUMENT_KIND[@env]
    @largest_timestamp = Time.now.to_i
  end

  def query(limit)
    documents = []
    query = @@datastore.query(@document_kind)
                         .where('timestamp', '<', @largest_timestamp)
                         .order('timestamp', :desc)
                         .limit(limit)

    @@datastore.run(query).each do |doc|
      @largest_timestamp = doc['timestamp']
      documents << DocumentEntity.new(doc['page_url'], doc['page_title'],
                                         doc['page_scores'], doc['page_html'])
    end
    documents
  end

end
