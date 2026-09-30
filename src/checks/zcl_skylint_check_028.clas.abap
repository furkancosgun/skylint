CLASS zcl_skylint_check_028 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBSOLETE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEPRECATED_KEY'.

    METHODS is_obsolete_keyword
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_028 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid obsolete statements (MOVE, REFRESH, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-obsolete_statement
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid obsolete statement; use modern expressions instead'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_obsolete_keyword( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-obsolete_statement ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_obsolete_keyword.
    rv_res = abap_false.

    CASE is_statement-keyword.
      WHEN 'MOVE' OR 'REFRESH' OR 'TEST-SEAM' OR 'TEST-INJECT' OR 'TABLES' OR 'FIELD-GROUPS'.
        rv_res = abap_true.
      WHEN 'COMPUTE'.
        IF matches_token_at( is_statement = is_statement
                             iv_index     = 1
                             iv_expected  = `COMPUTE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
