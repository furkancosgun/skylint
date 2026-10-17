CLASS zcl_skylint_max_attributes DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        attribute_count TYPE if_ci_atc_check=>ty_finding_code VALUE 'ATTR_COUNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'ATTRIBUTES'.

    DATA mv_max_attributes TYPE i VALUE 5.

ENDCLASS.


CLASS zcl_skylint_max_attributes IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of member attributes in a class (God Class smell)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-attribute_count
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Class has too many member attributes; split into cohesive components'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_ATTRIBUTES'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_attributes ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_count      TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'DATA' OR <ls_statement>-keyword = 'CLASS-DATA'.
        lv_count += 1.
      ENDIF.
    ENDLOOP.

    IF lv_count > mv_max_attributes.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-attribute_count ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
