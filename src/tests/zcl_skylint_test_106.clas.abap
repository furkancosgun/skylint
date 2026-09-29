CLASS zcl_skylint_test_106 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_106 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i VALUE 1.
    DATA lv_b TYPE i.

    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE i VALUE 1.
    DATA lv_b TYPE i.

    MOVE lv_a TO lv_b. "#EC AVOID_MOVE_STMT
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i VALUE 1.
    DATA lv_b TYPE i.

    lv_b = lv_a.
  ENDMETHOD.
ENDCLASS.
