CLASS zcl_skylint_check_099 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unused_var TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNUSED_VAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'UNUSED_VAR'.
ENDCLASS.


CLASS zcl_skylint_check_099 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect unused local variables and field symbols'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unused_var
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Local variable or field symbol is declared but never used'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_var_name TYPE string.
    DATA lv_uses     TYPE i.
    FIELD-SYMBOLS <ls_decl> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_decl>
         WHERE keyword = 'DATA' OR keyword = 'FIELD-SYMBOLS'.
      IF lines( <ls_decl>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_var_name = to_upper( <ls_decl>-tokens[ 2 ]-lexeme ).
      IF lv_var_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_uses = 0.
      LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
          IF to_upper( <ls_tok>-lexeme ) = lv_var_name.
            lv_uses += 1.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      " If only seen in its own declaration statement
      IF lv_uses <= 1.
        report_statement( is_statement    = <ls_decl>
                          iv_finding_code = c_finding_codes-unused_var ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
