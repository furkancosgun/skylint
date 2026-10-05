CLASS ltcl_check_064 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_064 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_064( )
        it_source   = VALUE #( ( `READ TABLE lt_tab INDEX 1.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_064=>c_finding_codes-check_subrc ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_064( )
                                               it_source = VALUE #( ( `READ TABLE lt_tab INDEX 1.` )
                                                                    ( `IF sy-subrc = 0.` )
                                                                    ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
