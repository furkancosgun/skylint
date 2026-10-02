CLASS zcl_skylint_check_029 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_parameters TYPE zif_skylint_types=>ty_finding_code VALUE 'PARAMCOUNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PARAM_COUNT'.

    DATA mv_max_parameters TYPE i VALUE 8.

    METHODS count_parameters
      IMPORTING is_statement    TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_029 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Method signature cleanliness (excessive parameter count)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-too_many_parameters
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Method signature has too many parameters; consider grouping into structures'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_PARAMETERS'
                                                kind  = zif_skylint_types=>attribute_kinds-elementary
                                                value = REF #( mv_max_parameters ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_procedure-id-kind <> zif_skylint_types=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    get_attribute( EXPORTING iv_name  = 'MAX_PARAMETERS'
                   IMPORTING ev_value = lv_max ).
    IF lv_max <= 0.
      lv_max = mv_max_parameters.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF count_parameters( <ls_statement> ) > lv_max.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-too_many_parameters ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_parameters.
    DATA ls_tok TYPE zif_skylint_types=>ty_token.

    rv_count = 0.
    LOOP AT is_statement-tokens INTO ls_tok.
      IF ls_tok-lexeme = 'TYPE' OR ls_tok-lexeme = 'LIKE'.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
