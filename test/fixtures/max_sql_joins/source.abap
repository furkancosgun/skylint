CLASS zcl_skylint_test_sql_joins DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.

ENDCLASS.


CLASS zcl_skylint_test_sql_joins IMPLEMENTATION.
  METHOD test_001.
    SELECT a~bukrs
      FROM t001 AS a
      INNER JOIN t005 AS b ON a~land1 = b~land1
      LEFT JOIN t005t AS c ON b~land1 = c~land1
      JOIN t005u AS d ON b~land1 = d~land1
      JOIN t005s AS e ON b~land1 = e~land1
      JOIN t005k AS f ON b~land1 = f~land1
      INTO TABLE @DATA(lt_res).
  ENDMETHOD.

  METHOD test_002.
    SELECT a~bukrs
      FROM t001 AS a
      INNER JOIN t005 AS b ON a~land1 = b~land1
      LEFT JOIN t005t AS c ON b~land1 = c~land1
      JOIN t005u AS d ON b~land1 = d~land1
      JOIN t005s AS e ON b~land1 = e~land1
      INTO TABLE @DATA(lt_res).
  ENDMETHOD.

  METHOD test_003.
    SELECT bukrs
      FROM t001
      INTO TABLE @DATA(lt_res).
  ENDMETHOD.

  METHOD test_004.
    SELECT a~bukrs
      FROM t001 AS a
      INNER JOIN t005 AS b ON a~land1 = b~land1
      LEFT JOIN t005t AS c ON b~land1 = c~land1
      INTO TABLE @DATA(lt_res).
  ENDMETHOD.

  METHOD test_005.
    SELECT a~bukrs "#EC MAX_SQL_JOINS
      FROM t001 AS a
      INNER JOIN t005 AS b ON a~land1 = b~land1
      LEFT JOIN t005t AS c ON b~land1 = c~land1
      JOIN t005u AS d ON b~land1 = d~land1
      JOIN t005s AS e ON b~land1 = e~land1
      JOIN t005k AS f ON b~land1 = f~land1
      INTO TABLE @DATA(lt_res).
  ENDMETHOD.
ENDCLASS.
