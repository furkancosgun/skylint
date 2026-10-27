CLASS zcl_skylint_pref_name_members DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_attribute  TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NMATR',
        method_parameter TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NMPAR',
        selection_screen TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_NAMSS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_NAME_MEMBERS'.

    DATA mv_attr_ignore_exceptions  TYPE abap_bool VALUE abap_true.
    DATA mv_attr_ignore_local       TYPE abap_bool VALUE abap_true.
    DATA mv_attr_ignore_interfaces  TYPE abap_bool VALUE abap_false.
    DATA mv_attr_statics            TYPE string    VALUE '^G._.+$'.
    DATA mv_attr_instance           TYPE string    VALUE '^M._.+$'.
    DATA mv_attr_constants          TYPE string    VALUE ''.

    DATA mv_param_ignore_exceptions TYPE abap_bool VALUE abap_true.
    DATA mv_param_importing         TYPE string    VALUE '^I._.+$'.
    DATA mv_param_returning         TYPE string    VALUE '^R._.+$'.
    DATA mv_param_changing          TYPE string    VALUE '^C._.+$'.
    DATA mv_param_exporting         TYPE string    VALUE '^E._.+$'.

    DATA mv_sscreen_parameter       TYPE string    VALUE '^P_.+$'.
    DATA mv_sscreen_select_option   TYPE string    VALUE '^S_.+$'.

    METHODS matches_pattern
      IMPORTING iv_text           TYPE string
                iv_pattern        TYPE string
      RETURNING VALUE(rv_matches) TYPE abap_bool.

    METHODS get_stmt_name
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
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

    METHODS check_class_attribute
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_method_definition
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_skip_params TYPE abap_bool.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_decl_name
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pattern      TYPE string
                iv_finding_code TYPE if_ci_atc_check=>ty_finding_code.

ENDCLASS.


CLASS zcl_skylint_pref_name_members IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Class Attribute and Parameter Naming Conventions'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity       = if_ci_atc_check=>finding_severities-warning
                                     pseudo_comment = c_pseudo_comment
                                     ( code = c_finding_codes-class_attribute
                                       text = 'Class attribute name does not match configured pattern' )
                                     ( code = c_finding_codes-method_parameter
                                       text = 'Method parameter name does not match configured pattern' )
                                     ( code = c_finding_codes-selection_screen
                                       text = 'Selection screen element name does not match configured pattern' ) )
                                 attributes        = VALUE #(
                                     ( name  = 'ATTR_IGN_EXC'
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
                                     ( name  = 'SSCR_PARAM'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_sscreen_parameter ) )
                                     ( name  = 'SSCR_SELOPT'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                       value = REF #( mv_sscreen_select_option ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      check_class_definition( is_procedure-statements ).
    ELSE.
      LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
        CASE <ls_statement>-keyword.
          WHEN 'PARAMETERS' OR 'PARAMETER'.
            check_decl_name( is_statement    = <ls_statement>
                             iv_pattern      = mv_sscreen_parameter
                             iv_finding_code = c_finding_codes-selection_screen ).

          WHEN 'SELECT-OPTIONS'.
            check_decl_name( is_statement    = <ls_statement>
                             iv_pattern      = mv_sscreen_select_option
                             iv_finding_code = c_finding_codes-selection_screen ).
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

  METHOD is_global_class.
    DATA lv_prev TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_global = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      IF <ls_tok>-references IS INITIAL.
        IF <ls_tok>-lexeme = 'PUBLIC' AND lv_prev <> 'CREATE'.
          rv_global = abap_true.
          RETURN.
        ENDIF.
        lv_prev = <ls_tok>-lexeme.
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
      IF ls_tok-lexeme CP '*CX_*' OR ls_tok-lexeme = 'CX_ROOT'.
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
        WHEN 'DATA' OR 'CLASS-DATA' OR 'CONSTANTS'.
          IF lv_skip_attrs = abap_false.
            check_class_attribute( <ls_stmt> ).
          ENDIF.

        WHEN 'METHODS' OR 'CLASS-METHODS'.
          check_method_definition( is_statement   = <ls_stmt>
                                   iv_skip_params = lv_skip_params ).
      ENDCASE.
    ENDLOOP.
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

  METHOD check_method_definition.
    DATA lv_name TYPE string.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = is_statement-keyword ).
    lv_name = ls_tok-lexeme.
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                     it_expected  = VALUE #( ( `FOR` ) ( `EVENT` ) ) )   > 0
       OR zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                     it_expected  = VALUE #( ( `FOR` ) ( `TESTING` ) ) ) > 0.
      RETURN.
    ENDIF.

    IF iv_skip_params = abap_false.
      check_method_parameters( is_statement ).
    ENDIF.
  ENDMETHOD.

  METHOD check_method_parameters.
    DATA lt_params  TYPE zcl_skylint_ast_util=>ty_method_parameters.
    DATA lv_pattern TYPE string.
    FIELD-SYMBOLS <ls_param> TYPE zcl_skylint_ast_util=>ty_method_parameter.

    lt_params = zcl_skylint_ast_util=>get_method_parameters( is_statement ).
    LOOP AT lt_params ASSIGNING <ls_param>.
      CASE <ls_param>-section.
        WHEN 'IMPORTING'.
          lv_pattern = mv_param_importing.
        WHEN 'EXPORTING'.
          lv_pattern = mv_param_exporting.
        WHEN 'CHANGING'.
          lv_pattern = mv_param_changing.
        WHEN 'RETURNING'.
          lv_pattern = mv_param_returning.
      ENDCASE.

      IF matches_pattern( iv_text    = <ls_param>-name
                          iv_pattern = lv_pattern ) = abap_false.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-method_parameter ).
      ENDIF.
    ENDLOOP.
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
