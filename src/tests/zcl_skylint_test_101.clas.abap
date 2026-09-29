CLASS zcl_skylint_test_101 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_101 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    TYPES ty_val TYPE i.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.
    TYPES ty_val TYPE i. "#EC LOCAL_DECL_ORDER
  ENDMETHOD.

  METHOD valid_code.
    TYPES ty_val TYPE i.
    CONSTANTS c_val TYPE i VALUE 1.
    DATA lv_val TYPE i.
    FIELD-SYMBOLS <fs_val> TYPE i.
  ENDMETHOD.
ENDCLASS.
