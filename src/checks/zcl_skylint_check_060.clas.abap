CLASS zcl_skylint_check_060 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        magic_number TYPE if_ci_atc_check=>ty_finding_code VALUE 'MAGIC_NUM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MAGIC_NUMBER'.

ENDCLASS.


CLASS zcl_skylint_check_060 IMPLEMENTATION.
  METHOD constructor.
    "TODO sadece numerik mı? '1' boyle olunca? compiler güvenelim yeniden yazılsın bu sınıf 
    super->constructor( VALUE #( description       = 'Avoid magic numbers in code; use named constants'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-magic_number
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid hardcoded magic numbers; declare a named constant'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_len    TYPE i.
    DATA lv_idx    TYPE i.
    DATA lv_char   TYPE c LENGTH 1.
    DATA lv_is_num TYPE abap_bool.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " Skip declarations (DATA, CONSTANTS, TYPES, STATICS)
      IF    <ls_statement>-keyword = 'DATA'  OR <ls_statement>-keyword = 'CONSTANTS'
         OR <ls_statement>-keyword = 'TYPES' OR <ls_statement>-keyword = 'STATICS'.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        lv_len = strlen( <ls_token>-lexeme ).
        IF lv_len = 0.
          CONTINUE.
        ENDIF.

        " Check if token consists purely of digits
        lv_is_num = abap_true.
        lv_idx = 0.
        WHILE lv_idx < lv_len.
          lv_char = <ls_token>-lexeme+lv_idx(1).
          IF lv_char < '0' OR lv_char > '9'.
            lv_is_num = abap_false.
            EXIT.
          ENDIF.
          lv_idx += 1.
        ENDWHILE.

        " 0 and 1 are commonly allowed in indices/loop initializations
        IF lv_is_num = abap_true AND <ls_token>-lexeme <> '0' AND <ls_token>-lexeme <> '1'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-magic_number ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
