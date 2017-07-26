class DatasetsController < ApplicationController
  def show
    @groups = [
        {
            year: '2016',
            datafiles: [
                {
                    name: 'Datafile A'
                }
            ]
        },
        {
            year: '2018',
            datafiles: [
                {
                    name: 'Datafile B'
                }
            ]
        }
    ]
    @dataset =  [
      { name: 'lovely data',
        url: 'lovely-data.url',
        last_updated: '20-01-17',
        format: 'CSV'},
        { name: 'boring data',
          url: 'boring-data.url',
          last_updated: '25-12-14',
          format: 'CSV'}
    ]
  end
end
