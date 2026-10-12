CLASS zcl_skylint_check_064 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHECKSUBRC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS sets_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_064 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Check sy-subrc after DB, table and string operations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-check_subrc
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF sets_sy_subrc( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = sy-tabix ).

      IF ls_next_stmt-keyword IS INITIAL OR checks_sy_subrc( ls_next_stmt ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-check_subrc ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sets_sy_subrc.
    rv_res = abap_false.

    CASE is_statement-keyword.
      WHEN 'ASSIGN' OR 'AUTHORITY-CHECK' OR 'FIND' OR 'SEARCH'.
        rv_res = abap_true.
      WHEN 'SELECT'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 2
                                                   iv_expected  = `SINGLE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
      WHEN 'READ'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 2
                                                   iv_expected  = `TABLE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD checks_sy_subrc.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex TYPE string.

    rv_res = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      IF lv_lex = 'SY-SUBRC'.
        rv_res = abap_true.
        RETURN.
      ENDIF.

      LOOP AT ls_tok-references TRANSPORTING NO FIELDS
           WHERE     full_name  CS 'SUBRC'
                 AND usage_mode  = if_ci_atc_source_code_provider=>usage_modes-read.
        rv_res = abap_true.
        RETURN.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
