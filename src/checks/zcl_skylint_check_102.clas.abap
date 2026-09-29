CLASS zcl_skylint_check_102 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        single_chain TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHAIN_ONE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SINGLE_CHAIN'.
ENDCLASS.


CLASS zcl_skylint_check_102 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Simplify single-element colon declaration chain (DATA: lv_a TYPE i.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-single_chain
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Do not use colon chaining for a single declaration'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_first TYPE string.
    DATA lv_has_comma TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'DATA' OR keyword = 'TYPES' OR keyword = 'CONSTANTS' OR keyword = 'FIELD-SYMBOLS'.
      IF lines( <ls_stmt>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_first = to_upper( <ls_stmt>-tokens[ 1 ]-lexeme ).
      IF lv_first CP '*:' OR ( lines( <ls_stmt>-tokens ) >= 2 AND <ls_stmt>-tokens[ 2 ]-lexeme = ':' ).
        lv_has_comma = abap_false.
        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
          IF <ls_tok>-lexeme = ','.
            lv_has_comma = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_has_comma = abap_false.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-single_chain ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
