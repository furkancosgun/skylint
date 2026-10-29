CLASS zcl_skylint_no_exc_overlap DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        overlap TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_EXC_OVL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EXC_OVERLAP'.

ENDCLASS.


CLASS zcl_skylint_no_exc_overlap IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Classic EXCEPTIONS must not overlap'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-overlap
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Two classic exceptions share the same error number'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_seen    TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    DATA ls_number  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_exc_idx TYPE i.
    DATA lv_eq_idx  TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CALL' AND <ls_statement>-keyword = '+CALL_METHOD'.
        CONTINUE.
      ENDIF.

      lv_exc_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                     iv_lexeme    = 'EXCEPTIONS' ).
      IF lv_exc_idx = 0.
        CONTINUE.
      ENDIF.

      CLEAR lt_seen.
      lv_eq_idx = lv_exc_idx.

      DO.
        lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement   = <ls_statement>
                                                      iv_lexeme      = '='
                                                      iv_start_index = lv_eq_idx + 1 ).
        IF lv_eq_idx = 0.
          EXIT.
        ENDIF.

        ls_number = zcl_skylint_ast_util=>get_token_after( is_statement   = <ls_statement>
                                                           iv_lexeme      = '='
                                                           iv_start_index = lv_eq_idx ).

        IF zcl_skylint_ast_util=>token_is_literal( ls_number ) = abap_true.
          IF line_exists( lt_seen[ table_line = ls_number-lexeme ] ).
            report_token( is_token        = ls_number
                          is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-overlap ).
          ELSE.
            INSERT ls_number-lexeme INTO TABLE lt_seen.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
