CLASS zcl_skylint_check_080 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hardcoded_user TYPE if_ci_atc_check=>ty_finding_code VALUE 'HARD_UNAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_HARDCODED_USER'.
ENDCLASS.


CLASS zcl_skylint_check_080 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid hardcoded user name comparisons; enforce authorization checks'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-hardcoded_user
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid hardcoded sy-uname comparisons; use AUTHORITY-CHECK instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_uname   TYPE abap_bool.
    DATA lv_has_literal TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'IF' OR keyword = 'ELSEIF' OR keyword = 'CHECK' OR keyword = 'WHEN'.
      lv_has_uname = abap_false.
      lv_has_literal = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) = 'SY-UNAME'.
          lv_has_uname = abap_true.
        ELSEIF <ls_token>-lexeme CP '''*''' OR <ls_token>-lexeme CP '`*`'.
          lv_has_literal = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_has_uname = abap_true AND lv_has_literal = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-hardcoded_user ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
