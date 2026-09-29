CLASS zcl_skylint_check_009 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        chained_declaration TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHAINDECL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CHAIN_DECL'.

    DATA mv_allow_structure_chains TYPE abap_bool VALUE abap_true.

    METHODS is_structure_start
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_009 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid chained declarations (DATA:, TYPES:, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-chained_declaration
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid chained declarations; declare each entity individually'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'ALLOW_STRUCTURE_CHAINS'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_allow_structure_chains ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_allow_struct TYPE abap_bool.
    DATA lv_total        TYPE i.
    DATA lv_idx          TYPE i.
    DATA lv_next_idx     TYPE i.
    DATA lv_report       TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'ALLOW_STRUCTURE_CHAINS'
                   IMPORTING ev_value = lv_allow_struct ).

    IF lv_allow_struct IS INITIAL.
      lv_allow_struct = mv_allow_structure_chains.
    ENDIF.

    lv_total = lines( is_procedure-statements ).

    DO lv_total TIMES.
      lv_idx = sy-index.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_statement>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS' OR 'FIELD-SYMBOLS' OR 'CLASS-DATA'.
          lv_next_idx = lv_idx + 1.
          IF lv_next_idx <= lv_total.
            ASSIGN is_procedure-statements[ lv_next_idx ] TO <ls_next_stmt>.
            IF sy-subrc = 0 AND ( <ls_next_stmt>-keyword IS INITIAL
               OR ( lines( <ls_next_stmt>-tokens ) > 0 AND lines( <ls_statement>-tokens ) > 0
                    AND <ls_next_stmt>-tokens[ 1 ]-position-line = <ls_statement>-tokens[ 1 ]-position-line
                    AND <ls_next_stmt>-position-line <> <ls_statement>-position-line ) ).
              lv_report = abap_true.
              IF lv_allow_struct = abap_true AND is_structure_start( <ls_statement> ) = abap_true.
                lv_report = abap_false.
              ENDIF.

              IF lv_report = abap_true.
                report_statement( is_statement    = <ls_statement>
                                  iv_finding_code = c_finding_codes-chained_declaration ).
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDDO.
  ENDMETHOD.

  METHOD is_structure_start.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = to_upper( <ls_token>-lexeme ).
      IF lv_lexeme = 'BEGIN'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
