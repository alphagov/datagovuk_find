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
    @documents = [
      { name: 'lovely doc',
      url: 'lovely-doc.url',
      last_updated: '20-01-17',
      format: 'CSV'},
      { name: 'boring doc',
        url: 'boring-doc.url',
        last_updated: '25-12-14',
        format: 'CSV'}
  ]
  @organisation = {
    contact_name: "contact lady",
    contact_email:"contact_lady@hello.com",
    foi_name: 'foi man', foi_email: 'foi_man@hello.com'}
  end
end
