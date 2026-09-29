CLASS zcl_skylint_check_090 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        offset_magic TYPE if_ci_atc_check=>ty_finding_code VALUE 'OFFST_MAG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAGIC_OFFSET'.
ENDCLASS.


CLASS zcl_skylint_check_090 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid magic offset/length substring expressions (var+0(2))'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-offset_magic
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid magic numbers in string offset/length; use constants or functions'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_lexeme = <ls_token>-lexeme.
        IF lv_lexeme CS '+' AND lv_lexeme CS '(' AND lv_lexeme CS ')'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-offset_magic ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
