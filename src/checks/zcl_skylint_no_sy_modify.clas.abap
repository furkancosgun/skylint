CLASS zcl_skylint_no_sy_modify DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SY_MODIFY'.

    METHODS modifies_system_field
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_modifies) TYPE abap_bool.

    METHODS is_system_write_token
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_sy_modify IMPLEMENTATION.
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
      IF modifies_system_field( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-system_var_mod ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD modifies_system_field.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_modifies = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF is_system_write_token( <ls_token> ) = abap_true.
        rv_modifies = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_system_write_token.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_is = abap_false.

    LOOP AT is_token-references ASSIGNING <ls_ref>
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
      IF (    <ls_ref>-full_name CP '\DA:SY\*'
           OR <ls_ref>-full_name CP '\DA:SYST\*'
           OR <ls_ref>-full_name  = '\DA:SY'
           OR <ls_ref>-full_name  = '\DA:SYST' )
         AND (    <ls_ref>-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-write
               OR <ls_ref>-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-write_partial
               OR <ls_ref>-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-read_and_write
               OR <ls_ref>-usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition ).
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
