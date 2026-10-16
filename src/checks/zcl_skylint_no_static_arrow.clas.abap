CLASS zcl_skylint_no_static_arrow DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STATIC_ARROW'.
    METHODS class_of_static_call
      IMPORTING is_token        TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_class) TYPE string.

    METHODS build_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                is_token           TYPE if_ci_atc_source_code_provider=>ty_token
                iv_tok_idx         TYPE i
                iv_class           TYPE string
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_static_arrow IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid calling static methods via instance arrow (->)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code     = c_finding_codes-static_call_via_instance
                                                severity = if_ci_atc_check=>finding_severities-warning
                                                text     = 'Call static method using => instead of ->'
                                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_class_call
                                                short_text = 'Call via class name' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_tok_idx  TYPE i.
    DATA lv_class    TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_tok_idx = sy-tabix.
        lv_class = class_of_static_call( <ls_token> ).
        IF lv_class IS INITIAL.
          CONTINUE.
        ENDIF.

        ls_quickfix = build_quickfix( is_statement = <ls_statement>
                                      iv_stmt_idx  = lv_stmt_idx
                                      is_token     = <ls_token>
                                      iv_tok_idx   = lv_tok_idx
                                      iv_class     = lv_class ).

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-static_call_via_instance
                          is_quickfix     = ls_quickfix ).
        EXIT.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD class_of_static_call.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rv_class.
    IF is_token-lexeme NS '->'.
      RETURN.
    ENDIF.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF zcl_skylint_rtti_util=>is_static_method( <ls_ref>-full_name ) = abap_true.
        zcl_skylint_rtti_util=>parse_full_name( EXPORTING iv_full_name  = <ls_ref>-full_name
                                                IMPORTING ev_class_name = rv_class ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_quickfix.
    DATA lv_lex       TYPE string.
    DATA lv_arrow     TYPE i.
    DATA lv_meth      TYPE string.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.

    lv_lex = is_token-lexeme.
    FIND FIRST OCCURRENCE OF '->' IN lv_lex MATCH OFFSET lv_arrow.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_meth = substring( val = lv_lex
                         off = lv_arrow + 2 ).
    IF lv_meth IS INITIAL.
      RETURN.
    ENDIF.

    lt_overrides = VALUE #( ( index  = iv_tok_idx
                              lexeme = |{ iv_class }=>{ lv_meth }| ) ).

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_class_call
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.
ENDCLASS.
