CLASS zcl_skylint_test_013 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_013 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    RETURN.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    RETURN. "#EC EXIT_OUTSIDE_LOOP
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_item TYPE string.

    RETURN.
    LOOP AT lt_tab INTO lv_item.
      EXIT.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
