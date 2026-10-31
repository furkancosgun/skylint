CLASS zcl_skylint_pref_sort_order DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        specify_order TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_SORT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_SORT_ORDER'.

    DATA mv_check_by_only TYPE abap_bool VALUE abap_true.

    METHODS inspect_sort_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
ENDCLASS.


CLASS zcl_skylint_pref_sort_order IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Explicitly specify ASCENDING or DESCENDING sort order'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-specify_order
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Specify ASCENDING or DESCENDING sort order explicitly'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_BY_ONLY'
                                                                value = REF #( mv_check_by_only ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'SORT'.
        inspect_sort_statement( <ls_statement> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_sort_statement.
    DATA lv_by_idx      TYPE i.
    DATA lv_asc_idx     TYPE i.
    DATA lv_desc_idx    TYPE i.
    DATA lv_has_fields  TYPE abap_bool.
    DATA lv_field_order TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    lv_by_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                  iv_lexeme    = 'BY' ).
    lv_asc_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'ASCENDING' ).
    lv_desc_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'DESCENDING' ).

    IF lv_by_idx = 0.
      IF mv_check_by_only = abap_false AND lv_asc_idx = 0 AND lv_desc_idx = 0.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-specify_order ).
      ENDIF.
      RETURN.
    ENDIF.

    IF    ( lv_asc_idx  > 0 AND lv_asc_idx  < lv_by_idx )
       OR ( lv_desc_idx > 0 AND lv_desc_idx < lv_by_idx ).
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM lv_by_idx + 1.
      IF <ls_token>-lexeme CA '()'.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM lv_by_idx + 1.
      IF <ls_token>-references IS INITIAL AND ( <ls_token>-lexeme = 'ASCENDING' OR <ls_token>-lexeme = 'DESCENDING' ).
        lv_field_order = abap_true.
      ELSEIF <ls_token>-references IS INITIAL AND ( <ls_token>-lexeme = 'AS' OR <ls_token>-lexeme = 'TEXT' ).
        CONTINUE.
      ELSE.
        IF lv_has_fields = abap_true AND lv_field_order = abap_false.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-specify_order ).
          RETURN.
        ENDIF.

        lv_has_fields = abap_true.
        lv_field_order = abap_false.
      ENDIF.
    ENDLOOP.

    IF lv_has_fields = abap_true AND lv_field_order = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-specify_order ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
