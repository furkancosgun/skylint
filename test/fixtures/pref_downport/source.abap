CLASS zcl_skylint_test_downport DEFINITION.
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
    METHODS test_013.
    METHODS test_014.
    METHODS test_015.
    METHODS test_shadow_new.
    METHODS get_self RETURNING VALUE(ro_self) TYPE REF TO zcl_skylint_test_downport.
    METHODS test_with_args IMPORTING iv_val TYPE i.
ENDCLASS.

CLASS zcl_skylint_test_downport IMPLEMENTATION.

  METHOD get_self.
    ro_self = me.
  ENDMETHOD.

  METHOD test_with_args.
  ENDMETHOD.

  METHOD test_001.
    DATA new TYPE i.
    DATA lv_text TYPE string.
    DATA lt_data TYPE string_table.

    " Compliant: default attributes are all abap_false
    new = 1.
    new += 2.
    lt_data = VALUE string_table( ( |Line: { new }| ) ).
    lt_data = VALUE #( ( `Item` ) ).
  ENDMETHOD.

  METHOD test_002.
    DATA lv_num TYPE i.

    " Compliant: classic ABAP 7.02 compliant
    lv_num = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_text TYPE string.

    " Suppressed via pseudo comment
    lv_text = VALUE #( ). "#EC PREF_DOWNPORT
  ENDMETHOD.

  METHOD test_004.
    DATA lo_obj TYPE REF TO zcl_skylint_test_downport.
    DATA lo_cast TYPE REF TO zcl_skylint_test_downport.
    DATA lt_data TYPE string_table.
    DATA lv_num TYPE i.
    DATA lr_ref TYPE REF TO data.

    " Flagged: Constructor expressions
    lt_data = VALUE string_table( ).
    lo_obj = NEW zcl_skylint_test_downport( ).
    lv_num = COND i( WHEN 1 = 1 THEN 10 ELSE 20 ).
    lv_num = CONV i( '42' ).
    lv_num = EXACT i( 10 ).
    lr_ref = REF #( lv_num ).
    lo_cast = CAST zcl_skylint_test_downport( lo_obj ).
  ENDMETHOD.

  METHOD test_shadow_new.
    DATA new TYPE i.

    " Compliant: variable named new is not a constructor expression
    new = 5.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_data TYPE string_table.
    DATA lv_val TYPE string.

    " Flagged: Table expressions
    lv_val = lt_data[ 1 ].
    lt_data[ 1 ] = 'Updated'.

    " Compliant: classic read table
    READ TABLE lt_data INDEX 1 INTO lv_val.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_data TYPE string_table.
    DATA lv_classic TYPE i.

    " Flagged: Inline declarations
    DATA(lv_inline) = 1.
    DATA(lv_final) = 2.
    ASSIGN lt_data[ 1 ] TO FIELD-SYMBOL(<fs_line>).

    " Compliant: classic declaration
    lv_classic = 10.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_text TYPE string.
    DATA lv_num TYPE i.

    " Flagged: String template
    lv_text = |Hello { lv_num }|.

    " Compliant: CONCATENATE
    CONCATENATE 'Hello ' 'world' INTO lv_text.
  ENDMETHOD.

  METHOD test_008.
    DATA lo_obj TYPE REF TO zcl_skylint_test_downport.

    " Flagged: Method chaining
    lo_obj->get_self( )->test_001( ).

    " Compliant: Single method call
    lo_obj->test_001( ).

    " Compliant: Multiple independent calls, NOT chaining
    IF lo_obj->get_self( ) = lo_obj->get_self( ).
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    " Flagged: WITH EMPTY KEY
    DATA lt_empty TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    " Compliant: WITH DEFAULT KEY
    DATA lt_def TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_num TYPE i.
    DATA lv_text TYPE string.

    " Flagged: Calculation assignments
    lv_num += 1.
    lv_text &&= 'suffix'.

    " Compliant: Classic assignment
    lv_num = lv_num + 1.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_data TYPE string_table.
    DATA lv_idx TYPE i.

    " Flagged: line_exists and line_index
    IF line_exists( lt_data[ 1 ] ).
      lv_idx = line_index( lt_data[ table_line = 'A' ] ).
    ENDIF.

    " Compliant: lines( )
    lv_idx = lines( lt_data ).
  ENDMETHOD.

  METHOD test_012.
    DATA lt_data TYPE STANDARD TABLE OF t100 WITH DEFAULT KEY.

    " Flagged: Strict SQL with @ host variable
    SELECT FROM t100 FIELDS sprsl INTO TABLE @lt_data.

    " Compliant: Classic SQL
    SELECT * FROM t100 INTO TABLE lt_data.
  ENDMETHOD.

  METHOD test_013.
    " Flagged: RAISE EXCEPTION with MESSAGE
    RAISE EXCEPTION TYPE zcx_custom MESSAGE e001(sy).

    " Compliant: RAISE EXCEPTION without MESSAGE
    RAISE EXCEPTION TYPE zcx_custom.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_num TYPE i.
    DATA lo_obj TYPE REF TO zcl_skylint_test_downport.

    " Compliant: Suppressed via pseudo comment
    lv_num += 1. "#EC PREF_DOWNPORT
    lo_obj->get_self( )->test_001( ). "#EC PREF_DOWNPORT
  ENDMETHOD.

  METHOD test_015.
    DATA lo_obj TYPE REF TO zcl_skylint_test_downport.
    DATA lt_data TYPE string_table.
    DATA lv_val TYPE string.

    " Parenthesized constructor expression
    lo_obj = ( NEW zcl_skylint_test_downport( ) ).

    " Table expression with nested parenthesized index expression
    lv_val = lt_data[ ( 1 + 0 ) ].

    " Method chaining with parenthesized parameter argument
    lo_obj->get_self( )->test_with_args( iv_val = ( 1 + 2 ) ).
  ENDMETHOD.

ENDCLASS.
