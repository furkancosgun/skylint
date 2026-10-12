CLASS zcl_skylint_check_029 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        too_many_parameters TYPE if_ci_atc_check=>ty_finding_code VALUE 'PARAMCOUNT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_max_parameters TYPE i VALUE 8.

    METHODS count_parameters
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_skylint_check_029 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Method signature cleanliness (excessive parameter count)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-too_many_parameters
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Method signature has too many parameters; consider grouping into structures' ) )
                 attributes        = VALUE #( ( name  = 'MAX_PARAMETERS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_parameters ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF count_parameters( <ls_statement> ) > mv_max_parameters.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-too_many_parameters ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_parameters.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_count = 0.
    LOOP AT is_statement-tokens INTO ls_tok WHERE references IS INITIAL.
      IF ls_tok-lexeme = 'TYPE' OR ls_tok-lexeme = 'LIKE'.
        rv_count += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
