CLASS zcl_skylint_pref_when_others DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_others  TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NO_WO',
        others_position TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_WOPOS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_case_context,
        statement        TYPE if_ci_atc_source_code_provider=>ty_statement,
        explicit_count   TYPE i,
        branch_count     TYPE i,
        others_index     TYPE i,
        has_others       TYPE abap_bool,
        others_statement TYPE if_ci_atc_source_code_provider=>ty_statement,
      END OF ty_case_context,
      ty_case_contexts TYPE STANDARD TABLE OF ty_case_context WITH EMPTY KEY.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_WHEN_OTHERS'.

    DATA mv_min_branches TYPE i         VALUE 2.
    DATA mv_require_last TYPE abap_bool VALUE abap_true.

    METHODS is_when_others
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_when_others IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Require WHEN OTHERS as the last CASE branch'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( severity       = if_ci_atc_check=>finding_severities-warning
                                              pseudo_comment = c_pseudo_comment
                                              ( code = c_finding_codes-missing_others
                                                text = 'CASE statement has no WHEN OTHERS fallback branch' )
                                              ( code = c_finding_codes-others_position
                                                text = 'WHEN OTHERS should be the last branch of the CASE statement' ) )
                 attributes        = VALUE #( ( name  = 'MIN_BRANCHES'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_min_branches ) )
                                              ( name  = 'REQUIRE_LAST'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_require_last ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_stack TYPE ty_case_contexts.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_context>   TYPE ty_case_context.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CASE'.
          APPEND VALUE #( statement = <ls_statement> ) TO lt_stack.
        WHEN 'WHEN'.
          IF lines( lt_stack ) = 0.
            CONTINUE.
          ENDIF.
          ASSIGN lt_stack[ lines( lt_stack ) ] TO <ls_context>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          <ls_context>-branch_count += 1.
          IF is_when_others( <ls_statement> ) = abap_true.
            <ls_context>-has_others       = abap_true.
            <ls_context>-others_index     = <ls_context>-branch_count.
            <ls_context>-others_statement = <ls_statement>.
          ELSE.
            <ls_context>-explicit_count += 1.
          ENDIF.
        WHEN 'ENDCASE'.
          IF lines( lt_stack ) = 0.
            CONTINUE.
          ENDIF.
          ASSIGN lt_stack[ lines( lt_stack ) ] TO <ls_context>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          IF     <ls_context>-has_others      = abap_false
             AND <ls_context>-explicit_count >= mv_min_branches.
            report_statement( is_statement    = <ls_context>-statement
                              iv_finding_code = c_finding_codes-missing_others ).
          ELSEIF     <ls_context>-has_others   = abap_true
                 AND mv_require_last           = abap_true
                 AND <ls_context>-others_index < <ls_context>-branch_count.
            report_statement( is_statement    = <ls_context>-others_statement
                              iv_finding_code = c_finding_codes-others_position ).
          ENDIF.
          DELETE lt_stack INDEX lines( lt_stack ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_when_others.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    IF zcl_skylint_ast_util=>token_count( is_statement ) < 2.
      RETURN.
    ENDIF.
    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 2 ).
    IF ls_token-lexeme = 'OTHERS' AND ls_token-references IS INITIAL.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
