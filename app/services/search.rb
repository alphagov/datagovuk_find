module Search
  Error = Class.new(StandardError)

  PhraseClause = Struct.new(:phrase)
  TermsClause = Struct.new(:terms)
end
