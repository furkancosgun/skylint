CLASS zcl_skylint_check_078 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHECKSUBRC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHECK_SUBRC'.

    METHODS sets_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_078 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Check sy-subrc after DB, table and string operations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-check_subrc
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    DATA lv_max TYPE i.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_next_found TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_max = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_idx = sy-tabix.
      IF sets_sy_subrc( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF lv_idx = lv_max.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-check_subrc ).
      ELSE.
        get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                      iv_index      = lv_idx + 1
                            IMPORTING es_statement  = ls_next_stmt
                                      ev_found      = lv_next_found ).
        IF lv_next_found = abap_false OR checks_sy_subrc( ls_next_stmt ) = abap_false.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-check_subrc ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sets_sy_subrc.
    rv_res = abap_false.  

    "TODO listeye ASSIGN de ekleyelim
    CASE is_statement-keyword.
      WHEN 'AUTHORITY-CHECK' OR 'FIND' OR 'SEARCH'.
        rv_res = abap_true.
      WHEN 'SELECT'.
        IF matches_token_at( is_statement = is_statement
                             iv_index     = 2
                             iv_expected  = `SINGLE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
      WHEN 'READ'.
        IF matches_token_at( is_statement = is_statement
                             iv_index     = 2
                             iv_expected  = `TABLE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD checks_sy_subrc.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex  TYPE string.

    "TODO assigned neden var? compiler güvenelim
    rv_res = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      IF lv_lex = 'SY-SUBRC' OR lv_lex = 'SUBRC' OR lv_lex = 'ASSIGNED'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
