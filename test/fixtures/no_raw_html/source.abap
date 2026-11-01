CLASS zcl_skylint_test_raw_html DEFINITION
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


CLASS zcl_skylint_test_raw_html IMPLEMENTATION.
  METHOD test_001.
    DATA lv_tag TYPE string VALUE '<script>alert(1)</script>'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_html TYPE string.
    lv_html = `<div><span>Hello</span></div>`.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_table TYPE string.
    lv_table = |<table><tr><td>Data</td></tr></table>|.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string VALUE 'Comparison: a < b and c > d'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_xml TYPE string VALUE '<OrderHeader id="123"/>'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_msg TYPE string VALUE 'Operation successful'.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_html TYPE string VALUE '<iframe src="test"></iframe>'. "#EC NO_RAW_HTML
  ENDMETHOD.
ENDCLASS.
