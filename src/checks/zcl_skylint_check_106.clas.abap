CLASS zcl_skylint_check_106 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'AVOID_MOVE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_MOVE_STMT'.
ENDCLASS.


CLASS zcl_skylint_check_106 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete MOVE ... TO statement; use assignment operator ='
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-avoid_move
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use modern assignment operator (=) instead of obsolete MOVE statement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>
         WHERE keyword = 'MOVE'.
      " Exclude MOVE-CORRESPONDING
      IF lines( <ls_stmt>-tokens ) >= 2 AND to_upper( <ls_stmt>-tokens[ 2 ]-lexeme ) = 'CORRESPONDING'.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-avoid_move ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
