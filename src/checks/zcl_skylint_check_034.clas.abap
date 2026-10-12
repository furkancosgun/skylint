CLASS zcl_skylint_check_034 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'IDENTMOVE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_034 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #(
                            description       = 'skylint: Detect Identical Self Assignments'
                            remote_enablement = abap_true
                            finding_codes     = VALUE #(
                                ( code     = c_finding_codes-identical_move
                                  severity = if_ci_atc_check=>finding_severities-warning
                                  text     = 'Identical assignment has no effect; remove redundant statement' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMPUTE'.
      IF is_identical_assignment( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-identical_move ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA lv_left  TYPE string.
    DATA lv_right TYPE string.

    rv_res = abap_false.

    IF zcl_skylint_ast_util=>token_count( is_statement ) <> 3.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = '=' ) = abap_true.
      lv_left = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = 1 ).
      lv_right = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = 3 ).
      IF lv_left = lv_right.
        rv_res = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
