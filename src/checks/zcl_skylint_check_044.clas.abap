CLASS zcl_skylint_check_044 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITPARM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OMIT_PARAM_NAME'.

    METHODS has_single_named_param
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_044 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit parameter name in single parameter method call'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_param
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit explicit parameter name in single parameter method call'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF has_single_named_param( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_param ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_single_named_param.
    DATA lv_count        TYPE i.
    DATA lv_idx          TYPE i.
    DATA lv_open_idx     TYPE i.
    DATA lv_close_idx    TYPE i.
    DATA lv_equals_count TYPE i.
    DATA lv_comma_count  TYPE i.
    DATA lv_tok          TYPE string.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).

    IF lv_count < 4.
      RETURN.
    ENDIF.

    DO lv_count TIMES.
      lv_idx = sy-index.
      lv_tok = is_statement-tokens[ lv_idx ]-lexeme.
      IF lv_tok CP '*(' OR lv_tok = '('.
        lv_open_idx = lv_idx.
      ELSEIF lv_tok = ')'.
        lv_close_idx = lv_idx.
        EXIT.
      ENDIF.
    ENDDO.

    IF lv_open_idx > 0 AND lv_close_idx > lv_open_idx + 2.
      lv_equals_count = 0.
      lv_comma_count = 0.
      lv_idx = lv_open_idx + 1.
      WHILE lv_idx < lv_close_idx.
        lv_tok = is_statement-tokens[ lv_idx ]-lexeme.
        CASE lv_tok.
          WHEN '='.
            lv_equals_count += 1.
          WHEN ','.
            lv_comma_count += 1.
        ENDCASE.
        lv_idx += 1.
      ENDWHILE.

      IF lv_equals_count = 1 AND lv_comma_count = 0.
        " Ensure not a constructor VALUE #( ... ) or COND #( ... )
        lv_tok = to_upper( is_statement-tokens[ lv_open_idx ]-lexeme ).
        IF     lv_tok <> 'VALUE'         AND lv_tok <> 'COND' AND lv_tok <> 'EXACT'
           AND lv_tok <> 'CORRESPONDING' AND lv_tok <> '#('   AND lv_tok <> '('.
          rv_res = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
