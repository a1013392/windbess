/****************************************************************************** 
 * create_windfarm.sql
 * SQL script for creating tables in WINDFARM database:
 * uigf_feed
 * uigf_5mpd
 * ndd_feed
 * dispatch
 * wind_meas
 *****************************************************************************/

\! echo "USE windfarm"
USE windfarm

\! echo "CREATE TABLE uigf_feed"
DROP TABLE IF EXISTS uigf_feed;
CREATE TABLE uigf_feed (
	duid char(8) not null,
	time_uigf_utc datetime not null,
	time_pred_utc datetime not null,
	time_scada_utc datetime not null,
	wind_pred_kw float not null
);
CREATE INDEX predidx 
ON uigf_feed (time_pred_utc);
DESCRIBE uigf_feed;

\! echo "CREATE TABLE uigf_5mpd and INDEXES"
DROP TABLE IF EXISTS uigf_5mpd;
CREATE TABLE uigf_5mpd (
	duid char(8) not null,
	time_pred_utc datetime not null,
	time_scada_utc datetime not null,
	wind_pred_5m_kw float not null,
	wind_pred_10m_kw float not null,
	wind_pred_15m_kw float not null,
	wind_pred_20m_kw float not null,
	wind_pred_25m_kw float not null,
	wind_pred_30m_kw float not null,
	wind_pred_35m_kw float not null,
	wind_pred_40m_kw float not null,
	wind_pred_45m_kw float not null,
	wind_pred_50m_kw float not null,
	wind_pred_55m_kw float not null,
	wind_pred_60m_kw float not null,
	wind_pred_65m_kw float not null,
	wind_pred_70m_kw float not null,
	wind_pred_75m_kw float not null,
	wind_pred_80m_kw float not null,
	wind_pred_85m_kw float not null,
	wind_pred_90m_kw float not null,
	wind_pred_95m_kw float not null,
	wind_pred_100m_kw float not null,
	wind_pred_105m_kw float not null,
	wind_pred_110m_kw float not null,
	wind_pred_115m_kw float not null,
	wind_pred_120m_kw float not null
);
CREATE UNIQUE INDEX uigfidx
ON uigf_5mpd (duid, time_pred_utc);
CREATE INDEX predidx 
ON uigf_5mpd (time_pred_utc);
DESCRIBE uigf_5mpd;

\! echo "CREATE TABLE ndd_feed"
DROP TABLE IF EXISTS ndd_feed;
CREATE TABLE ndd_feed (
	time_settle_aest datetime not null,
	duid char(8) not null,
	dispatch_int bigint not null,
	interven tinyint not null,
	wind_init_mw float not null,
	wind_clear_mw float not null,
	wind_avail_mw float not null,
	dispatch_cap tinyint not null
);
DESCRIBE uigf_feed;

\! echo "CREATE TABLE wind_meas and INDEXES"
DROP TABLE IF EXISTS wind_meas;
CREATE TABLE wind_meas (
	duid char(8) not null,
	time_meas_utc datetime not null,
	wind_act_kw float not null,
	wind_theo_kw float not null,
	wt_avail float not null,
	wind_avail_kw float not null,
	wt_wind_cut_out float not null,
	wind_avail_net_kw float not null,
	wind_ctrl_kw float not null,
	wind_ctrl_local_kw float not null,
	wind_sdc tinyint not null,
	wind_ext_sdc tinyint not null,
	wind_pot_kw float not null,
	wind_pot_farm_kw float not null
);
CREATE UNIQUE INDEX measidx
ON wind_meas (duid, time_meas_utc);
CREATE INDEX timeidx 
ON wind_meas (time_meas_utc);
DESCRIBE wind_meas;

\! echo "CREATE TABLE dispatch and INDEXES"
DROP TABLE IF EXISTS dispatch;
CREATE TABLE dispatch (
	duid char(8) not null,
	time_settle_utc datetime not null,
	dispatch_int bigint not null,
	wind_init_kw float not null,
	wind_clear_kw float not null,
	wind_avail_kw float not null,
	dispatch_cap tinyint not null
);
CREATE UNIQUE INDEX dptchidx
ON dispatch (duid, time_settle_utc);
DESCRIBE dispatch;

\! echo "CREATE TABLE wind_sim and INDEXES"
DROP TABLE IF EXISTS wind_sim;
CREATE TABLE wind_sim (
	duid char(8) not null,
	time_pred_utc datetime not null,
	time_scada_utc datetime not null,
	wind_pred_5m_kw float not null,
	wind_pred_10m_kw float not null,
	wind_pred_15m_kw float not null,
	wind_pred_20m_kw float not null,
	wind_pred_25m_kw float not null,
	wind_pred_30m_kw float not null,
	wind_pred_35m_kw float not null,
	wind_pred_40m_kw float not null,
	wind_pred_45m_kw float not null,
	wind_pred_50m_kw float not null,
	wind_pred_55m_kw float not null,
	wind_pred_60m_kw float not null,
	wind_pred_65m_kw float not null,
	wind_pred_70m_kw float not null,
	wind_pred_75m_kw float not null,
	wind_pred_80m_kw float not null,
	wind_pred_85m_kw float not null,
	wind_pred_90m_kw float not null,
	wind_pred_95m_kw float not null,
	wind_pred_100m_kw float not null,
	wind_pred_105m_kw float not null,
	wind_pred_110m_kw float not null,
	wind_pred_115m_kw float not null,
	wind_pred_120m_kw float not null,
	time_meas_utc datetime not null,
	time_meas_aet datetime not null,
	wind_act_kw float not null,
	wind_theo_kw float not null,
	wind_sdc tinyint not null
);
CREATE UNIQUE INDEX windidx
ON wind_sim (duid, time_pred_utc);
DESCRIBE wind_sim;
