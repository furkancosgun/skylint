CLASS zcl_test_prefer_msg_cls DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_prefer_msg_cls IMPLEMENTATION.
  METHOD test_001.
    MESSAGE 'Something went wrong' TYPE 'E'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    MESSAGE lv_text TYPE 'S'.
  ENDMETHOD.

  METHOD test_003.
    MESSAGE e001(00).
  ENDMETHOD.

  METHOD test_004.
    MESSAGE ID '00' TYPE 'E' NUMBER '001'.
  ENDMETHOD.

  METHOD test_006.
    MESSAGE 'Error' TYPE 'E' DISPLAY LIKE 'S'.
  ENDMETHOD.
ENDCLASS.
