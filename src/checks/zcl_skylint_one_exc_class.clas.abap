CLASS zcl_skylint_one_exc_class DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        one_exc_class TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_MULTEXC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'ONE_EXC_CLASS'.

    DATA mt_seen_classes TYPE string_table.

    METHODS inspect_raise_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_one_exc_class IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Raise At Most One Exception Type per Method'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-one_exc_class
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Method raises several different exception classes - raise one type instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    CLEAR mt_seen_classes.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'RAISE'.
        CONTINUE.
      ENDIF.

      inspect_raise_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_raise_statement.
    DATA lv_technical TYPE string.
    DATA lv_name      TYPE string.

    " Classic RAISE cxx (without EXCEPTION) is not examined
    IF zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                               iv_index     = 2 ) <> 'EXCEPTION'.
      RETURN.
    ENDIF.

    lv_technical = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                           iv_index     = 3 ).
    IF lv_technical <> 'TYPE' AND lv_technical <> 'NEW'.
      RETURN.
    ENDIF.

    " NEW form: the class name can carry the opening parenthesis ( lexeme 'CX_X(' )
    lv_name = segment( val = zcl_skylint_ast_util=>get_token_lexeme(
                                     is_statement = is_statement
                                     iv_index     = 4 )
                       index = 1
                       sep   = '(' ).
    IF lv_name IS INITIAL.
      RETURN.
    ENDIF.

    IF mt_seen_classes IS INITIAL.
      APPEND lv_name TO mt_seen_classes.
      RETURN.
    ENDIF.

    IF line_exists( mt_seen_classes[ table_line = lv_name ] ).
      RETURN.
    ENDIF.

    report_statement( is_statement    = is_statement
                      iv_finding_code = c_finding_codes-one_exc_class ).

    APPEND lv_name TO mt_seen_classes.
  ENDMETHOD.
ENDCLASS.
