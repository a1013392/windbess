/****************************************************************************** 
 * scratch.sql
 * Script for sundry SQL queries
 *****************************************************************************/

SET @start_time = '2017-11-01 00:00:00', @end_time = '2017-11-30 23:55:00';

SELECT gf.duid, gf.time_pred_utc, gf.wind_pred_5m_kw, dp.wind_avail_kw, dp.wind_clear_kw, dp.dispatch_cap 
FROM uigf_5mpd gf, dispatch dp 
WHERE gf.duid = dp.duid AND gf.time_pred_utc = dp.time_settle_utc 
AND gf.time_pred_utc >= @start_time AND gf.time_pred_utc <= @end_time 
AND gf.wind_pred_5m_kw<=0.0 AND dp.wind_clear_kw<=0.0 
ORDER BY gf.duid, gf.time_pred_utc;
