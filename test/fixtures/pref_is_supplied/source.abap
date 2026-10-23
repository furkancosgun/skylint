CLASS zcl_test_prefer_is_supplied DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001 IMPORTING iv_name TYPE string OPTIONAL.
    METHODS test_002 IMPORTING iv_name TYPE string OPTIONAL.
    METHODS test_003 IMPORTING iv_name TYPE string OPTIONAL.
ENDCLASS.

CLASS zcl_test_prefer_is_supplied IMPLEMENTATION.
  METHOD test_001.
    IF iv_name IS REQUESTED.
      WRITE iv_name.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    IF iv_name IS SUPPLIED.
      WRITE iv_name.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    IF iv_name IS NOT REQUESTED.
      WRITE iv_name.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
