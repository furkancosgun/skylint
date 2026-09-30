CLASS zcl_skylint_test_084 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_084 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_line TYPE string.

    LOOP AT lt_data INTO lv_line.
      MODIFY lt_data FROM lv_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_line TYPE string.

    LOOP AT lt_data INTO lv_line.
      MODIFY lt_data FROM lv_line. "#EC AVOID_FULL_MODIFY
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_line TYPE string.

    LOOP AT lt_data INTO lv_line.
      MODIFY lt_data FROM lv_line TRANSPORTING (table_line).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
