CLASS zcl_skylint_check_028 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_xsdbool TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERXSDBOOL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_XSDBOOL'.

    METHODS is_boolean_assignment
      IMPORTING
        is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING
        ev_target    TYPE string
        ev_is_bool   TYPE abap_bool.

    METHODS is_boolean_value
      IMPORTING
        iv_lexeme     TYPE string
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_028 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
      VALUE #( description       = 'Prefer xsdbool( ) expression over manual IF-ELSE assignment'
               remote_enablement = abap_true
               finding_codes     = VALUE #(
                   ( code           = c_finding_codes-prefer_xsdbool
                     severity       = if_ci_atc_check=>finding_severities-warning
                     text           = 'Prefer xsdbool( ... ) instead of manual IF-ELSE boolean assignment'
                     pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    DATA lv_max TYPE i.
    DATA ls_stmt_if TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_then TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_else_body TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt_endif TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_target_1 TYPE string.
    DATA lv_target_2 TYPE string.
    DATA lv_is_bool_1 TYPE abap_bool.
    DATA lv_is_bool_2 TYPE abap_bool.

    lv_max = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements INTO ls_stmt_if WHERE keyword = 'IF'.
      lv_idx = sy-tabix.
      IF lv_idx + 4 > lv_max.
        CONTINUE.
      ENDIF.

      ls_stmt_then      = is_procedure-statements[ lv_idx + 1 ].
      ls_stmt_else      = is_procedure-statements[ lv_idx + 2 ].
      ls_stmt_else_body = is_procedure-statements[ lv_idx + 3 ].
      ls_stmt_endif     = is_procedure-statements[ lv_idx + 4 ].

      IF ls_stmt_else-keyword <> 'ELSE' OR ls_stmt_endif-keyword <> 'ENDIF'.
        CONTINUE.
      ENDIF.

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_then
                             IMPORTING ev_target    = lv_target_1
                                       ev_is_bool   = lv_is_bool_1 ).

      is_boolean_assignment( EXPORTING is_statement = ls_stmt_else_body
                             IMPORTING ev_target    = lv_target_2
                                       ev_is_bool   = lv_is_bool_2 ).

      IF lv_is_bool_1 = abap_true AND lv_is_bool_2 = abap_true AND lv_target_1 = lv_target_2.
        report_statement( is_statement    = ls_stmt_if
                          iv_finding_code = c_finding_codes-prefer_xsdbool ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_boolean_assignment.
    DATA ls_tok_target TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_val    TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_is_bool = abap_false.
    CLEAR ev_target.

    IF lines( is_statement-tokens ) <> 3.
      RETURN.
    ENDIF.

    ls_tok_target = is_statement-tokens[ 1 ].
    ls_tok_eq     = is_statement-tokens[ 2 ].
    ls_tok_val    = is_statement-tokens[ 3 ].

    IF ls_tok_eq-lexeme <> '='.
      RETURN.
    ENDIF.

    IF is_boolean_value( ls_tok_val-lexeme ) = abap_true.
      ev_target  = ls_tok_target-lexeme.
      ev_is_bool = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_boolean_value.
    DATA lv_upper TYPE string.
    lv_upper = to_upper( iv_lexeme ).

    CASE lv_upper.
      WHEN 'ABAP_TRUE' OR 'ABAP_FALSE' OR '''X''' OR ''' ''' OR '''''' OR 'SPACE'.
        rv_res = abap_true.
      WHEN OTHERS.
        rv_res = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
