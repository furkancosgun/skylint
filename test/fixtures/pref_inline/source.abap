CLASS zcl_test_pref_inline DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_pref_inline IMPLEMENTATION.
  METHOD test_001.
    DATA lv_count TYPE i.
    lv_count = 10.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_data TYPE STANDARD TABLE OF i.
    LOOP AT lt_data INTO DATA(ls_data).
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    IF 1 = 1.
      lv_x = 10.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_y TYPE i.
    WHILE 1 = 2.
      lv_y = 5.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_tab TYPE STANDARD TABLE OF i.
    DATA ls_row TYPE i.
    READ TABLE lt_tab INTO ls_row INDEX 1.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_tab TYPE STANDARD TABLE OF i.
    DATA ls_row TYPE i.
    LOOP AT lt_tab INTO ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_008.
    DATA lx_err TYPE REF TO cx_root.
    TRY.
      CATCH cx_root INTO lx_err.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
