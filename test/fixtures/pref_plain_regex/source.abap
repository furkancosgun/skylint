CLASS zcl_test_pref_plain_regex DEFINITION.
  PUBLIC SECTION.
    DATA lv_text   TYPE string.
    DATA lv_result TYPE string.
    DATA lv_pattern TYPE string.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_pref_plain_regex IMPLEMENTATION.

  METHOD test_001.
    lv_result = find( val = lv_text regex = 'HELLO' ).
  ENDMETHOD.

  METHOD test_002.
    lv_result = find( val = lv_text sub = 'HELLO' ).
  ENDMETHOD.

  METHOD test_003.
    lv_result = find( val = lv_text regex = 'HEL.O' ).
  ENDMETHOD.

  METHOD test_004.
    FIND REGEX 'HELLO' IN lv_text.
  ENDMETHOD.

  METHOD test_005.
    lv_result = find( val = lv_text regex = lv_pattern ).
  ENDMETHOD.

  METHOD test_006.
    lv_result = replace( val = lv_text regex = 'ABC' with = 'X' ).
  ENDMETHOD.

  METHOD test_007.
    lv_result = find( val = lv_text regex = |HELLO| ).
  ENDMETHOD.

  METHOD test_008.
    lv_result = find( val = lv_text regex = 'HELLO' ). "#EC PREF_PLAIN_REGEX
  ENDMETHOD.

ENDCLASS.
