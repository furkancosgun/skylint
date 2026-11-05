CLASS /skyl/cl_no_complex_arg DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        complex_argument TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CMPLX_A',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_COMPLEX_ARG'.

    METHODS is_argument_complex
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_complex) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_complex_arg IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid complex expressions in call arguments'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-complex_argument
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid complex expressions in call arguments; extract into a variable'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF /skyl/cl_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF is_argument_complex( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-complex_argument ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_argument_complex.
    DATA lv_depth   TYPE i.
    DATA lv_tok_idx TYPE i.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref     TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_complex = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_tok_idx = sy-tabix.

      IF lv_depth = 1.
        IF ls_tok-references IS INITIAL AND ( ls_tok-lexeme = 'COND' OR ls_tok-lexeme = 'SWITCH' ).
          ls_next = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_tok_idx + 1 ).
          IF ls_next-lexeme = '#('.
            rv_complex = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

        ls_ref = /skyl/cl_ast_util=>get_reference(
                     is_token = ls_tok
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
        IF ls_ref IS NOT INITIAL.
          ls_next = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_tok_idx + 1 ).
          IF ls_next-lexeme CP ')*->*' OR ls_next-lexeme CP ')->*'.
            rv_complex = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_depth += /skyl/cl_ast_util=>token_paren_delta( ls_tok ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
