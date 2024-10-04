module ApplicationHelper
  def format_timestamp(timestamp)
    Time.zone.parse(timestamp).strftime("%d %B %Y")
  end

  # As there is an issue with how Kaminari processes records -
  #
  # https://github.com/elastic/elasticsearch-rails/issues/966#issuecomment-772994670
  #
  # copy the function block without `collection.respond_to?(:records)` check to get paging working

  def dgu_page_entries_info(collection, entry_name: nil)
    entry_name = if entry_name
                   entry_name.pluralize(collection.size, I18n.locale)
                 else
                   collection.entry_name(count: collection.size).downcase
                 end

    if collection.total_pages < 2
      t("helpers.page_entries_info.one_page.display_entries", entry_name:, count: collection.total_count)
    else
      from = collection.offset_value + 1
      to   = collection.offset_value + collection.to_a.size

      t("helpers.page_entries_info.more_pages.display_entries", entry_name:, first: from, last: to, total: collection.total_count)
    end.html_safe
  end

  def dgu_solr_page_entries_info(collection, entry_name: nil)
    entry_name = if entry_name
                   entry_name.pluralize(collection.size, I18n.locale)
                 else
                   collection.entry_name(count: collection.size).downcase
                 end

    if collection.total_pages < 2
      t("helpers.page_entries_info.one_page.display_entries", entry_name:, count: collection.page_total)
    else
      offset_value = collection.per_page * (collection.current_page - 1)
      from = offset_value + 1
      to   = offset_value + collection.to_a.size
      t("helpers.page_entries_info.more_pages.display_entries", entry_name:, first: from, last: to, total: collection.page_total)
    end.html_safe
  end
end
