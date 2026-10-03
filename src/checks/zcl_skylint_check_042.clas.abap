CLASS zcl_skylint_check_042 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_returning TYPE zif_skylint_types=>ty_finding_code VALUE 'PREFER_RET',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_RETURNING'.

ENDCLASS.


CLASS zcl_skylint_check_042 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer RETURNING over single EXPORTING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_returning
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Prefer functional RETURNING parameter over single EXPORTING parameter'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    DATA ls_statement TYPE zif_skylint_types=>ty_statement.
    DATA ls_meth      TYPE abap_methdescr.
    DATA ls_param     TYPE abap_parmdescr.
    DATA lv_exp_count TYPE i.
    DATA lv_chg_count TYPE i.
    DATA lv_ret_count TYPE i.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    lo_class = zcl_skylint_rtti_util=>describe_class( is_code_block-object_name ).
    IF lo_class IS NOT BOUND.
      RETURN.
    ENDIF.

    ls_statement = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                        iv_index      = 1 ).
    IF ls_statement-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lo_class->methods INTO ls_meth
         WHERE is_redefined = abap_false.
      IF ls_meth-name = 'CONSTRUCTOR' OR ls_meth-name = 'CLASS_CONSTRUCTOR' OR ls_meth-for_event IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      lv_exp_count = 0.
      lv_chg_count = 0.
      lv_ret_count = 0.

      LOOP AT ls_meth-parameters INTO ls_param.
        CASE ls_param-parm_kind.
          WHEN cl_abap_objectdescr=>exporting.
            lv_exp_count += 1.
          WHEN cl_abap_objectdescr=>changing.
            lv_chg_count += 1.
          WHEN cl_abap_objectdescr=>returning.
            lv_ret_count += 1.
        ENDCASE.
      ENDLOOP.

      IF lv_exp_count = 1 AND lv_chg_count = 0 AND lv_ret_count = 0.
        report_statement( is_statement    = ls_statement
                          iv_finding_code = c_finding_codes-prefer_returning ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
