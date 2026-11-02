CLASS zcl_skylint_pref_read_key DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        read_key TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_READK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_READ_KEY'.

    " WITH KEY can only express exact matches combined with AND - the WHERE
    " clause is reported only when every comparison is an equality ( = / EQ )
    METHODS clause_is_key_compatible
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_where_index TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_read_key IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'READ With WITH KEY Instead of WHERE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-read_key
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'READ TABLE WHERE - use WITH KEY so the access benefits from key optimization'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_index TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'READ'.
        CONTINUE.
      ENDIF.

      lv_index = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'WHERE' ).
      IF lv_index = 0.
        CONTINUE.
      ENDIF.

      IF clause_is_key_compatible( is_statement  = <ls_statement>
                                   iv_where_index = lv_index ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-read_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clause_is_key_compatible.
    DATA lv_eq_count TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    " non-equality operators make the condition inexpressible with WITH KEY
    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM iv_where_index + 1.
      IF <ls_token>-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      CASE <ls_token>-lexeme.
        WHEN '=' OR 'EQ'.
          lv_eq_count += 1.
        WHEN 'OR' OR 'NOT' OR 'IS' OR 'IN' OR 'LIKE' OR 'BETWEEN'
             OR 'NE' OR 'GE' OR 'LE' OR 'GT' OR 'LT'
             OR 'CS' OR 'NS' OR 'CP' OR 'NP' OR 'CO' OR 'CN' OR 'CA' OR 'NA'
             OR '<>' OR '<=' OR '>=' OR '<' OR '>' OR '><'.
          " not expressible with WITH KEY
          RETURN.
        WHEN OTHERS.
          " connectors like AND and plain operands are fine
          CONTINUE.
      ENDCASE.
    ENDLOOP.

    rv_yes = xsdbool( lv_eq_count >= 1 ).
  ENDMETHOD.
ENDCLASS.
