CLASS zcl_skylint_check_002 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        describe_lines TYPE if_ci_atc_check=>ty_finding_code VALUE 'DESCRIBELN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DESCRIBE_LINES'.

ENDCLASS.


CLASS zcl_skylint_check_002 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-describe_lines
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use lines( ) function instead of DESCRIBE TABLE ... LINES'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_table TYPE abap_bool.
    DATA lv_has_lines TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'DESCRIBE'.
      lv_has_table = abap_false.
      lv_has_lines = abap_false.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        CASE to_upper( <ls_token>-lexeme ).
          WHEN 'TABLE'.
            lv_has_table = abap_true.
          WHEN 'LINES'.
            lv_has_lines = abap_true.
        ENDCASE.
      ENDLOOP.

      IF lv_has_table = abap_true AND lv_has_lines = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-describe_lines ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
