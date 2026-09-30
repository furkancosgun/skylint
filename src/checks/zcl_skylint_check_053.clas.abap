CLASS zcl_skylint_check_053 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_like TYPE if_ci_atc_check=>ty_finding_code VALUE 'AVOID_LIKE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_LIKE_TYPE'.

ENDCLASS.


CLASS zcl_skylint_check_053 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid LIKE referencing data objects; use explicit TYPE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-avoid_like
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid LIKE for data declarations; specify TYPE explicitly'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF    <ls_statement>-keyword = 'DATA'    OR <ls_statement>-keyword = 'TYPES'
         OR <ls_statement>-keyword = 'STATICS' OR <ls_statement>-keyword = 'CONSTANTS'.
        LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
          IF to_upper( <ls_token>-lexeme ) = 'LIKE'.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-avoid_like ).
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
