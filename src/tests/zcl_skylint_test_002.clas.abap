CLASS zcl_skylint_test_002 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.

ENDCLASS.


CLASS zcl_skylint_test_002 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab   TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_lines TYPE i.

    lv_lines = lines( lt_tab ).

    IF 1 = 1.
      lv_lines = lines( lt_tab ).
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab   TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_lines TYPE i.

    lv_lines = lines( lt_tab ). "#EC DESCRIBE_LINES

    IF 1 = 1.
      lv_lines = lines( lt_tab ). "#EC DESCRIBE_LINES
    ENDIF.
  ENDMETHOD.
ENDCLASS.
