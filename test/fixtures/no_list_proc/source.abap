CLASS zcl_test_no_list_processing DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_list_processing IMPLEMENTATION.
  METHOD test_001.
    " Non-compliant: WRITE, ULINE, SKIP
    WRITE / 'Output text'.
    ULINE.
    SKIP 2.
  ENDMETHOD.

  METHOD test_002.
    " Compliant: regular OO logic
    DATA lv_text TYPE string.
    lv_text = 'Hello'.
  ENDMETHOD.

  METHOD test_003.
    " Compliant: WRITE ... TO ... formatting (not screen list output)
    DATA lv_date TYPE d VALUE '20261019'.
    DATA lv_out  TYPE c LENGTH 10.
    WRITE lv_date TO lv_out.
  ENDMETHOD.

  METHOD test_004.
    " Non-compliant: other list processing statements
    NEW-LINE.
    NEW-PAGE.
    FORMAT COLOR 1.
  ENDMETHOD.
ENDCLASS.
