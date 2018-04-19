/******************************************************************************
 * export_windfarm.sql
 * SQL script for exporting data files from WINDFARM database
 *****************************************************************************/

\! echo "USE windfarm"
USE windfarm

#SET @start_time = '2017-04-01 00:00:00', @end_time = '2018-03-31 23:55:00';	# UTC
#SET @start_time = '2017-03-31 14:00:00', @end_time = '2018-03-31 13:55:00';	# AEST
SET @start_time = '2017-03-31 13:00:00', @end_time = '2018-03-31 12:55:00';		# AET
SELECT @start_time, @end_time;

/*****************************************************************************
 * Export data that is input to simulations of wind power dispatch using
 * battery energy storage to a tab delimited file.  And insert simulation  
 * input data into table wind_sim for analysis
 */
\! echo "SELECT * FROM uigf_5mpd, wind_meas, date_time INTO OUTFILE /data/uigf_meas.dat"
SELECT f5.*, wm.time_meas_utc, dt.date_time_aet, wm.wind_act_kw, wm.wind_theo_kw, wm.wind_sdc
FROM uigf_5mpd f5, wind_meas wm, date_time dt
WHERE f5.duid = wm.duid 
AND ADDTIME(f5.time_pred_utc, '00:05:00') = wm.time_meas_utc
AND wm.time_meas_utc = dt.date_time_utc
AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time
ORDER BY f5.duid, f5.time_pred_utc
INTO OUTFILE '/data/uigf_meas.dat'
COLUMNS TERMINATED BY '\t'
;

\! echo "INSERT INTO wind_sim SELECT * FROM uigf_5mpd, wind_meas, date_time"
INSERT INTO wind_sim
SELECT f5.*, wm.time_meas_utc, dt.date_time_aet, wm.wind_act_kw, wm.wind_theo_kw, wm.wind_sdc
FROM uigf_5mpd f5, wind_meas wm, date_time dt
WHERE f5.duid = wm.duid 
AND ADDTIME(f5.time_pred_utc, '00:05:00') = wm.time_meas_utc
AND wm.time_meas_utc = dt.date_time_utc
AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time
;

\! echo "SELECT * FROM wind_sim INTO OUTFILE /data/uigf_meas.dat"
SELECT *
FROM wind_sim
ORDER BY duid, time_pred_utc
INTO OUTFILE '/data/uigf_meas.dat'
COLUMNS TERMINATED BY '\t'
;

/*****************************************************************************
\! echo "SELECT * FROM uigf_5mpd, wind_meas INTO OUTFILE /data/nmae_5min.dat"
SELECT f5.duid, f5.time_pred_utc, f5.wind_pred_5m_kw, wm.time_meas_utc, wm.wind_act_kw, wm.wind_sdc
FROM uigf_5mpd f5, wind_meas wm
WHERE f5.duid = wm.duid AND wm.time_meas_utc = ADDTIME(f5.time_pred_utc, '00:05:00')
AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time 
AND f5.wind_pred_5m_kw > 0.0 AND wm.wind_act_kw > 0.0
AND wm.wind_sdc = 0
ORDER BY f5.duid, f5.time_pred_utc
INTO OUTFILE '/data/nmae_5min.csv'
COLUMNS TERMINATED BY ','
;
 */

/*****************************************************************************
\! echo "SELECT * FROM uigf_5mpd, dispatch INTO OUTFILE /data/uigf_dispatch.dat"
SELECT f5.*, dp.wind_avail_kw, dp.wind_clear_kw, dp.dispatch_cap
FROM uigf_5mpd f5, dispatch dp
WHERE f5.duid = dp.duid AND ADDTIME(f5.time_pred_utc, '00:05:00') = dp.time_settle_utc
AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time
ORDER BY f5.duid, f5.time_pred_utc
INTO OUTFILE '/data/uigf_dispatch.dat'
COLUMNS TERMINATED BY '\t'
;
-- SETTLEMENTDATE (converted to UTC) in the Next Day Dispatch file corresponds
-- to the UIGF forecast for the dispatch interval TimePred_UTC (5-min horizon, 
-- 5-min frequency, 5-min resolution)
 */

/*****************************************************************************
\! echo "SELECT * FROM uigf_5mpd INTO OUTFILE /data/uigf_5mpd.csv"
SELECT duid, time_pred_utc, time_scada_utc,
	CAST(wind_pred_5m_kw AS DECIMAL(12,3)) wind_pred_5m_kw,
	CAST(wind_pred_10m_kw AS DECIMAL(12,3)) wind_pred_10m_kw,
	CAST(wind_pred_15m_kw AS DECIMAL(12,3)) wind_pred_15m_kw,
	CAST(wind_pred_20m_kw AS DECIMAL(12,3)) wind_pred_20m_kw,
	CAST(wind_pred_25m_kw AS DECIMAL(12,3)) wind_pred_25m_kw,
	CAST(wind_pred_30m_kw AS DECIMAL(12,3)) wind_pred_30m_kw,
	CAST(wind_pred_35m_kw AS DECIMAL(12,3)) wind_pred_35m_kw,
	CAST(wind_pred_40m_kw AS DECIMAL(12,3)) wind_pred_40m_kw,
	CAST(wind_pred_45m_kw AS DECIMAL(12,3)) wind_pred_45m_kw,
	CAST(wind_pred_50m_kw AS DECIMAL(12,3)) wind_pred_50m_kw,
	CAST(wind_pred_55m_kw AS DECIMAL(12,3)) wind_pred_55m_kw,
	CAST(wind_pred_60m_kw AS DECIMAL(12,3)) wind_pred_60m_kw,
	CAST(wind_pred_65m_kw AS DECIMAL(12,3)) wind_pred_65m_kw,
	CAST(wind_pred_70m_kw AS DECIMAL(12,3)) wind_pred_70m_kw,
	CAST(wind_pred_75m_kw AS DECIMAL(12,3)) wind_pred_75m_kw,
	CAST(wind_pred_80m_kw AS DECIMAL(12,3)) wind_pred_80m_kw,
	CAST(wind_pred_85m_kw AS DECIMAL(12,3)) wind_pred_85m_kw,
	CAST(wind_pred_90m_kw AS DECIMAL(12,3)) wind_pred_90m_kw,
	CAST(wind_pred_95m_kw AS DECIMAL(12,3)) wind_pred_95m_kw,
	CAST(wind_pred_100m_kw AS DECIMAL(12,3)) wind_pred_100m_kw,
	CAST(wind_pred_105m_kw AS DECIMAL(12,3)) wind_pred_105m_kw,
	CAST(wind_pred_110m_kw AS DECIMAL(12,3)) wind_pred_110m_kw,
	CAST(wind_pred_115m_kw AS DECIMAL(12,3)) wind_pred_115m_kw,
	CAST(wind_pred_120m_kw AS DECIMAL(12,3)) wind_pred_120m_kw
FROM uigf_5mpd
ORDER BY duid, time_pred_utc
INTO OUTFILE '/data/uigf_5mpd.csv'
COLUMNS TERMINATED BY ','
;
 */