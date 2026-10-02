CLASS zcl_skylint_check_074 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        guard_loop TYPE zif_skylint_types=>ty_finding_code VALUE 'GUARD_LOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'GUARD_IN_LOOP'.
ENDCLASS.


CLASS zcl_skylint_check_074 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use early CONTINUE guard clause instead of wrapping loop in IF block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-guard_loop
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Invert IF condition and use CONTINUE to reduce nesting in loop'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx      TYPE i.
    DATA lv_max      TYPE i.
    DATA lv_scan_idx TYPE i.
    DATA lv_if_depth TYPE i.
    DATA ls_first    TYPE zif_skylint_types=>ty_statement.
    DATA ls_stmt     TYPE zif_skylint_types=>ty_statement.
    DATA ls_after    TYPE zif_skylint_types=>ty_statement.
    DATA lv_has_else TYPE abap_bool.
    FIELD-SYMBOLS <ls_loop> TYPE zif_skylint_types=>ty_statement.

    lv_max = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_loop>
         WHERE keyword = 'LOOP' OR keyword = 'DO' OR keyword = 'WHILE'.
      lv_idx = sy-tabix.
      IF lv_idx + 3 > lv_max.
        CONTINUE.
      ENDIF.

      ls_first = zcl_skylint_ast_util=>get_next_statement( it_statements     = is_procedure-statements
                                                              iv_current_index = lv_idx ).
      IF ls_first-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      lv_if_depth = 1.
      lv_has_else = abap_false.
      lv_scan_idx = lv_idx + 2.

      WHILE lv_scan_idx <= lv_max AND lv_if_depth > 0.
        ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
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
              ls_after = zcl_skylint_ast_util=>get_next_statement( it_statements     = is_procedure-statements
                                                                  iv_current_index = lv_scan_idx ).
              IF     lv_has_else = abap_false
                 AND ( ls_after-keyword = 'ENDLOOP' OR ls_after-keyword = 'ENDDO' OR ls_after-keyword = 'ENDWHILE' ).
                report_statement( is_statement    = ls_first
                                  iv_finding_code = c_finding_codes-guard_loop ).
              ENDIF.
              EXIT.
            ENDIF.
        ENDCASE.
        lv_scan_idx += 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
