CLASS zcl_test_require_subrc_check DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_require_subrc_check IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.
    DATA lv_off TYPE i.
    FIND 'abc' IN lv_text MATCH OFFSET lv_off.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    DATA lv_off TYPE i.
    FIND 'abc' IN lv_text MATCH OFFSET lv_off.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    UPDATE t100 SET arbgb = 'A'.
  ENDMETHOD.
ENDCLASS.
