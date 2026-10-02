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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'IDENTICAL_MOVE'.

    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_034 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Detect Identical Self Assignments'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-identical_move
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Identical assignment has no effect; remove redundant statement'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMPUTE'.
      IF is_identical_assignment( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-identical_move ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA ls_tok1   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok2   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok3   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found1 TYPE abap_bool.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found3 TYPE abap_bool.

    rv_res = abap_false.

    IF lines( is_statement-tokens ) <> 3.
      RETURN.
    ENDIF.

    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                    iv_index     = 1
                                          IMPORTING es_token     = ls_tok1
                                                    ev_found     = lv_found1 ).
    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                    iv_index     = 2
                                          IMPORTING es_token     = ls_tok2
                                                    ev_found     = lv_found2 ).
    zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                    iv_index     = 3
                                          IMPORTING es_token     = ls_tok3
                                                    ev_found     = lv_found3 ).
    IF lv_found1 = abap_false OR lv_found2 = abap_false OR lv_found3 = abap_false.
      RETURN.
    ENDIF.

    IF ls_tok2-lexeme = '=' AND to_upper( ls_tok1-lexeme ) = to_upper( ls_tok3-lexeme ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
