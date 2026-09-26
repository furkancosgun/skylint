CLASS zcl_skylint_test_014 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_014 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.

    LOOP AT lt_tab INTO lv_item.
      IF lv_item IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.

    LOOP AT lt_tab INTO lv_item.
      IF lv_item IS INITIAL. "#EC CHECK_IN_LOOP
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab  TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.

    CHECK lt_tab IS NOT INITIAL.
    LOOP AT lt_tab INTO lv_item.
      IF lv_item IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
