CLASS zcl_skylint_pref_icon_const DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        use_icon_const TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_ICON',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_ICON_CONST'.

    METHODS is_icon_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_icon_const IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer ICON_ constants over hardcoded icon codes'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-use_icon_const
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use icon_ constants instead of hardcoded icon codes'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF is_icon_literal( <ls_token> ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-use_icon_const ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_icon_literal.
    DATA lv_len TYPE i.
    DATA lv_val TYPE string.

    rv_yes = abap_false.
    IF zcl_skylint_ast_util=>token_is_literal( is_token ) = abap_false.
      RETURN.
    ENDIF.

    lv_len = strlen( is_token-lexeme ).
    IF lv_len <> 6.
      RETURN.
    ENDIF.

    lv_val = substring( val = is_token-lexeme
                        off = 1
                        len = strlen( is_token-lexeme ) - 2 ).

    IF lv_val CP '@++@'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
