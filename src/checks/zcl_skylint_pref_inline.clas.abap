CLASS zcl_skylint_pref_inline DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_inline TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_INLINE'.

ENDCLASS.


CLASS zcl_skylint_pref_inline IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Prefer Inline Declarations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_inline
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer inline declaration over separate DATA and assignment'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tabix      TYPE i.
    DATA lv_next_idx   TYPE i.
    DATA lv_var        TYPE string.
    DATA lv_is_inline  TYPE abap_bool.
    DATA ls_next_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_first_lex  TYPE string.
    DATA lv_second_lex TYPE string.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok_next>  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'DATA'.
      lv_tabix = sy-tabix.

      IF lines( <ls_statement>-tokens ) < 4.
        CONTINUE.
      ENDIF.

      lv_var = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                       iv_index     = 2 ).
      IF lv_var = 'BEGIN' OR lv_var = 'END'.
        CONTINUE.
      ENDIF.

      lv_next_idx = lv_tabix + 1.
      IF lv_next_idx > lines( is_procedure-statements ).
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                          iv_index      = lv_next_idx ).
      lv_is_inline = abap_false.

      IF ls_next_stmt-keyword = 'COMPUTE' AND lines( ls_next_stmt-tokens ) >= 2.
        lv_first_lex  = zcl_skylint_ast_util=>get_token_lexeme( is_statement = ls_next_stmt
                                                                iv_index     = 1 ).
        lv_second_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = ls_next_stmt
                                                                iv_index     = 2 ).
        IF lv_first_lex = lv_var AND lv_second_lex = '='.
          lv_is_inline = abap_true.
        ENDIF.
      ELSEIF ls_next_stmt-keyword = 'READ' OR ls_next_stmt-keyword = 'LOOP' OR ls_next_stmt-keyword = 'SELECT'.
        LOOP AT ls_next_stmt-tokens ASSIGNING <ls_tok_next>.
          IF <ls_tok_next>-lexeme = lv_var OR <ls_tok_next>-lexeme = |@{ lv_var }|.
            lv_is_inline = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lv_is_inline = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_inline ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
