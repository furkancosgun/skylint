CLASS zcl_skylint_no_ignored_return DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        ignored_return_value TYPE if_ci_atc_check=>ty_finding_code VALUE 'IGNRET',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IGNORED_RET'.

    METHODS get_invoked_method_full_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_ignored_return IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Disallow ignoring the return value of functional methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-ignored_return_value
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Do not ignore return value of functional method; assign or use result'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_full_name TYPE string.
    DATA ls_meth      TYPE abap_methdescr.
    DATA lv_found     TYPE abap_bool.
    DATA lv_is_ret    TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'CALL'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                   iv_index     = 2
                                                   iv_expected  = 'METHOD' ) = abap_false.
          CONTINUE.
        ENDIF.
      ELSEIF <ls_statement>-keyword <> '+CALL_METHOD'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'RECEIVING' ) = abap_true.
        CONTINUE.
      ENDIF.

      lv_full_name = get_invoked_method_full_name( <ls_statement> ).
      IF lv_full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR: ls_meth,
             lv_found.
      zcl_skylint_rtti_util=>get_method_descr( EXPORTING iv_full_name = lv_full_name
                                               IMPORTING es_method    = ls_meth
                                                         ev_found     = lv_found ).
      IF lv_found = abap_false.
        CONTINUE.
      ENDIF.

      lv_is_ret = line_exists( ls_meth-parameters[ parm_kind = cl_abap_objectdescr=>returning ] ).
      IF lv_is_ret = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-ignored_return_value ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_invoked_method_full_name.
    DATA lv_depth     TYPE i.
    DATA lv_first_ref TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rv_name.
    lv_depth = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_depth = 0.
        LOOP AT <ls_token>-references ASSIGNING <ls_ref>
             WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
          rv_name = <ls_ref>-full_name.
          IF lv_first_ref IS INITIAL.
            lv_first_ref = <ls_ref>-full_name.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF <ls_token>-lexeme CP '*('.
        lv_depth += 1.
      ELSEIF <ls_token>-lexeme = ')'.
        IF lv_depth > 0.
          lv_depth -= 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rv_name IS INITIAL.
      rv_name = lv_first_ref.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
