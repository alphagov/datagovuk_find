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

  end
end
