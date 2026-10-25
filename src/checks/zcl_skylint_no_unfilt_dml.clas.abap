CLASS zcl_skylint_no_unfilt_dml DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unfiltered_dml TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_UNF_DML',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_UNFILT_DML'.

    METHODS has_top_level_where
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS is_unfiltered_dml
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_unfilt_dml IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Flag DML without WHERE on database tables'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unfiltered_dml
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Filter database writes with a WHERE condition'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_unfiltered_dml( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-unfiltered_dml ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_unfiltered_dml.
    rv_yes = abap_false.

    CASE is_statement-keyword.
      WHEN 'UPDATE'.
        IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                             iv_lexeme    = 'SET' ) = 0.
          RETURN.
        ENDIF.
      WHEN 'DELETE'.
        IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = VALUE #( ( `DELETE` ) ( `FROM` ) ) ) = abap_false.
          RETURN.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    IF zcl_skylint_ast_util=>statement_is_db_access( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    IF has_top_level_where( is_statement ) = abap_true.
      RETURN.
    ENDIF.

    rv_yes = abap_true.
  ENDMETHOD.

  METHOD has_top_level_where.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0 AND zcl_skylint_ast_util=>token_is_keyword( is_token  = <ls_token>
                                                                  iv_lexeme = 'WHERE' ) = abap_true.
        rv_has = abap_true.
        RETURN.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
