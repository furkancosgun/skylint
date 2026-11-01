CLASS zcl_skylint_test_raw_str_tmpl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.

ENDCLASS.


CLASS zcl_skylint_test_raw_str_tmpl IMPLEMENTATION.
  METHOD test_001.
    DATA lv_txt TYPE string.
    lv_txt = |Hello World|.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_empty TYPE string.
    lv_empty = ||.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_dyn TYPE string.
    lv_dyn = |Hello { sy-uname }|.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_lit TYPE string VALUE 'Hello World'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_backtick TYPE string.
    lv_backtick = `Hello World`.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_supp TYPE string.
    lv_supp = |Hello World|. "#EC NO_RAW_STR_TMPL
  ENDMETHOD.
ENDCLASS.
