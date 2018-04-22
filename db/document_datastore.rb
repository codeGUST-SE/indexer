require 'google/cloud/datastore'
require_relative 'document_entity'
require_relative '../log/log'

# DocumentDatastore connects to the Datastore in Google Cloud Platform.
class DocumentDatastore

  MAX_URL_LIST = 2000

  DOCUMENT_KIND = {'DEV' => 'page_dev', 'PROD' => 'page'}
  INDEX_KIND = {'DEV' => 'index_dev', 'PROD' => 'index'}

  def initialize(env)
    @@datastore ||= Google::Cloud::Datastore.new(project_id: 'codegust')
    @env = env
    @document_kind = DOCUMENT_KIND[@env]
    @index_kind = INDEX_KIND[@env]
    @largest_timestamp = 1524070873
    @offset_cache = {}  # TODO not threadsafe :(
    Log::LOGGER.info('datastore') { "Initialized with largest_timestamp = #{@largest_timestamp}" }
  end

  def query(limit)
    Log::LOGGER.info('datastore') { "Query with largest_timestamp = #{@largest_timestamp}" }
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
      Log::LOGGER.info('datastore') { "Adding index = #{index}" }

      current_hash, offset = get_current_hash(index)
      next if current_hash == nil
      new_index_value, remaining_index_value = compute_index_value(current_hash, index_hash[index])

      save(index + offset.to_s, new_index_value)
      if remaining_index_value != nil
        save(index + (offset + 1).to_s, remaining_index_value)
        @offset_cache[index] = offset + 1
      else
        @offset_cache[index] = offset
      end
    end
  end

  private

  def save(index, value)
    # create new entity or update the existing one
    begin
      new_entity = @@datastore.entity @index_kind, index do |t|
        t['value'] = value
        t.exclude_from_indexes! 'value', true
      end
    rescue   # Key longer than 1500 bytes
      Log::LOGGER.debug('datastore') { "Index = #{index} threw and excetion A" }
      return
    end

    while true
      begin
        @@datastore.save new_entity
        break
      rescue # Deadline exceeded
        Log::LOGGER.debug('datastore') { "Deadline exceeded" }
        sleep(30)
      end
    end
  end

  def get_current_hash(index)
    if @offset_cache.key?(index)
      offset = @offset_cache[index]
    else
      offset = 0
      while true
        begin
          entity_key = @@datastore.key @index_kind, "#{index}#{offset}"
          entity = @@datastore.find(entity_key)
        rescue   # key longer than 1500
          Log::LOGGER.debug('datastore') { "Index = #{index} threw and excetion B" }
          return nil, nil
        end
        break if entity == nil
        offset += 1
      end
      offset -= 1 if offset > 0
    end
    entity_key = @@datastore.key @index_kind, "#{index}#{offset}"
    entity = @@datastore.find(entity_key)

    current_hash = entity == nil ? {} : eval(entity['value'])
    return current_hash, offset
  end

  # Computes the new index value given the current_hash and the new_hash.
  def compute_index_value(current_hash, new_hash)
    curr_size = current_hash.size
    new_size = new_hash.size

    if curr_size + new_size > MAX_URL_LIST
      result_hash = current_hash
      remaining_hash = {}
      i = curr_size
      new_hash.each do |key, value|
        if i < MAX_URL_LIST
          result_hash[key] = value
        else
          remaining_hash[key] = value
        end
        i += 1
      end
      return result_hash.to_s, remaining_hash.to_s
    else
      return current_hash.merge(new_hash).to_s, nil
    end
  end

end
