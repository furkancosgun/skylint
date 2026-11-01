CLASS zcl_skylint_test_hardcoded_ip DEFINITION
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

ENDCLASS.


CLASS zcl_skylint_test_hardcoded_ip IMPLEMENTATION.
  METHOD test_001.
    DATA lv_ip TYPE string VALUE '192.168.1.100'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_host TYPE string.
    lv_host = `10.20.30.40:8080`.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_ip TYPE string.
    lv_ip = |2001:0db8:85a3:0000:0000:8a2e:0370:7334|.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_version TYPE string VALUE '1.2.3'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_host TYPE string VALUE 'api.skylint.org'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_dest TYPE string VALUE 'SKYLINT_DEST'.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_ip TYPE string VALUE '172.16.0.1'. "#EC NO_HARDCODED_IP
  ENDMETHOD.
ENDCLASS.
