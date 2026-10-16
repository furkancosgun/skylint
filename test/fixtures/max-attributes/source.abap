CLASS lcl_god DEFINITION.
  PUBLIC SECTION.
    DATA mv_a1 TYPE i.
    DATA mv_a2 TYPE i.
    DATA mv_a3 TYPE i.
    DATA mv_a4 TYPE i.
    DATA mv_a5 TYPE i.
    DATA mv_a6 TYPE i.
    DATA mv_a7 TYPE i.
    DATA mv_a8 TYPE i.
    DATA mv_a9 TYPE i.
    DATA mv_a10 TYPE i.
    DATA mv_a11 TYPE i.
    DATA mv_a12 TYPE i.
    DATA mv_a13 TYPE i.
    DATA mv_a14 TYPE i.
    DATA mv_a15 TYPE i.
    DATA mv_a16 TYPE i.
    DATA mv_a17 TYPE i.
    DATA mv_a18 TYPE i.
    DATA mv_a19 TYPE i.
    DATA mv_a20 TYPE i.
    DATA mv_a21 TYPE i.
ENDCLASS.
CLASS lcl_god IMPLEMENTATION.
ENDCLASS.

CLASS lcl_small DEFINITION.
  PUBLIC SECTION.
    DATA mv_one TYPE i.
    DATA mv_two TYPE i.
ENDCLASS.
CLASS lcl_small IMPLEMENTATION.
ENDCLASS.

CLASS lcl_static_god DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA gv_a1 TYPE i.
    CLASS-DATA gv_a2 TYPE i.
    CLASS-DATA gv_a3 TYPE i.
    CLASS-DATA gv_a4 TYPE i.
    CLASS-DATA gv_a5 TYPE i.
    CLASS-DATA gv_a6 TYPE i.
ENDCLASS.
CLASS lcl_static_god IMPLEMENTATION.
ENDCLASS.

CLASS zcl_test_max_attributes DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_max_attributes IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD test_003.
    RETURN.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.
