require 'google/cloud/datastore'
require_relative 'document_entity'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  DOCUMENT_KIND = {'DEV' => 'page_dev', 'PROD' => 'page'}
  INDEX_KIND = {'DEV' => 'index_dev', 'PROD' => 'index'}

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
      entity = @@datastore.find(entity_key)
      current_hash = entity == nil ? {} : eval(entity['value'])

      # create new entity or update the existing one
      new_entity = @@datastore.entity @index_kind, index do |t|
        t['value'] = compute_index_value(current_hash, index_hash[index])
        t.exclude_from_indexes! 'value', true
      end
      @@datastore.save new_entity
    end
  end

  private

  # Computes the new index value given the current_hash and the new_hash.
  # TODO: Implement top k pruning
  def compute_index_value(current_hash, new_hash)
    current_hash.merge(new_hash).to_s
  end

end
