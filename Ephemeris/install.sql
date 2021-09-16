create or replace function EPHEMERIS
    ( "latitude"          float
     ,"longitude"         float
     ,"altitudeInMeters"  float
     ,"timeOfObservation" timestamp_tz
     ,"calculateMoon"     boolean
    )
returns variant
language javascript
strict immutable
as
$$
/********************************************************************************************************
*                                                                                                       *
*                                             Ephemeris UDF                                             *
*                                                                                                       *
*  Copyright (c) 2021 Snowflake Computing Inc. All rights reserved.                                     *
*                                                                                                       *
*  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in  *
*. compliance with the License. You may obtain a copy of the License at                                 *
*                                                                                                       *
*                               http://www.apache.org/licenses/LICENSE-2.0                              *
*                                                                                                       *
*  Unless required by applicable law or agreed to in writing, software distributed under the License    *
*  is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or  *
*  implied. See the License for the specific language governing permissions and limitations under the   *
*  License.                                                                                             *
*                                                                                                       *
*  Copyright (c) 2021 Snowflake Computing Inc. All rights reserved.                                     *
*                                                                                                       *
*  This Snowflake UDF uses code modified from SunCalc, (c) 2011-2015, Vladimir Agafonkin. See license.  *
*                                                                                                       *
********************************************************************************************************/

/********************************************************************************************************
* License information for SunCalc, (c) 2011-2015, Vladimir Agafonkin.                                   *
********************************************************************************************************/

/*
Code modified for use with Snowflake from SunCalc, a tiny BSD-licensed JavaScript library for calculating
sun position, sunlight phases (times for sunrise, sunset, dusk, etc.), moon position and lunar phase for
the given location and time, created by Vladimir Agafonkin (@mourner) as a part of the SunCalc.net
project. The SunCalc project including source code is available here: https://github.com/mourner/suncalc

Copyright (c) 2014, Vladimir Agafonkin
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*************************************************************************************************************
*  Beginning of SunCalc, (c) 2011-2015, Vladimir Agafonkin. Do not modify this section.                      *
*************************************************************************************************************/

/*
 (c) 2011-2015, Vladimir Agafonkin
 SunCalc is a JavaScript library for calculating sun/moon position and light phases.
 https://github.com/mourner/suncalc
*/

// Commented out for compatibility with Snowflake UDF structure.
//(function () { 'use strict';

// shortcuts for easier to read formulas

var PI   = Math.PI,
    sin  = Math.sin,
    cos  = Math.cos,
    tan  = Math.tan,
    asin = Math.asin,
    atan = Math.atan2,
    acos = Math.acos,
    rad  = PI / 180;

// sun calculations are based on http://aa.quae.nl/en/reken/zonpositie.html formulas


// date/time constants and conversions

var dayMs = 1000 * 60 * 60 * 24,
    J1970 = 2440588,
    J2000 = 2451545;

function toJulian(date) { return date.valueOf() / dayMs - 0.5 + J1970; }
//function fromJulian(j)  { return new Date((j + 0.5 - J1970) * dayMs); }
function fromJulian(j)  { 
    if (isNaN(j)) {return null;} else {return new Date((j + 0.5 - J1970) * dayMs)}; 
}

function toDays(date)   { return toJulian(date) - J2000; }


// general calculations for position

var e = rad * 23.4397; // obliquity of the Earth

function rightAscension(l, b) { return atan(sin(l) * cos(e) - tan(b) * sin(e), cos(l)); }
function declination(l, b)    { return asin(sin(b) * cos(e) + cos(b) * sin(e) * sin(l)); }

function azimuth(H, phi, dec)  { return atan(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi)); }
function altitude(H, phi, dec) { return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H)); }

function siderealTime(d, lw) { return rad * (280.16 + 360.9856235 * d) - lw; }

function astroRefraction(h) {
    if (h < 0) // the following formula works for positive altitudes only.
        h = 0; // if h = -0.08901179 a div/0 would occur.

    // formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
    // 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
    return 0.0002967 / Math.tan(h + 0.00312536 / (h + 0.08901179));
}

// general sun calculations

function solarMeanAnomaly(d) { return rad * (357.5291 + 0.98560028 * d); }

function eclipticLongitude(M) {

    var C = rad * (1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M)), // equation of center
        P = rad * 102.9372; // perihelion of the Earth

    return M + C + P + PI;
}

