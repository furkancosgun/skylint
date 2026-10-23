CLASS zcl_test_prefer_new_operator DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_prefer_new_operator IMPLEMENTATION.
  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    DATA lv_cls TYPE string.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_other TYPE REF TO zcl_test_prefer_new_operator.
    CREATE OBJECT lo_other.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_test_prefer_new_operator.
    lo_obj = NEW #( ).
  ENDMETHOD.

  METHOD test_005.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_006.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.
ENDCLASS.
