CLASS zcl_test_no_select_star DEFINITION
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
    METHODS test_013.
    METHODS test_014.
ENDCLASS.

CLASS zcl_test_no_select_star IMPLEMENTATION.
  METHOD test_001.
    SELECT * FROM t100 INTO @DATA(ls_row).
    ENDSELECT.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT arbgb FROM t100 INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_003.
    DATA ls_row TYPE t100.
    DATA ls_key TYPE string.
    SELECT SINGLE * FROM t100 INTO @ls_row WHERE arbgb = @ls_key.
  ENDMETHOD.

  METHOD test_004.
    DATA ls_row TYPE t100.
    DATA ls_key TYPE string.
    SELECT SINGLE arbgb FROM t100 INTO @ls_row WHERE arbgb = @ls_key.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT FROM t100 FIELDS * INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_val TYPE i.
    SELECT SINGLE price * 2 FROM t100 INTO @lv_val.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT tab~* FROM t100 AS tab INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT FROM t100 FIELDS arbgb INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT FROM t100 FIELDS * WHERE ( sprsl = 'E' ) INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_total TYPE i.
    SELECT SINGLE ( msgnr * 2 ) AS total FROM t100 INTO @lv_total WHERE ( sprsl = 'E' ).
  ENDMETHOD.

  METHOD test_011.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT msgnr FROM t100 WHERE msgnr IN ( SELECT msgnr FROM t100 WHERE ( sprsl = 'E' ) ) INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_012.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT FROM t100 AS a JOIN t100 AS b ON a~msgnr = b~msgnr FIELDS a~*, b~textpool INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_013.
    DATA lt_tab TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.
    SELECT FROM t100 AS a
      INNER JOIN t100 AS b ON ( a~msgnr = b~msgnr AND a~sprsl = b~sprsl )
      FIELDS a~arbgb, b~msgnr
      INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_count TYPE i.
    SELECT COUNT( * ) FROM t100 INTO @lv_count WHERE ( sprsl = 'E' ).
  ENDMETHOD.
ENDCLASS.
