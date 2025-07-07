library(tidyverse)

DATADIR = '~/data/midas-wind/' # where CEDA download data is stored
OUTDIR = './data/'             # where the processed csv files are written

# filter all csv files with quality control version 1
csv_files = 
  dir(DATADIR, recursive=TRUE, full.names=TRUE) |>
  grep(pattern='midas-open_uk.*qcv-1.*.csv', value=TRUE)


parse_csv = function(file) {
  lines = readLines(file) 
  # get data
  start = grep("^data$", lines) + 1
  end = grep("^end data$", lines) - 1
  data = read.csv(textConnection(lines[start:end])) |>
    dplyr::select(
      src_id, ob_end_time, 
      mean_wind_dir, mean_wind_speed, max_gust_dir, max_gust_speed,
      mean_wind_dir_q, mean_wind_speed_q, max_gust_dir_q, max_gust_speed_q
    ) |>
    dplyr::rename(
      time = ob_end_time, id = src_id, 
      dir = mean_wind_dir, speed = mean_wind_speed,
      gust_dir = max_gust_dir, gust_speed = max_gust_speed,
      dir_q = mean_wind_dir_q, speed_q = mean_wind_speed_q,
      gust_dir_q = max_gust_dir_q, gust_speed_q = max_gust_speed_q
    ) |>
    mutate(across(where(is.double), as.integer))
  # remove exactly duplicated rows and sort by id and time
  data = distinct(data) |> arrange(id, time)
  # meta data
  i_loc = grep("^observation_station,", lines)[1]
  i_cnty = grep("^historic_county_name,", lines)[1]
  i_coord = grep("^location,", lines)[1]
  i_elev = grep("^height,", lines)[1]
  loc = read.csv(textConnection(lines[i_loc]), header=FALSE)$V3
  cnty = read.csv(textConnection(lines[i_cnty]), header=FALSE)$V3
  elev = read.csv(textConnection(lines[i_elev]), header=FALSE)$V3
  coord = read.csv(textConnection(lines[i_coord]), header=FALSE)
  lat = coord$V3
  lon = coord$V4
  meta = list()
  meta$file = file
  meta$id = data$id[1]
  meta$loc = loc
  meta$cnty = cnty
  meta$lon = lon
  meta$lat = lat
  meta$elev = elev
  meta = as.data.frame(meta)
  return(list(data=data, meta=meta))
}

# save separate csv file by year
nc = nchar(csv_files)
csv_years = substr(csv_files, nc-7, nc-4) |> as.integer() 
years = csv_years |> unique() |> sort()
meta = NULL
for (yr in years) {
  cat('processing year', yr, '...\n')
  csv_files_ = csv_files[ csv_years == yr ]
  res = lapply(csv_files_, parse_csv)
  data = map_df(res, 'data') |> as_tibble()
  meta_ = map_df(res, 'meta') 
  meta = bind_rows(meta, meta_)
  outfile = paste(OUTDIR, '/midas-wind-', yr, '.csv.gz', sep='')
  cat('writing data to', outfile, '...\n')
  write_csv(data, outfile)
  cat('done\n')
}
# store meta data
meta = meta |> select(-file) |> distinct() |> arrange(id)
write_csv(meta, paste(OUTDIR, '/METADATA.csv', sep=''))



