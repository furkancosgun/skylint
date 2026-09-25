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

    METHODS is_chained_declaration
      IMPORTING
        is_statement      TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_chained) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_009 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid chained declarations (DATA:, TYPES:, etc.)'
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
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_chained_declaration( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-chained_declaration ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_chained_declaration.
    DATA lv_allow_struct TYPE abap_bool.
    DATA lv_first_token  TYPE string.
    DATA lv_lexeme       TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_chained = abap_false.

    IF lines( is_statement-tokens ) < 2.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'ALLOW_STRUCTURE_CHAINS'
                   IMPORTING ev_value = lv_allow_struct ).

    IF lv_allow_struct IS INITIAL.
      lv_allow_struct = mv_allow_structure_chains.
    ENDIF.

    IF lv_allow_struct = abap_true.
      LOOP AT is_statement-tokens ASSIGNING <ls_token>.
        lv_lexeme = to_upper( <ls_token>-lexeme ).
        IF lv_lexeme = 'BEGIN' OR lv_lexeme = 'END'.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lv_first_token = to_upper( is_statement-tokens[ 1 ]-lexeme ).

    CASE lv_first_token.
      WHEN 'DATA' OR 'DATA:' OR 'TYPES' OR 'TYPES:' OR 'CONSTANTS' OR 'CONSTANTS:'
        OR 'STATICS' OR 'STATICS:' OR 'FIELD-SYMBOLS' OR 'FIELD-SYMBOLS:'.
        IF lv_first_token CP '*:'
           OR ( lines( is_statement-tokens ) >= 2 AND is_statement-tokens[ 2 ]-lexeme = ':' ).
          rv_chained = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
