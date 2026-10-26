CLASS zcl_test_prefer_case DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
             status TYPE c LENGTH 1,
           END OF ty_data.

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
ENDCLASS.

CLASS zcl_test_prefer_case IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    IF lv_val = 1.
      lv_val = 10.
    ELSEIF lv_val = 2.
      lv_val = 20.
    ELSEIF lv_val = 3.
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 10.
    ELSEIF lv_b = 2.
      lv_b = 20.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_val TYPE i.
    IF ( lv_val = 1 ).
      lv_val = 10.
    ELSEIF ( lv_val = 2 ).
      lv_val = 20.
    ELSEIF ( lv_val = 3 ).
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val   TYPE i.
    DATA lv_other TYPE i.
    IF lv_val = 1 AND lv_other = 1.
      lv_val = 10.
    ELSEIF lv_val = 2 AND lv_other = 2.
      lv_val = 20.
    ELSEIF lv_val = 3 AND lv_other = 3.
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA ls_data TYPE ty_data.
    IF ls_data-status = 'A'.
      ls_data-status = 'X'.
    ELSEIF ls_data-status = 'B'.
      ls_data-status = 'Y'.
    ELSEIF ls_data-status = 'C'.
      ls_data-status = 'Z'.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_val TYPE i.
    IF ( ( lv_val = 1 ) ).
      lv_val = 10.
    ELSEIF ( ( lv_val = 2 ) ).
      lv_val = 20.
    ELSEIF ( ( lv_val = 3 ) ).
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    CONSTANTS c_stat_open TYPE c LENGTH 1 VALUE 'O'.
    CONSTANTS c_stat_done TYPE c LENGTH 1 VALUE 'D'.
    CONSTANTS c_stat_pend TYPE c LENGTH 1 VALUE 'P'.
    DATA lv_status TYPE c LENGTH 1.
    IF ( lv_status EQ c_stat_open ).
      lv_status = 'X'.
    ELSEIF ( lv_status EQ c_stat_done ).
      lv_status = 'Y'.
    ELSEIF ( lv_status EQ c_stat_pend ).
      lv_status = 'Z'.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_type TYPE c LENGTH 1.
    DATA lv_flag TYPE abap_bool.
    IF ( lv_type = 'A' AND lv_flag = abap_true ).
      lv_type = 'X'.
    ELSEIF ( lv_type = 'B' ).
      lv_type = 'Y'.
    ELSEIF ( lv_type = 'C' ).
      lv_type = 'Z'.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF ( lv_a = 1 ).
      lv_a = 10.
    ELSEIF ( lv_b = 2 ).
      lv_b = 20.
    ELSEIF ( lv_c = 3 ).
      lv_c = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_outer TYPE i.
    DATA lv_inner TYPE i.
    IF ( lv_outer = 1 ).
      IF ( lv_inner = 1 ).
        lv_inner = 10.
      ELSEIF ( lv_inner = 2 ).
        lv_inner = 20.
      ELSEIF ( lv_inner = 3 ).
        lv_inner = 30.
      ENDIF.
    ELSEIF ( lv_outer = 2 ).
      lv_outer = 20.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_val  TYPE i.
    DATA lv_base TYPE i.
    IF lv_val = ( lv_base + 1 ).
      lv_val = 10.
    ELSEIF lv_val = ( lv_base + 2 ).
      lv_val = 20.
    ELSEIF lv_val = ( lv_base + 3 ).
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_val TYPE i.
    IF ( lv_val = 1 ). "#EC PREF_CASE
      lv_val = 10.
    ELSEIF ( lv_val = 2 ).
      lv_val = 20.
    ELSEIF ( lv_val = 3 ).
      lv_val = 30.
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_type TYPE c LENGTH 1.
    IF ( lv_type = 'A' OR lv_type = 'B' ).
      lv_type = 'X'.
    ELSEIF ( lv_type = 'C' ).
      lv_type = 'Y'.
    ELSEIF ( lv_type = 'D' ).
      lv_type = 'Z'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
