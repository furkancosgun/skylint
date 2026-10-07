CLASS zcl_skylint_check_004 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_is_not TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFERISNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.

    METHODS has_not_is_pattern
      IMPORTING is_statement      TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_matched) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_004 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer IS NOT over NOT ... IS'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_is_not
                                                                severity = zif_skylint_types=>severities-warning
                                                                text           = 'Use IS NOT instead of NOT ... IS'
                                                                ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> LIKE LINE OF is_code_block-statements.
    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
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
    DATA lv_lexeme      TYPE string.
    DATA lv_next_lexeme TYPE string.
    DATA lv_idx         TYPE i.
    DATA ls_next        TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_token> TYPE zif_skylint_types=>ty_token.

    rv_matched = abap_false.
    lv_in_not = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_idx = sy-tabix.
      IF <ls_token>-references IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      lv_lexeme = to_upper( <ls_token>-lexeme ).

      IF lv_lexeme = 'NOT'.
        lv_in_not = abap_true.
      ELSEIF lv_lexeme = 'AND' OR lv_lexeme = 'OR' OR lv_lexeme = ')' OR lv_lexeme = '('.
        lv_in_not = abap_false.
      ELSEIF lv_in_not = abap_true AND lv_lexeme = 'IS'.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_idx + 1 ).
        lv_next_lexeme = to_upper( ls_next-lexeme ).
        IF ls_next-references IS INITIAL.
          CASE lv_next_lexeme.
            WHEN 'INITIAL' OR 'BOUND' OR 'ASSIGNED' OR 'SUPPLIED' OR 'REQUESTED' OR 'INSTANCE'.
              rv_matched = abap_true.
              RETURN.
          ENDCASE.
        ENDIF.
        lv_in_not = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
