module Search
  class QueryParser < Parslet::Parser
    rule(:whitespace) { match['\s'].repeat(1) }
    rule(:whitespace?) { whitespace.maybe }

    rule(:quote) { str('"') >> whitespace? }
    rule(:quote?) { quote.maybe }

    rule(:term) { match['[^\s"]'].repeat(1).as(:term) >> whitespace? }
    rule(:term?) { term.maybe }
    rule(:terms) { term.repeat(1) }

    rule(:phrase) { quote >> terms.as(:phrase) >> quote }

    rule(:clause) { (phrase | terms.as(:terms) >> whitespace?).as(:clause) >> whitespace? }

    rule(:query) { clause.repeat.as(:query) }

    root :query
  end
end
