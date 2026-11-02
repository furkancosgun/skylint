CLASS zcl_skylint_test_max_jumps DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_max_jumps IMPLEMENTATION.
  METHOD test_001.
    DATA lv_idx TYPE i.
    DO 10 TIMES.
      IF lv_idx = 1.
        CONTINUE.
      ENDIF.
      IF lv_idx = 2.
        EXIT.
      ENDIF.
      IF lv_idx = 3.
        CONTINUE.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_idx TYPE i.
    DO 10 TIMES.
      IF lv_idx = 1.
        CONTINUE.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DO 5 TIMES.
      IF lv_a = 1.
        CONTINUE.
      ENDIF.
      DO 5 TIMES.
        IF lv_b = 2.
          EXIT.
        ENDIF.
      ENDDO.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
