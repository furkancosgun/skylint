CLASS zcl_skylint_test_009 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_009 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA: lv_a TYPE i,
          lv_b TYPE i.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA: lv_a TYPE i, "#EC CHAIN_DECL
          lv_b TYPE i.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA: BEGIN OF ls_struc,
            field1 TYPE i,
            field2 TYPE i,
          END OF ls_struc.
  ENDMETHOD.
ENDCLASS.
