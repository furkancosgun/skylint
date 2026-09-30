CLASS zcl_skylint_test_047 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_047 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    IF 1 = 1.
    ENDIF.
    IF 2 = 2.
    ENDIF.
    IF 3 = 3.
    ENDIF.
    IF 4 = 4.
    ENDIF.
    IF 5 = 5.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments. "#EC CYCLOMATIC_COMPLEXITY
    IF 1 = 1.
    ENDIF.
    IF 2 = 2.
    ENDIF.
    IF 3 = 3.
    ENDIF.
    IF 4 = 4.
    ENDIF.
    IF 5 = 5.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    IF 1 = 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
