CLASS zcl_skylint_check_050 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        magic_number TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAGIC_NUM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAGIC_NUMBER'.

ENDCLASS.


CLASS zcl_skylint_check_050 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid magic numbers in code; use named constants'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-magic_number
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid hardcoded magic numbers; declare a named constant'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " Skip declarations (DATA, CONSTANTS, TYPES, STATICS)
      IF    <ls_statement>-keyword = 'DATA'  OR <ls_statement>-keyword = 'CONSTANTS'
         OR <ls_statement>-keyword = 'TYPES' OR <ls_statement>-keyword = 'STATICS'.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        " Semantic identifiers resolved by compiler are not raw numeric literals
        IF <ls_token>-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        IF <ls_token>-lexeme IS INITIAL.
          CONTINUE.
        ENDIF.

        " Detect hardcoded numeric literals (excluding standard 0 and 1 indices)
        IF <ls_token>-lexeme CO '0123456789' AND <ls_token>-lexeme <> '0' AND <ls_token>-lexeme <> '1'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-magic_number ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
