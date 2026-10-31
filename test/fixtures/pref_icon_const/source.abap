CLASS lcl_test DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS lcl_test IMPLEMENTATION.
  METHOD test_001.
    DATA lv_icon TYPE c LENGTH 4 VALUE '@01@'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_icon TYPE c LENGTH 4.
    lv_icon = '@BZ@'.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_icon TYPE string.
    lv_icon = `@5B@`.
  ENDMETHOD.

  METHOD test_004.
    CONSTANTS lc_icon TYPE c LENGTH 4 VALUE 'OKAY'.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE string VALUE 'email@test.com'.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_icon TYPE c LENGTH 4 VALUE '@01@'. "#EC PREF_ICON_CONST
  ENDMETHOD.
ENDCLASS.
