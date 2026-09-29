CLASS zcl_skylint_check_104 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        pref_index TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_INDX',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_LINE_INDEX'.
ENDCLASS.


CLASS zcl_skylint_check_104 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer line_index( ... ) over READ TABLE to retrieve row index'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-pref_index
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use modern line_index( ... ) expression instead of READ TABLE and sy-tabix'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx       TYPE i.
    DATA lv_count     TYPE i.
    DATA lv_has_tabix TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_count = lines( is_procedure-statements ).
    lv_idx = 1.

    WHILE lv_idx < lv_count.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_stmt>.

      IF <ls_stmt>-keyword = 'READ'.
        ASSIGN is_procedure-statements[ lv_idx + 1 ] TO <ls_next>.
        lv_has_tabix = abap_false.

        LOOP AT <ls_next>-tokens ASSIGNING <ls_tok>.
          IF to_upper( <ls_tok>-lexeme ) = 'SY-TABIX'.
            lv_has_tabix = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_has_tabix = abap_true.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-pref_index ).
        ENDIF.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
