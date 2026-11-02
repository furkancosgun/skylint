CLASS zcl_skylint_max_elseif_count DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_elseifs TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_ELSEIF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_ELSEIF_COUNT'.

    DATA mv_max_elseif_count TYPE i VALUE 5.

    TYPES:
      BEGIN OF ty_if_entry,
        statement    TYPE if_ci_atc_source_code_provider=>ty_statement,
        elseif_count TYPE i,
      END OF ty_if_entry,
      ty_if_stack TYPE STANDARD TABLE OF ty_if_entry WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_skylint_max_elseif_count IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of ELSEIF clauses per IF'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-too_many_elseifs
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'IF statement has too many ELSEIF clauses; consider CASE or polymorphism'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_ELSEIF_COUNT'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_elseif_count ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_stack       TYPE ty_if_stack.
    DATA ls_entry       TYPE ty_if_entry.
    DATA lv_stack_lines TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_top>       TYPE ty_if_entry.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF'.
          APPEND VALUE #( statement    = <ls_statement>
                          elseif_count = 0 ) TO lt_stack.

        WHEN 'ELSEIF'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ASSIGN lt_stack[ lv_stack_lines ] TO <ls_top>.
            <ls_top>-elseif_count += 1.
          ENDIF.

        WHEN 'ENDIF'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ls_entry = lt_stack[ lv_stack_lines ].
            DELETE lt_stack INDEX lv_stack_lines.
            IF ls_entry-elseif_count > mv_max_elseif_count.
              report_statement( is_statement    = ls_entry-statement
                                iv_finding_code = c_finding_codes-too_many_elseifs ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
