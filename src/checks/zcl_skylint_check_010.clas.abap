CLASS zcl_skylint_check_010 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_template TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONCATSTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_STR_TMPL'.

    DATA mv_allow_in_byte_mode TYPE abap_bool VALUE abap_false.

    METHODS is_byte_mode
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_byte_mode) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_010 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer string templates over CONCATENATE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_template
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Use string template |...| instead of CONCATENATE'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #(
                                     ( name  = 'ALLOW_IN_BYTE_MODE'
                                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                       value = REF #( mv_allow_in_byte_mode ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_allow_byte TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'ALLOW_IN_BYTE_MODE'
                   IMPORTING ev_value = lv_allow_byte ).

    "TODO: gereksiz if 
    IF lv_allow_byte IS INITIAL.
      lv_allow_byte = mv_allow_in_byte_mode.
    ENDIF.

    "TODO: byte mode ne kadar gerekli tartışılır string template yeterli duruyor
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CONCATENATE'.
      IF lv_allow_byte = abap_true AND is_byte_mode( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_template ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_byte_mode.
    DATA lv_prev_lexeme TYPE string.
    DATA lv_curr_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_byte_mode = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_curr_lexeme = to_upper( <ls_token>-lexeme ).
      IF lv_prev_lexeme = 'BYTE' AND lv_curr_lexeme = 'MODE'.
        rv_byte_mode = abap_true.
        RETURN.
      ENDIF.
      lv_prev_lexeme = lv_curr_lexeme.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
