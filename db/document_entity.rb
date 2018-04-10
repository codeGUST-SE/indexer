# DocumentEntity is a class representing the entities in Datastore.
class DocumentEntity

  attr_accessor :url, :title, :html, :scores

  def initialize(url = '', title = '', scores = '', html = '')
    @url = url
    @title = title
    @scores = scores
    @html = html
  end

end
