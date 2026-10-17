CLASS zcl_skylint_pref_lines DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        describe_lines TYPE if_ci_atc_check=>ty_finding_code VALUE 'DESCRIBELN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_lines TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'TOLINES',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LINES'.

    METHODS build_lines_quickfix
      IMPORTING iv_stmt_idx        TYPE i
                iv_table           TYPE string
                iv_target          TYPE string
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_pref_lines IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-describe_lines
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use lines( ) function instead of DESCRIBE TABLE ... LINES'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_lines
                                                                short_text = 'Use lines( ) function' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_table_idx TYPE i.
    DATA lv_lines_idx TYPE i.
    DATA lv_table     TYPE string.
    DATA lv_target    TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'DESCRIBE'.
        CONTINUE.
      ENDIF.
      lv_stmt_idx = sy-tabix.

      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'KIND' )       = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'OCCURS' )     = abap_true.
        CONTINUE.
      ENDIF.

      lv_table_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'TABLE' ).
      lv_lines_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'LINES' ).

      IF lv_table_idx = 0 OR lv_lines_idx = 0.
        CONTINUE.
      ENDIF.

      lv_table = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                         iv_index     = lv_table_idx + 1 ).
      lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                          iv_index     = lv_lines_idx + 1 ).
      IF lv_table IS INITIAL OR lv_target IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_quickfix = build_lines_quickfix( iv_stmt_idx = lv_stmt_idx
                                          iv_table    = lv_table
                                          iv_target   = lv_target ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-describe_lines
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_lines_quickfix.
    DATA lv_line TYPE string.

    lv_line = |{ iv_target } = lines( { iv_table } ).|.
    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_lines
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( lv_line ) ) ).
  ENDMETHOD.
ENDCLASS.
