INTERFACE lif_calc PUBLIC.
  METHODS compute
    IMPORTING iv_val        TYPE i
    RETURNING VALUE(rv_res) TYPE i.
ENDINTERFACE.

CLASS zcl_skylint_test_dup_subexp DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order,
        net TYPE i,
        vat TYPE i,
      END OF ty_order,
      ty_orders TYPE STANDARD TABLE OF ty_order WITH EMPTY KEY.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.

  PRIVATE SECTION.
    DATA lt_orders TYPE ty_orders.
    DATA lo_calc   TYPE REF TO lif_calc.
ENDCLASS.

CLASS zcl_skylint_test_dup_subexp IMPLEMENTATION.
  METHOD test_001.
    DATA lv_total TYPE i.
    lv_total = lt_orders[ 1 ]-net + lt_orders[ 1 ]-vat.
  ENDMETHOD.

  METHOD test_002.
    DATA ls_order TYPE ty_order.
    DATA lv_total TYPE i.
    ls_order = lt_orders[ 1 ].
    lv_total = ls_order-net + ls_order-vat.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_val TYPE i.
    lv_val = lo_calc->compute( 10 ) + lo_calc->compute( 10 ).
  ENDMETHOD.

  METHOD test_004.
    DATA lv_total TYPE i.
    DATA lv_val   TYPE i.
    lv_total = lt_orders[ 1 ]-net + lt_orders[ 2 ]-vat.
    lv_val = lo_calc->compute( 10 ) + lo_calc->compute( 20 ).
  ENDMETHOD.

  METHOD test_005.
    DATA lv_total TYPE i.
    lv_total = lt_orders[ 1 ]-net + lt_orders[ 1 ]-vat. "#EC NO_DUP_SUBEXPR
  ENDMETHOD.
ENDCLASS.
