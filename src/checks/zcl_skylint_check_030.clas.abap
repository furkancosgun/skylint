CLASS zcl_skylint_check_030 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        db_in_loop TYPE zif_skylint_types=>ty_finding_code VALUE 'DBINLOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DB_IN_LOOP'.

    METHODS is_direct_db_access
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_030 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid database access inside loop iterations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-db_in_loop
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Database access inside loop iteration; consider bulk operation or JOIN'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    lv_loop_depth = 0.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth = lv_loop_depth + 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth = lv_loop_depth - 1.
          ENDIF.
        WHEN OTHERS.
          IF lv_loop_depth > 0 AND is_direct_db_access( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-db_in_loop ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_direct_db_access.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.
    DATA ls_ref TYPE zif_skylint_types=>ty_compiler_reference.

    rv_res = abap_false.

    " 1. Inspect compiler semantic references (read/write database)
    LOOP AT is_statement-tokens INTO ls_tok.
      LOOP AT ls_tok-references INTO ls_ref.
        IF    ls_ref-usage_mode = zif_skylint_types=>usage_modes-read_database
           OR ls_ref-usage_mode = zif_skylint_types=>usage_modes-write_database.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " 2. Open SQL statements
    CASE is_statement-keyword.
      WHEN 'SELECT' OR 'UPDATE'.
        rv_res = abap_true.
      WHEN 'DELETE' OR 'INSERT' OR 'MODIFY'.
        IF     zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                       iv_lexeme    = 'FROM' )     = abap_true
           AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                       iv_index     = 2
                                                       iv_expected  = `TABLE` )    = abap_false.
          rv_res = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
