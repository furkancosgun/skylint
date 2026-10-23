CLASS zcl_test_no_raise_cx_sy DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_test_no_raise_cx_sy IMPLEMENTATION.
  METHOD test_001.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_clean TYPE i.
  ENDMETHOD.

  METHOD test_003.
    RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_ok TYPE i.
  ENDMETHOD.

  METHOD test_005.
    DATA cx_sy_help TYPE i.
    cx_sy_help = 1.
    RAISE EXCEPTION TYPE zcx_custom MESSAGE e001(00) WITH cx_sy_help.
  ENDMETHOD.
ENDCLASS.
