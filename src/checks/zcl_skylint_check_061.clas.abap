CLASS zcl_skylint_check_061 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        backtick TYPE if_ci_atc_check=>ty_finding_code VALUE 'BACKTICK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STRING_BACKTICK'.

ENDCLASS.


CLASS zcl_skylint_check_061 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer backtick string literals over single quotes for STRING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-backtick
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer backtick string literals over single quotes'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_is_string_context    TYPE abap_bool.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_is_string_context = abap_false.

      " Check if statement is in string type context (e.g. TYPE STRING, STRING(, etc.)
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) CS 'STRING'.
          lv_is_string_context = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_is_string_context = abap_true.
        LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
          IF strlen( <ls_token>-lexeme ) > 0 AND <ls_token>-lexeme(1) = ''''.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-backtick ).
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
