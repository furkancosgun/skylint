CLASS zcl_skylint_check_056 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bool_method_name TYPE zif_skylint_types=>ty_finding_code VALUE 'BOOL_NAME',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS is_non_compliant_bool_method
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_check_056 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-bool_method_name
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Boolean-returning method should use predicate name (IS_, HAS_, CAN_)'
                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      IF is_non_compliant_bool_method( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-bool_method_name ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_non_compliant_bool_method.
    DATA lv_ret_idx TYPE i.
    DATA ls_type    TYPE zif_skylint_types=>ty_token.
    DATA ls_name    TYPE zif_skylint_types=>ty_token.
    DATA lv_type    TYPE string.
    DATA lv_name    TYPE string.

    rv_yes = abap_false.

    lv_ret_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'RETURNING' ).
    IF lv_ret_idx = 0.
      RETURN.
    ENDIF.

    ls_type = zcl_skylint_ast_util=>get_token_after( is_statement   = is_statement
                                                     iv_lexeme      = 'TYPE'
                                                     iv_start_index = lv_ret_idx ).
    IF ls_type-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    lv_type = to_upper( ls_type-lexeme ).
    IF     lv_type <> 'ABAP_BOOL' AND lv_type <> 'FLAG'
       AND lv_type <> 'XSDBOOL' AND lv_type <> 'BOOLEAN'
       AND lv_type <> 'BOOLE_D' AND lv_type <> 'XFELD'.
      RETURN.
    ENDIF.

    ls_name = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                               iv_index     = 2 ).
    lv_name = to_upper( ls_name-lexeme ).

    IF     lv_name NP 'IS_*' AND lv_name NP 'HAS_*'
       AND lv_name NP 'CAN_*' AND lv_name NP 'CHECK_*'
       AND lv_name NP 'ARE_*' AND lv_name NP 'WAS_*'
       AND lv_name NP 'SHOULD_*'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
