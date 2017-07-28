module DatasetsHelper

  def documents
    docs = []
    @dataset['datafiles'].each do |file|
      if documentation?(file['documentation'])
        docs << file['documentation']
      end
    end
    docs
  end

  def format(timestamp)
    Time.parse(timestamp).strftime("%d %B %Y")
  end

  def no_documents?
    d = documents
    d.count == 0
  end

  def documentation?(key)
    key != nil && key != ""
  end

end
