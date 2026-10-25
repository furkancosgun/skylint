CLASS zcl_skylint_no_obs_memory DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_memory TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBS_MEM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OBSOLETE_MEM'.

    DATA mv_check_export_memory TYPE abap_bool VALUE abap_true.
    DATA mv_check_free_memory   TYPE abap_bool VALUE abap_true.
    DATA mv_check_provide       TYPE abap_bool VALUE abap_true.
    DATA mv_check_contexts      TYPE abap_bool VALUE abap_true.
    DATA mv_check_infotypes     TYPE abap_bool VALUE abap_true.
    DATA mv_check_communication TYPE abap_bool VALUE abap_true.
    DATA mv_check_call_transf   TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_obs_memory IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Obsolete Memory and Context Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_memory
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete memory, context, and legacy data-sharing constructs'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_EXPORT_MEMORY'
                                                value = REF #( mv_check_export_memory ) )
                                              ( name  = 'CHECK_FREE_MEMORY'
                                                value = REF #( mv_check_free_memory ) )
                                              ( name  = 'CHECK_PROVIDE'
                                                value = REF #( mv_check_provide ) )
                                              ( name  = 'CHECK_CONTEXTS'
                                                value = REF #( mv_check_contexts ) )
                                              ( name  = 'CHECK_INFOTYPES'
                                                value = REF #( mv_check_infotypes ) )
                                              ( name  = 'CHECK_COMMUNICATION'
                                                value = REF #( mv_check_communication ) )
                                              ( name  = 'CHECK_CALL_TRANSF'
                                                value = REF #( mv_check_call_transf ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'EXPORT'.
          IF     mv_check_export_memory = abap_true
             AND (    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                              iv_lexeme    = 'MEMORY' )     = abap_true
                   OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                              iv_lexeme    = 'DATABASE' )   = abap_true ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'FREE'.
          IF     mv_check_free_memory = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `MEMORY` )     = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'PROVIDE' OR 'ENDPROVIDE'.
          IF mv_check_provide = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'CONTEXTS' OR 'DEMAND' OR 'SUPPLY'.
          IF mv_check_contexts = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'INFOTYPES'.
          IF mv_check_infotypes = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'COMMUNICATION'.
          IF mv_check_communication = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.

        WHEN 'CALL'.
          IF     mv_check_call_transf = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                            it_expected  = VALUE #( ( `CALL` ) ( `TRANSFORMATION` ) ) ) > 0
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'OBJECTS' ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_memory ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
