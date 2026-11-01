CLASS zcl_skylint_test_hardcoded_url DEFINITION
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

ENDCLASS.


CLASS zcl_skylint_test_hardcoded_url IMPLEMENTATION.
  METHOD test_001.
    DATA lv_url TYPE string VALUE 'http://api.example.com/data'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_url TYPE string.
    lv_url = `https://myservice.sap.corp:8443/orders`.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_url TYPE string.
    lv_url = |ftp://files.example.com/exports|.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_dest TYPE string VALUE 'SKYLINT_DEST'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_path TYPE string VALUE '/api/v1/orders'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_dest TYPE string VALUE 'MY_RFC_DEST'.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_prefix TYPE string VALUE 'https://'.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_url TYPE string VALUE 'https://api.example.com'. "#EC NO_HARDCODED_URL
  ENDMETHOD.
ENDCLASS.
