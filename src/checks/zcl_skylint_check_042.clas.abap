CLASS zcl_skylint_check_042 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'IDENTMOVE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'IDENTICAL_MOVE'.

    METHODS is_identical_assignment
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_042 IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Detect Identical Self Assignments'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-identical_move
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Identical assignment has no effect; remove redundant statement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_identical_assignment( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-identical_move ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA lv_left TYPE string.
    DATA lv_eq TYPE string.
    DATA lv_right TYPE string.

    rv_res = abap_false.

    IF lines( is_statement-tokens ) <> 3.
      RETURN.
    ENDIF.

    IF is_statement-keyword = 'DATA'
       OR is_statement-keyword = 'CONSTANTS'
       OR is_statement-keyword = 'FIELD-SYMBOLS'.
      RETURN.
    ENDIF.

    lv_left  = to_upper( is_statement-tokens[ 1 ]-lexeme ).
    lv_eq    = is_statement-tokens[ 2 ]-lexeme.
    lv_right = to_upper( is_statement-tokens[ 3 ]-lexeme ).

    IF lv_eq = '=' AND lv_left = lv_right.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
