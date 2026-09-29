CLASS zcl_skylint_check_095 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        calc_assign TYPE if_ci_atc_check=>ty_finding_code VALUE 'CALC_ASSGN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_CALC_ASSIGN'.
ENDCLASS.


CLASS zcl_skylint_check_095 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-calc_assign
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use calculation assignment operator (+=, -=) or ADD statement replacement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.
    DATA lv_tok3 TYPE string.
    DATA lv_tok4 TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'ADD' OR <ls_statement>-keyword = 'SUBTRACT'
          OR <ls_statement>-keyword = 'MULTIPLY' OR <ls_statement>-keyword = 'DIVIDE'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-calc_assign ).
        CONTINUE.
      ENDIF.

      IF lines( <ls_statement>-tokens ) >= 5.
        lv_tok1 = to_upper( <ls_statement>-tokens[ 1 ]-lexeme ).
        lv_tok2 = to_upper( <ls_statement>-tokens[ 2 ]-lexeme ).
        lv_tok3 = to_upper( <ls_statement>-tokens[ 3 ]-lexeme ).
        lv_tok4 = to_upper( <ls_statement>-tokens[ 4 ]-lexeme ).

        IF lv_tok2 = '=' AND lv_tok1 = lv_tok3 AND ( lv_tok4 = '+' OR lv_tok4 = '-' OR lv_tok4 = '*' OR lv_tok4 = '/' ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-calc_assign ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
