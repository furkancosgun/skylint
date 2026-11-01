CLASS zcl_skylint_no_into_fs DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        into_field_symbol TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTO_FS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INTO_FS'.

ENDCLASS.


CLASS zcl_skylint_no_into_fs IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Do not use INTO with a field symbol; use ASSIGNING instead'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-into_field_symbol
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Do not use INTO with a field symbol; use ASSIGNING instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_into_idx TYPE i.
    DATA ls_target   TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'READ' AND <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      lv_into_idx = zcl_skylint_ast_util=>find_token(
                        is_statement = <ls_statement>
                        iv_lexeme    = 'INTO' ).
      IF lv_into_idx <= 0 OR lv_into_idx >= lines( <ls_statement>-tokens ).
        CONTINUE.
      ENDIF.

      ls_target = zcl_skylint_ast_util=>get_token(
                      is_statement = <ls_statement>
                      iv_index     = lv_into_idx + 1 ).

      IF ls_target-lexeme(1) = '<' AND ls_target-lexeme CP '*>'.
        report_statement(
            is_statement    = <ls_statement>
            iv_finding_code = c_finding_codes-into_field_symbol ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
