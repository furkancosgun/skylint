CLASS zcl_skylint_check_041 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        system_var_mod TYPE if_ci_atc_check=>ty_finding_code VALUE 'SYS_VAR_MD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_SY_MOD'.

    METHODS is_system_variable_mod
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_041 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid sy-* System Variable Modification'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-system_var_mod
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid modifying system fields (sy-*); system variables are read-only'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_system_variable_mod( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-system_var_mod ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_variable_mod.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_lex   TYPE string.
    DATA lv_found TYPE abap_bool.

    rv_res = abap_false.

    " 1. Compiler References (write mode on system structure)
    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
        LOOP AT ls_tok-references INTO ls_ref.
          IF ls_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    " 2. Direct statement AST analysis for assignments and modifications
    CASE is_statement-keyword.
      WHEN 'COMPUTE'.
        " sy-subrc = ...
        zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                  iv_index     = 1
                        IMPORTING es_token     = ls_tok
                                  ev_found     = lv_found ).
        IF lv_found = abap_true.
          lv_lex = to_upper( ls_tok-lexeme ).
          IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'CLEAR'.
        " CLEAR sy-subrc
        zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                  iv_index     = 2
                        IMPORTING es_token     = ls_tok
                                  ev_found     = lv_found ).
        IF lv_found = abap_true.
          lv_lex = to_upper( ls_tok-lexeme ).
          IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
