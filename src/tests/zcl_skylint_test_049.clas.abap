CLASS zcl_skylint_test_049 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_049 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    IF 1 = 1.
      IF 2 = 2.
        IF 3 = 3.
          IF 4 = 4.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    IF 1 = 1.
      IF 2 = 2.
        IF 3 = 3.
          IF 4 = 4. "#EC NESTING_DEPTH
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    IF 1 = 1.
      IF 2 = 2.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
