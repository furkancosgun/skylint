CLASS zcl_skylint_no_obs_strings DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_string TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_OBS_STR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_OBS_STRINGS'.

    DATA mv_check_pack         TYPE abap_bool VALUE abap_true.
    DATA mv_check_unpack       TYPE abap_bool VALUE abap_true.
    DATA mv_check_regex        TYPE abap_bool VALUE abap_true.
    DATA mv_check_occurences   TYPE abap_bool VALUE abap_true.
    DATA mv_check_replace_into TYPE abap_bool VALUE abap_true.

    METHODS uses_posix_api
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_obs_strings IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Obsolete String and Regex Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_string
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete string statements (PACK, UNPACK, POSIX REGEX, etc.)'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_PACK'
                                                value = REF #( mv_check_pack ) )
                                              ( name  = 'CHECK_UNPACK'
                                                value = REF #( mv_check_unpack ) )
                                              ( name  = 'CHECK_REGEX'
                                                value = REF #( mv_check_regex ) )
                                              ( name  = 'CHECK_OCCURENCES'
                                                value = REF #( mv_check_occurences ) )
                                              ( name  = 'CHECK_REPLACE_INTO'
                                                value = REF #( mv_check_replace_into ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PACK'.
          IF mv_check_pack = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_string ).
          ENDIF.

        WHEN 'UNPACK'.
          IF mv_check_unpack = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_string ).
          ENDIF.

        WHEN 'FIND' OR 'REPLACE'.
          IF     mv_check_regex = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'REGEX' )      > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_string ).
          ELSEIF     mv_check_occurences = abap_true
                 AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'OCCURENCES' ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_string ).
          ELSEIF     mv_check_replace_into = abap_true
                 AND <ls_statement>-keyword = 'REPLACE'
                 AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'INTO' )       > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_string ).
          ENDIF.
      ENDCASE.

      IF mv_check_regex = abap_true AND uses_posix_api( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-obsolete_string ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD uses_posix_api.
    DATA lv_full_name TYPE string.
    DATA lv_lexeme    TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_is = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
          CONTINUE.
        ENDIF.
        lv_full_name = <ls_ref>-full_name.
        IF    lv_full_name = '\TY:CL_ABAP_REGEX\ME:CREATE_POSIX'
           OR (     lv_full_name CP '\TY:CL_ABAP_MATCHER\ME:*'
                AND contains( val = lv_full_name
                              sub = 'POSIX' ) ).
          rv_is = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      IF    lv_lexeme CP 'CL_ABAP_REGEX=>CREATE_POSIX*'
         OR lv_lexeme CP 'CL_ABAP_MATCHER=>*POSIX*'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
