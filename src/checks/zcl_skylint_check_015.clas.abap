CLASS zcl_skylint_check_015 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        empty_catch TYPE zif_skylint_types=>ty_finding_code VALUE 'EMPTYCATCH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_HANDLER'.

    METHODS is_empty_catch
      IMPORTING iv_next_kw   TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_015 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect empty CATCH blocks swallowing exceptions'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-empty_catch
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Empty CATCH block swallowing exception; handle, log or re-raise'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA ls_next_stmt  TYPE zif_skylint_types=>ty_statement.
    DATA lv_found_next TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CATCH'.
      lv_idx = sy-tabix.
      zcl_skylint_ast_util=>get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                                          iv_index      = lv_idx + 1
                                                IMPORTING es_statement  = ls_next_stmt
                                                          ev_found      = lv_found_next ).
      IF     lv_found_next = abap_true
         AND is_empty_catch( ls_next_stmt-keyword ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-empty_catch ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_empty_catch.
    rv_is = abap_false.

    CASE iv_next_kw.
      WHEN 'CATCH' OR 'CLEANUP' OR 'ENDTRY' OR 'ENDCATCH'.
        rv_is = abap_true.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
