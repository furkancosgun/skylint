CLASS zcl_skylint_pref_opt_last DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        optional_last TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_OPT_L',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_OPTIONAL_LAST'.

    METHODS check_method_parameters
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

ENDCLASS.


CLASS zcl_skylint_pref_opt_last IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Declare optional and default parameters last in methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-optional_last
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Declare mandatory parameters before OPTIONAL and DEFAULT parameters'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'.
        check_method_parameters( <ls_statement> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_method_parameters.
    TYPES:
      BEGIN OF ty_param_info,
        token       TYPE if_ci_atc_source_code_provider=>ty_token,
        section     TYPE string,
        is_optional TYPE abap_bool,
      END OF ty_param_info.

    DATA lt_params        TYPE STANDARD TABLE OF ty_param_info WITH EMPTY KEY.
    DATA lv_curr_section  TYPE string.
    DATA ls_prev_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_tabix         TYPE i.
    DATA lv_param_idx     TYPE i.
    DATA lv_seen_optional TYPE abap_bool.
    DATA ls_param         TYPE ty_param_info.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_p>   TYPE ty_param_info.

    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tabix = sy-tabix.

      IF <ls_tok>-references IS NOT INITIAL.
        ls_prev_tok = <ls_tok>.
        CONTINUE.
      ENDIF.

      CASE <ls_tok>-lexeme.
        WHEN 'IMPORTING' OR 'CHANGING'.
          lv_curr_section = <ls_tok>-lexeme.

        WHEN 'EXPORTING' OR 'RETURNING' OR 'RAISING' OR 'EXCEPTIONS'
          OR 'FOR' OR 'REDEFINITION' OR 'ABSTRACT' OR 'FINAL'.
          CLEAR lv_curr_section.

        WHEN 'TYPE' OR 'LIKE'.
          IF lv_curr_section IS NOT INITIAL AND ls_prev_tok-lexeme IS NOT INITIAL.
            APPEND VALUE #( token       = ls_prev_tok
                            section     = lv_curr_section
                            is_optional = abap_false ) TO lt_params.
          ENDIF.

        WHEN 'OPTIONAL' OR 'DEFAULT'.
          lv_param_idx = lines( lt_params ).
          IF lv_param_idx > 0.
            ASSIGN lt_params[ lv_param_idx ] TO <ls_p>.
            IF sy-subrc = 0.
              <ls_p>-is_optional = abap_true.
            ENDIF.
          ENDIF.
      ENDCASE.

      ls_prev_tok = <ls_tok>.
    ENDLOOP.

    CLEAR: lv_curr_section,
           lv_seen_optional.

    LOOP AT lt_params INTO ls_param.
      IF ls_param-section <> lv_curr_section.
        lv_curr_section   = ls_param-section.
        lv_seen_optional = abap_false.
      ENDIF.

      IF ls_param-is_optional = abap_true.
        lv_seen_optional = abap_true.
      ELSEIF lv_seen_optional = abap_true.
        report_token( is_token        = ls_param-token
                      is_statement    = is_statement
                      iv_finding_code = c_finding_codes-optional_last ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
