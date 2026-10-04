CLASS zcl_skylint_check_058 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        attribute_count TYPE zif_skylint_types=>ty_finding_code VALUE 'ATTR_COUNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_max_attributes TYPE i VALUE 5.

ENDCLASS.


CLASS zcl_skylint_check_058 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Limit number of member attributes in a class (God Class smell)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-attribute_count
                       severity = zif_skylint_types=>severities-warning
                       text     = 'Class has too many member attributes; split into cohesive components' ) )
                 attributes        = VALUE #( ( name  = 'MAX_ATTRIBUTES'
                                                kind  = zif_skylint_types=>attribute_kinds-integer
                                                value = REF #( mv_max_attributes ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_first_stmt TYPE zif_skylint_types=>ty_statement.
    DATA lv_max_attr   TYPE i.
    DATA lv_count      TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_ATTRIBUTES'
                   IMPORTING ev_value = lv_max_attr ).

    IF lv_max_attr <= 0.
      lv_max_attr = mv_max_attributes.
    ENDIF.

    ls_first_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_code_block-statements
                                                         iv_index      = 1 ).
    IF ls_first_stmt-keyword IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'DATA' OR <ls_statement>-keyword = 'CLASS-DATA'.
        lv_count = lv_count + 1.
      ENDIF.
    ENDLOOP.

    IF lv_count > lv_max_attr.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-attribute_count ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
