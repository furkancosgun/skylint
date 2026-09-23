CLASS zcl_skylint_code_formatter DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_code_formatter.

  PRIVATE SECTION.
    METHODS flatten_tokens
      IMPORTING it_tokens      TYPE if_ci_atc_source_code_provider=>ty_tokens
      RETURNING VALUE(rv_flat) TYPE string.

    METHODS break_code
      IMPORTING iv_code         TYPE string
                iv_max_length   TYPE i
      RETURNING VALUE(rt_lines) TYPE if_ci_atc_quickfix=>ty_code
      RAISING   zcx_skylint_error.

ENDCLASS.


CLASS zcl_skylint_code_formatter IMPLEMENTATION.
  METHOD zif_skylint_code_formatter~flatten.
    rv_code = flatten_tokens( it_tokens ).
  ENDMETHOD.

  METHOD zif_skylint_code_formatter~break_lines.
    rt_lines = break_code( iv_code       = iv_code
                           iv_max_length = iv_max_length ).
  ENDMETHOD.

  METHOD zif_skylint_code_formatter~format.
    DATA(lv_flat) = |{ flatten_tokens( it_tokens ) }.|.
    rt_code = break_code( iv_code       = lv_flat
                          iv_max_length = zif_skylint_types=>c_max_line_length ).
  ENDMETHOD.

  METHOD flatten_tokens.
    rv_flat = REDUCE string( INIT lv = `` FOR ls_tok IN it_tokens NEXT lv = |{ lv }{ ls_tok-lexeme } | ).
    DATA(lv_len) = strlen( rv_flat ) - 1.
    IF lv_len >= 0 AND rv_flat+lv_len(1) = ` `.
      rv_flat = rv_flat(lv_len).
    ENDIF.
  ENDMETHOD.

  METHOD break_code.
    IF strlen( iv_code ) <= iv_max_length.
      rt_lines = VALUE #( ( iv_code ) ).
      RETURN.
    ENDIF.

    DATA(lv_code)       = iv_code.
    DATA(lv_pos)        = 0.
    DATA(lv_in_sq)      = abap_false.
    DATA(lv_in_quotes)  = abap_false.
    DATA(lv_in_tpl)     = abap_false.
    DATA(lv_in_braces)  = abap_false.
    DATA(lv_last_space) = 0.

    WHILE lv_pos < strlen( lv_code ).
      CASE lv_code+lv_pos(1).
        WHEN '`'.
          IF lv_in_quotes = abap_false AND lv_in_tpl = abap_false.
            lv_in_sq = xsdbool( lv_in_sq = abap_false ).
          ENDIF.
        WHEN `'`.
          IF lv_in_sq = abap_false AND lv_in_tpl = abap_false.
            lv_in_quotes = xsdbool( lv_in_quotes = abap_false ).
          ENDIF.
        WHEN '|'.
          IF lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_tpl = xsdbool( lv_in_tpl = abap_false ).
          ENDIF.
        WHEN `\`.
          lv_pos += 1.
        WHEN '{'.
          IF lv_in_tpl = abap_true AND lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_braces = abap_true.
          ENDIF.
        WHEN '}'.
          IF lv_in_tpl = abap_true AND lv_in_sq = abap_false AND lv_in_quotes = abap_false.
            lv_in_braces = abap_false.
          ENDIF.
        WHEN ` `.
          IF     lv_in_sq = abap_false AND lv_in_quotes = abap_false
             AND ( lv_in_tpl = abap_false OR lv_in_braces = abap_true ).
            lv_last_space = lv_pos.
          ENDIF.
      ENDCASE.

      lv_pos += 1.

      IF lv_pos > iv_max_length.
        IF lv_last_space = 0.
          RAISE EXCEPTION NEW zcx_skylint_error( message = |Line break impossible| ).
        ENDIF.
        INSERT lv_code(lv_last_space) INTO TABLE rt_lines.
        lv_last_space += 1.
        IF lv_last_space >= strlen( lv_code ).
          RETURN.
        ENDIF.
        lv_code = lv_code+lv_last_space.
        IF strlen( lv_code ) <= iv_max_length.
          INSERT lv_code INTO TABLE rt_lines.
          RETURN.
        ENDIF.
        lv_pos        = 0.
        lv_last_space = 0.
        lv_in_sq      = abap_false.
        lv_in_quotes  = abap_false.
        lv_in_tpl     = abap_false.
      ENDIF.
    ENDWHILE.

    IF lv_pos > iv_max_length.
      RAISE EXCEPTION NEW zcx_skylint_error( message = |Line break impossible| ).
    ELSE.
      INSERT lv_code INTO TABLE rt_lines.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
