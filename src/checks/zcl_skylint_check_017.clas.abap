CLASS zcl_skylint_check_017 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_if TYPE zif_skylint_types=>ty_finding_code VALUE 'NESTEDIF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.

    METHODS is_nested_if_mergeable
      IMPORTING iv_idx        TYPE i
                is_code_block TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rv_is)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_017 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect consecutive nested IF blocks that can be merged with AND'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-nested_if
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Nested IF block can be merged with outer IF using AND'
                                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'IF'.
      lv_idx = sy-tabix.
      IF is_nested_if_mergeable( iv_idx        = lv_idx
                                 is_code_block = is_code_block ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-nested_if ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_nested_if_mergeable.
    DATA lv_total     TYPE i.
    DATA lv_fwd_idx   TYPE i.
    DATA lv_depth     TYPE i.
    DATA ls_next_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_fwd_stmt  TYPE zif_skylint_types=>ty_statement.
    DATA ls_outer_end TYPE zif_skylint_types=>ty_statement.

    rv_is = abap_false.
    lv_total = zcl_skylint_ast_util=>statement_count( is_code_block-statements ).

    ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_code_block-statements
                                                             iv_current_index = iv_idx ).
    IF ls_next_stmt-keyword <> 'IF'.
      RETURN.
    ENDIF.

    lv_depth = 1.
    lv_fwd_idx = iv_idx + 2.

    WHILE lv_fwd_idx <= lv_total.
      ls_fwd_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                         iv_index      = lv_fwd_idx ).
      IF ls_fwd_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_fwd_stmt-keyword.
        WHEN 'IF'.
          lv_depth = lv_depth + 1.

        WHEN 'ENDIF'.
          lv_depth = lv_depth - 1.
          IF lv_depth = 0.
            ls_outer_end = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_code_block-statements
                                                                     iv_current_index = lv_fwd_idx ).
            IF ls_outer_end-keyword = 'ENDIF'.
              rv_is = abap_true.
            ENDIF.
            RETURN.
          ENDIF.
      ENDCASE.

      lv_fwd_idx = lv_fwd_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
