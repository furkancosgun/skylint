CLASS zcl_skylint_pref_loop_where DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        add_where TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_LOOPW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_LOOP_WHERE'.

    METHODS loop_starts_with_filter
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_loop_index TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_loop_where IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Filter LOOP AT With a WHERE Clause'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-add_where
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Loop starts with an IF CONTINUE guard - filter rows with WHERE instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_index TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_index = sy-tabix.
      IF <ls_statement>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      IF loop_starts_with_filter( it_statements = is_procedure-statements
                                  iv_loop_index = lv_index ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-add_where ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD loop_starts_with_filter.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_statement.

    ls_next = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                   iv_index      = iv_loop_index + 1 ).
    IF ls_next-keyword <> 'IF'.
      RETURN.
    ENDIF.

    ls_next = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                   iv_index      = iv_loop_index + 2 ).
    IF ls_next-keyword <> 'CONTINUE'.
      RETURN.
    ENDIF.

    ls_next = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                   iv_index      = iv_loop_index + 3 ).
    IF ls_next-keyword <> 'ENDIF'.
      RETURN.
    ENDIF.

    rv_yes = abap_true.
  ENDMETHOD.
ENDCLASS.
