CLASS zcl_skylint_no_dead_store DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        dead_store TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DEAD_ST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DEAD_STORE'.

    TYPES ty_statement_indexes TYPE STANDARD TABLE OF i WITH EMPTY KEY.

    METHODS collect_data_objects
      IMPORTING it_statements   TYPE if_ci_atc_source_code_provider=>ty_statements
      RETURNING VALUE(rt_names) TYPE string_table.

    METHODS check_object
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_full_name  TYPE string.

    METHODS classify_access
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_full_name TYPE string
      EXPORTING ev_read      TYPE abap_bool
                ev_write     TYPE abap_bool.

    METHODS is_whole_object
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_full_name  TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_block_boundary
      IMPORTING iv_keyword    TYPE clike
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_conditional_write
      IMPORTING iv_keyword    TYPE clike
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_assignment
      IMPORTING iv_keyword    TYPE clike
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_dead_store IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid assignments that are never read'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-dead_store
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'This value is overwritten before it is read; remove the assignment or read it'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_objects TYPE string_table.
    FIELD-SYMBOLS <lv_object> TYPE string.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_objects = collect_data_objects( is_procedure-statements ).

    LOOP AT lt_objects ASSIGNING <lv_object>.
      check_object( it_statements = is_procedure-statements
                    iv_full_name  = <lv_object> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_data_objects.
    DATA lt_refs TYPE if_ci_atc_source_code_provider=>ty_compiler_references.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      lt_refs = zcl_skylint_ast_util=>statement_get_references(
                    is_statement = <ls_statement>
                    iv_kind      = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      LOOP AT lt_refs ASSIGNING <ls_ref>.
        IF    zcl_skylint_ast_util=>is_data_definition( <ls_ref> )  = abap_false
           OR <ls_ref>-full_name IS INITIAL
           OR line_exists( rt_names[ table_line = <ls_ref>-full_name ] ).
          CONTINUE.
        ENDIF.
        APPEND <ls_ref>-full_name TO rt_names.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_object.
    DATA lv_read          TYPE abap_bool.
    DATA lv_write         TYPE abap_bool.
    DATA lv_index         TYPE i.
    DATA lv_pending       TYPE i.
    DATA lv_pending_store TYPE abap_bool.
    DATA lv_has_read      TYPE abap_bool.
    DATA ls_statement     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lt_dead          TYPE ty_statement_indexes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <lv_dead>      TYPE i.

    LOOP AT it_statements ASSIGNING <ls_statement>.
      lv_index = sy-tabix.

      classify_access( EXPORTING is_statement = <ls_statement>
                                 iv_full_name = iv_full_name
                       IMPORTING ev_read      = lv_read
                                 ev_write     = lv_write ).

      IF lv_read = abap_true.
        lv_has_read = abap_true.
        CLEAR lv_pending.
      ENDIF.

      IF is_block_boundary( <ls_statement>-keyword ) = abap_true.
        CLEAR lv_pending.
      ENDIF.

      IF lv_write = abap_false.
        CONTINUE.
      ENDIF.

      IF is_conditional_write( <ls_statement>-keyword ) = abap_true.
        CLEAR lv_pending.
        CONTINUE.
      ENDIF.

      IF lv_pending <> 0 AND lv_pending_store = abap_true.
        APPEND lv_pending TO lt_dead.
      ENDIF.

      lv_pending       = lv_index.
      lv_pending_store = is_assignment( <ls_statement>-keyword ).
    ENDLOOP.

    IF lv_has_read = abap_false.
      RETURN.
    ENDIF.

    LOOP AT lt_dead ASSIGNING <lv_dead>.
      ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                          iv_index      = <lv_dead> ).
      report_statement( is_statement    = ls_statement
                        iv_finding_code = c_finding_codes-dead_store ).
    ENDLOOP.
  ENDMETHOD.

  METHOD classify_access.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: ev_read,
           ev_write.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_token>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
      IF    ls_ref-full_name IS INITIAL
         OR zcl_skylint_ast_util=>reference_matches( iv_full_name = iv_full_name
                                                     iv_reference = ls_ref-full_name )  = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>is_read_usage( ls_ref ) = abap_true.
        ev_read = abap_true.
      ENDIF.

      IF     zcl_skylint_ast_util=>is_full_write_usage( ls_ref ) = abap_true
         AND is_whole_object( is_token     = <ls_token>
                              iv_full_name = iv_full_name )      = abap_true.
        ev_write = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_whole_object.
    DATA lv_name TYPE string.

    lv_name = zcl_skylint_ast_util=>get_reference_name( iv_full_name ).

    rv_yes = xsdbool( lv_name IS NOT INITIAL AND to_upper( is_token-lexeme ) = lv_name ).
  ENDMETHOD.

  METHOD is_block_boundary.
    CASE iv_keyword.
      WHEN 'IF' OR 'ELSE' OR 'ELSEIF' OR 'ENDIF'
        OR 'CASE' OR 'WHEN' OR 'ENDCASE'
        OR 'LOOP' OR 'ENDLOOP' OR 'DO' OR 'ENDDO'
        OR 'WHILE' OR 'ENDWHILE'
        OR 'TRY' OR 'CATCH' OR 'CLEANUP' OR 'ENDTRY'
        OR 'SELECT' OR 'ENDSELECT' OR 'PROVIDE' OR 'ENDPROVIDE'.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_conditional_write.
    CASE iv_keyword.
      WHEN 'LOOP' OR 'READ' OR 'SELECT' OR 'IMPORT' OR 'GET'.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_assignment.
    rv_yes = xsdbool( iv_keyword = 'COMPUTE' OR iv_keyword = 'MOVE' ).
  ENDMETHOD.
ENDCLASS.
