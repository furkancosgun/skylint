CLASS /skyl/cl_no_dedup_no_sort DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dedup_no_sort TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DEDUP_S',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DEDUP_NO_SORT'.

    METHODS is_table_sorted_before
      IMPORTING it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_target_idx       TYPE i
                is_table_tok        TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is_sorted) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_dedup_no_sort IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Sort internal tables before DELETE ADJACENT DUPLICATES'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-dedup_no_sort
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Sort internal table before DELETE ADJACENT DUPLICATES to prevent unexpected results'
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_idx TYPE i.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'DELETE'.
        CONTINUE.
      ENDIF.

      ls_tok = /skyl/cl_ast_util=>get_token_after_sequence(
                   is_statement = <ls_statement>
                   it_expected  = VALUE #( ( `ADJACENT` ) ( `DUPLICATES` ) ( `FROM` ) ) ).
      IF ls_tok IS INITIAL.
        CONTINUE.
      ENDIF.

      IF is_table_sorted_before( it_statements = is_procedure-statements
                                 iv_target_idx = lv_idx
                                 is_table_tok  = ls_tok ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-dedup_no_sort ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_table_sorted_before.
    DATA lv_i        TYPE i.
    DATA ls_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_sort_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_ref1     TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA ls_ref2     TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref1 = /skyl/cl_ast_util=>get_reference(
                  is_token = is_table_tok
                  iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).

    DO iv_target_idx - 1 TIMES.
      lv_i = sy-index.
      ls_stmt = /skyl/cl_ast_util=>get_statement( it_statements = it_statements
                                                  iv_index      = lv_i ).
      IF ls_stmt-keyword <> 'SORT'.
        CONTINUE.
      ENDIF.

      ls_sort_tok = /skyl/cl_ast_util=>get_token_after( is_statement = ls_stmt
                                                        iv_lexeme    = 'SORT' ).
      IF ls_sort_tok IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_ref2 = /skyl/cl_ast_util=>get_reference(
                    is_token = ls_sort_tok
                    iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF ls_ref2-full_name = ls_ref1-full_name.
        rv_is_sorted = abap_true.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
