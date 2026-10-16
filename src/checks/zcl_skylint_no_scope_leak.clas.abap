CLASS zcl_skylint_no_scope_leak DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        scope_leak TYPE if_ci_atc_check=>ty_finding_code VALUE 'SCOPELEAK',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SCOPE_LEAK'.
    TYPES: BEGIN OF ty_scoped_var,
             full_name TYPE if_ci_atc_source_code_provider=>ty_full_name,
             block_id  TYPE i,
           END OF ty_scoped_var,
           ty_scoped_vars TYPE STANDARD TABLE OF ty_scoped_var WITH EMPTY KEY.
    TYPES ty_block_ids TYPE STANDARD TABLE OF i WITH EMPTY KEY.

    METHODS update_block_stack
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  cv_block_counter TYPE i
                ct_block_stack   TYPE ty_block_ids.

    METHODS has_scope_leak
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                it_scoped_vars TYPE ty_scoped_vars
                it_block_stack TYPE ty_block_ids
      RETURNING VALUE(rv_leak) TYPE abap_bool.

    METHODS extract_declared_vars
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_block_id    TYPE i
      RETURNING VALUE(rt_vars) TYPE ty_scoped_vars.

    METHODS is_block_active
      IMPORTING iv_block_id   TYPE i
                it_stack      TYPE ty_block_ids
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_data_definition
      IMPORTING is_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_data_usage
      IMPORTING is_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_scope_leak IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Scope of variable (avoid variable leaking outside control blocks)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-scope_leak
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Variable declared in inner block is referenced outside its scope'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_block_counter TYPE i.
    DATA lt_block_stack   TYPE ty_block_ids.
    DATA lt_scoped_vars   TYPE ty_scoped_vars.
    DATA lt_new_vars      TYPE ty_scoped_vars.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      update_block_stack( EXPORTING is_statement     = <ls_statement>
                          CHANGING  cv_block_counter = lv_block_counter
                                    ct_block_stack   = lt_block_stack ).

      IF has_scope_leak( is_statement   = <ls_statement>
                         it_scoped_vars = lt_scoped_vars
                         it_block_stack = lt_block_stack ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-scope_leak ).
      ENDIF.

      IF lines( lt_block_stack ) > 0.
        lt_new_vars = extract_declared_vars( is_statement = <ls_statement>
                                             iv_block_id  = lt_block_stack[ 1 ] ).
        APPEND LINES OF lt_new_vars TO lt_scoped_vars.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update_block_stack.
    CASE is_statement-keyword.
      WHEN 'IF' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'CASE' OR 'TRY'.
        cv_block_counter += 1.
        INSERT cv_block_counter INTO ct_block_stack INDEX 1.

      WHEN 'ELSE' OR 'ELSEIF' OR 'WHEN' OR 'CATCH' OR 'CLEANUP'.
        IF lines( ct_block_stack ) > 0.
          DELETE ct_block_stack INDEX 1.
        ENDIF.
        cv_block_counter += 1.
        INSERT cv_block_counter INTO ct_block_stack INDEX 1.

      WHEN 'ENDIF' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDCASE' OR 'ENDTRY'.
        IF lines( ct_block_stack ) > 0.
          DELETE ct_block_stack INDEX 1.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD has_scope_leak.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_var>   TYPE ty_scoped_var.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF is_data_usage( <ls_ref> ) = abap_false.
          CONTINUE.
        ENDIF.

        ASSIGN it_scoped_vars[ full_name = <ls_ref>-full_name ] TO <ls_var>.
        IF     sy-subrc = 0
           AND is_block_active( iv_block_id = <ls_var>-block_id
                                it_stack    = it_block_stack )  = abap_false.
          rv_leak = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_declared_vars.
    DATA ls_var TYPE ty_scoped_var.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_var-block_id = iv_block_id.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF is_data_definition( <ls_ref> ) = abap_false OR <ls_ref>-full_name IS INITIAL.
          CONTINUE.
        ENDIF.

        IF NOT line_exists( rt_vars[ full_name = <ls_ref>-full_name ] ).
          ls_var-full_name = <ls_ref>-full_name.
          APPEND ls_var TO rt_vars.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_block_active.
    rv_res = xsdbool( line_exists( it_stack[ table_line = iv_block_id ] ) ).
  ENDMETHOD.

  METHOD is_data_definition.
    rv_yes = xsdbool(
          is_ref-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
      AND (    is_ref-usage_grade = if_ci_atc_source_code_provider=>usage_grades-definition
            OR is_ref-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition
            OR is_ref-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition_with_write
            OR is_ref-usage_mode  = if_ci_atc_source_code_provider=>usage_modes-definition_with_assign ) ).
  ENDMETHOD.

  METHOD is_data_usage.
    rv_yes = xsdbool(
          is_ref-kind                  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
      AND is_data_definition( is_ref ) = abap_false ).
  ENDMETHOD.
ENDCLASS.
