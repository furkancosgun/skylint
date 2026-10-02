CLASS zcl_skylint_check_047 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        cyclomatic_complexity TYPE zif_skylint_types=>ty_finding_code VALUE 'CYCLO_COMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CYCLOMATIC_COMPLEXITY'.

    DATA mv_max_complexity TYPE i VALUE 5.

    METHODS calculate_complexity
      IMPORTING is_procedure   TYPE zif_skylint_types=>ty_procedure
      RETURNING VALUE(rv_comp) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_047 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Cyclomatic Complexity Threshold'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-cyclomatic_complexity
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Procedure cyclomatic complexity exceeds threshold'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'MAX_COMPLEXITY'
                                       kind  = zif_skylint_types=>attribute_kinds-elementary
                                       value = REF #( mv_max_complexity ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max        TYPE i.
    DATA lv_cc         TYPE i.
    DATA ls_first_stmt TYPE zif_skylint_types=>ty_statement.

    IF is_procedure-id-kind = zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_COMPLEXITY'
                   IMPORTING ev_value = lv_max ).
    IF lv_max <= 0.
      lv_max = mv_max_complexity.
    ENDIF.

    lv_cc = calculate_complexity( is_procedure ).

    IF lv_cc > lv_max.
      ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                           iv_index      = 1 ).
      IF ls_first_stmt-keyword IS NOT INITIAL.
        report_statement( is_statement    = ls_first_stmt
                          iv_finding_code = c_finding_codes-cyclomatic_complexity ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_complexity.
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.
    DATA lv_lex TYPE string.

    rv_comp = 1.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'IF' OR 'ELSEIF' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'WHEN' OR 'CATCH' OR 'CLEANUP'.
          rv_comp += 1.
      ENDCASE.

      LOOP AT <ls_stmt>-tokens INTO ls_tok.
        lv_lex = to_upper( ls_tok-lexeme ).
        CASE lv_lex.
          WHEN 'AND' OR 'OR' OR 'COND' OR 'SWITCH'.
            rv_comp += 1.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
