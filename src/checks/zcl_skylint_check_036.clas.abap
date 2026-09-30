CLASS zcl_skylint_check_036 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITPARM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OMIT_PARAM_NAME'.

    METHODS is_exempt_statement
      IMPORTING iv_keyword       TYPE string
      RETURNING VALUE(rv_exempt) TYPE abap_bool.

    METHODS is_single_named_param_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tok_idx    TYPE i
                is_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_036 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit parameter name in single parameter method call'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_param
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit explicit parameter name in single parameter method call'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_tok_idx   TYPE i.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements INTO ls_statement.
      IF is_exempt_statement( ls_statement-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      lv_tok_idx = 0.
      LOOP AT ls_statement-tokens INTO ls_token.
        lv_tok_idx = lv_tok_idx + 1.

        LOOP AT ls_token-references INTO ls_ref
             WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
          IF is_single_named_param_call( is_statement = ls_statement
                                         iv_tok_idx   = lv_tok_idx
                                         is_ref       = ls_ref ) = abap_true.
            report_statement( is_statement    = ls_statement
                              iv_finding_code = c_finding_codes-omit_param ).
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt_statement.
    CASE iv_keyword.
      WHEN 'CALL' OR 'EXPORT' OR 'METHODS' OR 'CLASS-METHODS'
        OR 'EVENTS' OR 'CLASS-EVENTS' OR 'INTERFACES' OR 'SUBMIT'
        OR 'FORM' OR 'FUNCTION' OR 'MODULE'.
        rv_exempt = abap_true.
      WHEN OTHERS.
        rv_exempt = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_single_named_param_call.
    DATA lv_param_name TYPE string.
    DATA lv_is_single  TYPE abap_bool.
    DATA ls_tok        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_param_idx  TYPE i.
    DATA lv_next_idx   TYPE i.
    DATA lv_tok_found  TYPE abap_bool.

    rv_res = abap_false.

    zcl_skylint_rtti_util=>get_single_importing_param(
      EXPORTING
        iv_full_name  = is_ref-full_name
      IMPORTING
        ev_param_name = lv_param_name
        ev_is_single  = lv_is_single ).

    IF lv_is_single = abap_false.
      RETURN.
    ENDIF.

    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = iv_tok_idx
                    IMPORTING es_token     = ls_tok
                              ev_found     = lv_tok_found ).
    IF lv_tok_found = abap_false.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme CP '*('.
      lv_param_idx = iv_tok_idx + 1.
    ELSE.
      zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = iv_tok_idx + 1
                      IMPORTING es_token     = ls_tok
                                ev_found     = lv_tok_found ).
      IF lv_tok_found = abap_true AND ls_tok-lexeme = '('.
        lv_param_idx = iv_tok_idx + 2.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.

    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = lv_param_idx
                    IMPORTING es_token     = ls_tok
                              ev_found     = lv_tok_found ).
    IF lv_tok_found = abap_false.
      RETURN.
    ENDIF.

    CASE to_upper( ls_tok-lexeme ).
      WHEN lv_param_name.
        lv_next_idx = lv_param_idx + 1.
        zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                  iv_index     = lv_next_idx
                        IMPORTING es_token     = ls_next_tok
                                  ev_found     = lv_tok_found ).
        IF lv_tok_found = abap_true AND ls_next_tok-lexeme = '='.
          rv_res = abap_true.
        ENDIF.
      WHEN |{ lv_param_name }=|.
        rv_res = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
