CLASS zcl_skylint_check_055 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_class TYPE zif_skylint_types=>ty_finding_code VALUE 'STAT_CLASS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_055 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid static-only classes; prefer instantiable interface-based design'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-static_class
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid static-only classes; declare instance methods and interfaces'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_static_cnt TYPE i.
    DATA lv_has_inst   TYPE abap_bool.
    DATA ls_first_stmt TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CLASS-METHODS'.
          lv_static_cnt = lv_static_cnt + 1.
        WHEN 'METHODS'.
          IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'CONSTRUCTOR' ) = abap_false.
            lv_has_inst = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_static_cnt > 0 AND lv_has_inst = abap_false.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-static_class ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
