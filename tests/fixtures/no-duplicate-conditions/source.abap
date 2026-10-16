CLASS zcl_test_no_duplicate_conditio DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_no_duplicate_conditio IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 1.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 2.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_type TYPE i.
    DATA lv_x TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 1.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_type TYPE i.
    DATA lv_x TYPE i.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 2.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

