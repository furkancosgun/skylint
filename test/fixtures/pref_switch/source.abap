CLASS zcl_skylint_test_pref_switch DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_pref_switch IMPLEMENTATION.

  METHOD test_001.
    DATA lv_status TYPE c LENGTH 1 VALUE 'O'.
    DATA lv_text   TYPE string.

    CASE lv_status.
      WHEN 'O'.
        lv_text = 'Open'.
      WHEN 'C'.
        lv_text = 'Closed'.
      WHEN OTHERS.
        lv_text = 'Unknown'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_status TYPE c LENGTH 1 VALUE 'O'.
    DATA lv_text   TYPE string.
    DATA lv_count  TYPE i.

    " Compliant: multiple statements in WHEN branch
    CASE lv_status.
      WHEN 'O'.
        lv_text = 'Open'.
        lv_count = 1.
      WHEN OTHERS.
        lv_text = 'Other'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_status TYPE c LENGTH 1 VALUE 'O'.
    DATA lv_text   TYPE string.

    " Suppressed via pseudo comment
    CASE lv_status. "#EC PREF_SWITCH
      WHEN 'O'.
        lv_text = 'Open'.
      WHEN OTHERS.
        lv_text = 'Other'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_status TYPE c LENGTH 1 VALUE 'O'.
    DATA lv_text   TYPE string.

    " Compliant: already using SWITCH #( )
    lv_text = SWITCH #( lv_status
      WHEN 'O' THEN 'Open'
      WHEN 'C' THEN 'Closed'
      ELSE 'Unknown' ).
  ENDMETHOD.

ENDCLASS.
