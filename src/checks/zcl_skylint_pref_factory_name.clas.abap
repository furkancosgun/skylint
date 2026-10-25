CLASS zcl_skylint_pref_factory_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        factory_name TYPE if_ci_atc_check=>ty_finding_code VALUE 'FACT_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_FACTORY_NAME'.

    DATA mv_prefix TYPE string VALUE 'CREATE_'.

ENDCLASS.


CLASS zcl_skylint_pref_factory_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Factory methods should start with CREATE_'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-factory_name
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Factory method returning own class type should start with prefix'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                              ( name  = 'PREFIX'
                                                value = REF #( mv_prefix ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_cls_stmt    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_cls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_class_name  TYPE string.
    DATA ls_meth_tok    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_method_name TYPE string.
    DATA ls_type_tok    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_type        TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_cls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = 1 ).
    ls_cls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = ls_cls_stmt
                                                        iv_lexeme    = 'CLASS' ).
    lv_class_name = to_upper( ls_cls_tok-lexeme ).
    IF lv_class_name IS INITIAL.
      lv_class_name = to_upper( is_procedure-id-main_unit-name ).
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_stmt>
                                                 iv_lexeme    = 'RETURNING' ) = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_stmt>
                                                    it_expected  = VALUE #( ( `TYPE` ) ( `REF` ) ( `TO` ) ) ) = 0.
        CONTINUE.
      ENDIF.

      ls_type_tok = zcl_skylint_ast_util=>get_token_after_sequence(
                        is_statement = <ls_stmt>
                        it_expected  = VALUE #( ( `TYPE` ) ( `REF` ) ( `TO` ) ) ).
      lv_type = to_upper( ls_type_tok-lexeme ).
      IF lv_type <> lv_class_name.
        CONTINUE.
      ENDIF.

      ls_meth_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_stmt>
                                                           iv_lexeme    = 'CLASS-METHODS' ).
      lv_method_name = to_upper( ls_meth_tok-lexeme ).

      IF lv_method_name CP |{ to_upper( mv_prefix ) }*|.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_stmt>
                        iv_finding_code = c_finding_codes-factory_name ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
