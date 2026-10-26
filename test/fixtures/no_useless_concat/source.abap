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
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
    METHODS test_018.
    METHODS test_019.
    METHODS test_020.
    METHODS test_021.
    METHODS test_022.
    METHODS test_023.

    METHODS func
      IMPORTING iv_val TYPE string
      RETURNING VALUE(rv_res) TYPE string.

  PRIVATE SECTION.
    DATA mv_suffix TYPE string.
    DATA mv_prefix TYPE string.
ENDCLASS.

CLASS zcl_test_no_useless_concat IMPLEMENTATION.
  METHOD func.
    rv_res = iv_val.
  ENDMETHOD.

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

  METHOD test_015.
    DATA lv_text TYPE string.
    lv_text = |prefix { func( 'abc' ) }| && 'suffix'.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_text TYPE string.
    lv_text = |{ func( func( 'x' ) ) }| && 'suffix'.
  ENDMETHOD.

  METHOD test_017.
    DATA lv_text TYPE string.
    lv_text = |a { func( '1' ) }| && |b { func( '2' ) }|.
  ENDMETHOD.

  METHOD test_018.
    DATA lv_text TYPE string.
    lv_text = func( 'Hello' && 'World' ).
  ENDMETHOD.

  METHOD test_019.
    DATA lv_text TYPE string.
    lv_text = ( 'Hello' && 'World' ).
  ENDMETHOD.

  METHOD test_020.
    DATA lv_text TYPE string.
    lv_text = 'Hello' && ( mv_suffix ).
  ENDMETHOD.

  METHOD test_021.
    DATA lv_text TYPE string.
    lv_text = func( func( 'Hello' && `World` ) ).
  ENDMETHOD.

  METHOD test_022.
    DATA lv_text TYPE string.
    lv_text = func( |Hello| && |World| ).
  ENDMETHOD.

  METHOD test_023.
    IF ( func( 'a' && 'b' ) = 'ab' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
