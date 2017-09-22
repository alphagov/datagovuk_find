module Search
  class Result
    attr_reader :id, :source

    def initialize(id:, source:)
      @id = id
      @source = source
    end
  end
end
