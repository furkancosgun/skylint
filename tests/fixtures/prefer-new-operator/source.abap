CLASS zcl_skylint_test_022 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_022 IMPLEMENTATION.
  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    DATA lv_cls TYPE string.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_other TYPE REF TO zcl_skylint_test_022.
    CREATE OBJECT lo_other.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_skylint_test_022.
    lo_obj = NEW #( ).
  ENDMETHOD.
ENDCLASS.
