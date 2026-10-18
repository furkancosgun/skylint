CLASS zcl_skylint_test_hardcoded_env DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.

ENDCLASS.


CLASS zcl_skylint_test_hardcoded_env IMPLEMENTATION.
  METHOD test_001.
    IF sy-sysid = 'PRD'.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    IF '100' = sy-mandt.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    CASE sy-sysid.
      WHEN 'DEV'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    IF sy-host <> 'srv01'.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    IF sy-dbsys = 'HDB'.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_expected_sysid TYPE string VALUE 'PRD'.
    IF sy-sysid = lv_expected_sysid.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    IF sy-sysid = 'PRD'. "#EC HARDCODED_ENV
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_client TYPE string.
    lv_client = sy-mandt.
  ENDMETHOD.

  METHOD test_010.
    IF sy-opsys = 'LINUX'.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    IF sy-uname = 'FURKAN'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
