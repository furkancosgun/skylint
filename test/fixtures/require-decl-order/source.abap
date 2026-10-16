CLASS zcl_test_require_decl_order DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_require_decl_order IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    TYPES ty_t TYPE i.
  ENDMETHOD.

  METHOD test_002.
    TYPES ty_t TYPE i.
    DATA lv_x TYPE i.
  ENDMETHOD.

  METHOD test_003.
    FIELD-SYMBOLS <lv_fs> TYPE i.
    DATA lv_x TYPE i.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS lc_val TYPE i VALUE 1.
    DATA lv_x TYPE i.
  ENDMETHOD.
ENDCLASS.

