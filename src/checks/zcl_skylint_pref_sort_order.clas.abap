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

    METHODS has_order_before_by
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_by_idx     TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS check_fields_after_by
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_by_idx    TYPE i.
ENDCLASS.


CLASS zcl_skylint_pref_sort_order IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Explicitly specify ASCENDING or DESCENDING sort order'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-specify_order
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Specify ASCENDING or DESCENDING sort order explicitly'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'CHECK_BY_ONLY'
                       value = REF #( mv_check_by_only ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'SORT'.
        CONTINUE.
      ENDIF.

      inspect_sort_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_sort_statement.
    DATA lv_by_idx TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme = 'BY' AND <ls_token>-references IS INITIAL.
        lv_by_idx = sy-tabix.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_by_idx = 0.
      IF mv_check_by_only = abap_false.
        IF has_order_before_by( is_statement = is_statement
                                iv_by_idx    = lines( is_statement-tokens ) + 1 ) = abap_false.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-specify_order ).
        ENDIF.
      ENDIF.
      RETURN.
    ENDIF.

    IF has_order_before_by( is_statement = is_statement
                            iv_by_idx    = lv_by_idx ) = abap_true.
      RETURN.
    ENDIF.

    check_fields_after_by( is_statement = is_statement
                           iv_by_idx    = lv_by_idx ).
  ENDMETHOD.

  METHOD has_order_before_by.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    DO iv_by_idx - 1 TIMES.
      lv_idx = sy-index.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_token>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      IF <ls_token>-references IS INITIAL AND
         ( <ls_token>-lexeme = 'ASCENDING' OR <ls_token>-lexeme = 'DESCENDING' ).
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD check_fields_after_by.
    DATA lv_has_fields  TYPE abap_bool VALUE abap_false.
    DATA lv_field_order TYPE abap_bool VALUE abap_false.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM iv_by_idx + 1.
      IF <ls_token>-lexeme CA '()'.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM iv_by_idx + 1.
      IF <ls_token>-references IS INITIAL AND
         ( <ls_token>-lexeme = 'ASCENDING' OR <ls_token>-lexeme = 'DESCENDING' ).
        lv_field_order = abap_true.
      ELSEIF <ls_token>-references IS INITIAL AND
             ( <ls_token>-lexeme = 'AS' OR <ls_token>-lexeme = 'TEXT' ).
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
