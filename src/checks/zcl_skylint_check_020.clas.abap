CLASS zcl_skylint_check_020 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_if TYPE if_ci_atc_check=>ty_finding_code VALUE 'NESTEDIF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NESTED_IF'.

    METHODS is_nested_if_mergeable
      IMPORTING iv_idx       TYPE i
                is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_020 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect consecutive nested IF blocks that can be merged with AND'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-nested_if
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Nested IF block can be merged with outer IF using AND'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'IF'.
      lv_idx = sy-tabix.
      IF is_nested_if_mergeable( iv_idx       = lv_idx
                                 is_procedure = is_procedure ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-nested_if ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_nested_if_mergeable.
    DATA lv_total      TYPE i.
    DATA lv_next_idx   TYPE i.
    DATA lv_fwd_idx    TYPE i.
    DATA lv_check_idx  TYPE i.
    DATA lv_depth      TYPE i.
    DATA ls_next_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_fwd_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_outer_end  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found      TYPE abap_bool.
    DATA lv_found_fwd  TYPE abap_bool.
    DATA lv_found_outer TYPE abap_bool.

    rv_is = abap_false.
    lv_total = lines( is_procedure-statements ).
    lv_next_idx = iv_idx + 1.

    IF lv_next_idx > lv_total.
      RETURN.
    ENDIF.

    get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                  iv_index       = lv_next_idx
                        IMPORTING es_statement   = ls_next_stmt
                                  ev_found       = lv_found ).
    IF lv_found = abap_false OR ls_next_stmt-keyword <> 'IF'.
      RETURN.
    ENDIF.

    " Find matching ENDIF for inner IF (at lv_next_idx)
    lv_depth = 1.
    lv_fwd_idx = lv_next_idx + 1.

    WHILE lv_fwd_idx <= lv_total.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index       = lv_fwd_idx
                          IMPORTING es_statement   = ls_fwd_stmt
                                    ev_found       = lv_found_fwd ).
      IF lv_found_fwd = abap_false.
        EXIT.
      ENDIF.

      CASE ls_fwd_stmt-keyword.
        WHEN 'IF'.
          lv_depth += 1.

        WHEN 'ENDIF'.
          lv_depth -= 1.
          IF lv_depth = 0.
            " We found matching ENDIF for inner IF!
            " Check if directly following statement is outer ENDIF
            lv_check_idx = lv_fwd_idx + 1.
            IF lv_check_idx <= lv_total.
              get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                            iv_index       = lv_check_idx
                                  IMPORTING es_statement   = ls_outer_end
                                            ev_found       = lv_found_outer ).
              IF lv_found_outer = abap_true AND ls_outer_end-keyword = 'ENDIF'.
                rv_is = abap_true.
              ENDIF.
            ENDIF.
            RETURN.
          ENDIF.
      ENDCASE.

      lv_fwd_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
