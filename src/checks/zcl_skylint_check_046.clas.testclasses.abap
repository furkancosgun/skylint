CLASS ltcl_check_046 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_046 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_046( )
        it_source   = VALUE #( ( `SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_046=>c_finding_codes-missing_order_by ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_046( )
        it_source = VALUE #( ( `SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara ORDER BY matnr.` ) ) ).
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
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy UP TO 1 ROWS INTO TABLE @lt_tab ORDER BY field1.
  ENDMETHOD.
ENDCLASS.
