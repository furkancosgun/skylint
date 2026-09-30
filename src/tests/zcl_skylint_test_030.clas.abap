CLASS zcl_skylint_test_030 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_030 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_res  TYPE string.
    DO 10 TIMES.
      SELECT SINGLE @abap_true FROM tadir INTO @lv_res WHERE obj_name = 'TEST'.
    ENDDO.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_res  TYPE string.
    DO 10 TIMES.
      SELECT SINGLE @abap_true FROM tadir INTO @lv_res WHERE obj_name = 'TEST'. "#EC DB_IN_LOOP
    ENDDO.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_res  TYPE string.
    SELECT SINGLE @abap_true FROM tadir INTO @lv_res WHERE obj_name = 'TEST'.
    LOOP AT lt_data INTO lv_res.
      lv_res = 'OK'.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
