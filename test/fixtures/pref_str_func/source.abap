CLASS zcl_test_prefer_string_functio DEFINITION
  PUBLIC FINAL
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
ENDCLASS.


CLASS zcl_test_prefer_string_functio IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
    CONDENSE lv_text.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    lv_text = condense( lv_text ).
    lv_text = to_upper( lv_text ).
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.
    CONDENSE lv_text NO-GAPS.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    lv_text = to_lower( lv_text ).
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE c LENGTH 10.
    TRANSLATE lv_text USING 'abxy'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_text TYPE string.
    SHIFT lv_text LEFT DELETING LEADING '0'.
    SHIFT lv_text RIGHT DELETING TRAILING ` `.
    SHIFT lv_text BY 2 PLACES.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_text TYPE c LENGTH 10.
    SEARCH lv_text FOR 'ABC'.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_text TYPE c LENGTH 10.
    OVERLAY lv_text WITH '1234'.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_text TYPE string.
    lv_text = shift_left( val = lv_text sub = '0' ).
    lv_text = shift_right( val = lv_text sub = ` ` ).
  ENDMETHOD.

  METHOD test_010.
    DATA lv_text TYPE string.
    REPLACE 'foo' WITH 'bar' INTO lv_text.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_text TYPE c LENGTH 10.
    DATA lv_len TYPE i.
    DESCRIBE FIELD lv_text LENGTH lv_len IN CHARACTER MODE.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_text TYPE string.
    DATA lv_len TYPE i.
    lv_text = replace( val = lv_text sub = 'foo' with = 'bar' ).
    lv_len = strlen( lv_text ).
  ENDMETHOD.
ENDCLASS.
