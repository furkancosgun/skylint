CLASS zcl_skylint_check_057 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_order_by TYPE if_ci_atc_check=>ty_finding_code VALUE 'SELECT_UP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELECT_UP_TO_1'.

    METHODS is_unorder_select_up_to
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_057 IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: SELECT UP TO 1 ROWS requires ORDER BY'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-missing_order_by
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'SELECT'.
      IF is_unorder_select_up_to( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-missing_order_by ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_unorder_select_up_to.
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_lex TYPE string.
    DATA lv_next TYPE string.
    DATA lv_has_up_to TYPE abap_bool.
    DATA lv_has_order_by TYPE abap_bool.

    rv_res = abap_false.
    lv_has_up_to = abap_false.
    lv_has_order_by = abap_false.
    lv_count = lines( is_statement-tokens ).

    DO lv_count TIMES.
      lv_idx = sy-index.
      lv_lex = to_upper( is_statement-tokens[ lv_idx ]-lexeme ).

      " Check for separate tokens 'UP' followed by 'TO'
      IF lv_lex = 'UP' AND lv_idx < lv_count.
        lv_next = to_upper( is_statement-tokens[ lv_idx + 1 ]-lexeme ).
        IF lv_next = 'TO'.
          lv_has_up_to = abap_true.
        ENDIF.
      ENDIF.

      " Check for separate tokens 'ORDER' followed by 'BY'
      IF lv_lex = 'ORDER' AND lv_idx < lv_count.
        lv_next = to_upper( is_statement-tokens[ lv_idx + 1 ]-lexeme ).
        IF lv_next = 'BY'.
          lv_has_order_by = abap_true.
        ENDIF.
      ENDIF.
    ENDDO.

    IF lv_has_up_to = abap_true AND lv_has_order_by = abap_false.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
