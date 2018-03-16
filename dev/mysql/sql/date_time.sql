/******************************************************************************
 * date_time_aet.sql
 * SQL script for loading date_time table 
 *****************************************************************************/

\! echo "USE windfarm"
USE windfarm

\! echo "CREATE TABLE date_time_5m"
DROP TABLE IF EXISTS date_time_5m;
CREATE TABLE date_time_5m (
	date_time datetime not null
);

\! echo "CREATE TABLE date_time"
DROP TABLE IF EXISTS date_time;
CREATE TABLE date_time (
	date_time_utc datetime not null,
	date_time_aet datetime not null,
	date_time_aest datetime not null
);
CREATE UNIQUE INDEX utcidx
ON date_time (date_time_utc);
CREATE INDEX aetidx
ON date_time (date_time_aet);
CREATE INDEX aestidx
ON date_time (date_time_aest);
DESCRIBE date_time;

\! echo "LOAD DATA LOCAL INFILE '~/projects/windbess/data/date_time_5m.dat' INTO TABLE date_time_5m"
LOAD DATA LOCAL INFILE '/home/users/starca/projects/windbess/data/date_time_5m.dat'
INTO TABLE date_time_5m
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEDT 2016"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '11:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2015-10-04 02:00:00','10:00:00') 
AND date_time <= SUBTIME('2016-04-03 03:00:00','11:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEST 2016"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '10:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2016-04-03 03:00:00','11:00:00') 
AND date_time <= SUBTIME('2016-10-02 02:00:00','10:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEDT 2017"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '11:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2016-10-02 02:00:00','10:00:00')
AND date_time <= SUBTIME('2017-04-02 03:00:00','11:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEST 2017"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '10:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2017-04-02 03:00:00','11:00:00')
AND date_time <= SUBTIME('2017-10-01 02:00:00','10:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEDT 2018"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '11:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2017-10-01 02:00:00','10:00:00')
AND date_time <= SUBTIME('2018-04-01 03:00:00','11:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEST 2018"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '10:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2018-04-01 03:00:00','11:00:00')
AND date_time <= SUBTIME('2018-10-07 02:00:00','10:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEDT 2019"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '11:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2018-10-07 02:00:00','10:00:00')
AND date_time <= SUBTIME('2019-04-07 03:00:00','11:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEST 2019"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '10:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2019-04-07 03:00:00','11:00:00')
AND date_time <= SUBTIME('2019-10-06 02:00:00','10:00:00')
;

\! echo "INSERT INTO date_time SELECT date_time_utc, date_time_aet (ADDTIME) -- AEDT 2020"
INSERT INTO date_time (date_time_utc, date_time_aet, date_time_aest)
SELECT date_time, ADDTIME(date_time, '11:00:00'), ADDTIME(date_time, '10:00:00')
FROM date_time_5m
WHERE date_time > SUBTIME('2019-10-06 02:00:00','10:00:00')
AND date_time <= SUBTIME('2020-04-05 03:00:00','11:00:00')
;

\! echo "DROP TABLE date_time_5m"
DROP TABLE date_time_5m
;