function sunCoords(d) {

    var M = solarMeanAnomaly(d),
        L = eclipticLongitude(M);

    return {
        dec: declination(L, 0),
        ra: rightAscension(L, 0)
    };
}


var SunCalc = {};


// calculates sun position for a given date and latitude/longitude

SunCalc.getPosition = function (date, lat, lng) {

    var lw  = rad * -lng,
        phi = rad * lat,
        d   = toDays(date),

        c  = sunCoords(d),
        H  = siderealTime(d, lw) - c.ra;

    return {
        azimuth: azimuth(H, phi, c.dec),
        altitude: altitude(H, phi, c.dec)
    };
};


// sun times configuration (angle, morning name, evening name)

var times = SunCalc.times = [
    [-0.833, 'sunrise',       'sunset'      ],
    [  -0.3, 'sunriseEnd',    'sunsetStart' ],
    [    -6, 'dawn',          'dusk'        ],
    [   -12, 'nauticalDawn',  'nauticalDusk'],
    [   -18, 'nightEnd',      'night'       ],
    [     6, 'goldenHourEnd', 'goldenHour'  ]
];

// adds a custom time to the times config

SunCalc.addTime = function (angle, riseName, setName) {
    times.push([angle, riseName, setName]);
};


// calculations for sun times

var J0 = 0.0009;

function julianCycle(d, lw) { return Math.round(d - J0 - lw / (2 * PI)); }

function approxTransit(Ht, lw, n) { return J0 + (Ht + lw) / (2 * PI) + n; }
function solarTransitJ(ds, M, L)  { return J2000 + ds + 0.0053 * sin(M) - 0.0069 * sin(2 * L); }

function hourAngle(h, phi, d) { return acos((sin(h) - sin(phi) * sin(d)) / (cos(phi) * cos(d))); }
function observerAngle(height) { return -2.076 * Math.sqrt(height) / 60; }

// returns set time for the given sun altitude
function getSetJ(h, lw, phi, dec, n, M, L) {

    var w = hourAngle(h, phi, dec),
        a = approxTransit(w, lw, n);
    return solarTransitJ(a, M, L);
}


// calculates sun times for a given date, latitude/longitude, and, optionally,
// the observer height (in meters) relative to the horizon

SunCalc.getTimes = function (date, lat, lng, height) {

    height = height || 0;

    var lw = rad * -lng,
        phi = rad * lat,

        dh = observerAngle(height),

        d = toDays(date),
        n = julianCycle(d, lw),
        ds = approxTransit(0, lw, n),

        M = solarMeanAnomaly(ds),
        L = eclipticLongitude(M),
        dec = declination(L, 0),

        Jnoon = solarTransitJ(ds, M, L),

        i, len, time, h0, Jset, Jrise;


    var result = {
        solarNoon: fromJulian(Jnoon),
        nadir: fromJulian(Jnoon - 0.5)
    };

    for (i = 0, len = times.length; i < len; i += 1) {
        time = times[i];
        h0 = (time[0] + dh) * rad;

        Jset = getSetJ(h0, lw, phi, dec, n, M, L);
        Jrise = Jnoon - (Jset - Jnoon);

        result[time[1]] = fromJulian(Jrise);
        result[time[2]] = fromJulian(Jset);
    }

    return result;
};


// moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas

function moonCoords(d) { // geocentric ecliptic coordinates of the moon

    var L = rad * (218.316 + 13.176396 * d), // ecliptic longitude
        M = rad * (134.963 + 13.064993 * d), // mean anomaly
        F = rad * (93.272 + 13.229350 * d),  // mean distance

        l  = L + rad * 6.289 * sin(M), // longitude
        b  = rad * 5.128 * sin(F),     // latitude
        dt = 385001 - 20905 * cos(M);  // distance to the moon in km

    return {
        ra: rightAscension(l, b),
        dec: declination(l, b),
        dist: dt
    };
}

SunCalc.getMoonPosition = function (date, lat, lng) {

    var lw  = rad * -lng,
        phi = rad * lat,
        d   = toDays(date),

        c = moonCoords(d),
        H = siderealTime(d, lw) - c.ra,
        h = altitude(H, phi, c.dec),
        // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
        pa = atan(sin(H), tan(phi) * cos(c.dec) - sin(c.dec) * cos(H));

    h = h + astroRefraction(h); // altitude correction for refraction

    return {
        azimuth: azimuth(H, phi, c.dec),
        altitude: h,
        distance: c.dist,
        parallacticAngle: pa
    };
};


// calculations for illumination parameters of the moon,
// based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
// Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.

