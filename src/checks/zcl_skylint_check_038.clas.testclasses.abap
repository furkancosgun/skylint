CLASS ltcl_check_038 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_038 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_038( )
        it_source   = VALUE #( ( `MOVE-CORRESPONDING ls_src TO ls_dst.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_038=>c_finding_codes-prefer_corresponding ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_038( )
                                               it_source = VALUE #( ( `ls_dst = CORRESPONDING #( ls_src ).` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    MOVE-CORRESPONDING ls_src TO ls_dst.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.
    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.
    ls_dst = CORRESPONDING #( ls_src ).
  ENDMETHOD.
ENDCLASS.
