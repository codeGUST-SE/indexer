require_relative 'db/document_datastore'
require_relative 'enumerable'
require 'fast_stemmer'
require 'set'

class Indexer

  # doc_datastore: DocumentDatastore object
  def initialize(doc_datastore)
    @doc_datastore = doc_datastore
    @limit = 1
  end

  def start_indexing
    hashmap = Hash.new(0)
    while true
      request_docs = @doc_datastore.query(@limit)
      break if request_docs.empty?
      request_docs.pmap do |doc|
        index_list = get_index_list(doc.html)
        index_list.each do |word|
          # TODO add to Datastore instead of hashmap
          hashmap[word] = [] if hashmap.has_key?(word) == false
          hashmap[word] << doc.url
        end
      end
    end
  end

  private

  def get_index_list(page_html)
    word_set = Set.new
    word_list = remove_nonalpha(page_html).split()
    word_list.each do |word|
      word_set.add(get_stem(word))
    end
    word_set.to_a
  end

  def remove_nonalpha(page_html)
    page_html.gsub(/[^a-z ]/i, ' ')
  end

  def get_stem(word)
    # TODO return nil is the word is not a valid English word?
    Stemmer::stem_word(word.downcase)
  end

end
