CLASS /skyl/cl_no_hardcoded_url DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hardcoded_url TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_HARDURL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HARDCODED_URL'.

    DATA mv_check_http TYPE abap_bool VALUE abap_true.
    DATA mv_check_ftp  TYPE abap_bool VALUE abap_true.

    METHODS is_hardcoded_url
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_hardcoded_url IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid hardcoded HTTP, HTTPS, and FTP URLs in source code'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-hardcoded_url
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid hardcoded URL; use SM59 destination or communication arrangement'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_HTTP'
                                                value = REF #( mv_check_http ) )
                                              ( name  = 'CHECK_FTP'
                                                value = REF #( mv_check_ftp ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF /skyl/cl_ast_util=>token_is_literal( <ls_token> ) = abap_false.
          CONTINUE.
        ENDIF.

        IF is_hardcoded_url( <ls_token>-lexeme ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-hardcoded_url ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_hardcoded_url.
    DATA lv_len   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_clean TYPE string.

    rv_yes = abap_false.
    lv_len = strlen( iv_lexeme ).
    IF lv_len < 10.
      RETURN.
    ENDIF.

    lv_off   = lv_len - 2.
    lv_clean = to_upper( iv_lexeme+1(lv_off) ).

    IF mv_check_http = abap_true AND ( lv_clean CP '*HTTP://+*' OR lv_clean CP '*HTTPS://+*' ).
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF mv_check_ftp = abap_true AND lv_clean CP '*FTP://+*'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
