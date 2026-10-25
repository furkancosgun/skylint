CLASS zcl_test_no_custom_pattern DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_custom_pattern IMPLEMENTATION.
  METHOD test_001.
    DATA lv_todo_item TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_clean_item TYPE i.
    lv_clean_item = 42.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_fixme_var TYPE string.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_todo_suppressed TYPE i. "#EC NO_CUSTOM_PATTERN
  ENDMETHOD.
ENDCLASS.
