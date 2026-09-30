CLASS zcl_skylint_test_037 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_037 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    TRY.
        lv_val = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.
    TRY. "#EC TRY_WITHOUT_CATCH
        lv_val = 1.
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        lv_val = 1.
      CATCH cx_root INTO lx_root.
        lv_val = 0.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
