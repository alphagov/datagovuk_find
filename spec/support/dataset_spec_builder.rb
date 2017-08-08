class DatasetBuilder
  def initialize
    @dataset =  {
        name: 'Default dataset name',
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
        updated_at: '2017-07-24T14:47:25.975Z',
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
    @dataset['name'] = title
    @dataset['title'] = title
    self
  end

  def with_datafiles(datafiles)
    @dataset['datafiles'] = datafiles
    self
  end

  def with_notes(notes)
    @dataset['notes'] = notes
    self
  end

  def build
    @dataset
  end
end

DATA_TITLE = 'Some very interesting data'

DATA_FILES_WITH_START_AND_ENDDATE = [
    {'id' => 1,
     'name' => 'I have no end date',
     'url' => 'https://good_data.co.uk',
     'start_date' => '1/1/15',
     'end_date' => nil,
     'updated_at' => '2016-08-31T14:40:57.528Z'
    },
    {'id' => 2,
     'name' => 'I have an end date',
     'url' => 'https://good_data.co.uk',
     'start_date' => '1/1/15',
     'end_date' => '24/03/2018',
     'updated_at' => '2016-08-31T14:40:57.528Z'
    },
    {'id' => 3,
     'name' => 'I have an end date',
     'url' => 'https://good_data.co.uk',
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
