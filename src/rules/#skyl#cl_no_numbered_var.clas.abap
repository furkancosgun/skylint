CLASS /skyl/cl_no_numbered_var DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        numbered_variable TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_NUM_VAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_NUMBERED_VAR'.

    METHODS is_numbered_name
      IMPORTING iv_name      TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS check_decl_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS check_inline_declarations
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS /skyl/cl_no_numbered_var IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid variable names with numeric suffixes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-numbered_variable
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid numbered variable names like lv_count1; use descriptive names'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'DATA' OR 'CLASS-DATA' OR 'STATICS' OR 'FIELD-SYMBOLS'.
          check_decl_statement( <ls_stmt> ).
        WHEN OTHERS.
          check_inline_declarations( <ls_stmt> ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_decl_statement.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_tok = /skyl/cl_ast_util=>get_declaration_token( is_statement ).
    IF ls_tok IS NOT INITIAL AND is_numbered_name( ls_tok-lexeme ) = abap_true.
      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-numbered_variable ).
    ENDIF.
  ENDMETHOD.

  METHOD check_inline_declarations.
    DATA lt_inlines TYPE /skyl/cl_ast_util=>ty_inline_declarations.
    FIELD-SYMBOLS <ls_decl> TYPE /skyl/cl_ast_util=>ty_inline_declaration.

    lt_inlines = /skyl/cl_ast_util=>get_inline_declarations( is_statement ).
    LOOP AT lt_inlines ASSIGNING <ls_decl>.
      IF <ls_decl>-name IS NOT INITIAL AND is_numbered_name( <ls_decl>-name ) = abap_true.
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-numbered_variable ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_numbered_name.
    DATA lv_len   TYPE i.
    DATA lv_clean TYPE string.
    DATA lv_last  TYPE c LENGTH 1.

    rv_is = abap_false.
    lv_clean = iv_name.
    REPLACE ALL OCCURRENCES OF '<' IN lv_clean WITH ''.
    REPLACE ALL OCCURRENCES OF '>' IN lv_clean WITH ''.
    lv_clean = condense( lv_clean ).

    lv_len = strlen( lv_clean ).
    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_last = substring( val = lv_clean
                         off = lv_len - 1
                         len = 1 ).
    IF lv_last CA '0123456789'.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
