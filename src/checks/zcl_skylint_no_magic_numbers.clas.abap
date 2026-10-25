CLASS zcl_skylint_no_magic_numbers DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        magic_number TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_MAGIC_N',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_MAGIC_NUMBERS'.
ENDCLASS.


CLASS zcl_skylint_no_magic_numbers IMPLEMENTATION.
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
      IF    <ls_statement>-keyword = 'DATA'  OR <ls_statement>-keyword = 'CONSTANTS'
         OR <ls_statement>-keyword = 'TYPES' OR <ls_statement>-keyword = 'STATICS'.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF     <ls_token>-lexeme      = 'EXCEPTIONS'
           AND <ls_token>-references IS INITIAL.
          EXIT.
        ENDIF.

        IF <ls_token>-lexeme CO '0123456789' AND <ls_token>-lexeme <> '0' AND <ls_token>-lexeme <> '1'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-magic_number ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
