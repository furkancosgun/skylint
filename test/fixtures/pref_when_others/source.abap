CLASS zcl_skylint_test_pref_when_others DEFINITION
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
ENDCLASS.

CLASS zcl_skylint_test_pref_when_others IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
      WHEN 2.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
      WHEN OTHERS.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN OTHERS.
        lv_x = 1.
      WHEN 2.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    CASE lv_x.
      WHEN 1.
        lv_x = 1.
    ENDCASE.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    CASE lv_x.
      WHEN 1.
        CASE lv_y.
          WHEN 1.
            lv_y = 1.
          WHEN 2.
            lv_y = 2.
        ENDCASE.
      WHEN OTHERS.
        lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    CASE lv_x.
      WHEN 1.
        CASE lv_y.
          WHEN 1.
            lv_y = 10.
          WHEN OTHERS.
            lv_y = 20.
        ENDCASE.
      WHEN 2.
        lv_x = 20.
    ENDCASE.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_status TYPE c LENGTH 1.
    CASE ( lv_status ).
      WHEN ( 'A' ) OR ( 'B' ).
        lv_status = 'X'.
      WHEN ( 'C' ).
        lv_status = 'Y'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_status TYPE c LENGTH 1.
    CASE ( lv_status ).
      WHEN ( 'A' ).
        lv_status = 'X'.
      WHEN ( 'B' ).
        lv_status = 'Y'.
      WHEN OTHERS.
        lv_status = 'Z'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_009.
    DATA lx_error TYPE REF TO cx_root.
    DATA lv_msg   TYPE string.
    CASE TYPE OF lx_error.
      WHEN TYPE cx_sy_zerodivide.
        lv_msg = 'Div by zero'.
      WHEN TYPE cx_sy_conversion_error.
        lv_msg = 'Conversion error'.
      WHEN OTHERS.
        lv_msg = 'Unknown error'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_010.
    DATA lx_error TYPE REF TO cx_root.
    DATA lv_msg   TYPE string.
    CASE TYPE OF lx_error.
      WHEN TYPE cx_sy_zerodivide.
        lv_msg = 'Div by zero'.
      WHEN TYPE cx_sy_conversion_error.
        lv_msg = 'Conversion error'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    CASE lv_x.
      WHEN 1.
        CASE lv_y.
          WHEN OTHERS.
            lv_y = 10.
          WHEN 1.
            lv_y = 20.
        ENDCASE.
      WHEN OTHERS.
        lv_x = 20.
    ENDCASE.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_x TYPE i.
    CASE lv_x. "#EC PREF_WHEN_OTHERS
      WHEN 1.
        lv_x = 10.
      WHEN 2.
        lv_x = 20.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
