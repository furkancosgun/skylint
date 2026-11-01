CLASS zcl_skylint_no_hardcoded_ip DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        hardcoded_ip TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_HARD_IP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HARDCODED_IP'.

    CONSTANTS c_ipv4_pattern   TYPE string VALUE '.*(?:^|[^0-9.])([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(?:[^0-9.]|$).*'.
    CONSTANTS c_ipv6_pattern   TYPE string
              VALUE '.*(?:^|[^0-9a-fA-F:])((?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|::1)(?:[^0-9a-fA-F:]|$).*'.

    DATA mv_check_ipv4 TYPE abap_bool VALUE abap_true.
    DATA mv_check_ipv6 TYPE abap_bool VALUE abap_true.

    METHODS is_hardcoded_ip
      IMPORTING iv_lexeme     TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_hardcoded_ip IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid hardcoded IPv4 and IPv6 addresses in source code'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-hardcoded_ip
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid hardcoded IP address; use SM59 destination or hostname configuration'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_IPV4'
                                                value = REF #( mv_check_ipv4 ) )
                                              ( name  = 'CHECK_IPV6'
                                                value = REF #( mv_check_ipv6 ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF zcl_skylint_ast_util=>token_is_literal( <ls_token> ) = abap_false.
          CONTINUE.
        ENDIF.

        IF is_hardcoded_ip( <ls_token>-lexeme ) = abap_true.
          report_token( is_token        = <ls_token>
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-hardcoded_ip ).
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_hardcoded_ip.
    rv_yes = abap_false.

    IF mv_check_ipv4 = abap_true AND zcl_skylint_ast_util=>matches_regex( iv_text    = iv_lexeme
                                                                          iv_pattern = c_ipv4_pattern ) = abap_true.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF mv_check_ipv6 = abap_true AND zcl_skylint_ast_util=>matches_regex( iv_text    = iv_lexeme
                                                                          iv_pattern = c_ipv6_pattern ) = abap_true.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
