# SnowflakeUDFs
A set of user defined functions that augment or extend Snowflake's built-in library of functions. 

# Big Integer Math

This file contains a set of JavaScript UDFs to enable arbitrary precision integer math, in other words, math operations on integers with a high number of digits. Since Snowflake has a maximum numeric precision of 38, this library represents integers with precisions higher than 38 using the string (varchar) type. The library attempts to recreate the Snowflake numeric functions as closely as JavaScript UDFs and integer math allow. Testing indicates that the library will support mathematical operations with precisions up to at least a million digits. The practical limit is set by the 30-second maximum UDF execution time. BigInt operations with very high precisions can be very slow compared to the Snowflake built-in math functions. Use only when it is absolutely required to have higher precisions math.

# Regular Expressions

This file contains a set of JavaScript UDFs that extend the Snowflake regular expression capabilities to support lookarounds. https://www.rexegg.com/regex-lookarounds.html.

Each UDF uses the same name as the Snowflake built in regular expression function with a "2" suffix. Each UDF or overload attempts to recreate the functionality, as closely as JavaScript UDFs enable, of the built-in Snowflake regular expression function with the name name.
