// Set the context to the Snowflake building at 350 Concar Dr. San Mateo, CA
set LATITUDE            = 37.5534006;
set LONGITUDE           = -122.3082959;
set ALTITUDE            = 0;
set TIME_OF_OBSERVATION = (select current_timestamp);
set CALCULATE_MOON      = true;

set TIMEZONE            = 'America/Los_Angeles';
alter session 
  set timezone          = $TIMEZONE;

-- Simple use to determine if it's daylight or not:
select EPHEMERIS($LATITUDE, $LONGITUDE, $ALTITUDE, current_timestamp, true):sunlightCode::int >= 3
       as IS_DAYLIGHT
;

-- Simple use to determine current daylight conditions in plain language:
select EPHEMERIS($LATITUDE, $LONGITUDE, $ALTITUDE, current_timestamp, true):daylightTime::string
       as DAYLIGHT_CONDITIONS
;

/*

Sunlight Codes, higher numbers represent brighter sunlight conditions:

0 - Nighttime: no sunlight at all.
1 - Astronomical twilight: sunlight is not generally detectable except through optical instruments.
2 - Nautical twilight: sunlight is bright enough to discern the horizon.
3 - Civil twilight: sun is below the horizon, but there is sufficient light for most outdoor activities without artificial illumination.
4 - Sunrise or sunset: the sun is in the middle of rising or setting, part of the sun is above the horizon and part is below the horizon.
5 - Golden hour: the sun is above the horizon but at a very acute angle to the horizon and observer; its light appears softer and redder due to scattering through the atmosphere.
    (Note: Golden hour takes place shortly after sunrise and shortly before sunset, and is typically shorter than an hour)
6 - Full daylight: the sun is well above the horizon 
7 - Solar noon: the sun is within 1 hour either side of solar noon, representing the peak intensity of solar radiation

*/

// Center of Snowflake building at 350 Concar Dr. San Mateo, CA
set LATITUDE            = 37.5534006;
set LONGITUDE           = -122.3082959;
set ALTITUDE            = 0;
set TIME_OF_OBSERVATION = (select current_timestamp);
set CALCULATE_MOON      = true;

set TIMEZONE            = 'America/Los_Angeles';
alter session set timezone = $TIMEZONE;

-- Full use of all JSON properties generated by the Ephemeris UDF:
select   EPHEMERIS($LATITUDE, $LONGITUDE, $ALTITUDE, $TIME_OF_OBSERVATION, true) as SC
        ,SC:moonlight::string                              as MOONLIGHT
        ,SC:daylightTime::string                           as CURRENT_PART_OF_DAY
        ,SC:sunlightCode::int                              as SUNLIGHT_CODE
        ,SC:nadir::timestamp_tz                            as MIDDLE_OF_NIGHT
        ,SC:nightEnd::timestamp_tz                         as DAWN_ASTRONOMICAL_STARTS
        ,SC:nauticalDawn::timestamp_tz                     as DAWN_NAUTICAL_STARTS
        ,SC:dawn::timestamp_tz                             as DAWN_CIVIL_STARTS
        ,SC:sunrise::timestamp_tz                          as SUNRISE_STARTS
        ,SC:sunriseEnd::timestamp_tz                       as SUNRISE_COMPLETES
        ,SC:goldenHourEnd::timestamp_tz                    as MORNING_GOLDEN_HOUR_ENDS
        ,SC:solarNoon::timestamp_tz                        as SOLAR_NOON
        ,SC:goldenHour::timestamp_tz                       as EVENING_GOLDEN_HOUR_STARTS
        ,SC:sunsetStart::timestamp_tz                      as SUNSET_STARTS
        ,SC:sunset::timestamp_tz                           as SUNSET_ENDS
        ,SC:dusk::timestamp_tz                             as DUSK_CIVIL_ENDS
        ,SC:nauticalDusk::timestamp_tz                     as DUSK_NAUTICAL_ENDS
        ,SC:night::timestamp_tz                            as DUSK_ASTRONOMICAL_ENDS
        ,SC:moonRise::timestamp_tz                         as MOONRISE
        ,SC:moonSet::timestamp_tz                          as MOONSET
        ,SC:moonFractionIlluminated::float                 as MOON_ILLUMINATION
        ,SC:moonAngle::float                               as MOON_ANGLE_RADIANS
        ,SC:moonAngle::float * 180 / PI()                  as MOON_ANGLE_DEGREES
        ,SC:moonCycleDay::float                            as MOON_CYCLE_DAY
        ,SC:moonPhase::string                              as MOON_PHASE_IN_ENGLISH
        ,SC:moonPhaseIcon::string                          as MOON_PHASE_ICON
;


