CLASS zcl_skylint_check_018 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unreachable_code TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNREACHCD',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'UNREACHABLE_CODE'.

    TYPES:
      BEGIN OF ty_depth_state,
        depth       TYPE i,
        unreachable TYPE abap_bool,
      END OF ty_depth_state,
      ty_depth_states TYPE STANDARD TABLE OF ty_depth_state WITH EMPTY KEY.

    METHODS is_unconditional_jump
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_depth_unreachable
      IMPORTING it_states     TYPE ty_depth_states
                iv_depth      TYPE i
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS set_depth_unreachable
      IMPORTING iv_depth  TYPE i
                iv_val    TYPE abap_bool
      CHANGING  ct_states TYPE ty_depth_states.

ENDCLASS.


CLASS zcl_skylint_check_018 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect unreachable code following unconditional jump statements'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unreachable_code
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Statement is unreachable'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_depth  TYPE i.
    DATA lt_states TYPE ty_depth_states.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_depth = 0.
    set_depth_unreachable( EXPORTING iv_depth  = 0
                                     iv_val    = abap_false
                           CHANGING  ct_states = lt_states ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'CASE' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'TRY'.
          IF is_depth_unreachable( it_states = lt_states
                                   iv_depth  = lv_depth ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-unreachable_code ).
          ENDIF.
          lv_depth += 1.
          set_depth_unreachable( EXPORTING iv_depth  = lv_depth
                                           iv_val    = abap_false
                                 CHANGING  ct_states = lt_states ).

        WHEN 'ELSE' OR 'ELSEIF' OR 'WHEN' OR 'CATCH' OR 'CLEANUP'.
          IF lv_depth > 0 AND is_depth_unreachable( it_states = lt_states
                                                    iv_depth  = lv_depth - 1 ) = abap_false.
            set_depth_unreachable( EXPORTING iv_depth  = lv_depth
                                             iv_val    = abap_false
                                   CHANGING  ct_states = lt_states ).
          ENDIF.

        WHEN 'ENDIF' OR 'ENDCASE' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDTRY'.
          set_depth_unreachable( EXPORTING iv_depth  = lv_depth
                                           iv_val    = abap_false
                                 CHANGING  ct_states = lt_states ).
          IF lv_depth > 0.
            lv_depth -= 1.
          ENDIF.

        WHEN 'ENDMETHOD' OR 'ENDFORM' OR 'ENDFUNCTION' OR 'ENDMODULE'.
          CONTINUE.

        WHEN OTHERS.
          IF is_depth_unreachable( it_states = lt_states
                                   iv_depth  = lv_depth ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-unreachable_code ).
          ELSEIF is_unconditional_jump( <ls_statement> ) = abap_true.
            set_depth_unreachable( EXPORTING iv_depth  = lv_depth
                                             iv_val    = abap_true
                                   CHANGING  ct_states = lt_states ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_depth_unreachable.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_state> TYPE ty_depth_state.

    rv_res = abap_false.
    lv_idx = 0.
    WHILE lv_idx <= iv_depth.
      ASSIGN it_states[ depth = lv_idx ] TO <ls_state>.
      IF sy-subrc = 0 AND <ls_state>-unreachable = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD set_depth_unreachable.
    FIELD-SYMBOLS <ls_state> TYPE ty_depth_state.

    ASSIGN ct_states[ depth = iv_depth ] TO <ls_state>.
    IF sy-subrc = 0.
      <ls_state>-unreachable = iv_val.
    ELSE.
      INSERT VALUE #( depth       = iv_depth
                      unreachable = iv_val ) INTO TABLE ct_states.
    ENDIF.
  ENDMETHOD.

  METHOD is_unconditional_jump.
    rv_res = abap_false.

    CASE is_statement-keyword.
      WHEN 'RETURN' OR 'EXIT' OR 'CONTINUE'.
        rv_res = abap_true.

      WHEN 'RAISE'.
        IF matches_token_at( is_statement = is_statement
                             iv_index     = 2
                             iv_expected  = `SHORTDUMP` ) = abap_true.
          rv_res = abap_true.
        ELSEIF matches_token_at( is_statement = is_statement
                                 iv_index     = 2
                                 iv_expected  = `EXCEPTION` ) = abap_true.
          rv_res = abap_true.
          IF matches_token_at( is_statement = is_statement
                               iv_index     = 3
                               iv_expected  = `RESUMABLE` ) = abap_true.
            rv_res = abap_false.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
