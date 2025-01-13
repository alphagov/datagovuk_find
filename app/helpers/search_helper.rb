module SearchHelper
  STOP_WORDS = %w[i
                  me
                  my
                  myself
                  we
                  our
                  ours
                  ourselves
                  you
                  your
                  yours
                  yourself
                  yourselves
                  he
                  him
                  his
                  himself
                  she
                  her
                  hers
                  herself
                  it
                  its
                  itself
                  they
                  them
                  their
                  theirs
                  themselves
                  what
                  which
                  who
                  whom
                  this
                  that
                  these
                  those
                  am
                  is
                  are
                  was
                  were
                  be
                  been
                  being
                  have
                  has
                  had
                  having
                  do
                  does
                  did
                  doing
                  a
                  an
                  the
                  and
                  &
                  but
                  if
                  or
                  because
                  as
                  until
                  while
                  of
                  at
                  by
                  for
                  with
                  about
                  against
                  between
                  into
                  through
                  during
                  before
                  after
                  above
                  below
                  to
                  from
                  up
                  down
                  in
                  out
                  on
                  off
                  over
                  under
                  again
                  further
                  then
                  once
                  here
                  there
                  when
                  where
                  why
                  how
                  all
                  any
                  both
                  each
                  few
                  more
                  most
                  other
                  some
                  such
                  no
                  nor
                  not
                  only
                  own
                  same
                  so
                  than
                  too
                  very
                  s
                  t
                  can
                  will
                  just
                  don
                  should
                  now].freeze

  def self.process_query(query_string)
    phrase_regex = /"(.*?)"|\b(\w+)\b/

    matches = query_string.scan(phrase_regex)

    processed_terms = matches.map do |phrase, term|
      if phrase
        "\"#{phrase}\""
      elsif term
        STOP_WORDS.include?(term.downcase) ? nil : term
      end
    end

    processed_terms.compact.join(" ")
  end

  def display_sort(sort)
    sort == "best" ? "Best Match" : "Most Recent"
  end

  def datafile_formats_for_select
    buckets = search.aggregations["datafiles"]["datafile_formats"]["buckets"]
    map_keys(buckets).map(&:upcase)
  end

  def dataset_topics_for_select
    buckets = search.aggregations["topics"]["topic_titles"]["buckets"]
    map_keys(buckets)
  end

  def dataset_publishers_for_select
    buckets = search.aggregations["organisations"]["org_titles"]["buckets"]
    map_keys(buckets)
  end

  def selected_publisher
    params.dig(:filters, :publisher)
  end

  def selected_topic
    params.dig(:filters, :topic)
  end

  def selected_format
    params.dig(:filters, :format)
  end

  def selected_filters
    return [] if no_filters_selected?

    params[:filters].except(:publisher).values.reject(&:blank?)
  end

private

  def no_filters_selected?
    params[:filters].nil? || params[:filters].values.reject(&:blank?).empty?
  end

  def map_keys(buckets)
    buckets.map { |bucket| bucket["key"] }.sort.uniq.reject(&:empty?)
  end

  def search
    query = Search::Query.search(params)
    Dataset.search(query, track_total_hits: true)
  end
end
