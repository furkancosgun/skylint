CLASS zcl_skylint_test_001 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.

ENDCLASS.


CLASS zcl_skylint_test_001 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_lines TYPE i.

    DESCRIBE TABLE lt_tab LINES lv_lines.

    IF 1 = 1.
      DESCRIBE TABLE lt_tab LINES lv_lines.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_lines TYPE i.

    DESCRIBE TABLE lt_tab LINES lv_lines. "#EC DESCRIBE_LINES

    IF 1 = 1.
      DESCRIBE TABLE lt_tab LINES lv_lines. "#EC DESCRIBE_LINES
    ENDIF.
  ENDMETHOD.
ENDCLASS.
