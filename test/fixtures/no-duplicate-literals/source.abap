CLASS zcl_test_no_dup_literals DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_no_dup_literals IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
    lv_text = 'ACTIVE'.
    lv_text = 'ACTIVE'.
    lv_text = 'ACTIVE'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    lv_text = 'ACTIVE'.
    lv_text = 'ACTIVE'.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.
    lv_text = 'AB'.
    lv_text = 'AB'.
    lv_text = 'AB'.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    lv_text = 'ACTIVE'.
    lv_text = 'ACTIVE'.
    lv_text = 'PASSIVE'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE string.
    lv_text = |TEXT|.
    lv_text = |TEXT|.
    lv_text = |TEXT|.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_text  TYPE string.
    DATA lv_value TYPE string.
    lv_text = |{ lv_value }x|.
    lv_text = |{ lv_value }x|.
    lv_text = |{ lv_value }x|.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_text TYPE string.
    lv_text = 'SHARED'.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_text TYPE string.
    lv_text = 'SHARED'.
    lv_text = 'SHARED'.
  ENDMETHOD.
ENDCLASS.
