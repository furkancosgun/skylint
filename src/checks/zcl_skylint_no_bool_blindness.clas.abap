CLASS zcl_skylint_no_bool_blindness DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        boolean_flag TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_BOOL_BL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_BOOL_BLINDNESS'.

    METHODS has_bool_importing_param
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS token_is_abap_bool
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_bool_blindness IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid boolean flag importing parameters'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-boolean_flag
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Boolean importing parameters hide intent; use dedicated methods or a typed flag'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'METHODS' AND <ls_statement>-keyword <> 'CLASS-METHODS'.
        CONTINUE.
      ENDIF.
      IF has_bool_importing_param( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-boolean_flag ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_bool_importing_param.
    DATA lv_in_importing TYPE abap_bool.
    DATA lv_count        TYPE i.
    DATA lv_idx          TYPE i.
    DATA lv_lexeme       TYPE string.
    DATA ls_token        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_type_token   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 2.

    WHILE lv_idx <= lv_count.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_lexeme = to_upper( ls_token-lexeme ).
      CASE lv_lexeme.
        WHEN 'IMPORTING'.
          IF zcl_skylint_ast_util=>token_is_keyword( ls_token ) = abap_true.
            lv_in_importing = abap_true.
          ENDIF.
        WHEN 'EXPORTING' OR 'CHANGING' OR 'RETURNING' OR 'RAISING' OR 'EXCEPTIONS'.
          IF zcl_skylint_ast_util=>token_is_keyword( ls_token ) = abap_true.
            lv_in_importing = abap_false.
          ENDIF.
        WHEN 'TYPE'.
          IF    zcl_skylint_ast_util=>token_is_keyword( ls_token ) = abap_true
             AND lv_in_importing                                       = abap_true.
            ls_type_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                             iv_index     = lv_idx + 1 ).
            IF token_is_abap_bool( ls_type_token ) = abap_true.
              rv_yes = abap_true.
              RETURN.
            ENDIF.
          ENDIF.
      ENDCASE.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD token_is_abap_bool.
    rv_yes = abap_false.

    IF is_token-lexeme <> 'ABAP_BOOL'.
      RETURN.
    ENDIF.

    rv_yes = zcl_skylint_ast_util=>has_compiler_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type ).
  ENDMETHOD.
ENDCLASS.
