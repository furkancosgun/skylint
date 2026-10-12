CLASS zcl_skylint_check_026 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_call_via_instance TYPE if_ci_atc_check=>ty_finding_code VALUE 'STATICVIAI',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_class_call TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'STATICCL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS class_of_static_call
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_class) TYPE string.

ENDCLASS.


CLASS zcl_skylint_check_026 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid calling static methods via instance arrow (->)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code     = c_finding_codes-static_call_via_instance
                                                 severity = if_ci_atc_check=>finding_severities-warning
                                                 text     = 'Call static method using => instead of ->' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_class_call
                                                                short_text = 'Call via class name' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_tok_idx  TYPE i.
    DATA lv_class    TYPE string.
    DATA lv_lex      TYPE string.
    DATA lv_arrow    TYPE i.
    DATA lv_off      TYPE i.
    DATA lv_meth     TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_check_base=>ty_token_overrides.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements INTO ls_stmt.
      lv_stmt_idx = sy-tabix.
      lv_tok_idx = 0.
      LOOP AT ls_stmt-tokens INTO ls_tok.
        lv_tok_idx += 1.
        lv_class = class_of_static_call( ls_tok ).
        IF lv_class IS NOT INITIAL.
          CLEAR ls_quickfix.
          CLEAR lt_overrides.
          lv_lex = ls_tok-lexeme.
          FIND FIRST OCCURRENCE OF '->' IN lv_lex MATCH OFFSET lv_arrow.
          IF sy-subrc = 0.
            lv_off = lv_arrow + 2.
            lv_meth = substring( val = lv_lex
                                 off = lv_off ).
            IF lv_meth CP '*(' AND strlen( lv_meth ) > 1.
              lv_meth = substring( val = lv_meth
                                   len = strlen( lv_meth ) - 1 ).
            ENDIF.
            IF lv_meth IS NOT INITIAL.
              lt_overrides = VALUE #( ( index  = lv_tok_idx
                                        lexeme = |{ lv_class }=>{ lv_meth }| ) ).
              lv_line = flatten_statement( is_statement = ls_stmt
                                           it_overrides = lt_overrides ).
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_class_call
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
            ENDIF.
          ENDIF.
          report_statement( is_statement    = ls_stmt
                            iv_finding_code = c_finding_codes-static_call_via_instance
                            is_quickfix     = ls_quickfix ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD class_of_static_call.
    DATA ls_ref   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lv_upper TYPE string.
    DATA lv_head  TYPE string.
    DATA lv_meth  TYPE string.
    DATA lv_off   TYPE i.
    DATA lv_len   TYPE i.
    DATA lv_char  TYPE c LENGTH 1.

    CLEAR rv_class.

    IF is_token-lexeme NS '->'.
      RETURN.
    ENDIF.

    LOOP AT is_token-references INTO ls_ref
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF zcl_skylint_rtti_util=>is_static_method( ls_ref-full_name ) = abap_false.
        CONTINUE.
      ENDIF.
      lv_upper = to_upper( ls_ref-full_name ).
      SPLIT lv_upper AT '\ME:' INTO lv_head lv_meth.
      IF sy-subrc <> 0 OR lv_meth IS INITIAL.
        CONTINUE.
      ENDIF.
      WHILE strlen( lv_head ) > 0 AND lv_head CP '*\'.
        lv_len = strlen( lv_head ) - 1.
        lv_head = lv_head(lv_len).
      ENDWHILE.
      IF lv_head CA '\'.
        lv_off = strlen( lv_head ) - 1.
        WHILE lv_off >= 0.
          lv_char = lv_head+lv_off(1).
          IF lv_char = '\'.
            EXIT.
          ENDIF.
          lv_off -= 1.
        ENDWHILE.
        IF lv_off >= 0.
          lv_off += 1.
          lv_head = substring( val = lv_head
                               off = lv_off ).
        ENDIF.
      ENDIF.
      IF lv_head CP '*TY:*'.
        SPLIT lv_head AT 'TY:' INTO lv_meth lv_head.
      ENDIF.
      IF lv_head IS NOT INITIAL AND lv_head CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/'.
        rv_class = lv_head.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
