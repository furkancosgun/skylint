CLASS zcl_skylint_no_raise_cx_sy DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_sys TYPE if_ci_atc_check=>ty_finding_code VALUE 'RAISE_SYS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RAISE_CX_SY'.

    METHODS raises_system_exception
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_system_exception_token
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_raise_cx_sy IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid raising SAP internal system exceptions (cx_sy_*)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_sys
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid raising SAP internal system exceptions; use application exceptions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'RAISE'.
        CONTINUE.
      ENDIF.
      IF raises_system_exception( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_sys ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD raises_system_exception.
    DATA ls_type_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement   = is_statement
                                                         iv_lexeme      = 'TYPE'
                                                         iv_start_index = 1 ).
    IF ls_type_tok-lexeme IS INITIAL.
      ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement   = is_statement
                                                           iv_lexeme      = 'NEW'
                                                           iv_start_index = 1 ).
    ENDIF.

    IF ls_type_tok-lexeme IS NOT INITIAL.
      rv_yes = is_system_exception_token( ls_type_tok ).
    ENDIF.
  ENDMETHOD.

  METHOD is_system_exception_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
      IF <ls_ref>-full_name CP '\TY:CX_SY_*'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
