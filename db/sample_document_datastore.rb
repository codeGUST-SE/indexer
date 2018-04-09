require_relative 'document_entity'

class SampleDocumentDatastore

  def initialize(filepath)
    @filepath = filepath
  end

  def each_document
    File.readlines(@filepath).each do |line|
      doc = DocumentEntity.new(*(line.strip().split("\t")))
      yield(doc)
    end
  end

end
