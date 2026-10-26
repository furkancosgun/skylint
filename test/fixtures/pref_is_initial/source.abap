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
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
    METHODS test_018.
    METHODS test_019.
    METHODS test_020.
    METHODS test_021.
    METHODS test_022.
    METHODS test_023.
    METHODS is_valid
      IMPORTING iv_param TYPE i OPTIONAL
      RETURNING VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.

CLASS zcl_test_pref_is_initial IMPLEMENTATION.
  METHOD is_valid.
    rv_valid = abap_true.
  ENDMETHOD.

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

  METHOD test_012.
    DATA lv_str TYPE string.
    IF ( lv_str = '' ).
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_str TYPE string.
    IF ( lv_str <> '' ).
    ENDIF.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_str TYPE string.
    IF ( lv_str = space ).
    ENDIF.
  ENDMETHOD.

  METHOD test_015.
    DATA lt_tab TYPE string_table.
    IF ( lines( lt_tab ) > 0 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_016.
    DATA lt_tab TYPE string_table.
    IF ( lines( lt_tab ) = 0 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_017.
    DATA lv_str TYPE string.
    DATA lv_num TYPE i.
    IF ( ( lv_str = '' ) AND ( lv_num = 0 ) ).
    ENDIF.
  ENDMETHOD.

  METHOD test_018.
    DATA lt_tab TYPE string_table.
    DATA lv_str TYPE string.
    IF ( ( lines( lt_tab ) = 0 ) AND ( lv_str IS INITIAL ) ).
    ENDIF.
  ENDMETHOD.

  METHOD test_019.
    IF is_valid( iv_param = 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_020.
    IF ( is_valid( ) = abap_true ).
    ENDIF.
  ENDMETHOD.

  METHOD test_021.
    DATA lv_str TYPE string.
    IF ( is_valid( ) = abap_true ) AND ( lv_str = '' ).
    ENDIF.
  ENDMETHOD.

  METHOD test_022.
    DATA lv_str TYPE string.
    IF is_valid( iv_param = 1 ) AND lv_str = ''.
    ENDIF.
  ENDMETHOD.

  METHOD test_023.
    DATA lv_str TYPE string.
    IF ( ( lv_str = '' ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
