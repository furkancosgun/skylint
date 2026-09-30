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
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

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
    DATA lv_total      TYPE i.
    DATA lv_idx        TYPE i.
    DATA lv_next_idx   TYPE i.
    DATA lv_tok        TYPE string.
    DATA lv_next       TYPE string.
    DATA ls_t          TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_n          TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found      TYPE abap_bool.
    DATA lv_found_next TYPE abap_bool.

    rv_res = abap_false.
    lv_total = lines( is_statement-tokens ).
    IF lv_total < 3.
      RETURN.
    ENDIF.

    lv_idx = 1.
    WHILE lv_idx < lv_total.
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx
                      IMPORTING es_token     = ls_t
                                ev_found     = lv_found ).
      IF lv_found = abap_false.
        EXIT.
      ENDIF.

      lv_tok = to_upper( ls_t-lexeme ).
      IF lv_tok = 'TYPE'.
        lv_next_idx = lv_idx + 1.
        get_token_safe( EXPORTING is_statement = is_statement
                                  iv_index     = lv_next_idx
                        IMPORTING es_token     = ls_n
                                  ev_found     = lv_found_next ).
        IF lv_found_next = abap_true.
          lv_next = ls_n-lexeme.
          IF lv_next CP '*( *' OR lv_next CP '(*)' OR lv_next(1) = '('.
            " Dynamic type: TYPE (lv_cls)
            RETURN.
          ENDIF.
          rv_res = abap_true.
          RETURN.
        ENDIF.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
