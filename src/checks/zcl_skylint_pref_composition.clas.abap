CLASS zcl_skylint_pref_composition DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_composition TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_COMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_COMPOSITION'.

    DATA mv_allow_test_classes TYPE abap_bool VALUE abap_false.

    METHODS is_exception_class
      IMPORTING iv_super_name   TYPE string
      RETURNING VALUE(rv_is_exc) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_composition IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer composition over inheritance'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_composition
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer composition over inheritance; only CX_* classes should inherit'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                     ( name  = 'ALLOW_TEST_CLASSES'
                       value = REF #( mv_allow_test_classes ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_super_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_super_name TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'CLASS'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>find_token_sequence(
             is_statement = <ls_stmt>
             it_expected  = VALUE #( ( `INHERITING` ) ( `FROM` ) ) ) = 0.
        CONTINUE.
      ENDIF.

      ls_super_tok = zcl_skylint_ast_util=>get_token_after_sequence(
          is_statement = <ls_stmt>
          it_expected  = VALUE #( ( `INHERITING` ) ( `FROM` ) ) ).
      lv_super_name = to_upper( ls_super_tok-lexeme ).

      IF is_exception_class( lv_super_name ) = abap_true.
        CONTINUE.
      ENDIF.

      IF     mv_allow_test_classes = abap_true
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                     iv_lexeme    = 'TESTING' ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-prefer_composition ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_exception_class.
    rv_is_exc = abap_false.
    IF iv_super_name CP 'CX_*' OR iv_super_name CP '*/CX_*' OR iv_super_name = 'CX_ROOT'.
      rv_is_exc = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
