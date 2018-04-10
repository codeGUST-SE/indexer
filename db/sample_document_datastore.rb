require_relative 'document_entity'

# SampleDocumentDatastore is a mock of the DocumentDatastore class, that
# just reads entities from a file. This class is to be used just for
# experimenting more efficiently. 
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
