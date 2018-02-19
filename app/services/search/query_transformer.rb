require 'parslet/transform'

class Search::QueryTransformer < Parslet::Transform
  rule(clause: subtree(:clause)) do
    if clause[:terms]
      Search::TermsClause.new(clause[:terms].map { |p| p[:term].to_s }.join(' '))
    elsif clause[:phrase]
      Search::PhraseClause.new(clause[:phrase].map { |p| p[:term].to_s }.join(' '))
    else
      raise Search::Error, "Unexpected clause type: '#{clause}'"
    end
  end

  rule(query: sequence(:clauses)) { Search::Query.new(clauses) }
end
