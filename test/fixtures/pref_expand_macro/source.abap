CLASS zcl_skylint_test_expand_macros DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_expand_macros IMPLEMENTATION.
  METHOD test_001.
    DEFINE _my_macro.
      lv_a = 1.
    END-OF-DEFINITION.
    _my_macro.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.
ENDCLASS.
