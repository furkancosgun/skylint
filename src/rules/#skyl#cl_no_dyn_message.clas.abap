CLASS /skyl/cl_no_dyn_message DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_dyn_msg TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DYN_MSG',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DYN_MESSAGE'.

    METHODS uses_dynamic_operand
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_no) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_no_dyn_message IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Dynamic MESSAGE Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-no_dyn_msg
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'MESSAGE works with a dynamic operand - keep ID, TYPE and NUMBER static'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'MESSAGE'.
        CONTINUE.
      ENDIF.

      IF uses_dynamic_operand( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-no_dyn_msg ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD uses_dynamic_operand.
    DATA ls_id_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_typ_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_num_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_id_tok = /skyl/cl_ast_util=>get_token_after( is_statement = is_statement
                                                       iv_lexeme    = 'ID' ).
    IF ls_id_tok IS INITIAL.
      RETURN.
    ENDIF.
    ls_typ_tok = /skyl/cl_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'TYPE' ).
    ls_num_tok = /skyl/cl_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'NUMBER' ).
    rv_no = xsdbool(    /skyl/cl_ast_util=>token_is_literal( ls_id_tok )  = abap_false
                     OR /skyl/cl_ast_util=>token_is_literal( ls_typ_tok ) = abap_false
                     OR /skyl/cl_ast_util=>token_is_literal( ls_num_tok ) = abap_false ).
  ENDMETHOD.
ENDCLASS.
