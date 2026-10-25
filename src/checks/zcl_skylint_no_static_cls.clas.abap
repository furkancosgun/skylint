CLASS zcl_skylint_no_static_cls DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_class TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_STAT_CL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_STATIC_CLS'.
ENDCLASS.


CLASS zcl_skylint_no_static_cls IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid static-only classes; use instantiable classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-static_class
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid static-only classes; declare instance methods and interfaces'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_static_cnt TYPE i.
    DATA lv_has_inst   TYPE abap_bool.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CLASS-METHODS'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'CLASS_CONSTRUCTOR' ) = abap_false.
            lv_static_cnt += 1.
          ENDIF.
        WHEN 'METHODS'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'CONSTRUCTOR' ) = abap_false.
            lv_has_inst = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_static_cnt > 0 AND lv_has_inst = abap_false.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-static_class ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
