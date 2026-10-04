CLASS zcl_skylint_check_003 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        default_key TYPE zif_skylint_types=>ty_finding_code VALUE 'DEFAULTKEY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_003 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-default_key
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key'
                                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_expected TYPE zcl_skylint_ast_util=>ty_token_lexemes.
    DATA lv_matched  TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    lt_expected = VALUE #( ( `DEFAULT` ) ( `KEY` ) ).

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TYPES' OR 'DATA' OR 'STATICS' OR 'CLASS-DATA' OR 'FIELD-SYMBOL'.
          lv_matched = zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                                   it_expected  = lt_expected ).
          IF lv_matched = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-default_key ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
