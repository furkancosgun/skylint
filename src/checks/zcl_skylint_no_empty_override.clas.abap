CLASS zcl_skylint_no_empty_override DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_override TYPE if_ci_atc_check=>ty_finding_code VALUE 'EMPTY_OVR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EMPTY_OVERRIDE'.

    DATA mv_ignore_ctor TYPE abap_bool VALUE abap_true.

    METHODS is_super_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_empty_override IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid method override that only calls super'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_override
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Empty method override; method only delegates to super'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'IGNORE_CTOR'
                       value = REF #( mv_ignore_ctor ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_method_name TYPE string.
    DATA lt_body_stmts  TYPE if_ci_atc_source_code_provider=>ty_statements.
    DATA ls_target_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-method.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    lv_method_name = to_upper( zcl_skylint_ast_util=>get_token_lexeme( is_statement = ls_first_stmt
                                                                       iv_index     = 2 ) ).

    IF mv_ignore_ctor = abap_true AND lv_method_name = 'CONSTRUCTOR'.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF sy-tabix = 1 OR sy-tabix = lines( is_procedure-statements ).
        CONTINUE.
      ENDIF.
      IF <ls_stmt>-keyword = 'RETURN' AND sy-tabix = lines( is_procedure-statements ) - 1.
        CONTINUE.
      ENDIF.
      APPEND <ls_stmt> TO lt_body_stmts.
    ENDLOOP.

    IF lines( lt_body_stmts ) <> 1.
      RETURN.
    ENDIF.

    ls_target_stmt = lt_body_stmts[ 1 ].
    IF is_super_call( ls_target_stmt ) = abap_true.
      report_statement( is_statement    = ls_target_stmt
                        iv_finding_code = c_finding_codes-empty_override ).
    ENDIF.
  ENDMETHOD.

  METHOD is_super_call.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    IF zcl_skylint_ast_util=>statement_is_method_call( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF to_upper( ls_tok-lexeme ) CP 'SUPER->*'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
