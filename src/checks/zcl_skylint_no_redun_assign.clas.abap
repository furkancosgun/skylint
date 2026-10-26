CLASS zcl_skylint_no_redun_assign DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_IDN_MOV',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_self TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELIDENT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_IDENTICAL_MOVE'.

    METHODS get_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_redun_assign IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect identical assignments and moves'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-identical_move
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Identical assignment has no effect; remove redundant statement'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #(
                     ( code       = c_quickfix_codes-delete_self
                       short_text = 'Delete self-assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'COMPUTE' AND <ls_statement>-keyword <> 'MOVE'.
        CONTINUE.
      ENDIF.

      IF is_identical_assignment( <ls_statement> ) = abap_true.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_self
                                        iv_statement_from = sy-tabix
                                        it_new_code       = VALUE #( ) ).

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-identical_move
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

    rv_symbol = ls_ref-full_name.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA lv_lexeme TYPE string.
    DATA ls_op     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_left   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_right  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_last   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    CASE is_statement-keyword.
      WHEN 'COMPUTE'.
        IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
          RETURN.
        ENDIF.

        ls_op = zcl_skylint_ast_util=>get_token(
                    is_statement = is_statement
                    iv_index     = 2 ).

        IF ls_op-lexeme <> '=' AND ls_op-lexeme <> '?='.
          RETURN.
        ENDIF.

        ls_left  = zcl_skylint_ast_util=>get_first_token( is_statement ).
        ls_right = zcl_skylint_ast_util=>get_last_token( is_statement ).
        rv_res   = xsdbool( get_symbol( ls_left ) = get_symbol( ls_right ) ).

      WHEN 'MOVE'.
        lv_lexeme = 'TO'.
        IF zcl_skylint_ast_util=>has_token_lexeme(
               is_statement = is_statement
               iv_lexeme    = '?TO' ) = abap_true.
          lv_lexeme = '?TO'.
        ENDIF.

        ls_left  = zcl_skylint_ast_util=>get_token_after(
                       is_statement = is_statement
                       iv_lexeme    = lv_lexeme ).

        ls_right = zcl_skylint_ast_util=>get_token_before(
                       is_statement = is_statement
                       iv_lexeme    = lv_lexeme ).

        ls_last  = zcl_skylint_ast_util=>get_last_token( is_statement ).

        rv_res = xsdbool( get_symbol( ls_left ) = get_symbol( ls_right ) ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.