CLASS zcl_skylint_pref_def_top DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        definitions_top TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEF_TOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEF_TOP'.
ENDCLASS.


CLASS zcl_skylint_pref_def_top IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Place definitions at beginning of routine'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-definitions_top
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Reorder definitions to beginning of routine; avoid scattered DATA statements'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_seen_executable TYPE abap_bool VALUE abap_false.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      CASE <ls_stmt>-keyword.
        WHEN 'METHOD' OR 'FORM' OR 'FUNCTION' OR 'ENDMETHOD' OR 'ENDFORM' OR 'ENDFUNCTION'.
          CONTINUE.

        WHEN 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS' OR 'FIELD-SYMBOLS'.
          IF lv_seen_executable = abap_true.
            report_statement( is_statement    = <ls_stmt>
                              iv_finding_code = c_finding_codes-definitions_top ).
          ENDIF.
        WHEN OTHERS.
          lv_seen_executable = abap_true.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
