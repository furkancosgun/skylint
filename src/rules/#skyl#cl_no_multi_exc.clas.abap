CLASS /skyl/cl_no_multi_exc DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_multi_exc TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_MULTEXC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_MULTI_EXC'.

    METHODS get_exception_class
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_class) TYPE string.
ENDCLASS.


CLASS /skyl/cl_no_multi_exc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Raise At Most One Exception Type per Method'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-no_multi_exc
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Method raises several different exception classes - raise one type instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lv_class   TYPE string.
    DATA lt_classes TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'RAISE'.
        CONTINUE.
      ENDIF.

      lv_class = get_exception_class( <ls_statement> ).
      IF lv_class IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lt_classes IS INITIAL.
        APPEND lv_class TO lt_classes.
        CONTINUE.
      ENDIF.

      IF line_exists( lt_classes[ table_line = lv_class ] ).
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-no_multi_exc ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_exception_class.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_token = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 2 ).
    IF ls_token-lexeme <> 'EXCEPTION'.
      RETURN.
    ENDIF.

    ls_token = /skyl/cl_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    IF ls_token-lexeme <> 'TYPE' AND ls_token-lexeme <> 'NEW'.
      RETURN.
    ENDIF.

    rv_class = segment( val   = /skyl/cl_ast_util=>get_token_lexeme( is_statement = is_statement
                                                                        iv_index     = 4 )
                        index = 1
                        sep   = '(' ).
  ENDMETHOD.
ENDCLASS.
