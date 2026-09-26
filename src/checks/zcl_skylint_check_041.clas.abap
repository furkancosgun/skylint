CLASS zcl_skylint_check_041 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        superfluous_val TYPE if_ci_atc_check=>ty_finding_code VALUE 'SUPERFLUOUS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SUPERFLUOUS_VAL'.

    METHODS is_superfluous_value
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

    METHODS is_empty_value_assignment
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

    METHODS has_nested_value_constructor
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_041 IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid Superfluous VALUE Operator'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-superfluous_val
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Superfluous VALUE operator; prefer CLEAR or omit redundant constructor'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_superfluous_value( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-superfluous_val ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_superfluous_value.
    rv_res = xsdbool( is_empty_value_assignment( is_statement ) = abap_true
                      OR has_nested_value_constructor( is_statement ) = abap_true ).
  ENDMETHOD.

  METHOD is_empty_value_assignment.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.
    DATA lv_tok3 TYPE string.
    DATA lv_tok4 TYPE string.
    DATA lv_tok5 TYPE string.
    DATA lv_count TYPE i.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).

    IF lv_count = 5.
      lv_tok1 = is_statement-tokens[ 2 ]-lexeme.
      lv_tok2 = to_upper( is_statement-tokens[ 3 ]-lexeme ).
      lv_tok3 = to_upper( is_statement-tokens[ 4 ]-lexeme ).
      lv_tok4 = is_statement-tokens[ 5 ]-lexeme.

      IF lv_tok1 = '=' AND lv_tok2 = 'VALUE' AND ( lv_tok3 = '#(' OR lv_tok3 CP '*#(' ) AND lv_tok4 = ')'.
        rv_res = abap_true.
      ENDIF.
    ELSEIF lv_count >= 6.
      lv_tok1 = is_statement-tokens[ 2 ]-lexeme.
      lv_tok2 = to_upper( is_statement-tokens[ 3 ]-lexeme ).
      lv_tok3 = is_statement-tokens[ 4 ]-lexeme.
      lv_tok4 = is_statement-tokens[ 5 ]-lexeme.
      lv_tok5 = is_statement-tokens[ 6 ]-lexeme.

      IF lv_tok1 = '=' AND lv_tok2 = 'VALUE' AND ( lv_tok3 = '#' OR lv_tok3 CP '*_TAB' )
         AND lv_tok4 = '(' AND lv_tok5 = ')'.
        rv_res = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD has_nested_value_constructor.
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.
    DATA lv_tok3 TYPE string.

    rv_res = abap_false.
    lv_count = lines( is_statement-tokens ).

    DO lv_count TIMES.
      lv_idx = sy-index.
      IF lv_idx + 2 <= lv_count.
        lv_tok1 = is_statement-tokens[ lv_idx ]-lexeme.
        lv_tok2 = to_upper( is_statement-tokens[ lv_idx + 1 ]-lexeme ).
        lv_tok3 = to_upper( is_statement-tokens[ lv_idx + 2 ]-lexeme ).

        IF lv_tok1 = '(' AND lv_tok2 = 'VALUE' AND ( lv_tok3 = '#(' OR lv_tok3 CP '*#(' ).
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
