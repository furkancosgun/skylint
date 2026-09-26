CLASS zcl_skylint_test_028 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_028 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_active TYPE abap_bool.
    IF 1 = 2.
      lv_active = abap_true.
    ELSE.
      lv_active = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_active TYPE abap_bool.
    IF 1 = 2. "#EC PREFER_XSDBOOL
      lv_active = abap_true.
    ELSE.
      lv_active = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_active TYPE abap_bool.
    DATA lv_name   TYPE string.

    lv_active = xsdbool( 1 = 2 ).

    IF 1 = 2.
      lv_name = 'FOO'.
    ELSE.
      lv_name = 'BAR'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
