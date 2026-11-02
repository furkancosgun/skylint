CLASS zcl_skylint_test_max_elseif DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_max_elseif IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i VALUE 1.
    IF lv_val = 1.
      CLEAR lv_val.
    ELSEIF lv_val = 2.
      CLEAR lv_val.
    ELSEIF lv_val = 3.
      CLEAR lv_val.
    ELSEIF lv_val = 4.
      CLEAR lv_val.
    ELSEIF lv_val = 5.
      CLEAR lv_val.
    ELSEIF lv_val = 6.
      CLEAR lv_val.
    ELSEIF lv_val = 7.
      CLEAR lv_val.
    ELSE.
      CLEAR lv_val.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i VALUE 1.
    IF lv_val = 1.
      CLEAR lv_val.
    ELSEIF lv_val = 2.
      CLEAR lv_val.
    ELSE.
      CLEAR lv_val.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i VALUE 1.
    DATA lv_b TYPE i VALUE 2.
    IF lv_a = 1.
      IF lv_b = 1.
        CLEAR lv_b.
      ELSEIF lv_b = 2.
        CLEAR lv_b.
      ELSE.
        CLEAR lv_b.
      ENDIF.
    ELSEIF lv_a = 2.
      CLEAR lv_a.
    ELSE.
      CLEAR lv_a.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
