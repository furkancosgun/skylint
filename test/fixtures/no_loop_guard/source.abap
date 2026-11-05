CLASS zcl_skylint_test_lpguard DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_skylint_test_lpguard IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    IF lt_tab IS NOT INITIAL.
      LOOP AT lt_tab INTO DATA(lv_val).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    LOOP AT lt_tab INTO DATA(lv_val).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    IF lt_tab IS NOT INITIAL.
      DATA(lv_extra) = 1.
      LOOP AT lt_tab INTO DATA(lv_val).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA lt_other TYPE string_table.
    IF lt_tab IS NOT INITIAL.
      LOOP AT lt_other INTO DATA(lv_val).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) > 0.
      LOOP AT lt_tab INTO DATA(lv_val).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_tab TYPE string_table.
    IF lt_tab IS NOT INITIAL. "#EC NO_LOOP_GUARD
      LOOP AT lt_tab INTO DATA(lv_val).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
