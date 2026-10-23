CLASS zcl_test_identical_contents DEFINITION
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
    METHODS test_008.
ENDCLASS.


CLASS zcl_test_identical_contents IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSE.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSE.
      lv_a = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
      lv_a = 3.
    ELSE.
      lv_a = 4.
      lv_a = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSEIF lv_a = 2.
      lv_a = 2.
    ELSE.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSEIF lv_a = 2.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
      lv_a = 3.
    ELSEIF lv_a = 2.
      lv_a = 4.
      lv_a = 3.
    ELSE.
      lv_a = 5.
      lv_a = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      IF lv_b = 1.
        lv_a = 2.
      ELSE.
        lv_a = 2.
      ENDIF.
    ELSE.
      lv_a = 3.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
