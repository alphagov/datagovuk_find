module MapPreviewHelper
  def map_preview_url(dataset, wms_resource)
    urls = {
      url: wms_resource.url,
      n: dataset.inspire_dataset['bbox_north_lat'],
      e: dataset.inspire_dataset['bbox_east_long'],
      s: dataset.inspire_dataset['bbox_south_lat'],
      w: dataset.inspire_dataset['bbox_west_long'],
    }

    wfs_resource = dataset.datafiles.select(&:wfs?).first
    if wfs_resource
      urls[:wfsurl] = wfs_resource.url
      urls[:resid] = wfs_resource.uuid
      urls[:resname] = wfs_resource.name
    end

    "/data/map-preview?#{urls.to_query}"
  end
end
