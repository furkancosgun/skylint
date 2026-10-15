CLASS zcl_skylint_check_074 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        guard_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'GUARD_LOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS find_wrapping_if
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_loop_idx   TYPE i
      RETURNING VALUE(rs_if)  TYPE if_ci_atc_source_code_provider=>ty_statement.
ENDCLASS.


CLASS zcl_skylint_check_074 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use early CONTINUE guard clause instead of wrapping loop in IF block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-guard_loop
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Invert IF condition and use CONTINUE to reduce nesting in loop' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_if TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements TRANSPORTING NO FIELDS
         WHERE keyword = 'LOOP' OR keyword = 'DO' OR keyword = 'WHILE'.
      ls_if = find_wrapping_if( it_statements = is_procedure-statements
                                iv_loop_idx   = sy-tabix ).
      IF ls_if-keyword = 'IF'.
        report_statement( is_statement    = ls_if
                          iv_finding_code = c_finding_codes-guard_loop ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_wrapping_if.
    DATA lv_max      TYPE i.
    DATA lv_if_depth TYPE i.
    DATA lv_has_else TYPE abap_bool.
    DATA lv_scan_idx TYPE i.
    DATA ls_first    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_after    TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rs_if.
    lv_max = zcl_skylint_ast_util=>statement_count( it_statements ).
    IF iv_loop_idx + 3 > lv_max.
      RETURN.
    ENDIF.

    ls_first = zcl_skylint_ast_util=>get_next_statement( it_statements    = it_statements
                                                         iv_current_index = iv_loop_idx ).
    IF ls_first-keyword <> 'IF'.
      RETURN.
    ENDIF.

    lv_if_depth = 1.
    lv_has_else = abap_false.
    lv_scan_idx = iv_loop_idx + 2.

    WHILE lv_scan_idx <= lv_max AND lv_if_depth > 0.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_scan_idx ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'IF'.
          lv_if_depth += 1.
        WHEN 'ELSE' OR 'ELSEIF'.
          IF lv_if_depth = 1.
            lv_has_else = abap_true.
          ENDIF.
        WHEN 'ENDIF'.
          lv_if_depth -= 1.
          IF lv_if_depth = 0.
            ls_after = zcl_skylint_ast_util=>get_next_statement( it_statements    = it_statements
                                                                 iv_current_index = lv_scan_idx ).
            IF     lv_has_else = abap_false
               AND ( ls_after-keyword = 'ENDLOOP' OR ls_after-keyword = 'ENDDO' OR ls_after-keyword = 'ENDWHILE' ).
              rs_if = ls_first.
            ENDIF.
            EXIT.
          ENDIF.
      ENDCASE.
      lv_scan_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
