CLASS zcl_skylint_no_wrong_wildcard DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        like_wildcard TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_LIKE_WL',
        cp_wildcard   TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CP_WILD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_WRONG_WILDCARD'.

    DATA mv_check_like TYPE abap_bool VALUE abap_true.
    DATA mv_check_cp   TYPE abap_bool VALUE abap_true.

    METHODS is_string_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS check_like_token
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_token_idx TYPE i.

    METHODS check_cp_token
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_token_idx TYPE i.
ENDCLASS.


CLASS zcl_skylint_no_wrong_wildcard IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid wrong wildcards in LIKE, CP, and NP'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-like_wildcard
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use % or _ as wildcards in LIKE comparisons instead of *'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-cp_wildcard
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use * or + as wildcards in CP and NP comparisons instead of %'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'CHECK_LIKE'
                       value = REF #( mv_check_like ) )
                     ( name  = 'CHECK_CP'
                       value = REF #( mv_check_cp ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF <ls_token>-references IS NOT INITIAL.
          CONTINUE.
        ENDIF.

        lv_idx = sy-tabix.
        IF mv_check_like = abap_true AND <ls_token>-lexeme = 'LIKE'.
          check_like_token( is_statement = <ls_statement>
                            iv_token_idx = lv_idx ).
        ELSEIF mv_check_cp = abap_true AND ( <ls_token>-lexeme = 'CP' OR <ls_token>-lexeme = 'NP' ).
          check_cp_token( is_statement = <ls_statement>
                          iv_token_idx = lv_idx ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_like_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_next = zcl_skylint_ast_util=>get_token(
        is_statement = is_statement
        iv_index     = iv_token_idx + 1 ).

    IF ls_next IS INITIAL OR is_string_literal( ls_next ) = abap_false.
      RETURN.
    ENDIF.

    IF ls_next-lexeme CA '*' AND ls_next-lexeme NA '%'.
      report_token( is_token        = ls_next
                    is_statement    = is_statement
                    iv_finding_code = c_finding_codes-like_wildcard ).
    ENDIF.
  ENDMETHOD.

  METHOD check_cp_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_next = zcl_skylint_ast_util=>get_token(
        is_statement = is_statement
        iv_index     = iv_token_idx + 1 ).

    IF ls_next IS INITIAL OR is_string_literal( ls_next ) = abap_false.
      RETURN.
    ENDIF.

    IF ls_next-lexeme CA '%' AND ls_next-lexeme NA '*'.
      report_token( is_token        = ls_next
                    is_statement    = is_statement
                    iv_finding_code = c_finding_codes-cp_wildcard ).
    ENDIF.
  ENDMETHOD.

  METHOD is_string_literal.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE string.
    DATA lv_last  TYPE string.

    rv_yes = abap_false.
    lv_len = strlen( is_token-lexeme ).
    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_first = is_token-lexeme(1).
    lv_last = substring( val = is_token-lexeme
                         off = lv_len - 1
                         len = 1 ).

    IF ( lv_first = `'` AND lv_last = `'` ) OR ( lv_first = '`' AND lv_last = '`' ).
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
