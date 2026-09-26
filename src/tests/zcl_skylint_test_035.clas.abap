CLASS zcl_skylint_test_035 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_035 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE string.
    SELECT SINGLE @abap_true FROM tadir INTO @lv_val WHERE obj_name = 'TEST'.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE string.
    SELECT SINGLE @abap_true FROM tadir INTO @lv_val WHERE obj_name = 'TEST'. "#EC DB_ACCESS_UT
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE string.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    lv_val = 'TEST'.
    INSERT lv_val INTO TABLE lt_tab.
    MODIFY lt_tab FROM lv_val INDEX 1.
    DELETE lt_tab INDEX 1.
  ENDMETHOD.
ENDCLASS.
