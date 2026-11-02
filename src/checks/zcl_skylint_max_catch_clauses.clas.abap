CLASS zcl_skylint_max_catch_clauses DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_catches TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_CATCH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_CATCH_CLAUSES'.

    DATA mv_max_catch_clauses TYPE i VALUE 3.

    TYPES:
      BEGIN OF ty_try_entry,
        statement   TYPE if_ci_atc_source_code_provider=>ty_statement,
        catch_count TYPE i,
      END OF ty_try_entry,
      ty_try_stack TYPE STANDARD TABLE OF ty_try_entry WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_skylint_max_catch_clauses IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Limit CATCH clauses per TRY block'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-too_many_catches
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'TRY block has too many CATCH clauses; handling too many errors indicates coupling'
                  pseudo_comment = c_pseudo_comment ) )
            attributes        = VALUE #( ( name  = 'MAX_CATCH_CLAUSES'
                                           kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                           value = REF #( mv_max_catch_clauses ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_stack       TYPE ty_try_stack.
    DATA ls_entry       TYPE ty_try_entry.
    DATA lv_stack_lines TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_top>       TYPE ty_try_entry.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TRY'.
          APPEND VALUE #( statement   = <ls_statement>
                          catch_count = 0 ) TO lt_stack.

        WHEN 'CATCH'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ASSIGN lt_stack[ lv_stack_lines ] TO <ls_top>.
            <ls_top>-catch_count += 1.
          ENDIF.

        WHEN 'ENDTRY'.
          lv_stack_lines = lines( lt_stack ).
          IF lv_stack_lines > 0.
            ls_entry = lt_stack[ lv_stack_lines ].
            DELETE lt_stack INDEX lv_stack_lines.
            IF ls_entry-catch_count > mv_max_catch_clauses.
              report_statement( is_statement    = ls_entry-statement
                                iv_finding_code = c_finding_codes-too_many_catches ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
