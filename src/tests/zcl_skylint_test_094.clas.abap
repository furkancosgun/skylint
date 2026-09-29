CLASS zcl_skylint_test_094 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_094 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_text TYPE string VALUE 'abc'.
    TRANSLATE lv_text TO UPPER CASE.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_text TYPE string VALUE 'abc'.
    TRANSLATE lv_text TO UPPER CASE. "#EC TRANSLATE_STMT
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_text TYPE string VALUE 'abc'.
    lv_text = to_upper( lv_text ).
  ENDMETHOD.
ENDCLASS.
