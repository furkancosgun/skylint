CLASS zcl_skylint_check_041 DEFINITION
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
    METHODS is_system_variable_mod
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_system_field
      IMPORTING is_ref       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_write_access
      IMPORTING is_ref       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_041 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Avoid sy-* System Variable Modification'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-system_var_mod
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid modifying system fields (sy-*); system variables are read-only' ) ) ) ).
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
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF     is_system_field( <ls_ref> ) = abap_true
           AND is_write_access( <ls_ref> ) = abap_true.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_field.
    rv_is = xsdbool(
          is_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
      AND (    is_ref-full_name CS '\DA:SY\'
            OR is_ref-full_name CS '\DA:SYST\'
            OR is_ref-full_name CS '\PR:SYST\'
            OR is_ref-full_name  = '\DA:SY'
            OR is_ref-full_name  = '\DA:SYST' ) ).
  ENDMETHOD.

  METHOD is_write_access.
    rv_is = xsdbool(
         is_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write
      OR is_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-write_partial
      OR is_ref-usage_mode = if_ci_atc_source_code_provider=>usage_modes-read_and_write ).
  ENDMETHOD.
ENDCLASS.
