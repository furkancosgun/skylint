CLASS zcl_skylint_pref_full_typed DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        fully_typed TYPE if_ci_atc_check=>ty_finding_code VALUE 'FULLYTYPED',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'FULL_TYPED'.
    METHODS is_untyped_constant
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_full_typed IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Enforce fully typed constant declarations'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-fully_typed
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Constant declaration should explicitly specify TYPE'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CONSTANTS'.
      IF is_untyped_constant( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-fully_typed ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_untyped_constant.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_has_type TYPE abap_bool.
    DATA lv_is_struc TYPE abap_bool.

    rv_res = abap_false.
    lv_has_type = abap_false.
    lv_is_struc = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
      CASE ls_tok-lexeme.
        WHEN 'BEGIN' OR 'END'.
          lv_is_struc = abap_true.
        WHEN 'TYPE' OR 'LIKE'.
          lv_has_type = abap_true.
      ENDCASE.
    ENDLOOP.

    IF lv_is_struc = abap_false AND lv_has_type = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
