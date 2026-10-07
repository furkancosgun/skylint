CLASS zcl_skylint_test_019 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_019 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    DATA lv_type TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    ENDCASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    DATA lv_type TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 2.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    DATA lv_type TYPE i.
    CASE lv_type.
    WHEN OTHERS.
    lv_x = 1.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_type TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 2.
    lv_x = 2.
    WHEN 3.
    lv_x = 3.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

