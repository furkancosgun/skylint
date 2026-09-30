CLASS zcl_skylint_check_052 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dangerous_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'DANGER_STM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DANGEROUS_STMT'.

    METHODS is_dangerous_statement
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_052 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Dangerous / Unmanaged Dynamic Statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-dangerous_statement
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Dangerous or unmanaged dynamic statement detected'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_dangerous_statement( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-dangerous_statement ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dangerous_statement.
    DATA ls_tok1 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.

    rv_res = abap_false.

    IF is_statement-keyword = 'SYNTAX-CHECK' OR is_statement-keyword = 'SYSTEM-CALL'.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF lines( is_statement-tokens ) < 2.
      RETURN.
    ENDIF.

    READ TABLE is_statement-tokens INDEX 1 INTO ls_tok1.
    IF sy-subrc = 0.
      READ TABLE is_statement-tokens INDEX 2 INTO ls_tok2.
      IF sy-subrc = 0.
        lv_tok1 = to_upper( ls_tok1-lexeme ).
        lv_tok2 = to_upper( ls_tok2-lexeme ).

        IF    ( lv_tok1 = 'SYNTAX'   AND lv_tok2 = 'CHECK' )
           OR ( lv_tok1 = 'SYSTEM'   AND lv_tok2 = 'CALL' )
           OR ( lv_tok1 = 'GENERATE' AND lv_tok2 = 'SUBROUTINE' )
           OR ( lv_tok1 = 'INSERT'   AND lv_tok2 = 'REPORT' )
           OR ( lv_tok1 = 'DELETE'   AND lv_tok2 = 'REPORT' )
           OR ( lv_tok1 = 'READ'     AND lv_tok2 = 'REPORT' ).
          rv_res = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
