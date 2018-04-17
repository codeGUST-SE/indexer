require_relative 'document_entity'

# SampleDocumentDatastore is a mock of the DocumentDatastore class, that
# just reads entities from a file. This class is to be used just for
# experimenting more efficiently. 
class SampleDocumentDatastore

  def initialize(filepath)
    @filepath = filepath
  end

  def query(limit)
    return_value = []
    File.readlines(@filepath).each do |line|
      return_value << DocumentEntity.new(*(line.strip().split("\t")))
    end
    return_value
  end
  
end
