CLASS zcl_skylint_check_021 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        when_others_not_last TYPE if_ci_atc_check=>ty_finding_code VALUE 'WHENOTHERS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'WHEN_OTHERS_LAST'.

    METHODS is_when_others
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS has_subsequent_when
      IMPORTING iv_idx        TYPE i
                is_procedure  TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_021 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Enforce WHEN OTHERS to be the last branch in CASE construct'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-when_others_not_last
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'WHEN OTHERS must be the last branch in CASE construct'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'WHEN'.
      lv_idx = sy-tabix.
      IF     is_when_others( <ls_statement> )                   = abap_true
         AND has_subsequent_when( iv_idx       = lv_idx
                                  is_procedure = is_procedure ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-when_others_not_last ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_when_others.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    IF lines( is_statement-tokens ) >= 2.
      ASSIGN is_statement-tokens[ 2 ] TO <ls_token>.
      IF sy-subrc = 0 AND to_upper( <ls_token>-lexeme ) = 'OTHERS'.
        rv_is = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD has_subsequent_when.
    DATA lv_total   TYPE i.
    DATA lv_fwd_idx TYPE i.
    DATA lv_depth   TYPE i.
    FIELD-SYMBOLS <ls_fwd_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_has = abap_false.
    lv_total = lines( is_procedure-statements ).
    lv_depth = 0.
    lv_fwd_idx = iv_idx + 1.

    WHILE lv_fwd_idx <= lv_total.
      ASSIGN is_procedure-statements[ lv_fwd_idx ] TO <ls_fwd_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CASE <ls_fwd_stmt>-keyword.
        WHEN 'CASE'.
          lv_depth += 1.

        WHEN 'ENDCASE'.
          IF lv_depth = 0.
            RETURN.
          ELSE.
            lv_depth -= 1.
          ENDIF.

        WHEN 'WHEN'.
          IF lv_depth = 0.
            rv_has = abap_true.
            RETURN.
          ENDIF.
      ENDCASE.

      lv_fwd_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
