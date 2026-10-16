CLASS zcl_test_no_like_objects DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_like_objects IMPLEMENTATION.
  METHOD test_001.
    DATA lv_orig TYPE i.
    DATA lv_x LIKE lv_orig.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_y TYPE i.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_orig TYPE i.
    DATA lv_copy LIKE lv_orig.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_z TYPE string.
  ENDMETHOD.

  METHOD test_005.
    DATA like TYPE i.
  ENDMETHOD.
ENDCLASS.
