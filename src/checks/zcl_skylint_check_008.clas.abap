CLASS zcl_skylint_check_008 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        chained_declaration TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHAINDECL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHAIN_DECL'.

    DATA mv_allow_structure_chains TYPE abap_bool VALUE abap_true.

    METHODS is_structure_start
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS should_report_chain
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                is_next          TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_allow         TYPE abap_bool
      RETURNING VALUE(rv_report) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_008 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid chained declarations (DATA:, TYPES:, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-chained_declaration
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid chained declarations; declare each entity individually'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'ALLOW_STRUCTURE_CHAINS'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_allow_structure_chains ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA lv_next_idx   TYPE i.
    DATA ls_next_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found_next TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.

      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS' OR 'FIELD-SYMBOLS' OR 'CLASS-DATA'.
          lv_next_idx = lv_idx + 1.
          zcl_skylint_ast_util=>get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                                              iv_index      = lv_next_idx
                                                    IMPORTING es_statement  = ls_next_stmt
                                                              ev_found      = lv_found_next ).
          IF     lv_found_next = abap_true
             AND should_report_chain( is_statement = <ls_statement>
                                      is_next      = ls_next_stmt
                                      iv_allow     = mv_allow_structure_chains ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-chained_declaration ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_structure_start.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = to_upper( <ls_token>-lexeme ).
      IF lv_lexeme = 'BEGIN'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD should_report_chain.
    DATA ls_cur_token  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found_cur  TYPE abap_bool.
    DATA lv_found_next TYPE abap_bool.
    DATA lv_is_cont    TYPE abap_bool.

    rv_report = abap_false.

    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_next
                                                    iv_index     = 1
                                          IMPORTING es_token     = ls_next_token
                                                    ev_found     = lv_found_next ).
    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                    iv_index     = 1
                                          IMPORTING es_token     = ls_cur_token
                                                    ev_found     = lv_found_cur ).

    IF lv_found_next = abap_false OR lv_found_cur = abap_false.
      RETURN.
    ENDIF.

    IF     is_next-keyword IS NOT INITIAL
       AND (    ls_next_token-position-line <> ls_cur_token-position-line
             OR is_next-position-line        = is_statement-position-line ).
      RETURN.
    ENDIF.

    lv_is_cont = abap_true.
    IF iv_allow = abap_true AND is_structure_start( is_statement ) = abap_true.
      lv_is_cont = abap_false.
    ENDIF.

    IF lv_is_cont = abap_true.
      rv_report = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
