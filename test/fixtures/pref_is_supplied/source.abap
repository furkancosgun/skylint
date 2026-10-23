CLASS zcl_test_prefer_is_supplied DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001 EXPORTING ev_name TYPE string.
    METHODS test_002 IMPORTING iv_name TYPE string OPTIONAL.
    METHODS test_003 EXPORTING ev_name TYPE string.
ENDCLASS.

CLASS zcl_test_prefer_is_supplied IMPLEMENTATION.
  METHOD test_001.
    IF ev_name IS REQUESTED.
      ev_name = 'X'.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    IF iv_name IS SUPPLIED.
      WRITE iv_name.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    IF NOT ev_name IS REQUESTED.
      ev_name = 'X'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
