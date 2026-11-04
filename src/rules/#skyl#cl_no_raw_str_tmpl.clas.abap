CLASS /skyl/cl_no_raw_str_tmpl DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raw_string_template TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_RAWTMPL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_RAW_STR_TMPL'.

    DATA mv_check_empty_template  TYPE abap_bool VALUE abap_true.
    DATA mv_check_static_template TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS /skyl/cl_no_raw_str_tmpl IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid string templates without embedded expressions'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-raw_string_template
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'String template has no embedded expressions { }; use string literal or backticks'
                  pseudo_comment = c_pseudo_comment ) )
            attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                         ( name  = 'CHECK_EMPTY_TEMPLATE'
                                           value = REF #( mv_check_empty_template ) )
                                         ( name  = 'CHECK_STATIC_TEMPLATE'
                                           value = REF #( mv_check_static_template ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_idx       TYPE i.
    DATA lv_j         TYPE i.
    DATA lv_total     TYPE i.
    DATA lv_has_brace TYPE abap_bool.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_scan_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_total = lines( <ls_statement>-tokens ).
      lv_idx = 1.

      WHILE lv_idx <= lv_total.
        ls_tok = <ls_statement>-tokens[ lv_idx ].

        IF ls_tok-lexeme = '|'.
          lv_has_brace = abap_false.
          lv_j = lv_idx + 1.

          WHILE lv_j <= lv_total.
            ls_scan_tok = <ls_statement>-tokens[ lv_j ].
            IF ls_scan_tok-lexeme = '{'.
              lv_has_brace = abap_true.
            ENDIF.

            IF ls_scan_tok-lexeme = '|'.
              EXIT.
            ENDIF.
            lv_j += 1.
          ENDWHILE.

          IF lv_j <= lv_total AND lv_has_brace = abap_false.
            IF    ( lv_j = lv_idx + 1 AND mv_check_empty_template  = abap_true )
               OR ( lv_j > lv_idx + 1 AND mv_check_static_template = abap_true ).
              report_token( is_token        = ls_tok
                            is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-raw_string_template ).
            ENDIF.
            lv_idx = lv_j + 1.
            CONTINUE.
          ENDIF.
        ENDIF.

        lv_idx += 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
