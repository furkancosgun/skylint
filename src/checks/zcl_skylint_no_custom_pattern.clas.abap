CLASS zcl_skylint_no_custom_pattern DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        forbidden_pattern TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CUSTOM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CUSTOM_PATTERN'.

    DATA mv_pattern TYPE string VALUE 'TODO|FIXME|XXX'.

    METHODS matches_pattern
      IMPORTING iv_text           TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_custom_pattern IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Disallow configured custom regex patterns'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-forbidden_pattern
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Source code matches forbidden custom regex pattern'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'PATTERN'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_pattern ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF mv_pattern IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      LOOP AT <ls_stmt>-tokens INTO ls_tok.
        IF matches_pattern( ls_tok-lexeme ) = abap_true.
          report_token( is_statement    = <ls_stmt>
                        is_token        = ls_tok
                        iv_finding_code = c_finding_codes-forbidden_pattern ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD matches_pattern.
    DATA lv_upper_text TYPE string.
    DATA lv_upper_pat  TYPE string.

    rv_matches = abap_false.
    lv_upper_text = to_upper( iv_text ).
    lv_upper_pat = to_upper( mv_pattern ).

    TRY.
        IF contains( val   = iv_text
                     regex = mv_pattern ).
          rv_matches = abap_true.
        ELSEIF contains( val   = lv_upper_text
                         regex = lv_upper_pat ).
          rv_matches = abap_true.
        ENDIF.
      CATCH cx_sy_regex.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
