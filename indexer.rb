require_relative 'db/document_datastore'
require 'set'
require 'fast_stemmer'

class Indexer

  # doc_datastore: DocumentDatastore object
  def initialize(doc_datastore)
    @doc_datastore = doc_datastore
  end

  def start_indexing
    @doc_datastore.each_document do |doc|
      index_list = get_index_list(doc.html)
      puts doc.url
      puts index_list
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
