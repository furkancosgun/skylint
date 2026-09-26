CLASS zcl_skylint_test_056 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_056 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE lt_data.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE lt_data. "#EC SQL_HOST_VAR
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE @lt_data.
  ENDMETHOD.

ENDCLASS.
