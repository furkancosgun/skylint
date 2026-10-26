CLASS zcl_test_prefer_calc_assign_op DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
             count TYPE i,
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
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
ENDCLASS.

CLASS zcl_test_prefer_calc_assign_op IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    lv_x = lv_x + 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 10.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_num TYPE i.
    SUBTRACT 1 FROM lv_num.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_x = lv_y + 1.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_x TYPE i.
    lv_x = lv_x + ( 2 * 3 ).
  ENDMETHOD.

  METHOD test_006.
    DATA ls_data TYPE ty_data.
    ls_data-count = ls_data-count + 1.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_x TYPE i VALUE 10.
    lv_x = lv_x - 1.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_x TYPE i VALUE 10.
    lv_x = lv_x * 2.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_x TYPE i VALUE 10.
    lv_x = lv_x / 5.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_x TYPE i VALUE 10.
    ADD 5 TO lv_x.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_x TYPE i VALUE 10.
    MULTIPLY lv_x BY 2.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_x TYPE i VALUE 10.
    DIVIDE lv_x BY 4.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_count TYPE i VALUE 10.
    DATA lv_step  TYPE i VALUE 2.
    lv_count = lv_count + ( ( lv_step * 2 ) - 1 ).
  ENDMETHOD.

  METHOD test_014.
    DATA ls_data TYPE ty_data.
    DATA lv_step TYPE i VALUE 2.
    ls_data-count = ls_data-count - ( lv_step * 2 ).
  ENDMETHOD.

  METHOD test_015.
    DATA lv_x TYPE i VALUE 10.
    " Negative: LHS is not the first operand of addition
    lv_x = 10 + lv_x.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_str TYPE string VALUE 'hello'.
    " Negative: string concatenation operator is not calculation operator
    lv_str = lv_str && ' world'.
  ENDMETHOD.
ENDCLASS.
