CLASS zcl_skylint_pref_msg_cls DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        message_class TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_MSG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MSG_CLASS'.

    METHODS uses_message_class
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_msg_cls IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'skylint: Use a message class instead of inline message text'
            remote_enablement = abap_false
            finding_codes     = VALUE #( ( code           = c_finding_codes-message_class
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Define the message class and raise it as e001( msg_class )'
                                           pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'MESSAGE'.
        CONTINUE.
      ENDIF.

      IF uses_message_class( it_statements = is_procedure-statements
                             is_statement  = <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-message_class ).
    ENDLOOP.
  ENDMETHOD.

  METHOD uses_message_class.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_type  TYPE string.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'ID' ) > 0.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'MESSAGE' ).
    IF zcl_skylint_ast_util=>token_is_literal( ls_token ) = abap_true.
      rv_yes = abap_false.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>has_compiler_reference(
              is_token = ls_token
              iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message )        = abap_true
       OR zcl_skylint_ast_util=>has_compiler_reference(
              is_token = ls_token
              iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message_id )     = abap_true
       OR zcl_skylint_ast_util=>has_compiler_reference(
              is_token = ls_token
              iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-message_number ) = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    LOOP AT ls_token-references ASSIGNING <ls_ref>.
      IF zcl_skylint_rtti_util=>describe_object( <ls_ref>-full_name ) IS BOUND.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
      IF <ls_ref>-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
        lv_type = zcl_skylint_ast_util=>get_declared_type( it_statements = it_statements
                                                           iv_full_name  = <ls_ref>-full_name ).
        IF lv_type IS NOT INITIAL AND zcl_skylint_rtti_util=>describe_object( lv_type ) IS BOUND.
          rv_yes = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    rv_yes = abap_false.
  ENDMETHOD.
ENDCLASS.
