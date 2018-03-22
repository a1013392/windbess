/****************************************************************************** 
 * scratch.sql
 * Script for sundry SQL queries
 *****************************************************************************/

--SET @start_time = '2017-11-01 00:00:00', @end_time = '2017-11-30 23:55:00';
SET @start_time = '2017-11-01 00:00:00', @end_time = '2017-11-01 12:00:00';

SELECT f5.duid, f5.time_pred_utc, f5.wind_pred_60m_kw, wm.time_meas_utc, wm.wind_act_kw, wm.wind_sdc
FROM uigf_5mpd f5, wind_meas wm
WHERE f5.duid = wm.duid AND wm.time_meas_utc = ADDTIME(f5.time_pred_utc, '01:00:00')
AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time 
AND f5.wind_pred_60m_kw > 0.0 AND wm.wind_act_kw > 0.0
AND wm.wind_sdc = 0
ORDER BY f5.duid, f5.time_pred_utc;

--SELECT wm.duid, wm.time_meas_utc, wm.wind_act_kw, wm.wind_sdc, dp.time_settle_utc, dp.wind_avail_kw, dp.wind_clear_kw, dp.dispatch_cap  
--FROM wind_meas wm, dispatch dp
--WHERE wm.duid = dp.duid AND wm.time_meas_utc = dp.time_settle_utc
--AND wm.time_meas_utc >= @start_time AND wm.time_meas_utc <= @end_time 
--AND wm.wind_act_kw > 0.0 AND dp.wind_clear_kw > 0.0
--AND wm.wind_sdc = 0 AND dp.dispatch_cap = 0
--ORDER BY wm.duid, wm.time_meas_utc


--SELECT f5.duid, f5.time_pred_utc, f5.wind_pred_5m_kw, dp.wind_avail_kw, dp.wind_clear_kw, dp.dispatch_cap 
--FROM uigf_5mpd f5, dispatch dp 
--WHERE f5.duid = dp.duid AND f5.time_pred_utc = dp.time_settle_utc 
--AND f5.time_pred_utc >= @start_time AND f5.time_pred_utc <= @end_time 
--AND f5.wind_pred_5m_kw<=0.0 AND dp.wind_clear_kw<=0.0 
--ORDER BY f5.duid, f5.time_pred_utc;
