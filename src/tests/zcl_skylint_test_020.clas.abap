CLASS zcl_skylint_test_020 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_020 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    IF 1 = 1.
      IF 2 = 2.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    IF 1 = 1. "#EC NESTED_IF
      IF 2 = 2.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    IF 1 = 1 AND 2 = 2.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
