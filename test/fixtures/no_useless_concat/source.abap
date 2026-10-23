CLASS zcl_test_no_useless_concat DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.

  PRIVATE SECTION.
    DATA mv_suffix TYPE string.
    DATA mv_prefix TYPE string.
ENDCLASS.

CLASS zcl_test_no_useless_concat IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && 'World'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && mv_suffix.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.
    lv_text = mv_prefix && 'World'.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    lv_text = 'A' && 'B' && 'C'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE string.
    lv_text = '' && 'World'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_text TYPE string.
    lv_text = |Hello| && |World|.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && 'World' && mv_suffix.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_text TYPE string.
    lv_text = mv_prefix && 'Hello' && 'World'.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && 'World' && '!'.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && 'World'. "#EC NO_USELESS_CONCAT
  ENDMETHOD.

  METHOD test_011.
    DATA lv_text TYPE string.
    lv_text = |Hello { mv_suffix }| && 'World'.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && |World|.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_text TYPE string.
    lv_text = |Hello| && |World| && |!|.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_text TYPE string.
    lv_text = `Hello` && `World`.
  ENDMETHOD.
ENDCLASS.
