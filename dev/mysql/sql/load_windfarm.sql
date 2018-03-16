/******************************************************************************
 * load_windfarm.sql
 * SQL script for loading unconstrained intermittent generation forecasts (UIGF)
 * into tables in the WINDFRAM database: 
 * uifg_feed.dat
 *****************************************************************************/

\! echo "USE windfarm"
USE windfarm

-- Let @delta be the conversion factor from kW to kWh for 5-minute time intervals
-- SET @delta = 1.0/12.0;

/*****************************************************************************/
\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/ndd_snowtwn1.csv' INTO TABLE ndd_feed"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/ndd_snowtwn1.csv'
INTO TABLE ndd_feed
COLUMNS TERMINATED BY ','
;

\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/meas_snowtwn1.csv' INTO TABLE wind_meas"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/meas_snowtwn1.csv'
INTO TABLE wind_meas
COLUMNS TERMINATED BY '\t'
;

\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/uigf_snowtwn1.csv' INTO TABLE uigf_feed"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/uigf_snowtwn1.csv'
INTO TABLE uigf_feed
COLUMNS TERMINATED BY '\t'
;

/*****************************************************************************/

\! echo "INSERT INTO uigf_5mpd SELECT duid, time_pred_utc, PIVOT(wind_pred_kw FOR time_uigf_utc) FROM uigf_feed GROUP BY duid, time_pred_utc"
INSERT INTO uigf_5mpd
SELECT duid, 
	time_pred_utc,
	MIN(time_scada_utc),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:05:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:10:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:15:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:20:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:25:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:30:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:35:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:40:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:45:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:50:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'00:55:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:00:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:05:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:10:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:15:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:20:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:25:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:30:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:35:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:40:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:45:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:50:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'01:55:00') THEN wind_pred_kw END),
	MAX(CASE WHEN time_uigf_utc=ADDTIME(time_pred_utc,'02:00:00') THEN wind_pred_kw END)
FROM uigf_feed
GROUP BY duid, time_pred_utc
;

/*****************************************************************************/
\! echo "INSERT INTO dispatch SELECT * FROM ndd_feed, date_time"
INSERT INTO dispatch
SELECT duid, date_time_utc, dispatch_int, wind_init_mw*1000, wind_clear_mw*1000, wind_avail_mw*1000, dispatch_cap
FROM ndd_feed, date_time
WHERE time_settle_aest = date_time_aest
AND interven = 0
;



