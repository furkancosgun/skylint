CLASS zcl_skylint_check_041 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        system_var_mod TYPE zif_skylint_types=>ty_finding_code VALUE 'SYS_VAR_MD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.

    METHODS is_system_variable_mod
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_041 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid sy-* System Variable Modification'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-system_var_mod
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid modifying system fields (sy-*); system variables are read-only'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      IF is_system_variable_mod( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-system_var_mod ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_variable_mod.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.
    DATA ls_ref TYPE zif_skylint_types=>ty_compiler_reference.
    DATA lv_lex TYPE string.

    rv_res = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
        LOOP AT ls_tok-references INTO ls_ref.
          IF ls_ref-usage_mode = zif_skylint_types=>usage_modes-write.
            rv_res = abap_true.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    CASE is_statement-keyword.
      WHEN 'COMPUTE'.
        ls_tok = zcl_skylint_ast_util=>get_first_token( is_statement ).
        lv_lex = to_upper( ls_tok-lexeme ).
        IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
          rv_res = abap_true.
          RETURN.
        ENDIF.

      WHEN 'CLEAR'.
        ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = 2 ).
        lv_lex = to_upper( ls_tok-lexeme ).
        IF lv_lex CP 'SY-*' OR lv_lex CP 'SYST-*'.
          rv_res = abap_true.
          RETURN.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
