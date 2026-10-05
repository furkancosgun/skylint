CLASS zcl_skylint_test_009 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_009 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    CONCATENATE lv_a lv_b INTO lv_c.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    lv_c = |{ lv_a }{ lv_b }|.
  ENDMETHOD.
ENDCLASS.
