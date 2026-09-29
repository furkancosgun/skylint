CLASS zcl_skylint_check_066 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_cond TYPE if_ci_atc_check=>ty_finding_code VALUE 'COND_SWTCH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_COND'.

ENDCLASS.


CLASS zcl_skylint_check_066 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer COND / SWITCH expressions over multi-branch variable assignment'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_cond
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer COND or SWITCH expression over IF/CASE assignment branches'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_idx      TYPE i.
    DATA lv_total    TYPE i.
    DATA ls_next1    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next2    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next3    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next4    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_var_if   TYPE string.
    DATA lv_var_else TYPE string.

    lv_total = lines( is_procedure-statements ).
    lv_idx = 1.
    WHILE lv_idx <= lv_total.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_statement>.
      IF sy-subrc <> 0 OR <ls_statement>-keyword <> 'IF' OR lv_idx + 4 > lv_total.
        lv_idx += 1.
        CONTINUE.
      ENDIF.

      " Check pattern: IF (idx+1: COMPUTE lv_var = ) (idx+2: ELSE) (idx+3: COMPUTE lv_var = ) (idx+4: ENDIF)
      ls_next1 = is_procedure-statements[ lv_idx + 1 ].
      ls_next2 = is_procedure-statements[ lv_idx + 2 ].
      ls_next3 = is_procedure-statements[ lv_idx + 3 ].
      ls_next4 = is_procedure-statements[ lv_idx + 4 ].

      IF     ls_next1-keyword          = 'COMPUTE' AND ls_next2-keyword          = 'ELSE'
         AND ls_next3-keyword          = 'COMPUTE' AND ls_next4-keyword          = 'ENDIF'
         AND lines( ls_next1-tokens ) >= 2         AND lines( ls_next3-tokens ) >= 2.
        lv_var_if   = to_upper( ls_next1-tokens[ 1 ]-lexeme ).
        lv_var_else = to_upper( ls_next3-tokens[ 1 ]-lexeme ).
        IF lv_var_if = lv_var_else.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-prefer_cond ).
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
