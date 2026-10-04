CLASS zcl_skylint_test_046 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_046 IMPLEMENTATION.
  METHOD with_finding.
    SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara.
  ENDMETHOD.

  METHOD clean_code.
    SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara ORDER BY matnr.
  ENDMETHOD.
ENDCLASS.
