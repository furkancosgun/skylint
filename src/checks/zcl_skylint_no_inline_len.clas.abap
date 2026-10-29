CLASS zcl_skylint_no_inline_len DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        paren_length TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_INL_LEN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_length TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USELENGTH',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_INLINE_LEN'.

    METHODS parse_length_spec
      IMPORTING iv_lexeme   TYPE string
      EXPORTING ev_name     TYPE string
                ev_inner    TYPE string
                ev_islength TYPE abap_bool.

    METHODS build_length_fix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_name            TYPE string
                iv_inner           TYPE string
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_inline_len IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid inline length specification in declarations'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-paren_length
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Avoid length in parentheses; use TYPE ... LENGTH ...'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_length
                                                short_text = 'Use TYPE ... LENGTH ...' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_lexeme   TYPE string.
    DATA lv_name     TYPE string.
    DATA lv_inner    TYPE string.
    DATA lv_islength TYPE abap_bool.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF     <ls_statement>-keyword <> 'DATA'
         AND <ls_statement>-keyword <> 'CONSTANTS'
         AND <ls_statement>-keyword <> 'STATICS'.
        CONTINUE.
      ENDIF.
      lv_lexeme = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                          iv_index     = 2 ).
      parse_length_spec( EXPORTING iv_lexeme   = lv_lexeme
                         IMPORTING ev_name     = lv_name
                                   ev_inner    = lv_inner
                                   ev_islength = lv_islength ).
      IF lv_islength = abap_false.
        CONTINUE.
      ENDIF.
      CLEAR ls_quickfix.
      ls_quickfix = build_length_fix( is_statement = <ls_statement>
                                      iv_stmt_idx  = lv_stmt_idx
                                      iv_name      = lv_name
                                      iv_inner     = lv_inner ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-paren_length
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_length_spec.
    DATA lv_off   TYPE i.
    DATA lv_close TYPE i.
    DATA lv_start TYPE i.
    DATA lv_count TYPE i.

    CLEAR: ev_name,
           ev_inner,
           ev_islength.
    IF iv_lexeme IS INITIAL.
      RETURN.
    ENDIF.
    IF iv_lexeme NP '*(*)'.
      RETURN.
    ENDIF.
    FIND FIRST OCCURRENCE OF '(' IN iv_lexeme MATCH OFFSET lv_off.
    IF sy-subrc <> 0 OR lv_off <= 0.
      RETURN.
    ENDIF.
    FIND FIRST OCCURRENCE OF ')' IN iv_lexeme MATCH OFFSET lv_close.
    IF sy-subrc <> 0 OR lv_close <= lv_off + 1.
      RETURN.
    ENDIF.
    ev_name = substring( val = iv_lexeme
                         len = lv_off ).
    lv_start = lv_off + 1.
    lv_count = lv_close - lv_off - 1.
    ev_inner = substring( val = iv_lexeme
                          off = lv_start
                          len = lv_count ).
    ev_islength = abap_true.
  ENDMETHOD.

  METHOD build_length_fix.
    DATA lv_type_pos TYPE i.
    DATA lv_next_idx TYPE i.
    DATA lv_indent   TYPE i.
    DATA lv_idx      TYPE i.
    DATA lv_line     TYPE string.
    DATA lt_parts    TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA ls_next     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_quickfix.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok> WHERE references IS INITIAL.
      lv_idx = sy-tabix.
      IF <ls_tok>-lexeme = 'TYPE' OR <ls_tok>-lexeme = 'LIKE'.
        lv_type_pos = lv_idx.
        lv_next_idx = lv_type_pos + 1.
        EXIT.
      ENDIF.
    ENDLOOP.
    LOOP AT is_statement-tokens INTO ls_next.
      lv_idx = sy-tabix.
      IF lv_idx = 2.
        APPEND iv_name TO lt_parts.
        IF lv_type_pos = 0.
          APPEND 'TYPE' TO lt_parts.
          APPEND 'c' TO lt_parts.
          APPEND 'LENGTH' TO lt_parts.
          APPEND iv_inner TO lt_parts.
        ENDIF.
        CONTINUE.
      ENDIF.
      APPEND ls_next-lexeme TO lt_parts.
      IF lv_type_pos > 0 AND lv_idx = lv_next_idx.
        APPEND 'LENGTH' TO lt_parts.
        APPEND iv_inner TO lt_parts.
      ENDIF.
    ENDLOOP.
    lv_indent = is_statement-position-column.
    lv_line = repeat( val = ` `
                      occ = lv_indent )
              && concat_lines_of( table = lt_parts
                                  sep   = ` ` ).
    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_length
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.
ENDCLASS.
