CLASS zcl_skylint_check_063 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_sys TYPE if_ci_atc_check=>ty_finding_code VALUE 'RAISE_SYS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_RAISE_SY_EXC'.
ENDCLASS.


CLASS zcl_skylint_check_063 IMPLEMENTATION.
  METHOD constructor.
    "TODO bu kural suan sadece raise exception type durumunda calisir compiler ekleyelim
    super->constructor(
        VALUE #( description       = 'Avoid raising SAP internal system exceptions (cx_sy_*)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_sys
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid raising SAP internal system exceptions; use application exceptions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF to_upper( <ls_token>-lexeme ) CP 'CX_SY_*'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-raise_sys ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
