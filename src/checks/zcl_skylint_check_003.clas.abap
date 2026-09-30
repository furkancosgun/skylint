CLASS zcl_skylint_check_003 DEFINITION
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


CLASS zcl_skylint_check_003 IMPLEMENTATION.
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
    DATA lt_expected TYPE ty_token_lexemes.
    DATA lv_matched TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lt_expected = VALUE #( ( `DEFAULT` ) ( `KEY` ) ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TYPES' OR 'DATA' OR 'STATICS' OR 'CLASS-DATA'.
          lv_matched = match_token_sequence( is_statement = <ls_statement>
                                             it_expected  = lt_expected ).
          IF lv_matched = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-default_key ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
