CLASS zcl_skylint_test_025 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS run
      IMPORTING iv_in TYPE i OPTIONAL
      RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS zcl_skylint_test_025 IMPLEMENTATION.
  METHOD run.
    rv_val = iv_in.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_obj TYPE REF TO zcl_skylint_test_025.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_obj TYPE REF TO zcl_skylint_test_025.
    DATA lv_x TYPE i.
    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x.
  ENDMETHOD.
ENDCLASS.
