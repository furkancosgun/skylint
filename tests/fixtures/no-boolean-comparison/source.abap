CLASS zcl_skylint_test_010 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS zcl_skylint_test_010 IMPLEMENTATION.
  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD test_001.
    DATA lo_validator TYPE REF TO zcl_skylint_test_010.
    IF lo_validator->is_valid( ) = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_validator TYPE REF TO zcl_skylint_test_010.
    DATA lv_flag TYPE abap_bool.
    IF lo_validator->is_valid( ).
    ENDIF.
    IF lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lo_validator TYPE REF TO zcl_skylint_test_010.
    WHILE lo_validator->is_valid( ) <> abap_false.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_validator TYPE REF TO zcl_skylint_test_010.
    WHILE lo_validator->is_valid( ).
    ENDWHILE.
  ENDMETHOD.

  METHOD test_005.
    DATA space TYPE string.
    DATA ne TYPE i.
    DATA lv_x TYPE i.
    IF lv_x = space.
    ENDIF.
    IF lv_x = ne.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
