CLASS zcl_skylint_check_079 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        param_escape TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAM_ESCP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'UNNECESSARY_ESCAPE'.
ENDCLASS.


CLASS zcl_skylint_check_079 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect unnecessary exclamation mark parameter escape (!iv_param)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-param_escape
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Only escape parameter names with ! if they clash with an ABAP keyword'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
        IF <ls_tok>-lexeme CP '!*'.
          "TODO asagidaki hicbir if'e gerek yok silinsin direkt raporlanabilir
          lv_name = to_upper( <ls_tok>-lexeme+1 ).
          IF     lv_name <> 'EXPORTING' AND lv_name <> 'IMPORTING'
             AND lv_name <> 'CHANGING'  AND lv_name <> 'RETURNING'
             AND lv_name <> 'TABLES'    AND lv_name <> 'VALUE'
             AND lv_name <> 'REFERENCE' AND lv_name <> 'DEFAULT'.
            report_statement( is_statement    = <ls_stmt>
                              iv_finding_code = c_finding_codes-param_escape ).
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
