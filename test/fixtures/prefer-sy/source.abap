CLASS zcl_test_prefer_sy DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_test_prefer_sy IMPLEMENTATION.
  METHOD test_001.
    WRITE syst-uname.
  ENDMETHOD.

  METHOD test_002.
    WRITE sy-uname.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_subrc TYPE i.
    lv_subrc = syst-subrc.
  ENDMETHOD.
ENDCLASS.
