/********************************************************************************************************
*                                                                                                       *
*                             Snowflake Regular Expression Extensions                                   *
*                                                                                                       *
*  Copyright (c) 2020 Snowflake Computing Inc. All rights reserved.                                     *
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
*  Copyright (c) 2020, 2021, 2022, 2023 Snowflake Computing Inc. All rights reserved.                   *
*                                                                                                       *
********************************************************************************************************/

-- Note: The GROUP_NUM parameter is not implemented and not used.
create or replace function REGEXP_SUBSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float, PARAMETERS string, GROUP_NUM float)
returns string
language javascript strict immutable
as
$$
    if (OCCURRENCE < 1) OCCURRENCE = 1;

    var pos = POSITION - 1;
    if (pos < 0) pos = 0;
    var str = SUBJECT;
    if (pos != 0) {
        str = str.substring(pos);
    }
    var params = "g" + PARAMETERS;
    var regex = new RegExp(PATTERN, params)
    var instr = 0;
    var cursor = pos;

    for (i = 1; i <= OCCURRENCE; i++) {
        instr = str.search(regex);
        if (instr === -1) break;
        str = str.substring(instr);  // Next iteration for occurrence
        cursor = cursor + instr + 1;
    }
    
    if (instr != -1) {
        return str.match(regex);
    } else {
        return "";
    }
$$;

create or replace function REGEXP_SUBSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float, PARAMETERS string)
returns string
language SQL
as
$$
    regexp_substr2(SUBJECT, PATTERN, POSITION, OCCURRENCE, PARAMETERS, 0)
$$;

create or replace function REGEXP_SUBSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float)
returns string
language SQL
as
$$
    regexp_substr2(SUBJECT, PATTERN, POSITION, OCCURRENCE, '', 0)
$$;

create or replace function REGEXP_SUBSTR2(SUBJECT string, PATTERN string, POSITION float)
returns string
language SQL
as
$$
    regexp_substr2(SUBJECT, PATTERN, POSITION, 1, '', 0)
$$;

create or replace function REGEXP_SUBSTR2(SUBJECT string, PATTERN string)
returns string
language SQL
as
$$
    regexp_substr2(SUBJECT, PATTERN, 1, 1, '', 0)
$$;


-- Note: The GROUP_NUM parameter is not implemented and not used.
create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float, RETURN_OPTION float, PARAMETERS string, GROUP_NUM float)
returns float
language javascript strict immutable
as
$$

    if (SUBJECT == null || PATTERN == null) return null;

    if (OCCURRENCE < 1) OCCURRENCE = 1;

    var pos = POSITION - 1;
    if (pos < 0) pos = 0;
    var str = SUBJECT;
    if (pos != 0) {
        str = str.substring(pos);
    }
    var params = "g" + PARAMETERS;
    var regex = new RegExp(PATTERN, params)
    var instr = 0;
    var cursor = pos;

    for (i = 1; i <= OCCURRENCE; i++) {
        instr = str.search(regex);
        if (instr === -1) break;
        str = str.substring(instr + 1);  // Next iteration for occurrence
        cursor = cursor + instr + 1;
    }
    
    if (instr != -1) {
        //instr = instr + pos + 1;
        if (RETURN_OPTION >= 1) {
            cursor++;
        }
    } else {
        cursor = -1;
    }
    return cursor;
$$;

create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float, RETURN_OPTION float, PARAMETERS string)
returns float
language SQL
as
$$
    regexp_instr2(SUBJECT, PATTERN, POSITION, OCCURRENCE, RETURN_OPTION, PARAMETERS, 0)
$$;

create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float, RETURN_OPTION float)
returns float
language SQL
as
$$
    regexp_instr2(SUBJECT, PATTERN, POSITION, OCCURRENCE, RETURN_OPTION, '', 0)
$$;

create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string, POSITION float, OCCURRENCE float)
returns float
language SQL
as
$$
    regexp_instr2(SUBJECT, PATTERN, POSITION, OCCURRENCE, 0,'', 0)
$$;

create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string, POSITION float)
returns float
language SQL
as
$$
    regexp_instr2(SUBJECT, PATTERN, POSITION, 1, 0,'', 0)
