CLASS zcl_skylint_no_chain_decl DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        chained_declaration TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHAINDECL',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        resolve_chain TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'PREFINLDCL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHAIN_DECL'.

    DATA mv_allow_structure_chains TYPE abap_bool VALUE abap_true.

    METHODS is_structure_start
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_same_position
      IMPORTING is_first       TYPE if_ci_atc_source_code_provider=>ty_statement
                is_second      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_same) TYPE abap_bool.

    METHODS collect_chain_count
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_start        TYPE i
                is_head         TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

    METHODS build_chain_code
      IMPORTING it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_from        TYPE i
                iv_to          TYPE i
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

ENDCLASS.


CLASS zcl_skylint_no_chain_decl IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid chained declarations (DATA:, TYPES:, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-chained_declaration
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid chained declarations; declare each entity individually'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-resolve_chain
                                                short_text = 'Resolve chain into single declarations' ) )
                 attributes        = VALUE #( ( name  = 'ALLOW_STRUCTURE_CHAINS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_allow_structure_chains ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA lv_skip_until TYPE i.
    DATA lv_count      TYPE i.
    DATA lv_is_struct  TYPE abap_bool.
    DATA ls_target     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code   TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.
      IF lv_idx <= lv_skip_until.
        CONTINUE.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'TYPES' OR 'CLASS-DATA' OR 'CONSTANTS' OR 'STATICS'.
          lv_count = collect_chain_count( it_statements = is_procedure-statements
                                          iv_start      = lv_idx
                                          is_head       = <ls_statement> ).
          IF lv_count > 1.
            lv_skip_until = lv_idx + lv_count - 1.
            lv_is_struct = is_structure_start( <ls_statement> ).
            IF mv_allow_structure_chains = abap_true AND lv_is_struct = abap_true.
              CONTINUE.
            ENDIF.
            CLEAR ls_quickfix.
            IF lv_is_struct = abap_false.
              lt_new_code = build_chain_code( it_statements = is_procedure-statements
                                              iv_from       = lv_idx
                                              iv_to         = lv_skip_until ).
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-resolve_chain
                                              iv_statement_from = lv_idx
                                              iv_statement_to   = lv_skip_until
                                              it_new_code       = lt_new_code ).
            ENDIF.
            ls_target = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                                  iv_current_index = lv_idx ).
            IF ls_target-keyword IS NOT INITIAL.
              report_statement( is_statement    = ls_target
                                iv_finding_code = c_finding_codes-chained_declaration
                                is_quickfix     = ls_quickfix ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_chain_count.
    DATA lv_next_idx TYPE i.
    DATA ls_next     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_done     TYPE abap_bool.

    rv_count = 1.
    lv_next_idx = iv_start + 1.
    lv_done = abap_false.
    WHILE lv_done = abap_false.
      ls_next = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_next_idx ).
      IF ls_next-keyword IS INITIAL.
        lv_done = abap_true.
      ELSEIF ls_next-keyword <> is_head-keyword.
        lv_done = abap_true.
      ELSEIF is_same_position( is_first  = is_head
                               is_second = ls_next ) = abap_false.
        lv_done = abap_true.
      ELSE.
        rv_count += 1.
        lv_next_idx += 1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD build_chain_code.
    DATA ls_member TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rt_code.
    LOOP AT it_statements INTO ls_member FROM iv_from TO iv_to.
      APPEND |{ zcl_skylint_ast_util=>flatten_statement( ls_member ) }.| TO rt_code.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_structure_start.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      IF lv_lexeme = 'BEGIN' AND <ls_token>-references IS INITIAL.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_same_position.
    DATA ls_first_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_same = abap_false.
    ls_first_tok = zcl_skylint_ast_util=>get_first_token( is_first ).
    ls_second_tok = zcl_skylint_ast_util=>get_first_token( is_second ).
    IF ls_first_tok-lexeme IS INITIAL OR ls_second_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.
    IF ls_first_tok-position = ls_second_tok-position.
      rv_same = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
