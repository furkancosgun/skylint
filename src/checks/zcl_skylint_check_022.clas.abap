CLASS zcl_skylint_check_022 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_new TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFERNEW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_static_create_object
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_022 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer NEW #( ) constructor expression over legacy CREATE OBJECT'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-prefer_new
                                       severity = zif_skylint_types=>severities-warning
                                       text     = 'Prefer NEW #( ) expression over CREATE OBJECT' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CREATE'.
      IF is_static_create_object( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_new ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_static_create_object.
    DATA ls_tok   TYPE zif_skylint_types=>ty_token.
    DATA lv_idx   TYPE i.
    DATA lv_tok   TYPE string.
    DATA lv_count TYPE i.

    rv_res = abap_false.
    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `CREATE` ) ( `OBJECT` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    " Exclude RAP FOR TESTING and dynamic calls
    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) = abap_true.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `PARAMETER-TABLE` ) ) ) = abap_true.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = 3 ).
    lv_tok = to_upper( ls_tok-lexeme ).
    IF ls_tok-lexeme IS NOT INITIAL AND ( lv_tok(1) = `'` OR lv_tok(1) = '`' ).
      RETURN.
    ENDIF.

    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 3.
    WHILE lv_idx <= lv_count.
      IF     zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = lv_idx )      = 'TYPE'
         AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                     iv_index     = lv_idx + 1 ) CP '(*'.
        RETURN.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.

    rv_res = abap_true.
  ENDMETHOD.
ENDCLASS.
