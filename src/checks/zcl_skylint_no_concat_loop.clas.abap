CLASS zcl_skylint_no_concat_loop DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        concat_in_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONCATLP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CONCAT_LOOP'.

    TYPES: BEGIN OF ty_target,
             token     TYPE if_ci_atc_source_code_provider=>ty_token,
             full_name TYPE string,
           END OF ty_target.

    METHODS get_write_target
      IMPORTING is_statement     TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_target) TYPE ty_target.

    METHODS is_self_concat
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS token_reads_target
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
                iv_full_name  TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS has_template_target
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_full_name  TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_no_concat_loop IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid string concatenation inside loops'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-concat_in_loop
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Accumulate parts in a table and concatenate once'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_depth += 1.
        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_depth > 0.
            lv_depth -= 1.
          ENDIF.
        WHEN OTHERS.
          IF lv_depth > 0 AND is_self_concat( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-concat_in_loop ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_write_target.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>   TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    CLEAR rs_target.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      LOOP AT <ls_token>-references ASSIGNING <ls_ref>.
        IF     <ls_ref>-kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
           AND zcl_skylint_ast_util=>is_write_usage( <ls_ref> ) = abap_true.
          rs_target-token     = <ls_token>.
          rs_target-full_name = <ls_ref>-full_name.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_self_concat.
    DATA ls_target TYPE ty_target.
    DATA lv_into   TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    IF is_statement-keyword <> 'COMPUTE' AND is_statement-keyword <> 'CONCATENATE'.
      RETURN.
    ENDIF.

    ls_target = get_write_target( is_statement ).
    IF ls_target-full_name IS INITIAL.
      RETURN.
    ENDIF.

    IF is_statement-keyword = 'COMPUTE'.
      IF     zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                               iv_lexeme    = '&&' )       = 0
         AND has_template_target( is_statement = is_statement
                                  iv_full_name = ls_target-full_name )     = abap_false.
        RETURN.
      ENDIF.
    ELSE.
      lv_into = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                  iv_lexeme    = 'INTO' ).
      IF lv_into = 0.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF is_statement-keyword = 'CONCATENATE' AND sy-tabix >= lv_into.
        EXIT.
      ENDIF.
      IF token_reads_target( is_token     = <ls_token>
                             iv_full_name = ls_target-full_name ) = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_template_target.
    DATA lv_in_template TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme = '|'.
        IF lv_in_template = abap_true.
          lv_in_template = abap_false.
        ELSE.
          lv_in_template = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.
      IF lv_in_template = abap_false.
        CONTINUE.
      ENDIF.
      IF token_reads_target( is_token     = <ls_token>
                             iv_full_name = iv_full_name ) = abap_true.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD token_reads_target.
    FIELD-SYMBOLS <ls_ref> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_yes = abap_false.

    LOOP AT is_token-references ASSIGNING <ls_ref>.
      IF <ls_ref>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-data.
        CONTINUE.
      ENDIF.
      IF <ls_ref>-full_name <> iv_full_name.
        CONTINUE.
      ENDIF.
      IF zcl_skylint_ast_util=>is_read_usage( <ls_ref> ) = abap_false.
        CONTINUE.
      ENDIF.

      rv_yes = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
