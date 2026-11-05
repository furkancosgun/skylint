CLASS zcl_skylint_test_complex_arg DEFINITION.
  PUBLIC SECTION.
    METHODS test_001
      IMPORTING
        iv_param TYPE any OPTIONAL
        iv_val   TYPE any OPTIONAL
      RETURNING
        VALUE(ro_self) TYPE REF TO zcl_skylint_test_complex_arg.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_skylint_test_complex_arg IMPLEMENTATION.
  METHOD test_001.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lo_factory TYPE REF TO zcl_skylint_test_complex_arg.
    lo_service->test_001( ).
  ENDMETHOD.

  METHOD test_002.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lo_a TYPE REF TO zcl_skylint_test_complex_arg.
    lo_service->test_001( iv_param = lo_a->test_001( ) ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lo_a TYPE REF TO zcl_skylint_test_complex_arg.
    lo_service->test_001( iv_param = lo_a->test_001( )->test_001( ) ).
  ENDMETHOD.

  METHOD test_004.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lv_ok TYPE abap_bool.
    lo_service->test_001( iv_val = COND #( WHEN lv_ok = abap_true THEN 1 ELSE 2 ) ).
  ENDMETHOD.

  METHOD test_005.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lo_a TYPE REF TO zcl_skylint_test_complex_arg.
    lo_service->test_001( iv_param = lo_a->test_001( )->test_001( ) ). "#EC NO_COMPLEX_ARG
  ENDMETHOD.

  METHOD test_006.
    DATA lo_service TYPE REF TO zcl_skylint_test_complex_arg.
    DATA lv_num TYPE i VALUE 10.
    lo_service->test_001( iv_val = lv_num + 5 ).
  ENDMETHOD.
ENDCLASS.
