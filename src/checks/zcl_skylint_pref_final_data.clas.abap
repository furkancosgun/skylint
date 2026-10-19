CLASS zcl_skylint_pref_final_data DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FIN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        to_final TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOFINAL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_FINAL'.

    METHODS is_written
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name  TYPE if_ci_atc_source_code_provider=>ty_full_name
      RETURNING VALUE(rv_written) TYPE abap_bool.

    TYPES: BEGIN OF ty_declaration,
             token_index TYPE i,
             full_name TYPE if_ci_atc_source_code_provider=>ty_full_name,
           END OF ty_declaration.

ENDCLASS.


CLASS zcl_skylint_pref_final_data IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Declare inline variables as FINAL when never written again'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_final
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Inline variable is never written again; declare it with FINAL( )'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-to_final
                                                                short_text = 'Declare as FINAL( )' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_declaration TYPE ty_declaration.
    DATA lv_name        TYPE string.
    DATA lv_line        TYPE string.
    DATA ls_quickfix    TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_token       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref         TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_token_index TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CLEAR ls_declaration.
      LOOP AT <ls_statement>-tokens INTO ls_token.
        lv_token_index = sy-tabix.
        LOOP AT ls_token-references INTO ls_ref
             WHERE kind        = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
               AND usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write.
          IF zcl_skylint_ast_util=>token_is_inline_declaration(
                 is_token  = ls_token
                 iv_prefix = 'FINAL' ) = abap_true.
            EXIT.
          ENDIF.
          IF zcl_skylint_ast_util=>token_is_inline_declaration(
                 is_token  = ls_token
                 iv_prefix = 'DATA' ) = abap_false.
            CONTINUE.
          ENDIF.
          ls_declaration-token_index = lv_token_index.
          ls_declaration-full_name  = ls_ref-full_name.
          EXIT.
        ENDLOOP.
        IF ls_declaration-token_index > 0.
          IF is_written( it_statements = is_procedure-statements
                     iv_full_name  = ls_declaration-full_name ) = abap_true.
            CONTINUE.
          ENDIF.

          lv_name = zcl_skylint_ast_util=>get_reference_name( ls_declaration-full_name ).
          IF lv_name IS INITIAL.
            CONTINUE.
          ENDIF.

          lv_line     = zcl_skylint_ast_util=>flatten_statement(
                      is_statement = <ls_statement>
                      it_overrides = VALUE #( ( index  = ls_declaration-token_index
                                                lexeme = `FINAL(` && lv_name && `)` ) )
                      iv_suffix    = `.` ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-to_final
                                      iv_statement_from = sy-tabix
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

          report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_final
                        is_quickfix     = ls_quickfix ).
          CLEAR ls_declaration.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_written.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_written = abap_false.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_ref>
             WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          IF <ls_ref>-full_name <> iv_full_name.
            CONTINUE.
          ENDIF.
          IF zcl_skylint_ast_util=>is_write_usage( <ls_ref> ) = abap_true.
            rv_written = abap_true.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
