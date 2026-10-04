CLASS zcl_skylint_check_028 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_statement TYPE zif_skylint_types=>ty_finding_code VALUE 'OBSOLETE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_obsolete_keyword
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_028 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid obsolete statements (MOVE, REFRESH, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-obsolete_statement
                                       severity = zif_skylint_types=>severities-warning
                                       text     = 'Avoid obsolete statement; use modern expressions instead' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 1
                                                   iv_expected  = `COMPUTE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
