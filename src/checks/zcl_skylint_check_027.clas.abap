CLASS zcl_skylint_check_027 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_exception_new TYPE if_ci_atc_check=>ty_finding_code VALUE 'RAISEEXCNEW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RAISE_EXC_NEW'.

    METHODS is_raise_exception_type
      IMPORTING
        is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING
        VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_027 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_exception_new
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      IF is_raise_exception_type( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_exception_new ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_exception_type.
    DATA lv_total TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_tok   TYPE string.
    DATA lv_next  TYPE string.
    FIELD-SYMBOLS <ls_t> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_n> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.
    lv_total = lines( is_statement-tokens ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx < lv_total.
      READ TABLE is_statement-tokens ASSIGNING <ls_t> INDEX lv_idx.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_tok = to_upper( <ls_t>-lexeme ).
      IF lv_tok = 'TYPE'.
        READ TABLE is_statement-tokens ASSIGNING <ls_n> INDEX lv_idx + 1.
        IF sy-subrc = 0.
          lv_next = <ls_n>-lexeme.
          IF lv_next CP '*( *' OR lv_next CP '(*)' OR lv_next(1) = '('.
            " Dynamic type: TYPE (lv_cls)
            RETURN.
          ENDIF.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDIF.

      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
