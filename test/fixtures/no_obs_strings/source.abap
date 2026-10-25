CLASS zcl_test_no_obs_strings DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_obs_strings IMPLEMENTATION.
  METHOD test_001.
    FIND REGEX 'a' IN 'abc'.
  ENDMETHOD.

  METHOD test_002.
    cl_abap_regex=>create_posix( pattern = `a` ).
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string VALUE 'abc'.
    REPLACE FIRST OCCURRENCE OF 'a' IN lv_text WITH 'x'.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_p TYPE p.
    DATA lv_c TYPE c LENGTH 10.
    PACK lv_c TO lv_p.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_p TYPE p.
    DATA lv_c TYPE c LENGTH 10.
    UNPACK lv_p TO lv_c.
  ENDMETHOD.
ENDCLASS.
