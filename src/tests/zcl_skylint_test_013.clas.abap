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
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.
    LOOP AT lt_tab INTO lv_item.
      CHECK lv_item IS NOT INITIAL.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.
    LOOP AT lt_tab INTO lv_item.
      CHECK lv_item IS NOT INITIAL. "#EC CHECK_IN_LOOP
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_item TYPE string.
    CHECK lt_tab IS NOT INITIAL.
    LOOP AT lt_tab INTO lv_item.
      IF lv_item IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
