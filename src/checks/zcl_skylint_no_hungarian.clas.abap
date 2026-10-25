CLASS zcl_skylint_no_hungarian DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hungarian TYPE if_ci_atc_check=>ty_finding_code VALUE 'HUNGARIAN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HUNGARIAN'.

    DATA mv_check_attributes TYPE abap_bool VALUE abap_true.
    DATA mv_check_locals     TYPE abap_bool VALUE abap_true.
    DATA mv_check_params     TYPE abap_bool VALUE abap_true.

    METHODS is_hungarian
      IMPORTING iv_name      TYPE string
                iv_type      TYPE string DEFAULT ''
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_decl_name
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS extract_name_from_paren
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_hungarian IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid Hungarian notation and encoding prefixes'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-hungarian
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid Hungarian notation and encoding prefixes in names'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_ATTR'
                                                                value = REF #( mv_check_attributes ) )
                                                              ( name  = 'CHECK_LOCAL'
                                                                value = REF #( mv_check_locals ) )
                                                              ( name  = 'CHECK_PARAM'
                                                                value = REF #( mv_check_params ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'DATA' OR 'CLASS-DATA' OR 'STATICS' OR 'CONSTANTS' OR 'FIELD-SYMBOLS'.
          IF mv_check_attributes = abap_true OR mv_check_locals = abap_true.
            check_decl_name( <ls_stmt> ).
          ENDIF.

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          IF mv_check_params = abap_true.
            check_method_parameters( <ls_stmt> ).
          ENDIF.

        WHEN OTHERS.
          IF mv_check_locals = abap_true.
            check_inline_declarations( <ls_stmt> ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_name.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name     TYPE string.
    DATA lv_type     TYPE string.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `BEGIN` ) ( `OF` ) ) ) > 0.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'OF' ).
      lv_name = ls_tok-lexeme.
    ELSEIF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                      it_expected  = VALUE #( ( `END` ) ( `OF` ) ) ) > 0.
      RETURN.
    ELSE.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = is_statement-keyword ).
      lv_name = ls_tok-lexeme.

      ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                           iv_lexeme    = 'TYPE' ).
      IF ls_type_tok-lexeme IS INITIAL.
        ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                             iv_lexeme    = 'LIKE' ).
      ENDIF.
      lv_type = ls_type_tok-lexeme.
    ENDIF.

    IF lv_name IS NOT INITIAL AND is_hungarian( iv_name = lv_name
                                                iv_type = lv_type ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-hungarian ).
    ENDIF.
  ENDMETHOD.

  METHOD check_method_parameters.
    DATA lv_in_clause TYPE abap_bool.
    DATA ls_prev_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name      TYPE string.
    DATA lv_type      TYPE string.
    DATA lv_tabix     TYPE i.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tabix = sy-tabix.

      IF <ls_tok>-references IS NOT INITIAL.
        ls_prev_tok = <ls_tok>.
        CONTINUE.
      ENDIF.

      CASE <ls_tok>-lexeme.
        WHEN 'IMPORTING' OR 'EXPORTING' OR 'CHANGING' OR 'RETURNING'.
          lv_in_clause = abap_true.

        WHEN 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION' OR 'ABSTRACT' OR 'FINAL' OR 'DEFAULT'.
          lv_in_clause = abap_false.

        WHEN 'TYPE' OR 'LIKE'.
          IF lv_in_clause = abap_true AND ls_prev_tok-lexeme IS NOT INITIAL.
            lv_name = extract_name_from_paren( ls_prev_tok-lexeme ).
            ls_type_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                           iv_index     = lv_tabix + 1 ).
            lv_type = ls_type_tok-lexeme.

            IF is_hungarian( iv_name = lv_name
                             iv_type = lv_type ) = abap_true.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-hungarian ).
              RETURN.
            ENDIF.
          ENDIF.
      ENDCASE.

      ls_prev_tok = <ls_tok>.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      LOOP AT <ls_tok>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        IF    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
           OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
          lv_name = extract_name_from_paren( <ls_tok>-lexeme ).
          IF lv_name IS NOT INITIAL AND is_hungarian( lv_name ) = abap_true.
            report_statement( is_statement    = is_statement
                              iv_finding_code = c_finding_codes-hungarian ).
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_hungarian.
    DATA lv_clean TYPE string.

    rv_is = abap_false.
    lv_clean = condense( iv_name ).

    IF lv_clean CS '<'.
      REPLACE ALL OCCURRENCES OF '<' IN lv_clean WITH ''.
    ENDIF.
    IF lv_clean CS '>'.
      REPLACE ALL OCCURRENCES OF '>' IN lv_clean WITH ''.
    ENDIF.

    IF lv_clean CP 'IS_*' AND iv_type = 'ABAP_BOOL'.
      RETURN.
    ENDIF.

    IF    matches( val   = lv_clean
                   regex = '^[LMSGICER][VSTROCF]?_.*' )
       OR matches( val   = lv_clean
                   regex = '^FS_.*' ).
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD extract_name_from_paren.
    DATA lv_len TYPE i.
    DATA lv_pos TYPE i.

    rv_name = iv_lexeme.
    lv_pos = find( val = iv_lexeme
                   sub = '(' ).
    IF lv_pos < 0.
      RETURN.
    ENDIF.

    lv_pos += 1.
    lv_len = strlen( iv_lexeme ) - lv_pos.
    IF     lv_len > 0
       AND substring( val = iv_lexeme
                      off = strlen( iv_lexeme ) - 1
                      len = 1 ) = ')'.
      lv_len -= 1.
    ENDIF.

    IF lv_len > 0.
      rv_name = substring( val = iv_lexeme
                           off = lv_pos
                           len = lv_len ).
    ENDIF.
    rv_name = condense( rv_name ).
  ENDMETHOD.
ENDCLASS.
