CLASS zcl_skylint_no_unnec_return DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unnecessary_return TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNNEC_RET',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_return TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REMOVE_RET',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_UNNEC_RETURN'.

    DATA mv_allow_empty TYPE abap_bool VALUE abap_false.

ENDCLASS.


CLASS zcl_skylint_no_unnec_return IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Omit unnecessary RETURN at end of routine'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unnecessary_return
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit optional RETURN at end of routine; routines return automatically'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_return
                                                short_text = 'Remove unnecessary RETURN' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'ALLOW_EMPTY'
                                                value = REF #( mv_allow_empty ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx          TYPE i.
    DATA lv_next_idx     TYPE i.
    DATA lv_stmt_count   TYPE i.
    DATA lv_is_last      TYPE abap_bool.
    DATA ls_quickfix     TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_stmt>      TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_stmt_count = 0.
    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword IS NOT INITIAL AND <ls_stmt>-keyword <> 'METHOD'
         AND <ls_stmt>-keyword <> 'FORM' AND <ls_stmt>-keyword <> 'FUNCTION'.
        lv_stmt_count = lv_stmt_count + 1.
      ENDIF.
    ENDLOOP.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_idx = sy-tabix.

      IF <ls_stmt>-keyword <> 'RETURN'.
        CONTINUE.
      ENDIF.

      IF mv_allow_empty = abap_true AND lv_stmt_count <= 2.
        CONTINUE.
      ENDIF.

      lv_is_last = abap_false.
      lv_next_idx = lv_idx + 1.
      WHILE lv_next_idx <= lines( is_procedure-statements ).
        ASSIGN is_procedure-statements[ lv_next_idx ] TO <ls_next_stmt>.
        IF sy-subrc = 0 AND <ls_next_stmt>-keyword IS NOT INITIAL.
          IF <ls_next_stmt>-keyword = 'ENDMETHOD' OR <ls_next_stmt>-keyword = 'ENDFORM'
             OR <ls_next_stmt>-keyword = 'ENDFUNCTION'.
            lv_is_last = abap_true.
          ENDIF.
          EXIT.
        ENDIF.
        lv_next_idx = lv_next_idx + 1.
      ENDWHILE.

      IF lv_is_last = abap_true.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_return
                                        iv_statement_from = lv_idx
                                        it_new_code       = VALUE #( ) ).
        report_statement( is_statement    = <ls_stmt>
                          iv_finding_code = c_finding_codes-unnecessary_return
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
