class DatasetBuilder
  def initialize
    @dataset =  {
        name: 'default-dataset-name',
        title: 'Default dataset title',
        summary: 'Ethnicity data',
        description: 'Ethnicity data',
        licence: 'no-licence',
        licence_other: '',
        location1: 'London',
        location2: 'Southwark',
        location3: '',
        frequency: 'monthly',
        published_date: '2013-08-31T00:56:15.435Z',
        harvested: false,
        created_at: '2013-08-31T00:56:15.435Z',
        last_updated_at: '2017-07-24T14:47:25.975Z',
        uuid: '67436432-07c3-4964-a365-5eb58d68a152',
        organisation: {
            id: 582,
            name: 'ministry-of-defence',
            title: 'Ministry of Defence',
            description: 'We protect the security, independence and interests of our country at home and abroad. We work with our allies and partners whenever possible. Our aim is to ensure that the armed forces have the training, equipment and support necessary for their work, and that we keep within budget.\r\n\r\nMOD is a ministerial department, supported by 28 agencies and public bodies.\r\n\r\nhttps://www.gov.uk/government/organisations/ministry-of-defence\r\n\r\n',
            abbreviation: 'MOD',
            replace_by: '[]',
            contact_email: '',
            contact_phone: '',
            contact_name: '',
            foi_email: '',
            foi_phone: '',
            foi_name: '',
            foi_web: '',
            category: 'ministerial-department',
            organisation_user_id: '',
            created_at: '2017-07-24T12:54:26.087Z',
            updated_at: '2017-07-24T12:54:26.087Z',
            uuid: '5db6e904-ea2f-42a7-93bd-a61da059246f',
            active: true,
            org_type: 'central-government',
            ancestry: ''
        },
        datafiles: [],
        notes: ''
    }
  end

  def with_title(title)
    @dataset[:title] = title
    self
  end

  def with_name(slug)
    @dataset[:name] = slug
    self
  end

  def with_contact_email(contact_email)
    @dataset[:organisation][:contact_email] = contact_email
    self
  end

  def with_datafiles(datafiles)
    @dataset[:datafiles] = datafiles
    self
  end

  def with_location(location)
    @dataset[:location1] = location
    self
  end

  def with_summary(summary)
    @dataset[:summary] = summary
    self
  end

  def with_description(description)
    @dataset[:description] = description
    self
  end

  def with_notes(notes)
    @dataset[:notes] = notes
    self
  end

  def last_updated_at(date_string)
    @dataset[:last_updated_at] = date_string
    self
  end

  def with_publisher(publisher)
    @dataset[:organisation][:name] = publisher
    @dataset[:organisation][:title] = publisher
    self
  end

  def build
    @dataset
  end
end

DATA_TITLE = 'some-very-interesting-data'

DATA_FILES_WITH_START_AND_ENDDATE = [
    {'id' => 1,
     'name' => 'I have no end date',
     'url' => 'https://good_data.co.uk',
     'format' => 'HTML',
     'start_date' => '1/1/15',
     'end_date' => nil,
     'updated_at' => '2016-08-31T14:40:57.528Z'
    },
    {'id' => 2,
     'name' => 'I have an end date',
     'url' => 'https://good_data.co.uk',
     'format' => 'CSV',
     'start_date' => '1/1/15',
     'end_date' => '24/03/2018',
     'updated_at' => '2016-08-31T14:40:57.528Z'
    },
    {'id' => 3,
     'name' => 'I have an end date',
     'url' => 'https://good_data.co.uk',
     'format' => 'HTML',
     'start_date' => '1/1/15',
     'end_date' => '01/12/2018',
     'updated_at' => '2016-08-31T14:40:57.528Z'
    }
]

DATAFILES_WITHOUT_START_AND_ENDDATE = [
    {'id' => 1,
     'name' => 'I have no end date',
     'url' => 'https://good_data.co.uk',
     'start_date' => nil,
     'end_date' => nil,
     'updated_at' => '2016-08-31T14:40:57.528Z'
    },
    {'id' => 2,
     'name' => 'I have an end date',
     'url' => 'https://good_data.co.uk',
     'start_date' => nil,
     'end_date' => nil,
     'updated_at' => '2016-08-31T14:40:57.528Z'
    }]

UNFORMATTED_DATASETS_MULTIYEAR = [
    {'id' => 1,
     'name' => 'Dataset 1',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2017-09-24',
     'end_date' => nil,
     'updated_at' => '2017-08-31T14:40:57.528Z'
    },
    {'id' => 2,
     'name' => 'Dataset 2',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2015-09-25',
     'end_date' => nil,
     'updated_at' => '2015-10-31T14:40:57.528Z'
    },
    {'id' => 3,
     'name' => 'Dataset 3',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2015-09-24',
     'end_date' => nil,
     'updated_at' => '2015-08-31T14:40:57.528Z'
    },
    {'id' => 4,
     'name' => 'Dataset 4',
     'url' => 'https://good_data.co.uk',
     'start_date' => nil,
     'end_date' => nil,
     'updated_at' => '2015-10-31T14:40:57.528Z'
    }]

UNFORMATTED_DATASETS_SINGLEYEAR = [
    {'id' => 1,
     'name' => 'Dataset 1',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2017-09-24',
     'end_date' => nil,
     'updated_at' => '2017-08-31T14:40:57.528Z'
    },
    {'id' => 2,
     'name' => 'Dataset 2',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2017-09-25',
     'end_date' => nil,
     'updated_at' => '2015-10-31T14:40:57.528Z'
    },
    {'id' => 3,
     'name' => 'Dataset 3',
     'url' => 'https://good_data.co.uk',
     'start_date' => '2017-09-24',
     'end_date' => nil,
     'updated_at' => '2015-08-31T14:40:57.528Z'
    }]


FORMATTED_DATASETS = {
    '2017' => [{'id' => 1,
                'name' => 'Dataset 1',
                'url' => 'https://good_data.co.uk',
                'start_date' => '2017-09-24',
                'end_date' => nil,
                'updated_at' => '2017-08-31T14:40:57.528Z',
                'start_year' => '2017'
               }],
    '2015' => [{'id' => 2,
                'name' => 'Dataset 2',
                'url' => 'https://good_data.co.uk',
                'start_date' => '2015-09-25',
                'end_date' => nil,
                'updated_at' => '2015-10-31T14:40:57.528Z',
                'start_year' => '2015'},
               {'id' => 3,
                'name' => 'Dataset 3',
                'url' => 'https://good_data.co.uk',
                'start_date' => '2015-09-24',
                'end_date' => nil,
                'updated_at' => '2015-08-31T14:40:57.528Z',
                'start_year' => '2015'
               }],
        "" => [{'id' => 4,
         'name' => 'Dataset 4',
         'url' => 'https://good_data.co.uk',
         'start_date' => nil,
         'end_date' => nil,
         'updated_at' => '2015-10-31T14:40:57.528Z',
         'start_year' => ''
        }]
}

CSV_DATAFILE = {
  'id' => 1,
  'name' => 'I have no end date',
  'format' => 'CSV',
  'start_date' => '1/1/15',
  'end_date' => nil,
  'updated_at' => '2016-08-31T14:40:57.528Z',
  'url' => 'https://find-data-beta.herokuapp.com/file/9/preview'
}
