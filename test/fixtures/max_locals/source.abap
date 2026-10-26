CLASS zcl_skylint_test_max_locals DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_skylint_test_max_locals IMPLEMENTATION.
  METHOD test_001.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    lv_01 = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA lv_11 TYPE i.
    DATA lv_12 TYPE i.
    DATA lv_13 TYPE i.
    DATA lv_14 TYPE i.
    DATA lv_15 TYPE i.
    DATA lv_16 TYPE i.
    lv_01 = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA lv_11 TYPE i.
    DATA lv_12 TYPE i.
    DATA lv_13 TYPE i.
    DATA lv_14 TYPE i.
    DATA lv_15 TYPE i.
    DATA lv_16 TYPE i.
    lv_01 = 1.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA lv_11 TYPE i.
    DATA lv_12 TYPE i.
    DATA lv_13 TYPE i.
    DATA lv_14 TYPE i.
    DATA lv_15 TYPE i.
    FIELD-SYMBOLS <ls_01> TYPE i.
    lv_01 = 1.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA lv_11 TYPE i.
    DATA lv_12 TYPE i.
    DATA lv_13 TYPE i.
    DATA lv_14 TYPE i.
    DATA lv_15 TYPE i.
    lv_01 = 1.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA(lv_11) = 1.
    DATA(lv_12) = 2.
    DATA(lv_13) = 3.
    DATA(lv_14) = 4.
    DATA(lv_15) = 5.
    DATA(lv_16) = 6.
  ENDMETHOD.

  METHOD test_007.
    TYPES: BEGIN OF ty_dummy,
             field1 TYPE i,
           END OF ty_dummy.
    CONSTANTS c_const TYPE i VALUE 42.
    DATA lv_01 TYPE i.
    DATA lv_02 TYPE i.
    DATA lv_03 TYPE i.
    DATA lv_04 TYPE i.
    DATA lv_05 TYPE i.
    DATA lv_06 TYPE i.
    DATA lv_07 TYPE i.
    DATA lv_08 TYPE i.
    DATA lv_09 TYPE i.
    DATA lv_10 TYPE i.
    DATA lv_11 TYPE i.
    DATA lv_12 TYPE i.
    DATA lv_13 TYPE i.
    DATA lv_14 TYPE i.
    DATA lv_15 TYPE i.
    lv_01 = c_const.
  ENDMETHOD.
ENDCLASS.
