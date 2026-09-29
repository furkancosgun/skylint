CLASS zcl_skylint_check_069 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_reduce TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_REDUC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_REDUCE'.

ENDCLASS.


CLASS zcl_skylint_check_069 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer REDUCE expression over manual loop aggregation'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_reduce
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer REDUCE #( ... ) over manual loop aggregation'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_idx                  TYPE i.
    DATA lv_total                TYPE i.
    DATA ls_next1                TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next2                TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_has_accum            TYPE abap_bool.
    DATA lv_lexeme               TYPE string.

    lv_total = lines( is_procedure-statements ).
    lv_idx = 1.
    WHILE lv_idx <= lv_total.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_statement>.
      IF sy-subrc <> 0 OR <ls_statement>-keyword <> 'LOOP' OR lv_idx + 2 > lv_total.
        lv_idx = lv_idx + 1.
        CONTINUE.
      ENDIF.

      " Check short aggregation loop pattern: LOOP (idx+1: COMPUTE / statement) (idx+2: ENDLOOP)
      ls_next1 = is_procedure-statements[ lv_idx + 1 ].
      ls_next2 = is_procedure-statements[ lv_idx + 2 ].

      IF ls_next2-keyword = 'ENDLOOP'.
        lv_has_accum = abap_false.
        LOOP AT ls_next1-tokens ASSIGNING <ls_token>.
          lv_lexeme = to_upper( <ls_token>-lexeme ).
          IF lv_lexeme = '+' OR lv_lexeme = '-' OR lv_lexeme = '*' OR lv_lexeme = '/'
              OR lv_lexeme = 'DIV' OR lv_lexeme = 'MOD' OR lv_lexeme = '&&'
              OR lv_lexeme = 'ADD' OR lv_lexeme = 'SUBTRACT' OR lv_lexeme = 'MULTIPLY'
              OR lv_lexeme = 'DIVIDE' OR lv_lexeme = 'CONCATENATE'
              OR lv_lexeme CP '|*|' OR lv_lexeme CP '*&&*'
              OR lv_lexeme = 'BIT-AND' OR lv_lexeme = 'BIT-OR' OR lv_lexeme = 'BIT-XOR'.
            lv_has_accum = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF lv_has_accum = abap_true.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-prefer_reduce ).
        ENDIF.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
