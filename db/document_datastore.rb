require 'google/cloud/datastore'
require_relative 'document_entity'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  DOCUMENT_KIND = {'DEV' => 'page_dev', 'PROD' => 'page'}
  LIMIT = 10
  def initialize(env)
    @@datastore ||= Google::Cloud::Datastore.new(project_id: 'codegust')
    @env = env
    # TODO remove this check in the future
    raise NotImplementedError if @env == 'PROD'
    @document_kind = DOCUMENT_KIND[@env]
  end

  def each_document
    offset = 0
    while true do
      query = @@datastore.query(@document_kind)
                         .offset(offset)
                         .limit(LIMIT)

      offset += LIMIT
      @@datastore.run(query).each do |doc|
        yield DocumentEntity.new(doc['page_url'], doc['page_title'],
                                 doc['page_scores'], doc['page_html'])
      end .empty? and begin
        return
      end
    end
  end

end
