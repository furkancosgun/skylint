CLASS zcl_skylint_no_msg_raising DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        msg_raise TYPE if_ci_atc_check=>ty_finding_code VALUE 'MSG_RAISE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MSG_RAISING'.
ENDCLASS.


CLASS zcl_skylint_no_msg_raising IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete MESSAGE ... RAISING; use class-based exceptions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-msg_raise
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'MESSAGE'.
        CONTINUE.
      ENDIF.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF <ls_token>-lexeme = 'RAISING' AND <ls_token>-references IS INITIAL.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-msg_raise ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
