CLASS zcl_skylint_check_004 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_not TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERISNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_IS_NOT'.

    METHODS has_not_is_pattern
      IMPORTING is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_matched) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_004 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer IS NOT over NOT ... IS'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_is_not
                                                                severity = if_ci_atc_check=>finding_severities-warning
                                                                text           = 'Use IS NOT instead of NOT ... IS'
                                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> LIKE LINE OF is_procedure-statements.
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'IF' OR keyword = 'ELSEIF' OR keyword = 'CHECK'
            OR keyword = 'WHILE'.
      IF has_not_is_pattern( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_is_not ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_not_is_pattern.
    DATA lv_in_not      TYPE abap_bool.
    DATA lv_is_idx      TYPE i.
    DATA lv_lexeme      TYPE string.
    DATA lv_next_lexeme TYPE string.
    DATA lv_idx         TYPE i.
    DATA ls_next_token  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found       TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_matched = abap_false.
    lv_in_not = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_idx = sy-tabix.
      lv_lexeme = to_upper( <ls_token>-lexeme ).

      IF lv_lexeme = 'NOT'.
        lv_in_not = abap_true.
      ELSEIF lv_lexeme = 'AND' OR lv_lexeme = 'OR' OR lv_lexeme = ')' OR lv_lexeme = '('.
        lv_in_not = abap_false.
      ELSEIF lv_in_not = abap_true AND lv_lexeme = 'IS'.
        lv_is_idx = lv_idx + 1.
        zcl_skylint_ast_util=>get_token_safe( EXPORTING is_statement = is_statement
                                                        iv_index     = lv_is_idx
                                              IMPORTING es_token     = ls_next_token
                                                        ev_found     = lv_found ).
        IF lv_found = abap_true.
          lv_next_lexeme = to_upper( ls_next_token-lexeme ).
          IF    lv_next_lexeme = 'INITIAL'   OR lv_next_lexeme = 'BOUND'
             OR lv_next_lexeme = 'ASSIGNED'  OR lv_next_lexeme = 'SUPPLIED'
             OR lv_next_lexeme = 'REQUESTED' OR lv_next_lexeme = 'INSTANCE'.
            rv_matched = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
        lv_in_not = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