SunCalc.getMoonIllumination = function (date) {

    var d = toDays(date || new Date()),
        s = sunCoords(d),
        m = moonCoords(d),

        sdist = 149598000, // distance from Earth to Sun in km

        phi = acos(sin(s.dec) * sin(m.dec) + cos(s.dec) * cos(m.dec) * cos(s.ra - m.ra)),
        inc = atan(sdist * sin(phi), m.dist - sdist * cos(phi)),
        angle = atan(cos(s.dec) * sin(s.ra - m.ra), sin(s.dec) * cos(m.dec) -
                cos(s.dec) * sin(m.dec) * cos(s.ra - m.ra));

    return {
        fraction: (1 + cos(inc)) / 2,
        phase: 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Math.PI,
        angle: angle
    };
};


function hoursLater(date, h) {
    return new Date(date.valueOf() + h * dayMs / 24);
}

// calculations for moon rise/set times are based on http://www.stargazing.net/kepler/moonrise.html article

SunCalc.getMoonTimes = function (date, lat, lng, inUTC) {
    var t = new Date(date);
    if (inUTC) t.setUTCHours(0, 0, 0, 0);
    else t.setHours(0, 0, 0, 0);

    var hc = 0.133 * rad,
        h0 = SunCalc.getMoonPosition(t, lat, lng).altitude - hc,
        h1, h2, rise, set, a, b, xe, ye, d, roots, x1, x2, dx;

    // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
    for (var i = 1; i <= 24; i += 2) {
        h1 = SunCalc.getMoonPosition(hoursLater(t, i), lat, lng).altitude - hc;
        h2 = SunCalc.getMoonPosition(hoursLater(t, i + 1), lat, lng).altitude - hc;

        a = (h0 + h2) / 2 - h1;
        b = (h2 - h0) / 2;
        xe = -b / (2 * a);
        ye = (a * xe + b) * xe + h1;
        d = b * b - 4 * a * h1;
        roots = 0;

        if (d >= 0) {
            dx = Math.sqrt(d) / (Math.abs(a) * 2);
            x1 = xe - dx;
            x2 = xe + dx;
            if (Math.abs(x1) <= 1) roots++;
            if (Math.abs(x2) <= 1) roots++;
            if (x1 < -1) x1 = x2;
        }

        if (roots === 1) {
            if (h0 < 0) rise = i + x1;
            else set = i + x1;

        } else if (roots === 2) {
            rise = i + (ye < 0 ? x2 : x1);
            set = i + (ye < 0 ? x1 : x2);
        }

        if (rise && set) break;

        h0 = h2;
    }

    var result = {};

    if (rise) result.rise = hoursLater(t, rise);
    if (set) result.set = hoursLater(t, set);

    if (!rise && !set) result[ye > 0 ? 'alwaysUp' : 'alwaysDown'] = true;

    return result;
}

/*  Section of SunCalc commented out since it does not apply to Snowflake and generates an error.
 
// export as Node module / AMD module / browser variable
if (typeof exports === 'object' && typeof module !== 'undefined') module.exports = SunCalc;
else if (typeof define === 'function' && define.amd) define(SunCalc);
else window.SunCalc = SunCalc;

}());
*/

/*************************************************************************************************************
*  End of SunCalc, (c) 2011-2015, Vladimir Agafonkin. Do not modify code in this section.                    *
*************************************************************************************************************/

// Validate input parameters.

var err = {};

if (latitude  < -90  || latitude  > 90  ) { err.latitude  = "Parameter for latitude is out of range.";  err.error = "Invalid parameter"}
if (longitude < -180 || longitude > 180 ) { err.longitude = "Parameter for longitude is out of range."; err.error = "Invalid parameter"}
if (altitude  < 0    || altitude > 18000) { err.altitude  = "Parameter for altitude is out of range.";  err.error = "Invalid parameter"}

if (typeof(err.error) !== 'undefined') return err;

var out = SunCalc.getTimes(timeOfObservation, latitude, longitude, altitudeInMeters);

var daylightState = currentPartOfDay(timeOfObservation, out);

out.daylightTime = daylightState.daylightTime;
out.sunlightCode = daylightState.sunlight;

