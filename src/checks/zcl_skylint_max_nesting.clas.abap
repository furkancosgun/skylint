CLASS zcl_skylint_max_nesting DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nesting_depth TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_NEST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_NESTING'.

    DATA mv_max_depth TYPE i VALUE 3.
ENDCLASS.


CLASS zcl_skylint_max_nesting IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Nesting Depth Limit (excessive control block nesting)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-nesting_depth
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = |Control block nesting depth exceeds|
                                                               && |maximum allowed limit|
                                                pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_depth = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'IF' OR 'CASE' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'TRY'.
          lv_depth += 1.
          IF lv_depth > mv_max_depth.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-nesting_depth ).
          ENDIF.
        WHEN 'ENDIF' OR 'ENDCASE' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDTRY'.
          IF lv_depth > 0.
            lv_depth -= 1.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
