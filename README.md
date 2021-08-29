# SnowflakeUDFs
A set of user defined functions that augment or extend Snowflake's built-in library of functions. 

regexp.sql

This file contains a set of JavaScript UDFs that extend the Snowflake regular expression capabilities to support lookarounds. https://www.rexegg.com/regex-lookarounds.html.

Each UDF uses the same name as the Snowflake built in regular expression function with a "2" suffix. Each UDF or overload attempts to recreate the functionality, as closely as JavaScript UDFs enable, of the built-in Snowflake regular expression function with the name name.
