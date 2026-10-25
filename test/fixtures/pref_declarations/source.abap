CLASS zcl_test_prefer_def_top DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA lv_a TYPE i.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_test_prefer_def_top IMPLEMENTATION.
  METHOD test_001.
    lv_a = 1.
    DATA lv_b TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_b TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_b TYPE i.
    CLEAR lv_b.
    FIELD-SYMBOLS <fs> TYPE i.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_require_decl_order DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_test_require_decl_order IMPLEMENTATION.
  METHOD test_004.
    DATA lv_x TYPE i.
    TYPES ty_t TYPE i.
  ENDMETHOD.

  METHOD test_005.
    TYPES ty_t TYPE i.
    DATA lv_x TYPE i.
  ENDMETHOD.

  METHOD test_006.
    FIELD-SYMBOLS <lv_fs> TYPE i.
    DATA lv_x TYPE i.
  ENDMETHOD.

  METHOD test_007.
    CONSTANTS lc_val TYPE i VALUE 1.
    DATA lv_x TYPE i.
  ENDMETHOD.
ENDCLASS.
