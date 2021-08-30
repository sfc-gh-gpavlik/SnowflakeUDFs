/********************************************************************************************************
*                                                                                                       *
*                             Snowflake Arbitrary Precision Integer Math                                *
*                                                                                                       *
*  Copyright (c) 2021 Snowflake Computing Inc. All rights reserved.                                     *
*                                                                                                       *
*  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in  *
*  compliance with the License. You may obtain a copy of the License at                                 *
*                                                                                                       *
*                             http://www.apache.org/licenses/LICENSE-2.0                                *
*                                                                                                       *
*  Unless required by applicable law or agreed to in writing, software distributed under the License    *
*  is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or  *
*  implied. See the License for the specific language governing permissions and limitations under the   *
*  License.                                                                                             *
*                                                                                                       *
*  Copyright (c) 2021 Snowflake Computing Inc. All rights reserved.                                     *
*                                                                                                       *
********************************************************************************************************/

create or replace function TO_BIGINT(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        // if X has a decimal point, remove it and all digits after it:
        X = X.split('.')[0];
        var x = BigInt(X);
        return x;
    } catch {
        throw "Cannot cast value to BigInt.";
    }
$$;

create or replace function TRY_TO_BIGINT(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return x;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_ADD(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x + y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_SUBTRACT(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x - y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_MULTIPLY(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x * y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_DIVIDE(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        if (y == 0n) return 'NaN';
        return x / y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_POW(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x ** y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_POWER(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x ** y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_GREATER_THAN(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return false;
        if (X == 'NaN') return true;
        if (Y == 'NaN') return false;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x > y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_LESS_THAN(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return false;
        if (X == 'NaN') return false;
        if (Y == 'NaN') return true;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x < y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_LESS_THAN_OR_EQUALS(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return true;
        if (X == 'NaN') return false;
        if (Y == 'NaN') return true;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x <= y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_LT_EQ(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return true;
        if (X == 'NaN') return false;
        if (Y == 'NaN') return true;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x <= y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_GREATER_THAN_OR_EQUALS(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return true;
        if (X == 'NaN') return true;
        if (Y == 'NaN') return false;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x >= y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_GT_EQ(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return true;
        if (X == 'NaN') return true;
        if (Y == 'NaN') return false;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x >= y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_EQUALS(X string, Y string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return true;
        if (X == 'NaN') return false;
        if (Y == 'NaN') return false;
        var x = BigInt(X);
        var y = BigInt(Y);
        return x === y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_DIV0(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var y = BigInt(Y);
        if (y == 0n) return 0;
        var x = BigInt(X);
        return x / y;
    } catch {
        return null;
    }
$$;

create or replace function IS_BIGINT(X string)
returns boolean
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return false;
        var x = BigInt(X);
        return true;
    } catch {
        return false;
    }
$$;

create or replace function BIGINT_MOD(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == 'NaN') return 'NaN';
        var x = BigInt(X);
        var y = BigInt(Y);
        return x % y;
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_SIGN(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        if (x == 0n) return 0;
        return(x > 0 ? '1' : '-1');
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_SQUARE(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return x * x;
    } catch (err){
        return null;
    }
$$;

create or replace function BIGINT_FACTORIAL(X string)
returns string
language javascript
strict immutable
as
$$
    // Note: At high precisions, factorials will return a high number
    // of trailing zeros. This is not a loss of precision on the function.
    // It is a result of multiplying numbers with factors of 2 and 5 in the
    // factorial resulting in an accumulation of trailing zeros.
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        if (x < 0n) return "NaN";
        if (x == 0n) return 1;
        var y = 1n;
        var i = 1n;
        for (i = x; i > 1n; i=i-1n) {
            y = y * i;
        }
        return y;
    } catch (e){
        return null;
    }
$$;

create or replace function BIGINT_ABS(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return (x < 0 ? -1n * x : x);
    } catch (e){
        return null;
    }
$$;

// Currently there is no regression test for this UDF.
create or replace function BIGINT_RANDOM("numDigits" float)
returns string
language javascript
strict volatile
as
$$
    if (numDigits > 8388608 || numDigits < 1) return null;
    var x = "";
    for (var i = 0; i < numDigits; i++) {
        x += Math.floor(Math.random() * 10) + 1;
    }
    return x;
$$;

create or replace function BIGINT_SQRT(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        if (x < 0n) return 'NaN';
        if (x <= BigInt(Number.MAX_SAFE_INTEGER)) {
            sx = Number(x);
            return Math.floor(Math.sqrt(sx));
        }
        return calculateRoot(x, 2n);
    } catch (e){
        return null;
    }

function calculateRoot(radicand, index) {
    // Uses Newton's Method to calculate roots
    // https://en.wikipedia.org/wiki/Newton%27s_method

    var intercept = 0n;
    var x = radicand;
    var maxIterations = 10000;
    
    while(x ** index !== index && x !== intercept && --maxIterations) {
      intercept = x;
      x = (((index-1n) * x)  +
          (radicand / x ** (index-1n))) / index;
    }
    return x;
}
$$;

create or replace function BIGINT_CBRT(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        if (x < 0n) return 'NaN';
        if (x <= BigInt(Number.MAX_SAFE_INTEGER)) {
            sx = Number(x);
            return Math.floor(Math.pow(sx, 1/3));
        }
        return calculateRoot(x, 3n);
    } catch (e){
        return null;
    }

function calculateRoot(radicand, index) {
    // Uses Newton's Method to calculate roots
    // https://en.wikipedia.org/wiki/Newton%27s_method

    var intercept = 0n;
    var x = radicand;
    var maxIterations = 10000;
    
    while(x ** index !== index && x !== intercept && --maxIterations) {
      intercept = x;
      x = (((index-1n) * x)  +
          (radicand / x ** (index-1n))) / index;
    }
    return x;
}
$$;

create or replace function BIGINT_NTH_ROOT("radicand" string, "index" string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (radicand == 'NaN' || index == 'NaN') return 'NaN';
        var x = BigInt(radicand);
        var y = BigInt(index);
        if (x < 0n) return 'NaN';
        if (x <= BigInt(Number.MAX_SAFE_INTEGER) && y <= BigInt(Number.MAX_SAFE_INTEGER)) {
            sx = Number(x);
            sy = Number(y);
            return Math.floor(Math.pow(sx, 1/sy));
        }
        return calculateRoot(x, y);
    } catch (e){
        return null;
    }

function calculateRoot(radicand, index) {
    // Uses Newton's Method to calculate roots
    // https://en.wikipedia.org/wiki/Newton%27s_method

    var intercept = 0n;
    var x = radicand;
    var maxIterations = 10000;
    
    while(x ** index !== index && x !== intercept && --maxIterations) {
      intercept = x;
      x = (((index-1n) * x)  +
          (radicand / x ** (index-1n))) / index;
    }
    return x;
}
$$;

create or replace function AS_BIGINT(X variant)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return x;
    } catch (e){
        return null;
    }
$$;

create or replace function BIGINT_TRUNCATE(X string, Y float)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == NaN) return 'NaN';
        var x = BigInt(X);
        var y = Y * -1;
        if (y <= 0) return; // Do nothing.
        var l = X.length;
        return X.substring(0, l-y) + "0".repeat(y);
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_TRUNC(X string, Y float)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' || Y == NaN) return 'NaN';
        var x = BigInt(X);
        var y = Y * -1;
        if (y <= 0) return; // Do nothing.
        var l = X.length;
        return X.substring(0, l-y) + "0".repeat(y);
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_NULLIF(X string, Y string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN' && Y == 'NaN') return null;
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        if (Y == 'NaN') return x;
        var y = BigInt(Y);
        return (x == y ? null : x);
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_NULLIFZERO(X string)
returns string
language javascript
strict immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return (x == 0n ? null : x);
    } catch {
        return null;
    }
$$;

create or replace function BIGINT_IFNULL(X string, Y string)
returns string
language javascript
immutable
as
$$
    if (X == 'NaN') return 'NaN';
    try{var x = BigInt(X);} catch {var x = null;}
    try{var y = BigInt(Y);} catch {var y = null;}
    if (Y == 'NaN' && x == null) return 'NaN';
    return (x == null ? y : x);
$$;

create or replace function BIGINT_ZEROIFNULL(X string)
returns string
language javascript
immutable
as
$$
    try{
        if (X == 'NaN') return 'NaN';
        var x = BigInt(X);
        return (x == null ? 0 : x);
    } catch {
        return 0;
    }
$$;

create or replace function BIGINT_NVL(X string, Y string)
returns string
language javascript
immutable
as
$$
    if (X == 'NaN') return 'NaN';
    try{var x = BigInt(X);} catch {var x = null;}
    try{var y = BigInt(Y);} catch {var y = null;}
    if (x == null && Y == 'Nan') return 'NaN';
    return (x == null ? y : x);
$$;

create or replace function BIGINT_NVL2(X string, Y string, Z string)
returns string
language javascript
immutable
as
$$
    try{var x = BigInt(X);} catch {var x = null;}
    try{var y = BigInt(Y);} catch {var y = null;}
    try{var z = BigInt(Z);} catch {var z = null;}
    if (X == 'NaN') x = 'NaN';
    return (x != null ? y : z);
$$;
