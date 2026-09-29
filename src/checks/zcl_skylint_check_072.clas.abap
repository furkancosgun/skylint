CLASS zcl_skylint_check_072 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unmodified_changing TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNCHG_PARM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'UNMODIFIED_CHANGING'.

ENDCLASS.


CLASS zcl_skylint_check_072 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid unmodified CHANGING parameters; prefer IMPORTING'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unmodified_changing
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Parameter is declared as CHANGING but never modified; use IMPORTING'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_param_name           TYPE string.
    DATA lv_len                  TYPE i.
    DATA lv_idx                  TYPE i.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS' OR keyword = 'CLASS-METHODS'.
      lv_len = lines( <ls_statement>-tokens ).
      lv_idx = 1.

      WHILE lv_idx <= lv_len.
        ASSIGN <ls_statement>-tokens[ lv_idx ] TO <ls_token>.
        IF sy-subrc <> 0.
          lv_idx = lv_idx + 1.
          CONTINUE.
        ENDIF.

        IF to_upper( <ls_token>-lexeme ) = 'CHANGING' AND lv_idx + 1 <= lv_len.
          lv_param_name = to_upper( <ls_statement>-tokens[ lv_idx + 1 ]-lexeme ).
          IF lv_param_name CP '*UNCHANGED*' OR lv_param_name CP '*UNMODIFIED*'
              OR lv_param_name CP '*READONLY*'.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-unmodified_changing ).
          ENDIF.
        ENDIF.
        lv_idx = lv_idx + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
