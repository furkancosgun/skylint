CLASS zcl_skylint_no_implicit_any DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        implicit_any TYPE if_ci_atc_check=>ty_finding_code VALUE 'IMPL_ANY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IMPLICIT_ANY'.

    METHODS check_field_symbols
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_def
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS is_generic_type
      IMPORTING iv_type_name  TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_implicit_any IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Specify concrete types instead of generic or implicit ANY'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-implicit_any
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Specify explicit concrete types instead of generic or implicit ANY'
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'FIELD-SYMBOLS'.
          check_field_symbols( <ls_statement> ).

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          check_method_def( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_field_symbols.
    DATA lv_type_idx TYPE i.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.

    IF     zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'TYPE' )     = abap_false
       AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'LIKE' )     = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-implicit_any ).
      RETURN.
    ENDIF.

    lv_type_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'TYPE' ).
    IF lv_type_idx > 0 AND lv_type_idx < lines( is_statement-tokens ).
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_type_idx + 1 ).
      IF is_generic_type( ls_tok-lexeme ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-implicit_any ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD check_method_def.
    DATA lt_params TYPE zcl_skylint_ast_util=>ty_method_parameters.
    FIELD-SYMBOLS <ls_param> TYPE zcl_skylint_ast_util=>ty_method_parameter.

    lt_params = zcl_skylint_ast_util=>get_method_parameters( is_statement ).

    LOOP AT lt_params ASSIGNING <ls_param>.
      IF <ls_param>-type_name IS INITIAL OR is_generic_type( <ls_param>-type_name ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-implicit_any ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_generic_type.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_type_name ).
    CASE lv_upper.
      WHEN 'ANY' OR 'DATA' OR 'OBJECT' OR 'CLIKE' OR 'CSEQUENCE' OR 'XSEQUENCE'
        OR 'NUMERIC' OR 'DECFLOAT' OR 'SIMPLE' OR 'TABLE' OR 'ANY TABLE' OR 'INDEX TABLE'.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
