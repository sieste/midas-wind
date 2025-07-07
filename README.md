## Download MIDAS OPEN UK wind data from CEDA

* Data source: https://data.ceda.ac.uk/badc/ukmo-midas-open/data/uk-mean-wind-obs
* Total 8.3GB (41 minutes)
* Download data with `wget` as follows:

```
$> wget -e robots=off --mirror --no-parent -r https://dap.ceda.ac.uk/badc/ukmo-midas-open/data/uk-mean-wind-obs/dataset-version-202407/
```
 
* You might need to obtain an access token as described at https://help.ceda.ac.uk/article/5191-downloading-multiple-files-with-wget
* To download data with an authentication token, copy the token text from website and use `wget` to download data as follows:

```
$> export TOKEN="...TOKEN TEXT..."
$> wget -e robots=off --mirror --no-parent -r https://dap.ceda.ac.uk/badc/ukmo-midas-open/data/uk-mean-wind-obs/dataset-version-202407/ --header "Authorization: Bearer $TOKEN"
```

## Wrangle data

* Assuming the download data directory is `~/data/midas-wind/`

```
$> tree ~/data/midas-wind -d -L 7

~/data/midas-wind
└── dap.ceda.ac.uk
    └── badc
        └── ukmo-midas-open
            └── data
                └── uk-mean-wind-obs
                    └── dataset-version-202407
                        ├── aberdeenshire
                        ├── angus
                        ├── antrim
                        ├── argyll-in-strathclyde-region
                        ├── armagh
                        ├── avon
                        .........

106 directories
```

* data are available in two quality control versions, "qcv0" (raw data) and "qcv1" (improved), and we shall use only "qcv1" data
* station data are stored in csv files per year, for example
```
$> find ~/data/midas-wind -type f -name "*midas-open_uk*qcv-1*csv" | shuf | head

midas-open_uk-mean-wind-obs_dv-202407_west-yorkshire_00523_leeds-weather-centre_qcv-1_1988.csv
midas-open_uk-mean-wind-obs_dv-202407_cumbria_01054_eskmeals_qcv-1_1989.csv
midas-open_uk-mean-wind-obs_dv-202407_dorset_01319_isle-of-portland_qcv-1_2016.csv
midas-open_uk-mean-wind-obs_dv-202407_avon_00674_avonmouth_qcv-1_2013.csv
midas-open_uk-mean-wind-obs_dv-202407_hampshire_00847_middle-wallop_qcv-1_1999.csv
midas-open_uk-mean-wind-obs_dv-202407_hampshire_00869_south-farnborough_qcv-1_2011.csv
```

* the R script `wrangle.R` reads each of the over 11k csv files, combines them and stores them in one compressed csv file per year in the `./data` directory of this repo

## File format

```
$> zcat ./data/midas-wind-2023.csv.gz | head

id,time,dir,speed,gust_dir,gust_speed,dir_q,speed_q,gust_dir_q,gust_speed_q
150,2023-01-01 00:00:00,300,3,310,5,6,6,6,6
150,2023-01-01 01:00:00,290,3,290,5,6,6,6,6
150,2023-01-01 02:00:00,280,3,240,4,6,6,6,6
150,2023-01-01 03:00:00,270,2,260,4,6,6,6,6
150,2023-01-01 04:00:00,270,3,260,4,6,6,6,6
150,2023-01-01 05:00:00,260,3,250,4,6,6,6,6
150,2023-01-01 06:00:00,250,2,250,3,6,6,6,6
150,2023-01-01 07:00:00,260,2,260,2,6,6,6,6
150,2023-01-01 08:00:00,270,2,260,4,6,6,6,6
```

**Description**

* `id`: station ID, see `data/METADATA.csv`
* `time`: Timestamp 
* `dir`, `gust_dir`: Mean/gust wind direction, in degrees
* `speed`, `gust_speed`: Mean/gust speed, in knots
* `*_q`: Quality flags, 0 (poor) - 9 (good); NOTE: not well documented on CEDA


## Citation and license

* CEDA catalogue entry: https://catalogue.ceda.ac.uk/uuid/91cb9985a6c2453d99084bde4ff5f314
* Use of MIDAS OPEN data is covered by the Open Government Licence: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/


