CLASS zcl_test_no_static_via_instanc DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS do_work.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_static_via_instanc IMPLEMENTATION.
  METHOD do_work.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_no_static_via_instanc.
    lo_obj->do_work( ).
  ENDMETHOD.

  METHOD test_002.
    zcl_test_no_static_via_instanc=>do_work( ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_obj TYPE REF TO zcl_test_no_static_via_instanc.
    CALL METHOD lo_obj->do_work.
  ENDMETHOD.

  METHOD test_004.
    CALL METHOD zcl_test_no_static_via_instanc=>do_work.
  ENDMETHOD.
ENDCLASS.
