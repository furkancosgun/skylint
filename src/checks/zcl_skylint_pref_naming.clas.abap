CLASS zcl_skylint_pref_naming DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_attribute  TYPE if_ci_atc_check=>ty_finding_code VALUE 'ATTR_NAME',
        method_parameter TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAM_NAME',
        local_variable   TYPE if_ci_atc_check=>ty_finding_code VALUE 'LVAR_NAME',
        local_class      TYPE if_ci_atc_check=>ty_finding_code VALUE 'LCLS_NAME',
        global_class     TYPE if_ci_atc_check=>ty_finding_code VALUE 'GCLS_NAME',
        selection_screen TYPE if_ci_atc_check=>ty_finding_code VALUE 'SCSCR_NAME',
        types            TYPE if_ci_atc_check=>ty_finding_code VALUE 'TYPE_NAME',
        macro            TYPE if_ci_atc_check=>ty_finding_code VALUE 'MACRO_NAME',
        form             TYPE if_ci_atc_check=>ty_finding_code VALUE 'FORM_NAME',
        function_module  TYPE if_ci_atc_check=>ty_finding_code VALUE 'FUNC_NAME',
        local_interface  TYPE if_ci_atc_check=>ty_finding_code VALUE 'INTF_NAME',
        global_interface TYPE if_ci_atc_check=>ty_finding_code VALUE 'GINTF_NAME',
        event            TYPE if_ci_atc_check=>ty_finding_code VALUE 'EVENT_NAME',
        test_method      TYPE if_ci_atc_check=>ty_finding_code VALUE 'TMETH_NAME',
        program          TYPE if_ci_atc_check=>ty_finding_code VALUE 'PROG_NAME',
        function_group   TYPE if_ci_atc_check=>ty_finding_code VALUE 'FUGR_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NAMING'.

    " Class Attribute Names
    DATA mv_attr_ignore_exceptions  TYPE abap_bool VALUE abap_true.
    DATA mv_attr_ignore_local       TYPE abap_bool VALUE abap_true.
    DATA mv_attr_ignore_interfaces  TYPE abap_bool VALUE abap_false.
    DATA mv_attr_statics            TYPE string    VALUE '^G._.+$'.
    DATA mv_attr_instance           TYPE string    VALUE '^M._.+$'.
    DATA mv_attr_constants          TYPE string    VALUE ''.

    " Method Parameter Names
    DATA mv_param_ignore_exceptions TYPE abap_bool VALUE abap_true.
    DATA mv_param_importing         TYPE string    VALUE '^I._.+$'.
    DATA mv_param_returning         TYPE string    VALUE '^R._.+$'.
    DATA mv_param_changing          TYPE string    VALUE '^C._.+$'.
    DATA mv_param_exporting         TYPE string    VALUE '^E._.+$'.

    " Local Variable Names
    DATA mv_local_data              TYPE string    VALUE '^L._.+$'.
    DATA mv_local_constant          TYPE string    VALUE '^LC_.+$'.
    DATA mv_local_fs                TYPE string    VALUE '^<L._.+>$'.
    DATA mv_local_statics           TYPE string    VALUE '^S._.+$'.

    " Class Names (abaplint unified pattern style)
    DATA mv_class_global            TYPE string    VALUE '^ZC(L|X)_.+$'.
    DATA mv_class_local             TYPE string    VALUE '^LC(L|X)_.+$'.
    DATA mv_class_test              TYPE string    VALUE '^LTCL_.+$'.

    " Selection Screen Names
    DATA mv_sscreen_parameter       TYPE string    VALUE '^P_.+$'.
    DATA mv_sscreen_select_option   TYPE string    VALUE '^S_.+$'.

    " Types Naming
    DATA mv_types_pattern           TYPE string    VALUE '^TY_.+$'.

    " Macro Naming
    DATA mv_macro_pattern           TYPE string    VALUE '^_.+$'.

    " Form Naming
    DATA mv_form_pattern            TYPE string    VALUE '^F_.+$'.

    " Function Module Naming
    DATA mv_function_pattern        TYPE string    VALUE '^Z.*$'.

    " Interface Naming
    DATA mv_intf_local              TYPE string    VALUE '^LIF_.+$'.
    DATA mv_intf_global             TYPE string    VALUE '^ZIF_.+$'.

    " Event Naming
    DATA mv_event_name              TYPE string    VALUE '^[A-Z][A-Z0-9_]+$'.
    DATA mv_event_handler           TYPE string    VALUE '^ON_.+$'.

    " Test Method Naming
    DATA mv_test_method             TYPE string    VALUE '^(TEST|SHOULD)_.+$'.

    " Program & Function Group Naming
    DATA mv_program_pattern         TYPE string    VALUE '^Z.+$'.
    DATA mv_fugr_pattern            TYPE string    VALUE '^Z.+$'.

    METHODS matches_pattern
      IMPORTING iv_text           TYPE string
                iv_pattern        TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS get_stmt_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

    METHODS extract_name_from_paren
      IMPORTING iv_lexeme      TYPE string
      RETURNING VALUE(rv_name) TYPE string.

    METHODS is_global_class
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_global) TYPE abap_bool.

    METHODS is_global_interface
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_global) TYPE abap_bool.

    METHODS is_exception_class
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_exception) TYPE abap_bool.

    METHODS check_class_definition
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS check_class_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_interface_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_class_attribute
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_event_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_definition
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_skip_params TYPE abap_bool.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_param_by_section
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_section   TYPE string
                iv_lexeme    TYPE string.

    METHODS check_types_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_procedure_body
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS check_decl_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

    METHODS check_var_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_pref_naming IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Standard Naming Conventions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity       = if_ci_atc_check=>finding_severities-warning
                     pseudo_comment = c_pseudo_comment
                     ( code = c_finding_codes-class_attribute
                       text = 'Class attribute name does not match configured pattern' )
                     ( code = c_finding_codes-method_parameter
                       text = 'Method parameter name does not match configured pattern' )
                     ( code = c_finding_codes-local_variable
                       text = 'Local variable name does not match configured pattern' )
                     ( code = c_finding_codes-local_class
                       text = 'Local class name does not match configured pattern' )
                     ( code = c_finding_codes-global_class
                       text = 'Global class name does not match configured pattern' )
                     ( code = c_finding_codes-selection_screen
                       text = 'Selection screen element name does not match configured pattern' )
                     ( code = c_finding_codes-types
                       text = 'Type name does not match configured pattern' )
                     ( code = c_finding_codes-macro
                       text = 'Macro name does not match configured pattern' )
                     ( code = c_finding_codes-form
                       text = 'Form routine name does not match configured pattern' )
                     ( code = c_finding_codes-function_module
                       text = 'Function module name does not match configured pattern' )
                     ( code = c_finding_codes-local_interface
                       text = 'Local interface name does not match configured pattern' )
                     ( code = c_finding_codes-global_interface
                       text = 'Global interface name does not match configured pattern' )
                     ( code = c_finding_codes-event
                       text = 'Event or event handler name does not match configured pattern' )
                     ( code = c_finding_codes-test_method
                       text = 'Test method name does not match configured pattern' )
                     ( code = c_finding_codes-program
                       text = 'Program name does not match configured pattern' )
                     ( code = c_finding_codes-function_group
                       text = 'Function group name does not match configured pattern' ) )
                 attributes        = VALUE #( ( name  = 'ATTR_IGN_EXC'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_attr_ignore_exceptions ) )
                                              ( name  = 'ATTR_IGN_LOCAL'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_attr_ignore_local ) )
                                              ( name  = 'ATTR_IGN_INTF'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_attr_ignore_interfaces ) )
                                              ( name  = 'ATTR_STATICS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_attr_statics ) )
                                              ( name  = 'ATTR_INSTANCE'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_attr_instance ) )
                                              ( name  = 'ATTR_CONSTANTS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_attr_constants ) )
                                              ( name  = 'PARAM_IGN_EXC'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_param_ignore_exceptions ) )
                                              ( name  = 'PARAM_IMPORTING'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_param_importing ) )
                                              ( name  = 'PARAM_RETURNING'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_param_returning ) )
                                              ( name  = 'PARAM_CHANGING'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_param_changing ) )
                                              ( name  = 'PARAM_EXPORTING'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_param_exporting ) )
                                              ( name  = 'LOCAL_DATA'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_local_data ) )
                                              ( name  = 'LOCAL_CONST'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_local_constant ) )
                                              ( name  = 'LOCAL_FS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_local_fs ) )
                                              ( name  = 'LOCAL_STATICS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_local_statics ) )
                                              ( name  = 'CLASS_LOCAL'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_class_local ) )
                                              ( name  = 'CLASS_TEST'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_class_test ) )
                                              ( name  = 'CLASS_GLOBAL'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_class_global ) )
                                              ( name  = 'SSCR_PARAM'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_sscreen_parameter ) )
                                              ( name  = 'SSCR_SELOPT'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_sscreen_select_option ) )
                                              ( name  = 'TYPES_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_types_pattern ) )
                                              ( name  = 'MACRO_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_macro_pattern ) )
                                              ( name  = 'FORM_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_form_pattern ) )
                                              ( name  = 'FUNCTION_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_function_pattern ) )
                                              ( name  = 'INTF_LOCAL'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_intf_local ) )
                                              ( name  = 'INTF_GLOBAL'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_intf_global ) )
                                              ( name  = 'EVENT_NAME'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_event_name ) )
                                              ( name  = 'EVENT_HANDLER'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_event_handler ) )
                                              ( name  = 'TEST_METHOD'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_test_method ) )
                                              ( name  = 'PROG_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_program_pattern ) )
                                              ( name  = 'FUGR_PATTERN'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_fugr_pattern ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      check_class_definition( is_procedure-statements ).
    ELSE.
      check_procedure_body( is_procedure-statements ).
    ENDIF.
  ENDMETHOD.

  METHOD matches_pattern.
    DATA lv_val TYPE string.
    DATA lv_pat TYPE string.

    IF iv_pattern IS INITIAL.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    lv_val = to_upper( condense( iv_text ) ).
    lv_pat = to_upper( condense( iv_pattern ) ).

    TRY.
        rv_matches = matches( val  = lv_val
                              pcre = lv_pat ).
      CATCH cx_root.
        rv_matches = abap_true.
    ENDTRY.
  ENDMETHOD.

  METHOD get_stmt_name.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `BEGIN` ) ( `OF` ) ) ) > 0.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'OF' ).
      rv_name = ls_tok-lexeme.
    ELSEIF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                      it_expected  = VALUE #( ( `END` ) ( `OF` ) ) ) > 0.
      RETURN.
    ELSE.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = is_statement-keyword ).
      rv_name = ls_tok-lexeme.
    ENDIF.
  ENDMETHOD.

  METHOD extract_name_from_paren.
    DATA lv_len TYPE i.
    DATA lv_pos TYPE i.

    rv_name = iv_lexeme.
    lv_pos = find( val = iv_lexeme
                   sub = '(' ).
    IF lv_pos < 0.
      RETURN.
    ENDIF.

    lv_pos += 1.
    lv_len = strlen( iv_lexeme ) - lv_pos.
    IF     lv_len > 0
       AND substring( val = iv_lexeme
                      off = strlen( iv_lexeme ) - 1
                      len = 1 ) = ')'.
      lv_len -= 1.
    ENDIF.

    IF lv_len > 0.
      rv_name = substring( val = iv_lexeme
                           off = lv_pos
                           len = lv_len ).
    ENDIF.
    rv_name = condense( rv_name ).
  ENDMETHOD.

  METHOD is_global_class.
    DATA lv_prev TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_global = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-references IS INITIAL.
        IF to_upper( <ls_tok>-lexeme ) = 'PUBLIC' AND lv_prev <> 'CREATE'.
          rv_global = abap_true.
          RETURN.
        ENDIF.
        lv_prev = to_upper( <ls_tok>-lexeme ).
      ELSE.
        CLEAR lv_prev.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_global_interface.
    rv_global = xsdbool( zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                           iv_lexeme    = 'PUBLIC' ) > 0 ).
  ENDMETHOD.

  METHOD is_exception_class.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_exception = abap_false.
    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `INHERITING` ) ( `FROM` ) ) ) > 0.
      ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'FROM' ).
      IF to_upper( ls_tok-lexeme ) CP '*CX_*' OR to_upper( ls_tok-lexeme ) = 'CX_ROOT'.
        rv_exception = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD check_class_definition.
    DATA lv_is_intf     TYPE abap_bool.
    DATA lv_is_local    TYPE abap_bool.
    DATA lv_is_exc      TYPE abap_bool.
    DATA lv_skip_attrs  TYPE abap_bool.
    DATA lv_skip_params TYPE abap_bool.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword = 'INTERFACE'.
        lv_is_intf = abap_true.
        lv_is_local = xsdbool( is_global_interface( <ls_stmt> ) = abap_false ).
        EXIT.
      ELSEIF     <ls_stmt>-keyword = 'CLASS'
             AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_stmt>
                                                            it_expected  = VALUE #( ( `DEFINITION` ) ) ) > 0.
        lv_is_exc = is_exception_class( <ls_stmt> ).
        lv_is_local = xsdbool( is_global_class( <ls_stmt> ) = abap_false ).
        EXIT.
      ENDIF.
    ENDLOOP.

    IF    ( lv_is_intf  = abap_true AND mv_attr_ignore_interfaces = abap_true )
       OR ( lv_is_local = abap_true AND mv_attr_ignore_local      = abap_true )
       OR ( lv_is_exc   = abap_true AND mv_attr_ignore_exceptions = abap_true ).
      lv_skip_attrs = abap_true.
    ENDIF.

    IF lv_is_exc = abap_true AND mv_param_ignore_exceptions = abap_true.
      lv_skip_params = abap_true.
    ENDIF.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'CLASS'.
          IF zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_stmt>
                                                        it_expected  = VALUE #( ( `DEFINITION` ) ) ) > 0.
            check_class_statement( <ls_stmt> ).
          ENDIF.

        WHEN 'INTERFACE'.
          check_interface_statement( <ls_stmt> ).

        WHEN 'DATA' OR 'CLASS-DATA' OR 'CONSTANTS'.
          IF lv_skip_attrs = abap_false.
            check_class_attribute( <ls_stmt> ).
          ENDIF.

        WHEN 'EVENTS' OR 'CLASS-EVENTS'.
          check_event_statement( <ls_stmt> ).

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          check_method_definition( is_statement   = <ls_stmt>
                                   iv_skip_params = lv_skip_params ).

        WHEN 'TYPES'.
          check_types_statement( <ls_stmt> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_class_statement.
    DATA lv_name  TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_token = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'CLASS' ).
    lv_name = ls_token-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) > 0.
      IF matches_pattern( iv_text    = lv_name
                          iv_pattern = mv_class_test ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-local_class ).
      ENDIF.
      RETURN.
    ENDIF.

    IF is_global_class( is_statement ) = abap_true.
      IF matches_pattern( iv_text    = lv_name
                          iv_pattern = mv_class_global ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-global_class ).
      ENDIF.
    ELSEIF matches_pattern( iv_text    = lv_name
                            iv_pattern = mv_class_local ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-local_class ).
    ENDIF.
  ENDMETHOD.

  METHOD check_interface_statement.
    DATA lv_name  TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_token = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'INTERFACE' ).
    lv_name = ls_token-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF is_global_interface( is_statement ) = abap_true.
      IF matches_pattern( iv_text    = lv_name
                          iv_pattern = mv_intf_global ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-global_interface ).
      ENDIF.
    ELSEIF matches_pattern( iv_text    = lv_name
                            iv_pattern = mv_intf_local ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-local_interface ).
    ENDIF.
  ENDMETHOD.

  METHOD check_class_attribute.
    DATA lv_name TYPE string.

    lv_name = get_stmt_name( is_statement ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'CLASS-DATA'.
        IF matches_pattern( iv_text    = lv_name
                            iv_pattern = mv_attr_statics ) = abap_false.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-class_attribute ).
        ENDIF.

      WHEN 'DATA'.
        IF matches_pattern( iv_text    = lv_name
                            iv_pattern = mv_attr_instance ) = abap_false.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-class_attribute ).
        ENDIF.

      WHEN 'CONSTANTS'.
        IF     mv_attr_constants IS NOT INITIAL
           AND matches_pattern( iv_text    = lv_name
                                iv_pattern = mv_attr_constants )  = abap_false.
          report_statement( is_statement    = is_statement
                            iv_finding_code = c_finding_codes-class_attribute ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD check_event_statement.
    DATA lv_name TYPE string.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = is_statement-keyword ).
    lv_name = ls_tok-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = mv_event_name ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-event ).
    ENDIF.
  ENDMETHOD.

  METHOD check_method_definition.
    DATA lv_name TYPE string.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = is_statement-keyword ).
    lv_name = ls_tok-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `FOR` ) ( `EVENT` ) ) ) > 0.
      IF matches_pattern( iv_text    = lv_name
                          iv_pattern = mv_event_handler ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-event ).
      ENDIF.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) > 0.
      IF matches_pattern( iv_text    = lv_name
                          iv_pattern = mv_test_method ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-test_method ).
      ENDIF.
      RETURN.
    ENDIF.

    IF iv_skip_params = abap_false.
      check_method_parameters( is_statement ).
    ENDIF.
  ENDMETHOD.

  METHOD check_method_parameters.
    DATA lv_section  TYPE string.
    DATA ls_prev_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-references IS NOT INITIAL.
        ls_prev_tok = <ls_tok>.
        CONTINUE.
      ENDIF.

      CASE <ls_tok>-lexeme.
        WHEN 'IMPORTING' OR 'EXPORTING' OR 'CHANGING' OR 'RETURNING'.
          lv_section = <ls_tok>-lexeme.

        WHEN 'RAISING' OR 'EXCEPTIONS' OR 'FOR' OR 'REDEFINITION' OR 'ABSTRACT' OR 'FINAL'.
          CLEAR lv_section.

        WHEN 'TYPE' OR 'LIKE'.
          IF lv_section IS NOT INITIAL AND ls_prev_tok-lexeme IS NOT INITIAL.
            check_param_by_section( is_statement = is_statement
                                    iv_section   = lv_section
                                    iv_lexeme    = ls_prev_tok-lexeme ).
          ENDIF.
      ENDCASE.

      ls_prev_tok = <ls_tok>.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_param_by_section.
    DATA lv_name    TYPE string.
    DATA lv_pattern TYPE string.

    lv_name = extract_name_from_paren( iv_lexeme ).
    CASE iv_section.
      WHEN 'IMPORTING'.
        lv_pattern = mv_param_importing.
      WHEN 'EXPORTING'.
        lv_pattern = mv_param_exporting.
      WHEN 'CHANGING'.
        lv_pattern = mv_param_changing.
      WHEN 'RETURNING'.
        lv_pattern = mv_param_returning.
    ENDCASE.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = lv_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-method_parameter ).
    ENDIF.
  ENDMETHOD.

  METHOD check_procedure_body.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'REPORT' OR 'PROGRAM'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_program_pattern
                           iv_finding_code = c_finding_codes-program ).

        WHEN 'FUNCTION-POOL'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_fugr_pattern
                           iv_finding_code = c_finding_codes-function_group ).

        WHEN 'FUNCTION'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_function_pattern
                           iv_finding_code = c_finding_codes-function_module ).

        WHEN 'FORM'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_form_pattern
                           iv_finding_code = c_finding_codes-form ).

        WHEN 'DATA'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_data
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'STATICS'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_statics
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'CONSTANTS'.
          check_var_name( is_statement    = <ls_statement>
                          iv_pattern      = mv_local_constant
                          iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'FIELD-SYMBOLS'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_local_fs
                           iv_finding_code = c_finding_codes-local_variable ).

        WHEN 'PARAMETERS' OR 'PARAMETER'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_sscreen_parameter
                           iv_finding_code = c_finding_codes-selection_screen ).

        WHEN 'SELECT-OPTIONS'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_sscreen_select_option
                           iv_finding_code = c_finding_codes-selection_screen ).

        WHEN 'TYPES'.
          check_types_statement( <ls_statement> ).

        WHEN 'DEFINE'.
          check_decl_name( is_statement    = <ls_statement>
                           iv_pattern      = mv_macro_pattern
                           iv_finding_code = c_finding_codes-macro ).

        WHEN OTHERS.
          check_inline_declarations( <ls_statement> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_name.
    DATA lv_name TYPE string.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = is_statement-keyword ).
    lv_name = ls_tok-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = iv_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = iv_finding_code ).
    ENDIF.
  ENDMETHOD.

  METHOD check_var_name.
    DATA lv_name TYPE string.

    lv_name = get_stmt_name( is_statement ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = iv_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = iv_finding_code ).
    ENDIF.
  ENDMETHOD.

  METHOD check_types_statement.
    DATA lv_name TYPE string.

    lv_name = get_stmt_name( is_statement ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = mv_types_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-types ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lv_name TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
          CONTINUE.
        ENDIF.

        CASE <ls_ref>-usage_mode.
          WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_write.
            lv_name = extract_name_from_paren( <ls_token>-lexeme ).
            IF matches_pattern( iv_text    = lv_name
                                iv_pattern = mv_local_data ) = abap_false.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-local_variable ).
              RETURN.
            ENDIF.

          WHEN if_ci_atc_source_code_provider=>usage_modes-definition_with_assign.
            lv_name = extract_name_from_paren( <ls_token>-lexeme ).
            IF matches_pattern( iv_text    = lv_name
                                iv_pattern = mv_local_fs ) = abap_false.
              report_statement( is_statement    = is_statement
                                iv_finding_code = c_finding_codes-local_variable ).
              RETURN.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
