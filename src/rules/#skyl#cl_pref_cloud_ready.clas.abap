CLASS /skyl/cl_pref_cloud_ready DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        cloud_forbidden TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CLOUD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CLOUD_READY'.
    CONSTANTS c_at_pf_regex    TYPE string VALUE `^PF\d\d?$`.
    CONSTANTS:
      BEGIN OF c_create_object_sections,
        type            TYPE string VALUE 'TYPE',
        exporting       TYPE string VALUE 'EXPORTING',
        exceptions      TYPE string VALUE 'EXCEPTIONS',
        parameter_table TYPE string VALUE 'PARAMETER-TABLE',
        exception_table TYPE string VALUE 'EXCEPTION-TABLE',
      END OF c_create_object_sections.

    DATA mt_forbidden TYPE /skyl/cl_cloud_stmts=>ty_token_patterns.
    DATA mt_allowed   TYPE /skyl/cl_cloud_stmts=>ty_token_patterns.

    METHODS load_patterns.

    METHODS split_patterns
      IMPORTING it_patterns        TYPE /skyl/cl_cloud_stmts=>ty_lines
      RETURNING VALUE(rt_patterns) TYPE /skyl/cl_cloud_stmts=>ty_token_patterns.

    METHODS is_cloud_forbidden
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_forbidden) TYPE abap_bool.

    METHODS max_prefix_length
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
                it_patterns      TYPE /skyl/cl_cloud_stmts=>ty_token_patterns
      RETURNING VALUE(rv_length) TYPE i.

    METHODS is_at_pf
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_result) TYPE abap_bool.

    METHODS is_sort_dataset
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_result) TYPE abap_bool.

    METHODS is_ole_create
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_result) TYPE abap_bool.

    METHODS is_create_object_section
      IMPORTING iv_lexeme        TYPE string
      RETURNING VALUE(rv_result) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_pref_cloud_ready IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Statements not available in ABAP Cloud'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-cloud_forbidden
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Statement is not supported in ABAP Cloud; use modern syntax or a released API'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
    load_patterns( ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_cloud_forbidden( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-cloud_forbidden ).
    ENDLOOP.
  ENDMETHOD.

  METHOD load_patterns.
    mt_forbidden = split_patterns( /skyl/cl_cloud_stmts=>get_forbidden_patterns( ) ).
    mt_allowed   = split_patterns( /skyl/cl_cloud_stmts=>get_allowed_patterns( ) ).
  ENDMETHOD.

  METHOD split_patterns.
    DATA ls_tokens TYPE /skyl/cl_cloud_stmts=>ty_tokens.
    FIELD-SYMBOLS <lv_pattern> TYPE string.

    LOOP AT it_patterns ASSIGNING <lv_pattern>.
      CLEAR ls_tokens.
      SPLIT <lv_pattern> AT ` ` INTO TABLE ls_tokens.
      APPEND ls_tokens TO rt_patterns.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_cloud_forbidden.
    DATA lv_forbidden_length TYPE i.
    DATA lv_allowed_length   TYPE i.

    IF is_at_pf( is_statement ) = abap_true OR is_sort_dataset( is_statement ) = abap_true.
      rv_forbidden = abap_true.
      RETURN.
    ENDIF.

    lv_forbidden_length = max_prefix_length( is_statement = is_statement
                                             it_patterns  = mt_forbidden ).
    IF lv_forbidden_length = 0.
      RETURN.
    ENDIF.

    IF is_ole_create( is_statement ) = abap_true.
      rv_forbidden = abap_true.
      RETURN.
    ENDIF.

    lv_allowed_length = max_prefix_length( is_statement = is_statement
                                           it_patterns  = mt_allowed ).

    rv_forbidden = xsdbool( lv_forbidden_length > lv_allowed_length ).
  ENDMETHOD.

  METHOD max_prefix_length.
    DATA lv_length TYPE i.
    FIELD-SYMBOLS <lt_pattern> TYPE /skyl/cl_cloud_stmts=>ty_tokens.

    LOOP AT it_patterns ASSIGNING <lt_pattern>.
      IF /skyl/cl_ast_util=>find_token_sequence( is_statement = is_statement
                                                 it_expected  = <lt_pattern> ) <> 1.
        CONTINUE.
      ENDIF.

      lv_length = lines( <lt_pattern> ).
      IF lv_length > rv_length.
        rv_length = lv_length.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_at_pf.
    DATA ls_first  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_text   TYPE string.

    ls_first = /skyl/cl_ast_util=>get_first_token( is_statement ).
    IF ls_first-lexeme <> 'AT' OR ls_first-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    ls_second = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = 2 ).
    IF ls_second-lexeme IS INITIAL OR ls_second-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    lv_text   = to_upper( ls_second-lexeme ).
    rv_result = /skyl/cl_ast_util=>matches_regex( iv_text    = lv_text
                                                  iv_pattern = c_at_pf_regex ).
  ENDMETHOD.

  METHOD is_sort_dataset.
    DATA ls_first  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_first = /skyl/cl_ast_util=>get_first_token( is_statement ).
    IF ls_first-lexeme <> 'SORT' OR ls_first-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    ls_second = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = 2 ).
    IF ls_second-lexeme IS INITIAL.
      rv_result = abap_true.
      RETURN.
    ENDIF.

    IF ls_second-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    rv_result = xsdbool( ls_second-lexeme = 'AS' OR ls_second-lexeme = 'BY' ).
  ENDMETHOD.

  METHOD is_ole_create.
    DATA ls_first  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_fourth TYPE if_ci_atc_source_code_provider=>ty_token.

    IF lines( is_statement-tokens ) <= 3.
      RETURN.
    ENDIF.

    ls_first = /skyl/cl_ast_util=>get_first_token( is_statement ).
    IF ls_first-lexeme <> 'CREATE' OR ls_first-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF /skyl/cl_ast_util=>get_token_lexeme( is_statement = is_statement
                                            iv_index     = 2 ) <> 'OBJECT'.
      RETURN.
    ENDIF.

    ls_fourth = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = 4 ).
    rv_result = xsdbool( is_create_object_section( ls_fourth-lexeme ) = abap_false ).
  ENDMETHOD.

  METHOD is_create_object_section.
    CASE iv_lexeme.
      WHEN c_create_object_sections-type
        OR c_create_object_sections-exporting
        OR c_create_object_sections-exceptions
        OR c_create_object_sections-parameter_table
        OR c_create_object_sections-exception_table.
        rv_result = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
