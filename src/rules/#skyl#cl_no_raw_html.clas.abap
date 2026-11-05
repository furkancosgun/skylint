CLASS /skyl/cl_no_raw_html DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raw_html TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RAWHTML',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_RAW_HTML'.
    CONSTANTS c_script_pattern TYPE string VALUE '.*<[/ ]*(script|iframe).*'.
    CONSTANTS c_tags_pattern   TYPE string
                               VALUE '.*<[/ ]*(html|body|div|span|table|thead|tbody|tr|td|th|form|input|img|a\b|p\b).*'.

    DATA mv_check_scripts TYPE abap_bool VALUE abap_true.
    DATA mv_check_tags    TYPE abap_bool VALUE abap_true.

    METHODS is_raw_html
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_raw_html IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid raw unescaped HTML tags in strings and templates'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-raw_html
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Avoid hardcoded raw HTML; use UI5, BSP, or cl_abap_format/escape to prevent XSS'
                  pseudo_comment = c_pseudo_comment ) )
            attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                         ( name  = 'CHECK_SCRIPTS'
                                           value = REF #( mv_check_scripts ) )
                                         ( name  = 'CHECK_TAGS'
                                           value = REF #( mv_check_tags ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF /skyl/cl_ast_util=>token_is_literal( <ls_token> ) = abap_false.
          CONTINUE.
        ENDIF.

        IF is_raw_html( <ls_token>-lexeme ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-raw_html ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raw_html.
    DATA lv_lower TYPE string.

    rv_yes = abap_false.
    lv_lower = to_lower( iv_lexeme ).

    IF lv_lower NA '<'.
      RETURN.
    ENDIF.

    IF     mv_check_scripts = abap_true
       AND /skyl/cl_ast_util=>matches_regex( iv_text    = lv_lower
                                             iv_pattern = c_script_pattern
                                             iv_pcre    = abap_true )      = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF     mv_check_tags = abap_true
       AND /skyl/cl_ast_util=>matches_regex( iv_text    = lv_lower
                                             iv_pattern = c_tags_pattern
                                             iv_pcre    = abap_true )    = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
