CLASS zcl_skylint_test_016 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_016 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    IF 1 = 1.
      RETURN.
    ELSEIF 1 = 1.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    IF 1 = 1.
      RETURN.
    ELSEIF 1 = 1. "#EC IDENTICAL_CONDITIONS
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    IF 1 = 1.
      RETURN.
    ELSEIF 1 = 2.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
