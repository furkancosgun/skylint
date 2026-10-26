CLASS zcl_test_no_kernel_call DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_kernel_call IMPLEMENTATION.
  METHOD test_001.
    DATA lo TYPE REF TO object.
    SYSTEM-CALL OBJMGR CLONE lo TO lo.
  ENDMETHOD.

  METHOD test_002.
    CALL 'C_DIR_READ_FINISH'.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_d TYPE d.
    EXEC SQL.
      SELECT SYSDATE INTO :lv_d FROM DUAL;
    ENDEXEC.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
