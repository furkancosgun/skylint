CLASS zcl_skylint_pref_xsdbool DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_XSDBL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_xsdbool TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOXSDBOOL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_XSDBOOL'.

    METHODS get_bool_assignment
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_is_true   TYPE abap_bool
                ev_valid     TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_xsdbool IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_xsdbool
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer xsdbool( ) over manual IF-ELSE assignment'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_xsdbool
                                                short_text = 'Use xsdbool( )' ) ) ) ).
  ENDMETHOD.

  METHOD get_bool_assignment.
    DATA ls_tok_target TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_val    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_val        TYPE string.

    ev_valid = abap_false.
    IF is_statement-keyword <> 'COMPUTE' OR lines( is_statement-tokens ) <> 3.
      RETURN.
    ENDIF.

    ls_tok_target = is_statement-tokens[ 1 ].
    ls_tok_eq     = is_statement-tokens[ 2 ].
    ls_tok_val    = is_statement-tokens[ 3 ].

    IF ls_tok_eq-lexeme <> '=' OR ls_tok_eq-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok_val-references IS NOT INITIAL AND ls_tok_val-lexeme <> 'ABAP_TRUE' AND ls_tok_val-lexeme <> 'ABAP_FALSE'.
      RETURN.
    ENDIF.

    lv_val = to_upper( ls_tok_val-lexeme ).
    CASE lv_val.
      WHEN 'ABAP_TRUE' OR '''X'''.
        ev_target  = ls_tok_target-lexeme.
        ev_is_true = abap_true.
        ev_valid   = abap_true.
      WHEN 'ABAP_FALSE' OR 'SPACE' OR '''''' OR ''' '''.
        ev_target  = ls_tok_target-lexeme.
        ev_is_true = abap_false.
        ev_valid   = abap_true.
    ENDCASE.
  ENDMETHOD.

  METHOD check.
    DATA lv_idx         TYPE i.
    DATA lv_max         TYPE i.
    DATA lv_target_then TYPE string.
    DATA lv_target_else TYPE string.
    DATA lv_true_then   TYPE abap_bool.
    DATA lv_true_else   TYPE abap_bool.
    DATA lv_valid_then  TYPE abap_bool.
    DATA lv_valid_else  TYPE abap_bool.
    DATA lv_cond        TYPE string.
    DATA lv_line        TYPE string.
    DATA lv_indent      TYPE string.
    DATA ls_quickfix    TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_if> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_max = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_if> WHERE keyword = 'IF'.
      lv_idx = sy-tabix.
      IF lv_idx + 4 > lv_max.
        CONTINUE.
      ENDIF.

      " Pattern: IF, COMPUTE, ELSE, COMPUTE, ENDIF
      IF    is_procedure-statements[ lv_idx + 2 ]-keyword <> 'ELSE'
         OR is_procedure-statements[ lv_idx + 4 ]-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      get_bool_assignment( EXPORTING is_statement = is_procedure-statements[ lv_idx + 1 ]
                           IMPORTING ev_target    = lv_target_then
                                     ev_is_true   = lv_true_then
                                     ev_valid     = lv_valid_then ).

      get_bool_assignment( EXPORTING is_statement = is_procedure-statements[ lv_idx + 3 ]
                           IMPORTING ev_target    = lv_target_else
                                     ev_is_true   = lv_true_else
                                     ev_valid     = lv_valid_else ).

      IF    lv_valid_then = abap_false OR lv_valid_else = abap_false
         OR to_upper( lv_target_then ) <> to_upper( lv_target_else )
         OR lv_true_then = lv_true_else.
        CONTINUE.
      ENDIF.

      lv_cond = zcl_skylint_ast_util=>extract_tokens_text(
                    is_statement = <ls_if>
                    iv_from_idx  = 2
                    iv_to_idx    = lines( <ls_if>-tokens ) ).

      lv_indent = repeat( val = ` `
                          occ = <ls_if>-position-column ).

      IF lv_true_then = abap_true.
        lv_line = |{ lv_indent }{ lv_target_then } = xsdbool( { lv_cond } ).|.
      ELSE.
        lv_line = |{ lv_indent }{ lv_target_then } = xsdbool( NOT ( { lv_cond } ) ).|.
      ENDIF.

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_xsdbool
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_idx + 4
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_if>
                        iv_finding_code = c_finding_codes-prefer_xsdbool
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
