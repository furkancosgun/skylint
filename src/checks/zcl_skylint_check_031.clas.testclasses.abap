CLASS ltcl_check_031 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_031 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_031( )
        it_source   = VALUE #( ( `SELECT * FROM t INTO TABLE r FOR ALL ENTRIES IN s WHERE f = s-f.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_031=>c_finding_codes-unsecure_fae ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_031( )
        it_source = VALUE #( ( `IF s IS NOT INITIAL.` )
                             ( `SELECT * FROM t INTO TABLE r FOR ALL ENTRIES IN s WHERE f = s-f.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_entry,
        field1 TYPE c LENGTH 10,
      END OF ty_entry.
    TYPES tt_entry TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN s WHERE field1 = s-field1.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA s TYPE tt_entry.
    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
    IF s IS NOT INITIAL.
      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN s WHERE field1 = s-field1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
