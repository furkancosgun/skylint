CLASS zcl_test_no_dynamic_stuff DEFINITION PUBLIC FINAL CREATE PUBLIC.
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

CLASS zcl_test_no_dynamic_stuff IMPLEMENTATION.
  METHOD test_001.
    DATA lv_func TYPE string VALUE 'FM_NAME'.
    CALL FUNCTION lv_func.
  ENDMETHOD.

  METHOD test_002.
    CALL FUNCTION 'FM_NAME'.
  ENDMETHOD.

  METHOD test_003.
    DATA lo TYPE REF TO object.
    DATA lv_m TYPE string VALUE 'DO_WORK'.
    CALL METHOD lo->(lv_m).
  ENDMETHOD.

  METHOD test_004.
    DATA lo TYPE REF TO object.
    DATA lv_m TYPE string VALUE 'DO_WORK'.
    CALL METHOD lo->(lv_m).
  ENDMETHOD.

  METHOD test_005.
    DATA lo TYPE REF TO object.
    CALL METHOD lo->do_work.
  ENDMETHOD.

  METHOD test_006.
    FIELD-SYMBOLS <fs> TYPE any.
    ASSIGN COMPONENT 1 OF STRUCTURE sy TO <fs>.
  ENDMETHOD.

  METHOD test_007.
    DATA lo TYPE REF TO object.
    DATA lv_cls TYPE string VALUE 'CL_DEMO'.
    CREATE OBJECT lo TYPE (lv_cls).
  ENDMETHOD.

  METHOD test_008.
    DATA lv_rep TYPE string VALUE 'ZREP'.
    SUBMIT (lv_rep).
  ENDMETHOD.
ENDCLASS.
