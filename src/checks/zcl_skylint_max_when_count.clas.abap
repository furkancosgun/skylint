CLASS zcl_skylint_max_when_count DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_whens TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_WHEN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_WHEN_COUNT'.

    DATA mv_max_when_count TYPE i VALUE 10.

    TYPES:
      BEGIN OF ty_case_entry,
        statement  TYPE if_ci_atc_source_code_provider=>ty_statement,
        when_count TYPE i,
      END OF ty_case_entry,
      ty_case_stack TYPE STANDARD TABLE OF ty_case_entry WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_skylint_max_when_count IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of WHEN clauses per CASE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-too_many_whens
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'CASE statement has too many WHEN clauses; consider refactoring'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_WHEN_COUNT'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_when_count ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_stack       TYPE ty_case_stack.
    DATA ls_entry       TYPE ty_case_entry.
    DATA lv_stack_lines TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_top>       TYPE ty_case_entry.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CASE'.
          APPEND VALUE #( statement  = <ls_statement>
                          when_count = 0 ) TO lt_stack.

        WHEN 'WHEN'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ASSIGN lt_stack[ lv_stack_lines ] TO <ls_top>.
            <ls_top>-when_count = <ls_top>-when_count + 1.
          ENDIF.

        WHEN 'ENDCASE'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ls_entry = lt_stack[ lv_stack_lines ].
            DELETE lt_stack INDEX lv_stack_lines.
            IF ls_entry-when_count > mv_max_when_count.
              report_statement( is_statement    = ls_entry-statement
                                iv_finding_code = c_finding_codes-too_many_whens ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
