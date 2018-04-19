/******************************************************************************
 * load_windfarm.sql
 * SQL script for loading unconstrained intermittent generation forecasts (UIGF)
 * into tables in the WINDFRAM database:
 * wind_meas
 * uigf_feed
 * uigf_5mpd
 *****************************************************************************/

\! echo "USE windfarm"
USE windfarm

-- Let @delta be the conversion factor from kW to kWh for 5-minute time intervals
-- SET @delta = 1.0/12.0;

SET @start_time = '2017-03-31 00:00:00', @end_time = '2018-04-02 00:00:00';
SELECT @start_time, @end_time;

/*****************************************************************************/
\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/meas_snowtwn1.csv' INTO TABLE wind_meas"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/meas_snowtwn1.dat'
INTO TABLE wind_meas
COLUMNS TERMINATED BY '\t'
;

\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/uigf_snowtwn1.csv' INTO TABLE uigf_feed"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/uigf_snowtwn1.dat'
INTO TABLE uigf_feed
COLUMNS TERMINATED BY '\t'
;

--\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/ndd_snowtwn1.csv' INTO TABLE ndd_feed"
--LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/ndd_snowtwn1.csv'
--INTO TABLE ndd_feed
--COLUMNS TERMINATED BY ','
--;

/*****************************************************************************
 * Queries for identifying and inserting missing measured (SCADA) data from  
 * windfarm downloaded from ANEMOS platform maintained by AEMO
 */
SELECT date_time_utc FROM date_time 
WHERE date_time_utc >= @start_time AND date_time_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM wind_meas 
	WHERE date_time_utc = time_meas_utc
	);
	
INSERT INTO wind_meas
SELECT 'SNOWTWN1', date_time_utc, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, -1, 0.0, 0.0
FROM date_time
WHERE date_time_utc >= @start_time AND date_time_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM wind_meas
	WHERE date_time_utc = time_meas_utc
	);
	
SELECT time_meas_utc from wind_meas
WHERE time_meas_utc >= @start_time AND time_meas_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM date_time
	WHERE time_meas_utc = date_time_utc
	);

DELETE FROM wind_meas
WHERE time_meas_utc >= @start_time AND time_meas_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM date_time
	WHERE time_meas_utc = date_time_utc
	);

/*****************************************************************************
 * Queries for identifying and inserting missing 5-minute pre-dispatch UIGF 
 * forecasts (rows) into table uigf_5mpd (UIGF forecasts are downloaded from
 * ANEMOS platform maintained by AEMO
 */
SELECT date_time_utc FROM date_time 
WHERE date_time_utc >= @start_time AND date_time_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM uigf_feed 
	WHERE date_time_utc = time_pred_utc
	);
	
SELECT date_time_utc FROM date_time 
WHERE date_time_utc >= @start_time AND date_time_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM uigf_5mpd 
	WHERE date_time_utc = time_pred_utc
	);
	
INSERT INTO uigf_5mpd
SELECT 'SNOWTWN1', date_time_utc, '1900-01-01 00:00:00', 
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
FROM date_time
WHERE date_time_utc >= @start_time AND date_time_utc <= @end_time 
AND NOT EXISTS (
	SELECT * FROM uigf_5mpd 
	WHERE date_time_utc = time_pred_utc
	);
	
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

/*****************************************************************************
\! echo "INSERT INTO dispatch SELECT * FROM ndd_feed, date_time"
INSERT INTO dispatch
SELECT duid, date_time_utc, dispatch_int, wind_init_mw*1000, wind_clear_mw*1000, wind_avail_mw*1000, dispatch_cap
FROM ndd_feed, date_time
WHERE time_settle_aest = date_time_aest
AND interven = 0
;
 */


