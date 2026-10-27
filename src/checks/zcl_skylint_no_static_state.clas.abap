CLASS zcl_skylint_no_static_state DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_state TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_STAT_ST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_STATIC_STATE'.

    DATA mv_check_class_data TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics    TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_static_state IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid CLASS-DATA and STATICS state'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-static_state
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Static state hides dependencies and survives between calls; inject state instead'
                  pseudo_comment = c_pseudo_comment ) )
            attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                         ( name  = 'CHECK_CLASS_DATA'
                                           value = REF #( mv_check_class_data ) )
                                         ( name  = 'CHECK_STATICS'
                                           value = REF #( mv_check_statics ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    CASE is_procedure-id-kind.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
        IF mv_check_class_data = abap_false.
          RETURN.
        ENDIF.
        LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
          IF <ls_statement>-keyword <> 'CLASS-DATA'.
            CONTINUE.
          ENDIF.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-static_state ).
        ENDLOOP.
      WHEN if_ci_atc_source_code_provider=>procedure_kinds-method
        OR if_ci_atc_source_code_provider=>procedure_kinds-form_routine
        OR if_ci_atc_source_code_provider=>procedure_kinds-function.
        IF mv_check_statics = abap_false.
          RETURN.
        ENDIF.
        LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
          IF <ls_statement>-keyword <> 'STATICS'.
            CONTINUE.
          ENDIF.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-static_state ).
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
