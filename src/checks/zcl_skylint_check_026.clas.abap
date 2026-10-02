CLASS zcl_skylint_check_026 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_call_via_instance TYPE if_ci_atc_check=>ty_finding_code VALUE 'STATICVIAINST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STATIC_CALL'.

    METHODS is_static_call
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_026 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid calling static methods via instance arrow (->)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-static_call_via_instance
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Call static method using => instead of ->'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    IF is_procedure-id-kind = zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements INTO ls_stmt.
      LOOP AT ls_stmt-tokens INTO ls_tok.
        IF is_static_call( ls_tok ) = abap_true.
          report_statement( is_statement    = ls_stmt
                            iv_finding_code = c_finding_codes-static_call_via_instance ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_static_call.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    IF is_token-lexeme NS '->'.
      RETURN.
    ENDIF.

    LOOP AT is_token-references INTO ls_ref
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF zcl_skylint_rtti_util=>is_static_method( ls_ref-full_name ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