if (calculateMoon) {
    var moonTimes = SunCalc.getMoonTimes(timeOfObservation, latitude, longitude, altitudeInMeters);
    var moonIllumination = SunCalc.getMoonIllumination(timeOfObservation, latitude, longitude, altitudeInMeters);
    out.moonRise = moonTimes.rise;
    out.moonSet  = moonTimes.set;
    out.moonAngle = moonIllumination.angle;
    out.moonFractionIlluminated = moonIllumination.fraction;
    var moonPhase = getMoonPhase(moonIllumination.phase);
    out.moonPhase = moonPhase.phase;
    out.moonPhaseIcon = moonPhase.icon;
    out.moonCycleDay = moonPhase.cycleDay;
    out.moonlight = moonlight(timeOfObservation, out);
}

function getMoonPhase(fractionOfCycle) {

    p = fractionOfCycle * 29.5305882;

    if (p < 1.845660) return { "cycleDay":p, "icon":"🌑", "phase":"New"};
    if (p < 5.536990) return { "cycleDay":p, "icon":"🌒", "phase":"Waxing crescent"};
    if (p < 9.228310) return { "cycleDay":p, "icon":"🌓", "phase":"First quarter"};
    if (p < 12.91963) return { "cycleDay":p, "icon":"🌔", "phase":"Waxing gibbous"};
    if (p < 16.61096) return { "cycleDay":p, "icon":"🌕", "phase":"Full"};
    if (p < 20.30228) return { "cycleDay":p, "icon":"🌖", "phase":"Waning gibbous"};
    if (p < 23.99361) return { "cycleDay":p, "icon":"🌗", "phase":"Last quarter"};
    if (p < 27.68493) return { "cycleDay":p, "icon":"🌘", "phase":"Waning crescent"};
                      return { "cycleDay":p, "icon":"🌑", "phase":"New"};
}


function getPolarPartOfDay(theTime, sc) {

    



    return {"daylightTime":"not calculated - polar", "sunlight":-1};
}

function isPolarRegion(sc) {
    return (!sc.nightEnd || !sc.nauticalDawn || !sc.dawn || !sc.sunrise || !sc.sunriseEnd ||
            !sc.goldenHourEnd || !sc.goldenHour || !sc.sunsetStart || !sc.sunset || !sc.dusk ||
            !sc.nauticalDusk || !sc.night);
}

function currentPartOfDay(theTime, sc) {

    // Check for polar latitudes with nulls on one or more events
    if (isPolarRegion(sc)) {
        return getPolarPartOfDay(sc);
    }

    // Check for 1 hour either side of solar noon first:

    var solarNoon = new Date(sc.solarNoon);
    var d1 = new Date(solarNoon - 3600000);
    var d2 = new Date(solarNoon - (3600000 * -1));

    if( theTime >= d1 && theTime <= d2) return {"daylightTime":"solar noon",                    "sunlight":7};
    if( theTime < sc.nightEnd         ) return {"daylightTime":"night",                         "sunlight":0};
    if( theTime < sc.nauticalDawn     ) return {"daylightTime":"morning astronomical twilight", "sunlight":1};
    if( theTime < sc.dawn             ) return {"daylightTime":"morning nautical twilight",     "sunlight":2};
    if( theTime < sc.sunrise          ) return {"daylightTime":"morning civil twilight",        "sunlight":3};
    if( theTime < sc.sunriseEnd       ) return {"daylightTime":"sun rising",                    "sunlight":4};
    if( theTime < sc.goldenHourEnd    ) return {"daylightTime":"morning golden hour",           "sunlight":5};
    if( theTime < sc.goldenHour       ) return {"daylightTime":"full daylight",                 "sunlight":6};
    if( theTime < sc.sunsetStart      ) return {"daylightTime":"evening golden hour",           "sunlight":5};
    if( theTime < sc.sunset           ) return {"daylightTime":"sun setting",                   "sunlight":4};
    if( theTime < sc.dusk             ) return {"daylightTime":"evening civil twilight",        "sunlight":3};
    if( theTime < sc.nauticalDusk     ) return {"daylightTime":"evening nautical twilight",     "sunlight":2};
    if( theTime < sc.night            ) return {"daylightTime":"evening astronomical twilight", "sunlight":1};
                                        return {"daylightTime":"night",                         "sunlight":0};
}

function moonlight(theTime, sc) {

    var moonIsUp = false;

    if (sc.moonRise > sc.moonSet) {
        moonIsUp = (theTime > sc.moonRise || theTime < sc.moonSet);
    } else {
        moonIsUp = (theTime > sc.moonRise && theTime < sc.moonSet);
    }
    if (moonIsUp) {
        return sc.moonFractionIlluminated;
    } else {
        return 0;
    }
}

return out;

$$;
