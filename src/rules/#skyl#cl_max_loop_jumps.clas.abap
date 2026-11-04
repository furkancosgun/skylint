CLASS /skyl/cl_max_loop_jumps DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_jumps TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_JUMPS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_LOOP_JUMPS'.

    DATA mv_max_loop_jumps TYPE i VALUE 2.

    TYPES:
      BEGIN OF ty_loop_entry,
        statement  TYPE if_ci_atc_source_code_provider=>ty_statement,
        jump_count TYPE i,
      END OF ty_loop_entry,
      ty_loop_stack TYPE STANDARD TABLE OF ty_loop_entry WITH EMPTY KEY.

ENDCLASS.


CLASS /skyl/cl_max_loop_jumps IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit jump statements (CONTINUE/EXIT) per loop'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-too_many_jumps
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Loop has too many jump statements (CONTINUE/EXIT); simplify loop control flow'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_LOOP_JUMPS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_loop_jumps ) ) ) ) ).
  ENDMETHOD.

  METHOD execute.
    DATA lt_stack       TYPE ty_loop_stack.
    DATA ls_entry       TYPE ty_loop_entry.
    DATA lv_stack_lines TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_top>       TYPE ty_loop_entry.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          APPEND VALUE #( statement  = <ls_statement>
                          jump_count = 0 ) TO lt_stack.

        WHEN 'CONTINUE' OR 'EXIT'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ASSIGN lt_stack[ lv_stack_lines ] TO <ls_top>.
            <ls_top>-jump_count += 1.
          ENDIF.

        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ls_entry = lt_stack[ lv_stack_lines ].
            DELETE lt_stack INDEX lv_stack_lines.
            IF ls_entry-jump_count > mv_max_loop_jumps.
              report_statement( is_statement    = ls_entry-statement
                                iv_finding_code = c_finding_codes-too_many_jumps ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
