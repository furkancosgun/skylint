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
    DATA lv_total    TYPE i.
    DATA lv_next_idx TYPE i.
    DATA lv_fwd_idx  TYPE i.
    DATA lv_depth    TYPE i.
    FIELD-SYMBOLS <ls_next_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_fwd_stmt>  TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_outer_end> TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_is = abap_false.
    lv_total = lines( is_procedure-statements ).
    lv_next_idx = iv_idx + 1.

    IF lv_next_idx > lv_total.
      RETURN.
    ENDIF.

    ASSIGN is_procedure-statements[ lv_next_idx ] TO <ls_next_stmt>.
    IF sy-subrc <> 0 OR <ls_next_stmt>-keyword <> 'IF'.
      RETURN.
    ENDIF.

    " Find matching ENDIF for inner IF (at lv_next_idx)
    lv_depth = 1.
    lv_fwd_idx = lv_next_idx + 1.

    WHILE lv_fwd_idx <= lv_total.
      ASSIGN is_procedure-statements[ lv_fwd_idx ] TO <ls_fwd_stmt>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CASE <ls_fwd_stmt>-keyword.
        WHEN 'IF'.
          lv_depth += 1.

        WHEN 'ENDIF'.
          lv_depth -= 1.
          IF lv_depth = 0.
            " We found matching ENDIF for inner IF!
            " Check if directly following statement is outer ENDIF
            IF lv_fwd_idx + 1 <= lv_total.
              ASSIGN is_procedure-statements[ lv_fwd_idx + 1 ] TO <ls_outer_end>.
              IF sy-subrc = 0 AND <ls_outer_end>-keyword = 'ENDIF'.
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
