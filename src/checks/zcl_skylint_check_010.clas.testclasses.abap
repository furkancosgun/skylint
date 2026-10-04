CLASS ltcl_check_010 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_010 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_010( )
        it_source   = VALUE #( ( `IF lo_validator->is_valid( ) = abap_true.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_010=>c_finding_codes-bool_comparison ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_010( )
                                               it_source = VALUE #( ( `IF lo_validator->is_valid( ).` )
                                                                    ( `IF lv_flag = abap_true.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD test_with_finding.
    DATA lo_validator TYPE REF TO lcl_test_code.
    IF lo_validator->is_valid( ) = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lo_validator TYPE REF TO lcl_test_code.
    DATA lv_flag TYPE abap_bool.
    IF lo_validator->is_valid( ).
    ENDIF.
    IF lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
