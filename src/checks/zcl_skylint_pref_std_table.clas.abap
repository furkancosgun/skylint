CLASS zcl_skylint_pref_std_table DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        std_table TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_STDTB',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_standard TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADD_STDTAB',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_STD_TABLE'.

    METHODS collect_overrides
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_found) TYPE zcl_skylint_ast_util=>ty_token_overrides.

ENDCLASS.


CLASS zcl_skylint_pref_std_table IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer explicit TYPE STANDARD TABLE OF over TYPE TABLE OF'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-std_table
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Specify the table kind explicitly: TYPE STANDARD TABLE OF'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_standard
                                                                short_text = 'Add STANDARD table kind' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_line      TYPE string.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lt_overrides = collect_overrides( <ls_statement> ).
      IF lt_overrides IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                         it_overrides = lt_overrides
                                                         iv_suffix    = '.' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_standard
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-std_table
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD collect_overrides.
    DATA lv_start TYPE i.
    DATA lv_index TYPE i.
    DATA lv_count TYPE i.

    CLEAR rt_found.
    lv_start = 1.
    lv_count = lines( is_statement-tokens ).

    WHILE lv_start > 0 AND lv_start <= lv_count.
      lv_index = zcl_skylint_ast_util=>find_token_sequence( is_statement   = is_statement
                                                            it_expected    = VALUE #( ( `TYPE` ) ( `TABLE` ) ( `OF` ) )
                                                            iv_start_index = lv_start ).
      IF lv_index = 0.
        EXIT.
      ENDIF.
      APPEND VALUE #( index  = lv_index
                      lexeme = 'TYPE STANDARD' ) TO rt_found.
      lv_start = lv_index + 3.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
