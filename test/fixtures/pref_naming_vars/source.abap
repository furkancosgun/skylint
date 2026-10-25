CLASS zcl_test_naming_variables DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS test_001.
    CLASS-METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_test_naming_variables IMPLEMENTATION.
  METHOD test_001.
    DATA lv_value TYPE i.
    CONSTANTS lc_max TYPE i VALUE 100.
    STATICS sv_count TYPE i.
    FIELD-SYMBOLS <ls_item> TYPE any.
    DATA(lv_num) = 1.
    ASSIGN lv_num TO FIELD-SYMBOL(<lv_ptr>).
  ENDMETHOD.

  METHOD test_002.
    DATA bad_var TYPE i.
    CONSTANTS bad_const TYPE i VALUE 1.
    STATICS bad_static TYPE i.
    FIELD-SYMBOLS <bad_fs> TYPE any.
  ENDMETHOD.

  METHOD test_003.
    DATA(bad_inline) = 1.
    ASSIGN bad_inline TO FIELD-SYMBOL(<bad_inline_fs>).
  ENDMETHOD.
ENDCLASS.
