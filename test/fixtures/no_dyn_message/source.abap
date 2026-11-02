CLASS zcl_test_no_dyn_message DEFINITION.
  PUBLIC SECTION.
    DATA lv_text  TYPE string.
    DATA lv_msgid TYPE symsgid.
    DATA lv_msgty TYPE symsgty.
    DATA lv_msgno TYPE symsgno.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_test_no_dyn_message IMPLEMENTATION.

  METHOD test_001.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO lv_text.
  ENDMETHOD.

  METHOD test_002.
    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '001' INTO lv_text.
  ENDMETHOD.

  METHOD test_003.
    MESSAGE ID 'ZMSG' TYPE lv_msgty NUMBER '001' INTO lv_text.
  ENDMETHOD.

  METHOD test_004.
    MESSAGE 'oops' TYPE 'E'.
  ENDMETHOD.

  METHOD test_005.
    MESSAGE e001(ad) INTO lv_text.
  ENDMETHOD.

  METHOD test_006.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO lv_text. "#EC NO_DYN_MESSAGE
  ENDMETHOD.

ENDCLASS.
