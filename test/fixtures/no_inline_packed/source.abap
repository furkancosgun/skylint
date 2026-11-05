CLASS zcl_skylint_test_packed DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_packed IMPLEMENTATION.
  METHOD test_001.
    DATA lv_p TYPE p DECIMALS 2.
    DATA(lv_res) = lv_p * 10 / 3.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_p TYPE p DECIMALS 2.
    DATA(lv_res) = lv_p + 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_p TYPE p DECIMALS 2.
    DATA(lv_res) = lv_p.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_p TYPE p DECIMALS 2.
    DATA(lv_res) = CONV decfloat34( lv_p * 10 / 3 ).
  ENDMETHOD.

  METHOD test_005.
    DATA lv_p TYPE p DECIMALS 2.
    DATA(lv_res) = lv_p * 10 / 3. "#EC NO_INLINE_PACKED
  ENDMETHOD.
ENDCLASS.
