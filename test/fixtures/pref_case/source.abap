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
ENDCLASS.
