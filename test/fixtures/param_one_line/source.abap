CLASS zcl_skylint_test_param_1l DEFINITION.
  PUBLIC SECTION.
    METHODS run IMPORTING iv_name TYPE string iv_age TYPE i.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_param_1l IMPLEMENTATION.
  METHOD run.
  ENDMETHOD.

  METHOD test_001.
    TYPES: BEGIN OF ty_data,
             a TYPE i,
             b TYPE i,
           END OF ty_data.
    DATA ls_data TYPE ty_data.
    ls_data = VALUE #( a = 1 b = 2 ).
  ENDMETHOD.

  METHOD test_002.
    TYPES: BEGIN OF ty_data,
             a TYPE i,
             b TYPE i,
           END OF ty_data.
    DATA ls_data TYPE ty_data.
    ls_data = VALUE #(
        a = 1
        b = 2 ).
  ENDMETHOD.

  METHOD test_003.
    run(
        iv_name = 'Furkan'
        iv_age  = 100 ).
  ENDMETHOD.
ENDCLASS.
