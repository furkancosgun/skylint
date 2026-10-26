CLASS zcl_skylint_max_locals DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        local_count TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_LOCALS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_LOCALS'.

    DATA mv_max_locals TYPE i VALUE 15.

ENDCLASS.


CLASS zcl_skylint_max_locals IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit local variable count per procedure'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-local_count
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Procedure declares too many local symbols'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_LOCALS'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_locals ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_count      TYPE i.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'FIELD-SYMBOLS'.
          lv_count += 1.

        WHEN OTHERS.
          LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
            LOOP AT <ls_token>-references ASSIGNING <ls_ref>
              WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.

              IF    <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
                 OR <ls_ref>-usage_mode = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
                lv_count += 1.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.

    IF lv_count > mv_max_locals.
      ls_first_stmt = zcl_skylint_ast_util=>get_statement(
                          it_statements = is_procedure-statements
                          iv_index      = 1 ).
      IF ls_first_stmt-keyword IS NOT INITIAL.
        report_statement( is_statement    = ls_first_stmt
                          iv_finding_code = c_finding_codes-local_count ).
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.