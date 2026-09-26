CLASS zcl_skylint_check_004 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        default_key TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEFAULTKEY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEFAULT_KEY'.

ENDCLASS.


CLASS zcl_skylint_check_004 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-default_key
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_prev_lexeme TYPE string.
    DATA lv_curr_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TYPES' OR keyword = 'DATA' OR keyword = 'STATICS' OR keyword = 'CLASS-DATA'.
      CLEAR lv_prev_lexeme.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_curr_lexeme = to_upper( <ls_token>-lexeme ).
        IF lv_prev_lexeme = 'DEFAULT' AND lv_curr_lexeme = 'KEY'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-default_key ).
          EXIT.
        ENDIF.
        lv_prev_lexeme = lv_curr_lexeme.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
