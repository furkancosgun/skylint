CLASS zcl_skylint_pref_returning DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_returning TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFER_RET',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RETURNING'.

    METHODS is_single_exporting
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_returning IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer RETURNING over single EXPORTING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_returning
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer functional RETURNING parameter over single EXPORTING parameter'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF is_single_exporting( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_returning ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_single_exporting.
    DATA lv_idx     TYPE i.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_exp_idx TYPE i.
    DATA lv_count   TYPE i.

    rv_yes = abap_false.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'CONSTRUCTOR' )  = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'FOR' )          = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'REDEFINITION' ) = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'CHANGING' )     = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'RETURNING' )    = abap_true.
      RETURN.
    ENDIF.

    lv_exp_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'EXPORTING' ).
    IF lv_exp_idx = 0.
      RETURN.
    ENDIF.

    lv_idx = lv_exp_idx + 1.
    WHILE lv_idx <= lines( is_statement-tokens ).
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      CASE ls_tok-lexeme.
        WHEN 'EXCEPTIONS' OR 'RAISING'.
          IF ls_tok-references IS INITIAL.
            EXIT.
          ENDIF.
        WHEN 'TYPE' OR 'LIKE'.
          IF ls_tok-references IS INITIAL.
            lv_count += 1.
          ENDIF.
      ENDCASE.
      lv_idx += 1.
    ENDWHILE.

    rv_yes = xsdbool( lv_count = 1 ).
  ENDMETHOD.
ENDCLASS.
