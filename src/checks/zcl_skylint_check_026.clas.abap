CLASS zcl_skylint_check_026 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_new TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFERNEW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_NEW'.

    METHODS is_static_create_object
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_026 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer NEW #( ) constructor expression over legacy CREATE OBJECT'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_new
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Prefer NEW #( ) expression over CREATE OBJECT'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CREATE'.
      IF is_static_create_object( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_new ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_static_create_object.
    DATA lv_total TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_tok   TYPE string.
    DATA lv_tok2  TYPE string.
    DATA lv_last1 TYPE string.
    DATA lv_last2 TYPE string.
    FIELD-SYMBOLS <ls_t1> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_t2> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.
    lv_total = lines( is_statement-tokens ).
    IF lv_total < 2.
      RETURN.
    ENDIF.

    ASSIGN is_statement-tokens[ 2 ] TO <ls_t1>.
    IF sy-subrc <> 0 OR to_upper( <ls_t1>-lexeme ) <> 'OBJECT'.
      RETURN.
    ENDIF.

    " Check for RAP FOR TESTING
    IF lv_total >= 4.
      ASSIGN is_statement-tokens[ lv_total - 1 ] TO <ls_t1>.
      IF sy-subrc = 0.
        ASSIGN is_statement-tokens[ lv_total ] TO <ls_t2>.
        IF sy-subrc = 0.
          lv_last1 = to_upper( <ls_t1>-lexeme ).
          lv_last2 = to_upper( <ls_t2>-lexeme ).
          IF lv_last1 = 'FOR' AND lv_last2 = 'TESTING'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    " Check tokens for dynamic TYPE (...), PARAMETER-TABLE, or OLE strings
    lv_idx = 3.
    WHILE lv_idx <= lv_total.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_t1>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_tok = to_upper( <ls_t1>-lexeme ).

      IF lv_tok = 'PARAMETER-TABLE'.
        RETURN.
      ENDIF.

      IF lv_tok = 'TYPE' AND lv_idx < lv_total.
        ASSIGN is_statement-tokens[ lv_idx + 1 ] TO <ls_t2>.
        IF sy-subrc = 0.
          lv_tok2 = <ls_t2>-lexeme.
          IF lv_tok2 CP '*( *' OR lv_tok2 CP '(*)' OR lv_tok2(1) = '('.
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.

      " OLE Automation: CREATE OBJECT excel 'Excel.Application'
      IF lv_idx = 3 AND ( lv_tok(1) = `'` OR lv_tok(1) = '`' ).
        RETURN.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.

    rv_res = abap_true.
  ENDMETHOD.
ENDCLASS.
