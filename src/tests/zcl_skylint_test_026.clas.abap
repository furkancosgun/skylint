CLASS zcl_skylint_test_026 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS do_work.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_026 IMPLEMENTATION.
  METHOD do_work.
    RETURN.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_026.
    lo_obj->do_work( ).
  ENDMETHOD.

  METHOD test_002.
    zcl_skylint_test_026=>do_work( ).
  ENDMETHOD.
ENDCLASS.
