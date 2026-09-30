CLASS zcl_skylint_check_025 DEFINITION
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

ENDCLASS.


CLASS zcl_skylint_check_025 IMPLEMENTATION.
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
    DATA lv_is_call        TYPE abap_bool.
    DATA ls_tok            TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_next_idx       TYPE i.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_found          TYPE abap_bool.
    DATA lv_lex            TYPE string.
    DATA lv_next_lex       TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF    <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'
         OR <ls_statement>-keyword = 'INTERFACES'.
        CONTINUE.
      ENDIF.

      lv_is_call = zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ).
      IF lv_is_call = abap_false.
        lv_is_call = zcl_skylint_rtti_util=>has_compiler_reference(
                         is_statement = <ls_statement>
                         iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
      ENDIF.

      IF lv_is_call = abap_false.
        CONTINUE.
      ENDIF.

      lv_has_receiving  = abap_false.
      lv_has_exceptions = abap_false.

      LOOP AT <ls_statement>-tokens INTO ls_tok.
        lv_next_idx = sy-tabix + 1.
        CLEAR ls_next_tok.
        zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = <ls_statement>
                                                        iv_index     = lv_next_idx
                                              IMPORTING es_token     = ls_next_tok
                                                        ev_found     = lv_found ).

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
ENDCLASS.
