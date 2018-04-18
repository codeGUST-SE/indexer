require_relative 'db/document_datastore'
require_relative 'log/log'
require_relative 'enumerable'
require 'fast_stemmer'
require 'set'

class Indexer

  # doc_datastore: DocumentDatastore object
  def initialize(doc_datastore, batch_size)
    @doc_datastore = doc_datastore
    @batch_size = batch_size
  end

  def start_indexing
    while true
      request_docs = @doc_datastore.query(@batch_size)
      break if request_docs.empty?
      request_docs.pmap do |doc|
        Log::LOGGER.info('indexing') { "#{doc.url}" }
        index_hash = Hash.new(0)
        stem_list, index_list = get_index_list(doc.html)
        index_list.each do |word|
          index_hash[word] = {} if !index_hash.has_key?(word)
          pos_list = stem_list.each_index.select{|i| stem_list[i] == word}
          in_title = found_in_title(doc.title, word)
          index_hash[word][doc.url] = [in_title, pos_list]
        end
        @doc_datastore.add_indexes(index_hash)
      end
    end
  end

  private

  # Returns 1 if the index is found in the title, 0 otherwise
  def found_in_title(page_title, index)
    title = remove_nonalpha(page_title).split()
    title.each do |word|
      if index == get_stem(word)
        return 1
      end
    end
    return 0
  end

  def get_index_list(page_html)
    word_set = Set.new
    word_list = remove_nonalpha(page_html).split()
    stem_word_list = []
    word_list.each do |word|
      stem = get_stem(word)
      stem_word_list << stem
      word_set.add(stem)
    end
    return stem_word_list, word_set.to_a
  end

  def remove_nonalpha(page_html)
    page_html.gsub(/[^a-z ]/i, ' ')
  end

  def get_stem(word)
    # TODO return nil is the word is not a valid English word?
    Stemmer::stem_word(word.downcase)
  end

end
