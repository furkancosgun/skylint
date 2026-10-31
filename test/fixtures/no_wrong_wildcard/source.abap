CLASS zcl_test_no_wrong_wildcard DEFINITION.
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

CLASS zcl_test_no_wrong_wildcard IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
    SELECT SINGLE carrid FROM scarr WHERE carrid LIKE '*LH*' INTO @lv_text.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    SELECT SINGLE carrid FROM scarr WHERE carrid LIKE '%LH%' INTO @lv_text.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.
    IF lv_text CP 'prefix%'.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    IF lv_text CP 'prefix*'.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE string.
    IF lv_text NP 'prefix%'.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_text TYPE string.
    IF lv_text NP 'prefix*'.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_text TYPE string.
    IF lv_text CP 'prefix%'. "#EC NO_WRONG_WILDCARD
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_text TYPE string.
    DATA lv_pattern TYPE string.
    IF lv_text CP lv_pattern.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
