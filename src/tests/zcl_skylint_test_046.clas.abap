CLASS zcl_skylint_test_046 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_046 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE @lt_data UP TO 1 ROWS.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE @lt_data UP TO 1 ROWS. "#EC SELECT_UP_TO_1
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF t100.
    SELECT * FROM t100 INTO TABLE @lt_data UP TO 1 ROWS ORDER BY msgnr.
  ENDMETHOD.

ENDCLASS.
