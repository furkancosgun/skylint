CLASS zcl_skylint_check_029 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_receiving TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITRECEIV',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RECEIVING_USAGE'.

    METHODS is_exempt_statement
      IMPORTING iv_keyword       TYPE string
      RETURNING VALUE(rv_exempt) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_029 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit RECEIVING in method calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_receiving
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit RECEIVING keyword; use functional call or omit parameter'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_receiving  TYPE abap_bool.
    DATA lv_has_exceptions TYPE abap_bool.
    DATA lv_tok_cnt        TYPE i.
    DATA lv_tok_idx        TYPE i.
    DATA ls_tok            TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex            TYPE string.
    DATA lv_next_lex       TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_exempt_statement( <ls_statement>-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      lv_has_receiving  = abap_false.
      lv_has_exceptions = abap_false.
      lv_tok_cnt = lines( <ls_statement>-tokens ).

      LOOP AT <ls_statement>-tokens INTO ls_tok.
        lv_tok_idx = sy-tabix.
        CLEAR ls_next_tok.
        IF lv_tok_idx < lv_tok_cnt.
          ls_next_tok = <ls_statement>-tokens[ lv_tok_idx + 1 ].
        ENDIF.

        lv_lex = to_upper( ls_tok-lexeme ).
        lv_next_lex = to_upper( ls_next_tok-lexeme ).

        IF lv_lex = 'RECEIVING' AND lv_next_lex <> '='.
          lv_has_receiving = abap_true.
        ENDIF.

        IF lv_lex = 'EXCEPTIONS' AND lv_next_lex <> '='.
          lv_has_exceptions = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_has_receiving = abap_true AND lv_has_exceptions = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_receiving ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exempt_statement.
    CASE iv_keyword.
      WHEN 'CALL' OR 'EXPORT' OR 'METHODS' OR 'CLASS-METHODS'
        OR 'EVENTS' OR 'CLASS-EVENTS' OR 'INTERFACES' OR 'SUBMIT'
        OR 'FORM' OR 'FUNCTION' OR 'MODULE'.
        rv_exempt = abap_true.
      WHEN OTHERS.
        rv_exempt = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
