CLASS zcl_test_no_chained_assign DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
             val1 TYPE i,
             val2 TYPE i,
           END OF ty_data.

    METHODS compute
      IMPORTING iv_x TYPE i
                iv_y TYPE i
      RETURNING VALUE(rv_res) TYPE i.

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

CLASS zcl_test_no_chained_assign IMPLEMENTATION.
  METHOD compute.
    rv_res = iv_x + iv_y.
  ENDMETHOD.

  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    lv_a = lv_b = lv_c.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    lv_a = lv_b = '('.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE string.
    lv_a = '('.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b = ( 1 + 2 ).
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    lv_a = lv_b = lv_c = lv_d = 100.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i VALUE 5.
    DATA lv_d TYPE i VALUE 10.
    lv_a = lv_b = ( ( lv_c * 2 ) + ( lv_d - 5 ) ).
  ENDMETHOD.

  METHOD test_008.
    DATA ls_data TYPE ty_data.
    DATA lv_a    TYPE i VALUE 5.
    ls_data-val1 = ls_data-val2 = ( lv_a + 10 ).
  ENDMETHOD.

  METHOD test_009.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    lv_a = lv_b = |value = (test)|.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    lv_a = lv_b = 'SELECT * WHERE id = 1'.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_a    TYPE i VALUE 10.
    DATA lv_bool TYPE abap_bool.
    " Negative: single assignment with comparison inside parentheses
    lv_bool = xsdbool( lv_a = 10 ).
  ENDMETHOD.

  METHOD test_012.
    DATA lv_a TYPE i.
    " Negative: method call with named parameters inside parentheses
    lv_a = compute( iv_x = 1
                    iv_y = 2 ).
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a    TYPE i VALUE 5.
    DATA lv_b    TYPE i VALUE 3.
    DATA lv_bool TYPE abap_bool.
    " Negative: nested parenthesized comparison expression
    lv_bool = xsdbool( ( lv_a + 1 ) = ( lv_b * 2 ) ).
  ENDMETHOD.
ENDCLASS.
