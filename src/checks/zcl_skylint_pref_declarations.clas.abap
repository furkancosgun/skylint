CLASS zcl_skylint_pref_declarations DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        definitions_top TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEF_TOP',
        decl_order      TYPE if_ci_atc_check=>ty_finding_code VALUE 'DECL_ORDER',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_top   TYPE string VALUE 'DEF_TOP'.
    CONSTANTS c_pseudo_comment_order TYPE string VALUE 'DECL_ORDER'.

    DATA mv_check_def_top    TYPE abap_bool VALUE abap_true.
    DATA mv_check_decl_order TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_pref_declarations IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Routine Declaration Hygiene (top placement & order)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-definitions_top
                       text           = 'Reorder definitions to beginning of routine; avoid scattered declarations'
                       pseudo_comment = c_pseudo_comment_top )
                     ( code           = c_finding_codes-decl_order
                       text           = 'Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS'
                       pseudo_comment = c_pseudo_comment_order ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_DEF_TOP'
                                                value = REF #( mv_check_def_top ) )
                                              ( name  = 'CHECK_DECL_ORDER'
                                                value = REF #( mv_check_decl_order ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_seen_executable TYPE abap_bool VALUE abap_false.
    DATA lv_max_rank        TYPE i         VALUE 0.
    DATA lv_curr_rank       TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_curr_rank = 0.

      CASE <ls_stmt>-keyword.
        WHEN 'METHOD' OR 'FORM' OR 'FUNCTION' OR 'ENDMETHOD' OR 'ENDFORM' OR 'ENDFUNCTION'.
          CONTINUE.

        WHEN 'TYPES'.
          lv_curr_rank = 1.
        WHEN 'CONSTANTS'.
          lv_curr_rank = 2.
        WHEN 'DATA' OR 'STATICS'.
          lv_curr_rank = 3.
        WHEN 'FIELD-SYMBOLS'.
          lv_curr_rank = 4.

        WHEN OTHERS.
          lv_seen_executable = abap_true.
      ENDCASE.

      IF lv_curr_rank > 0.
        IF mv_check_def_top = abap_true AND lv_seen_executable = abap_true.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-definitions_top ).
        ENDIF.

        IF mv_check_decl_order = abap_true AND lv_seen_executable = abap_false.
          IF lv_curr_rank < lv_max_rank.
            report_statement( is_statement    = <ls_stmt>
                              iv_finding_code = c_finding_codes-decl_order ).
          ELSE.
            lv_max_rank = lv_curr_rank.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
