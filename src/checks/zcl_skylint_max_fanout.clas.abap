CLASS zcl_skylint_max_fanout DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        type_fanout TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAX_FANOUT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    TYPES ty_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAX_FANOUT'.

    DATA mv_max_fanout TYPE i VALUE 15.

    METHODS collect_types
      IMPORTING is_procedure     TYPE if_ci_atc_source_code_provider=>ty_procedure
      RETURNING VALUE(rt_names)  TYPE ty_names.

    METHODS is_class_like
      IMPORTING iv_name       TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_max_fanout IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit type fan-out per procedure'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-type_fanout
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Procedure depends on too many distinct classes or interfaces'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #(
                     ( name  = 'MAX_FANOUT'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                       value = REF #( mv_max_fanout ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_types      TYPE ty_names.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    lt_types = collect_types( is_procedure ).

    IF lines( lt_types ) <= mv_max_fanout.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS NOT INITIAL.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-type_fanout ).
    ENDIF.
  ENDMETHOD.

  METHOD collect_types.
    DATA lv_class TYPE string.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_reference> TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        LOOP AT <ls_token>-references ASSIGNING <ls_reference>.
          IF <ls_reference>-kind <> if_ci_atc_source_code_provider=>compiler_reference_kinds-type.
            CONTINUE.
          ENDIF.

          lv_class = ``.
          zcl_skylint_ast_util=>parse_full_name( EXPORTING iv_full_name  = <ls_reference>-full_name
                                                 IMPORTING ev_class_name = lv_class ).
          IF is_class_like( lv_class ) = abap_false.
            CONTINUE.
          ENDIF.
          IF line_exists( rt_names[ table_line = lv_class ] ).
            CONTINUE.
          ENDIF.
          INSERT lv_class INTO TABLE rt_names.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_class_like.
    rv_yes = abap_false.
    IF iv_name IS INITIAL.
      RETURN.
    ENDIF.
    rv_yes = xsdbool(    iv_name CP 'CL_*'
                      OR iv_name CP 'ZCL_*'
                      OR iv_name CP 'ZIF_*'
                      OR iv_name CP 'ZCX_*'
                      OR iv_name(1) = '/' ).
  ENDMETHOD.
ENDCLASS.