$$;

create or replace function REGEXP_INSTR2(SUBJECT string, PATTERN string)
returns float
language SQL
as
$$
    regexp_instr2(SUBJECT, PATTERN, 1, 1, 0,'', 0)
$$;

create or replace function REGEXP_COUNT2(SUBJECT string, PATTERN string, POSITION float, PARAMETERS string)
returns float
language javascript strict immutable
as
$$
    if (SUBJECT == null || PATTERN == null) return null;
    var pos = POSITION - 1;
    if (pos < 0) pos = 0;
    var str = "";
    if (pos != 0) {
      str = SUBJECT.substring(pos);
    } else {
      str = SUBJECT;
    }
    var params = "g" + PARAMETERS;
    var regex = new RegExp(PATTERN, params)
    var count = (str.match(regex) || []).length;
    return count;
$$;

create or replace function REGEXP_COUNT2(SUBJECT string, PATTERN string, POSITION float)
returns float
language SQL
as
$$
    regexp_count2(SUBJECT, PATTERN, POSITION, '')
$$;

create or replace function REGEXP_COUNT2(SUBJECT string, PATTERN string)
returns float
language SQL
as
$$
    regexp_count2(SUBJECT, PATTERN, 1, '')
$$;

-- Recommend placing in a common area, such as UTIL_DB.
--use database UTIL_DB;

create or replace function REGEXP_LIKE2(SUBJECT string, PATTERN string, PARAMETERS string)
returns boolean
language javascript strict immutable
as
$$
    if (SUBJECT == null || PATTERN == null) return null;
    const regex = RegExp(PATTERN, PARAMETERS);
    return regex.test(SUBJECT);
$$;

create or replace function REGEXP_LIKE2(SUBJECT string, PATTERN string)
returns boolean
language SQL
as
$$
    REGEXP_LIKE2(SUBJECT, PATTERN, '')
$$;

create or replace function RLIKE2(SUBJECT string, PATTERN string, PARAMETERS string)
returns boolean
language SQL
as
$$
    REGEXP_LIKE2(SUBJECT, PATTERN, PARAMETERS)
$$;

create or replace function RLIKE2(SUBJECT string, PATTERN string)
returns boolean
language SQL
as
$$
    REGEXP_LIKE2(SUBJECT, PATTERN, '')
$$;

create or replace function REGEXP_REPLACE2(SUBJECT string, PATTERN string, REPLACEMENT string, POSITION float, OCCURRENCE float, PARAMETERS string)
returns string
language javascript strict immutable
as
$$
    if (SUBJECT == null || PATTERN == null) return null;
    var params = PARAMETERS;
    if (OCCURRENCE == 0) {
        params = "g" + params;
    }
    var skippedString = SUBJECT.substring(0, POSITION - 1);
    var searchString = SUBJECT.substring(POSITION - 1);
    return skippedString + searchString.replace(new RegExp(PATTERN, params), REPLACEMENT);
$$;

create or replace function REGEXP_REPLACE2(SUBJECT string, PATTERN string)
returns string
language SQL
as
$$
    REGEXP_REPLACE2(SUBJECT, PATTERN, '', 1, 0, '')
$$;

create or replace function REGEXP_REPLACE2(SUBJECT string, PATTERN string, REPLACEMENT string)
returns string
language SQL
as
$$
    REGEXP_REPLACE2(SUBJECT, PATTERN, REPLACEMENT, 1, 0, '')
$$;

create or replace function REGEXP_REPLACE2(SUBJECT string, PATTERN string, REPLACEMENT string, POSITION int)
returns string
language SQL
as
$$
    REGEXP_REPLACE2(SUBJECT, PATTERN, REPLACEMENT, POSITION, 0, '')
$$;

create or replace function REGEXP_REPLACE2(SUBJECT string, PATTERN string, REPLACEMENT string, POSITION int, OCCURRENCE int)
returns string
language SQL
as
$$
    REGEXP_REPLACE2(SUBJECT, PATTERN, REPLACEMENT, POSITION, OCCURRENCE, '')
$$;
