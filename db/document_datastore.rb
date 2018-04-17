require 'google/cloud/datastore'
require_relative 'document_entity'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  DOCUMENT_KIND = {'DEV' => 'page_dev', 'PROD' => 'page'}
  INDEX_KIND = {'DEV' => 'in_dev', 'PROD' => 'in'}

  def initialize(env)
    @@datastore ||= Google::Cloud::Datastore.new(project_id: 'codegust')
    @env = env
    # TODO remove this check in the future
    raise NotImplementedError if @env == 'PROD'
    @document_kind = DOCUMENT_KIND[@env]
    @index_kind = INDEX_KIND[@env]
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

  def add_indexes(index_hash)
    index_hash.each_key do |index|
      # get the current entity if it exists
      entity_key = @@datastore.key @index_kind, index
      current_value = @@datastore.find entity_key

      # create new entity or update the existing one
      entity = @@datastore.entity @index_kind, index do |t|
        t['value'] = compute_index_value(current_value, index_hash[index])
        t.exclude_from_indexes! 'value', true
      end
      @@datastore.save entity
    end
  end

  private

  # Computes the index value given the current_value and the new value.
  def compute_index_value(a, b)
    raise NotImplementedError
  end

end
