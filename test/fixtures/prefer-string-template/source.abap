CLASS zcl_test_prefer_string_templat DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_prefer_string_templat IMPLEMENTATION.
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

  METHOD test_005.
    DATA lv_x TYPE xstring.
    DATA lv_y TYPE xstring.
    DATA lv_z TYPE xstring.
    CONCATENATE lv_x lv_y INTO lv_z IN BYTE MODE.
  ENDMETHOD.
ENDCLASS.
