CLASS zcl_skylint_test_021 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_021 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a EQ lv_b.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = lv_b.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_c NE lv_d.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_c <> lv_d.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

