CLASS zcl_skylint_pref_name_objects DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        local_class      TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_LCLS',
        global_class     TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_GCLS',
        local_interface  TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_LINTF',
        global_interface TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_GINTF',
        types            TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_TYP',
        event            TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_EVT',
        test_method      TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_TMETH',
        macro            TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_MACRO',
        form             TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FORM',
        function_module  TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FUNC',
        function_group   TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FUGR',
        program          TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PROG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_NAME_OBJECTS'.

    DATA mv_class_global     TYPE string VALUE '^ZC(L|X)_.+$'.
    DATA mv_class_local      TYPE string VALUE '^LC(L|X)_.+$'.
    DATA mv_class_test       TYPE string VALUE '^LTCL_.+$'.
    DATA mv_intf_local       TYPE string VALUE '^LIF_.+$'.
    DATA mv_intf_global      TYPE string VALUE '^ZIF_.+$'.
    DATA mv_types_pattern    TYPE string VALUE '^TY_.+$'.
    DATA mv_macro_pattern    TYPE string VALUE '^_.+$'.
    DATA mv_form_pattern     TYPE string VALUE '^F_.+$'.
    DATA mv_function_pattern TYPE string VALUE '^Z.*$'.
    DATA mv_event_name       TYPE string VALUE '^[A-Z][A-Z0-9_]+$'.
    DATA mv_event_handler    TYPE string VALUE '^ON_.+$'.
    DATA mv_test_method      TYPE string VALUE '^(TEST|SHOULD)_.+$'.
    DATA mv_program_pattern  TYPE string VALUE '^Z.+$'.
    DATA mv_fugr_pattern     TYPE string VALUE '^Z.+$'.

    METHODS matches_pattern
      IMPORTING iv_text           TYPE string
                iv_pattern        TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS get_stmt_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_name) TYPE string.

    METHODS check_class_definition
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements.

    METHODS check_class_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_interface_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_event_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_definition
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_types_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_decl_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

ENDCLASS.


CLASS zcl_skylint_pref_name_objects IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Class, Interface, Type and Object Naming'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-local_class
                                       text = 'Local class name does not match configured pattern' )
                                     ( code = c_finding_codes-global_class
                                       text = 'Global class name does not match configured pattern' )
                                     ( code = c_finding_codes-local_interface
                                       text = 'Local interface name does not match configured pattern' )
                                     ( code = c_finding_codes-global_interface
                                       text = 'Global interface name does not match configured pattern' )
                                     ( code = c_finding_codes-types
                                       text = 'Type name does not match configured pattern' )
                                     ( code = c_finding_codes-event
                                       text = 'Event or event handler name does not match configured pattern' )
                                     ( code = c_finding_codes-test_method
                                       text = 'Test method name does not match configured pattern' )
                                     ( code = c_finding_codes-macro
                                       text = 'Macro name does not match configured pattern' )
                                     ( code = c_finding_codes-form
                                       text = 'Form routine name does not match configured pattern' )
                                     ( code = c_finding_codes-function_module
                                       text = 'Function module name does not match configured pattern' )
                                     ( code = c_finding_codes-function_group
                                       text = 'Function group name does not match configured pattern' )
                                     ( code = c_finding_codes-program
                                       text = 'Program name does not match configured pattern' ) )
                                 attributes        = VALUE #(
                                     kind = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                     ( name  = 'CLASS_LOCAL'
                                       value = REF #( mv_class_local ) )
                                     ( name  = 'CLASS_TEST'
                                       value = REF #( mv_class_test ) )
                                     ( name  = 'CLASS_GLOBAL'
                                       value = REF #( mv_class_global ) )
                                     ( name  = 'INTF_LOCAL'
                                       value = REF #( mv_intf_local ) )
                                     ( name  = 'INTF_GLOBAL'
                                       value = REF #( mv_intf_global ) )
                                     ( name  = 'TYPES_PATTERN'
                                       value = REF #( mv_types_pattern ) )
                                     ( name  = 'MACRO_PATTERN'
                                       value = REF #( mv_macro_pattern ) )
                                     ( name  = 'FORM_PATTERN'
                                       value = REF #( mv_form_pattern ) )
                                     ( name  = 'FUNCTION_PATTERN'
                                       value = REF #( mv_function_pattern ) )
                                     ( name  = 'EVENT_NAME'
                                       value = REF #( mv_event_name ) )
                                     ( name  = 'EVENT_HANDLER'
                                       value = REF #( mv_event_handler ) )
                                     ( name  = 'TEST_METHOD'
                                       value = REF #( mv_test_method ) )
                                     ( name  = 'PROG_PATTERN'
                                       value = REF #( mv_program_pattern ) )
                                     ( name  = 'FUGR_PATTERN'
                                       value = REF #( mv_fugr_pattern ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      check_class_definition( is_procedure-statements ).
    ELSE.
      LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
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

          WHEN 'TYPES'.
            check_types_statement( <ls_statement> ).

          WHEN 'DEFINE'.
            check_decl_name( is_statement    = <ls_statement>
                             iv_pattern      = mv_macro_pattern
                             iv_finding_code = c_finding_codes-macro ).
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD matches_pattern.
    rv_matches = zcl_skylint_ast_util=>matches_regex(
        iv_text    = iv_text
        iv_pattern = iv_pattern ).
  ENDMETHOD.

  METHOD get_stmt_name.
    rv_name = zcl_skylint_ast_util=>get_declaration_name( is_statement ).
  ENDMETHOD.

  METHOD check_class_definition.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT it_statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'CLASS'.
          IF zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_stmt>
                                                        it_expected  = VALUE #( ( `DEFINITION` ) ) ) > 0.
            check_class_statement( <ls_stmt> ).
          ENDIF.

        WHEN 'INTERFACE'.
          check_interface_statement( <ls_stmt> ).

        WHEN 'EVENTS' OR 'CLASS-EVENTS'.
          check_event_statement( <ls_stmt> ).

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          check_method_definition( <ls_stmt> ).

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

    IF zcl_skylint_ast_util=>statement_is_public_class( is_statement ) = abap_true.
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

    IF zcl_skylint_ast_util=>statement_is_public_interface( is_statement ) = abap_true.
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

    IF     zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                      it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) > 0
       AND matches_pattern( iv_text    = lv_name
                            iv_pattern = mv_test_method ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-test_method ).
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

  METHOD check_decl_name.
    DATA lv_name TYPE string.

    lv_name = zcl_skylint_ast_util=>get_declaration_name( is_statement ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF matches_pattern( iv_text    = lv_name
                        iv_pattern = iv_pattern ) = abap_false.
      report_statement( is_statement    = is_statement
                        iv_finding_code = iv_finding_code ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
