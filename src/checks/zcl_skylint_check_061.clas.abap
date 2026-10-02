CLASS zcl_skylint_check_061 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        msg_raise TYPE zif_skylint_types=>ty_finding_code VALUE 'MSG_RAISE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_MSG_RAISING'.
ENDCLASS.


CLASS zcl_skylint_check_061 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete MESSAGE ... RAISING; use class-based exceptions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-msg_raise
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE zif_skylint_types=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'MESSAGE'.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) = 'RAISING'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-msg_raise ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
