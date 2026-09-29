CLASS zcl_skylint_check_051 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        system_var_mod TYPE if_ci_atc_check=>ty_finding_code VALUE 'SYS_VAR_MD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_SY_MOD'.

    METHODS is_system_variable_mod
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_051 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid sy-* System Variable Modification'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-system_var_mod
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid modifying system fields (sy-*); system variables are read-only'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_system_variable_mod( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-system_var_mod ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_variable_mod.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.

    rv_res = abap_false.

    IF lines( is_statement-tokens ) < 2.
      RETURN.
    ENDIF.

    lv_tok1 = to_upper( is_statement-tokens[ 1 ]-lexeme ).
    lv_tok2 = to_upper( is_statement-tokens[ 2 ]-lexeme ).

    " 1. Assignment: sy-subrc = 0.
    IF lv_tok2 = '=' AND ( lv_tok1 CP 'SY-*' OR lv_tok1 CP 'SYST-*' ).
      rv_res = abap_true.
      RETURN.
    ENDIF.

    " 2. CLEAR statement: CLEAR sy-subrc.
    IF lv_tok1 = 'CLEAR' AND ( lv_tok2 CP 'SY-*' OR lv_tok2 CP 'SYST-*' ).
      rv_res = abap_true.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
