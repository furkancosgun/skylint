CLASS zcl_skylint_test_091 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_091 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_tab TYPE string VALUE 'T100'.
    DATA lt_res TYPE STANDARD TABLE OF t100 WITH EMPTY KEY.

    SELECT * FROM (lv_tab) INTO TABLE @lt_res.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_tab TYPE string VALUE 'T100'.
    DATA lt_res TYPE STANDARD TABLE OF t100 WITH EMPTY KEY.

    SELECT * FROM (lv_tab) INTO TABLE @lt_res. "#EC AVOID_DYNAMIC_SQL
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_res TYPE STANDARD TABLE OF t100 WITH EMPTY KEY.

    SELECT * FROM t100 INTO TABLE @lt_res.
  ENDMETHOD.
ENDCLASS.
