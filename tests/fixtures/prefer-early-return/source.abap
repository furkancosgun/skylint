CLASS zcl_test_prefer_early_return DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_prefer_early_return IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ELSE.
    ls_val = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_other TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_other = abap_false.
      ls_val = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    ls_val = 0.
    IF lv_flag = abap_true.
      ls_val = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

