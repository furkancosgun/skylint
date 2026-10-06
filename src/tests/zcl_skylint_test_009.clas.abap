CLASS zcl_skylint_test_009 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
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

  METHOD test_003.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    CONCATENATE lv_a lv_b INTO lv_c SEPARATED BY space.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE string.
    DATA lv_b TYPE string.
    DATA lv_c TYPE string.
    lv_c = lv_a && lv_b.
  ENDMETHOD.
ENDCLASS.
