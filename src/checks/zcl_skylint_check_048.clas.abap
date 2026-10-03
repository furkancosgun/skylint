CLASS zcl_skylint_check_048 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        class_not_final TYPE zif_skylint_types=>ty_finding_code VALUE 'NOT_FINAL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CLASS_FINAL'.

    METHODS is_class_missing_final
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_048 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Prefer FINAL Classes by Default'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-class_not_final
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Classes should be marked FINAL by default unless designed for inheritance'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      IF is_class_missing_final( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-class_not_final ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_class_missing_final.
    DATA ls_tok         TYPE zif_skylint_types=>ty_token.
    DATA lv_lex         TYPE string.
    DATA lv_is_def      TYPE abap_bool.
    DATA lv_is_final    TYPE abap_bool.
    DATA lv_is_abstract TYPE abap_bool.
    DATA lv_is_test     TYPE abap_bool.

    rv_res = abap_false.
    lv_is_def = abap_false.
    lv_is_final = abap_false.
    lv_is_abstract = abap_false.
    lv_is_test = abap_false.

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_lex = to_upper( ls_tok-lexeme ).
      CASE lv_lex.
        WHEN 'DEFINITION'.
          lv_is_def = abap_true.
        WHEN 'FINAL'.
          lv_is_final = abap_true.
        WHEN 'ABSTRACT'.
          lv_is_abstract = abap_true.
        WHEN 'TESTING'.
          lv_is_test = abap_true.
      ENDCASE.
    ENDLOOP.

    IF     lv_is_def      = abap_true  AND lv_is_final = abap_false
       AND lv_is_abstract = abap_false AND lv_is_test  = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
