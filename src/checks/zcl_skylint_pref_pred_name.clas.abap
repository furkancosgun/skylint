CLASS zcl_skylint_pref_pred_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_method_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PREDN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_PRED_NAME'.

    METHODS has_boolean_return
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has_bool) TYPE abap_bool.

    METHODS is_boolean_type
      IMPORTING iv_type           TYPE string
      RETURNING VALUE(rv_is_bool) TYPE abap_bool.

    METHODS is_predicate_name
      IMPORTING iv_method_name TYPE string
      RETURNING VALUE(rv_yes)  TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_pred_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Enforce predicate naming (IS_, HAS_) on boolean methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_method_name
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Boolean-returning method should use predicate name (IS_, HAS_, CAN_)'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_method_name TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      IF has_boolean_return( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_method_name = zcl_skylint_ast_util=>get_declaration_name( <ls_statement> ).
      IF is_predicate_name( lv_method_name ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-bool_method_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_boolean_return.
    DATA lv_ret_idx  TYPE i.
    DATA ls_type_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has_bool = abap_false.

    lv_ret_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'RETURNING' ).
    IF lv_ret_idx = 0.
      RETURN.
    ENDIF.

    ls_type_tok = zcl_skylint_ast_util=>get_token_after( is_statement   = is_statement
                                                         iv_lexeme      = 'TYPE'
                                                         iv_start_index = lv_ret_idx ).
    IF ls_type_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    rv_has_bool = is_boolean_type( ls_type_tok-lexeme ).
  ENDMETHOD.

  METHOD is_boolean_type.
    CASE iv_type.
      WHEN 'ABAP_BOOL' OR 'ABAP_BOOLEAN' OR 'XSDBOOL'
        OR 'FLAG' OR 'XFELD' OR 'BOOLEAN' OR 'BOOLE_D'.
        rv_is_bool = abap_true.
      WHEN OTHERS.
        rv_is_bool = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_predicate_name.
    rv_yes = xsdbool(
         iv_method_name CP 'IS_*'      OR iv_method_name = 'IS'
      OR iv_method_name CP 'HAS_*'     OR iv_method_name = 'HAS'
      OR iv_method_name CP 'CAN_*'
      OR iv_method_name CP 'ARE_*'
      OR iv_method_name CP 'WAS_*'
      OR iv_method_name CP 'WERE_*'
      OR iv_method_name CP 'SHOULD_*'
      OR iv_method_name CP 'MUST_*'
      OR iv_method_name CP 'EXISTS*'
      OR iv_method_name CP 'CONTAINS*'
      OR iv_method_name CP 'SUPPORTS*'
      OR iv_method_name CP 'MATCHES*'
      OR iv_method_name CP 'EQUALS*' ).
  ENDMETHOD.
ENDCLASS.
