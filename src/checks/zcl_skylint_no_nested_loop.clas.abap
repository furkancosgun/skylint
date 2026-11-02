CLASS zcl_skylint_no_nested_loop DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_NEST_LP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_NESTED_LOOP'.

    TYPES:
      BEGIN OF ty_loop_entry,
        is_loop_at TYPE abap_bool,
        has_exempt TYPE abap_bool,
        statement  TYPE if_ci_atc_source_code_provider=>ty_statement,
      END OF ty_loop_entry,
      ty_loop_stack TYPE STANDARD TABLE OF ty_loop_entry WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_skylint_no_nested_loop IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Disallow nested LOOP AT statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-nested_loop
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Nested LOOP AT detected; avoid O(N*M) loops or use GROUP BY or parallel cursor'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_stack       TYPE ty_loop_stack.
    DATA lv_stack_lines TYPE i.
    DATA lv_is_loop_at  TYPE abap_bool.
    DATA lv_has_exempt  TYPE abap_bool.
    DATA ls_tok_after   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          lv_is_loop_at = zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                  iv_lexeme    = 'AT' ).
          IF lv_is_loop_at = abap_true.
            ls_tok_after = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                                  iv_lexeme    = 'AT' ).
            IF ls_tok_after-lexeme = 'SCREEN'.
              lv_is_loop_at = abap_false.
            ENDIF.
          ENDIF.

          lv_has_exempt = abap_false.
          IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                        iv_lexeme    = 'GROUP' )      = abap_true
             OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                        iv_lexeme    = 'FROM' )       = abap_true.
            lv_has_exempt = abap_true.
          ENDIF.

          IF lv_is_loop_at = abap_true AND lv_has_exempt = abap_false.
            LOOP AT lt_stack TRANSPORTING NO FIELDS
                 WHERE is_loop_at = abap_true AND has_exempt = abap_false.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-nested_loop ).
              EXIT.
            ENDLOOP.
          ENDIF.

          APPEND VALUE #( is_loop_at = lv_is_loop_at
                          has_exempt = lv_has_exempt
                          statement  = <ls_statement> ) TO lt_stack.

        WHEN 'ENDLOOP'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            DELETE lt_stack INDEX lv_stack_lines.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
