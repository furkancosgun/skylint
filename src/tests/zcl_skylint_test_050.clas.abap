CLASS zcl_skylint_test_050 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_050 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    lv_val = 42.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_val TYPE i.
    IF lv_val > 100.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS c_limit TYPE i VALUE 10.
    DATA lv_val TYPE i.
    lv_val = c_limit.
  ENDMETHOD.
ENDCLASS.

