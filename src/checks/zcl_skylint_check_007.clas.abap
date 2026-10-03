CLASS zcl_skylint_check_007 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        assignment_chaining TYPE zif_skylint_types=>ty_finding_code VALUE 'ASSIGNCHN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'ASSIGN_CHAIN'.

    METHODS has_assignment_chain
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_chain) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_007 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid assignment chaining (a = b = c)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-assignment_chaining
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Avoid chained assignments; write separate assignment statements'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'COMPUTE'.
      IF has_assignment_chain( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-assignment_chaining ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_assignment_chain.
    DATA lv_depth        TYPE i.
    DATA lv_equals_count TYPE i.
    DATA lv_lexeme       TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE zif_skylint_types=>ty_token.

    rv_chain = abap_false.

    lv_depth = 0.
    lv_equals_count = 0.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.

      IF    lv_lexeme CP '*(' OR lv_lexeme CP '*[' OR lv_lexeme CP '*{'
         OR lv_lexeme  = '('  OR lv_lexeme  = '['  OR lv_lexeme  = '{'.
        lv_depth += 1.
      ENDIF.

      IF lv_depth = 0 AND lv_lexeme = '='.
        lv_equals_count += 1.
      ENDIF.

      IF     (    lv_lexeme CP '*)' OR lv_lexeme CP '*]' OR lv_lexeme CP '*}'
               OR lv_lexeme  = ')'  OR lv_lexeme  = ']'  OR lv_lexeme  = '}' )
         AND lv_depth > 0.
        lv_depth -= 1.
      ENDIF.
    ENDLOOP.

    IF lv_equals_count > 1.
      rv_chain = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
