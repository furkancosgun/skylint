CLASS zcl_skylint_test_pref_switch DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
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

  METHOD test_005.
    TYPES: BEGIN OF ty_data,
             text TYPE string,
           END OF ty_data.
    DATA ls_data TYPE ty_data.
    DATA lv_status TYPE c LENGTH 1 VALUE 'O'.

    CASE lv_status.
      WHEN 'O'.
        ls_data-text = 'Open'.
      WHEN 'C'.
        ls_data-text = 'Closed'.
      WHEN OTHERS.
        ls_data-text = 'Unknown'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_code TYPE c LENGTH 1 VALUE 'A'.
    DATA lv_desc TYPE string.

    " Multiple values in WHEN with OR
    CASE lv_code.
      WHEN 'A' OR 'B'.
        lv_desc = 'Alpha'.
      WHEN 'C' OR 'D'.
        lv_desc = 'Beta'.
      WHEN OTHERS.
        lv_desc = 'Other'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_idx    TYPE i VALUE 1.
    DATA lv_factor TYPE i VALUE 10.
    DATA lv_res    TYPE i.

    " Parenthesized RHS arithmetic expressions
    CASE lv_idx.
      WHEN 1.
        lv_res = ( lv_factor * 2 ).
      WHEN 2.
        lv_res = ( lv_factor + 50 ).
      WHEN OTHERS.
        lv_res = 0.
    ENDCASE.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_code TYPE string VALUE 'open'.
    DATA lv_out  TYPE string.

    " Method call expression in CASE operand
    CASE to_upper( lv_code ).
      WHEN 'OPEN'.
        lv_out = 'O'.
      WHEN 'CLOSED'.
        lv_out = 'C'.
      WHEN OTHERS.
        lv_out = '?'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_009.
    TYPES: BEGIN OF ty_item,
             val TYPE i,
           END OF ty_item.
    DATA ls_item TYPE ty_item.
    DATA lv_key  TYPE i VALUE 2.
    DATA lv_base TYPE i VALUE 100.

    " Structure component targets with parenthesized expressions
    CASE lv_key.
      WHEN 1.
        ls_item-val = ( lv_base + 10 ).
      WHEN 2.
        ls_item-val = ( lv_base * 3 ).
      WHEN OTHERS.
        ls_item-val = 0.
    ENDCASE.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_code TYPE c LENGTH 1 VALUE 'A'.
    DATA lv_desc TYPE string.

    " CASE without WHEN OTHERS
    CASE lv_code.
      WHEN 'A'.
        lv_desc = 'First'.
      WHEN 'B'.
        lv_desc = 'Second'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_code TYPE c LENGTH 1 VALUE 'A'.
    DATA lv_res1 TYPE string.
    DATA lv_res2 TYPE string.

    " Negative case: different target variables in WHEN branches
    CASE lv_code.
      WHEN 'A'.
        lv_res1 = 'First'.
      WHEN 'B'.
        lv_res2 = 'Second'.
      WHEN OTHERS.
        lv_res1 = 'Other'.
    ENDCASE.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_code TYPE c LENGTH 1 VALUE 'A'.
    DATA lv_res  TYPE string.

    " Negative case: non-assignment statement in branch
    CASE lv_code.
      WHEN 'A'.
        RETURN.
      WHEN OTHERS.
        lv_res = 'Default'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
