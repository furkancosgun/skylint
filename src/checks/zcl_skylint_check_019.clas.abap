CLASS zcl_skylint_check_019 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        short_case TYPE zif_skylint_types=>ty_finding_code VALUE 'SHORTCASE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SHORT_CASE'.

    METHODS is_when_others
      IMPORTING is_statement TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS count_when_branches
      IMPORTING iv_start_idx  TYPE i
                is_code_block TYPE zif_skylint_types=>ty_code_block
      RETURNING VALUE(rv_cnt) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_019 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid short CASE constructs with only one WHEN branch; prefer IF'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-short_case
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'CASE statement has <= 1 WHEN branch; prefer IF'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx        TYPE i.
    DATA lv_when_count TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CASE'.
      lv_idx = sy-tabix.
      lv_when_count = count_when_branches( iv_start_idx  = lv_idx
                                           is_code_block = is_code_block ).
      IF lv_when_count <= 1.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-short_case ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_when_others.
    rv_is = zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                    iv_index     = 2
                                                    iv_expected  = `OTHERS` ).
  ENDMETHOD.

  METHOD count_when_branches.
    DATA lv_total    TYPE i.
    DATA lv_fwd_idx  TYPE i.
    DATA lv_depth    TYPE i.
    DATA ls_fwd_stmt TYPE zif_skylint_types=>ty_statement.

    rv_cnt = 0.
    lv_total = zcl_skylint_ast_util=>statement_count( is_code_block-statements ).
    lv_depth = 0.
    lv_fwd_idx = iv_start_idx + 1.

    WHILE lv_fwd_idx <= lv_total.
      ls_fwd_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                         iv_index      = lv_fwd_idx ).
      IF ls_fwd_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_fwd_stmt-keyword.
        WHEN 'CASE'.
          lv_depth = lv_depth + 1.

        WHEN 'ENDCASE'.
          IF lv_depth = 0.
            RETURN.
          ELSE.
            lv_depth = lv_depth - 1.
          ENDIF.

        WHEN 'WHEN'.
          IF lv_depth = 0 AND is_when_others( ls_fwd_stmt ) = abap_false.
            rv_cnt = rv_cnt + 1.
          ENDIF.
      ENDCASE.

      lv_fwd_idx = lv_fwd_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
