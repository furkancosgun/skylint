CLASS zcl_skylint_check_027 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        public_attribute TYPE if_ci_atc_check=>ty_finding_code VALUE 'NOPUBATTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NUM_PUBLIC_ATTR'.

    METHODS is_read_only
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_027 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid mutable public attributes in classes'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-public_attribute
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid public attributes; use private/protected with getters or READ-ONLY'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_public TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lv_in_public = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PUBLIC'.
          lv_in_public = abap_true.
        WHEN 'PROTECTED' OR 'PRIVATE'.
          lv_in_public = abap_false.
        WHEN 'DATA' OR 'CLASS-DATA'.
          IF lv_in_public = abap_true AND is_read_only( <ls_statement> ) = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-public_attribute ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_read_only.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      IF ls_tok-lexeme = 'READ-ONLY'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
