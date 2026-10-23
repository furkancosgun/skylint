CLASS zcl_test_pref_is_initial DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
ENDCLASS.

CLASS zcl_test_pref_is_initial IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) > 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) >= 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) <> 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_str TYPE string.
    IF lv_str = ''.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_str TYPE string.
    IF lv_str <> ''.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_str TYPE string.
    IF lv_str = space.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_num TYPE i.
    IF lv_num = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_tab TYPE string_table.
    IF lt_tab IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_tab TYPE string_table.
    IF lines( lt_tab ) > 5.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
