CLASS zcl_skylint_check_070 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        generic_field_symbols TYPE if_ci_atc_check=>ty_finding_code VALUE 'GEN_FS_TYP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'GENERIC_FS'.

ENDCLASS.


CLASS zcl_skylint_check_070 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid generic FIELD-SYMBOLS declarations (ANY/DATA/CLIKE/TABLE)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-generic_field_symbols
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid generic built-in types for FIELD-SYMBOLS; specify concrete type'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_tok      TYPE string.
    DATA lv_type_idx TYPE i.
    DATA lv_len      TYPE i.
    DATA lv_has_of   TYPE abap_bool.
    DATA lv_i        TYPE i.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'FIELD-SYMBOLS'.
      lv_len = lines( <ls_statement>-tokens ).
      lv_type_idx = 0.

      " Find token position of TYPE
      lv_i = 1.
      WHILE lv_i <= lv_len.
        IF to_upper( <ls_statement>-tokens[ lv_i ]-lexeme ) = 'TYPE'.
          lv_type_idx = lv_i + 1.
          EXIT.
        ENDIF.
        lv_i += 1.
      ENDWHILE.

      IF lv_type_idx <= 0 OR lv_type_idx > lv_len.
        CONTINUE.
      ENDIF.

      lv_tok = to_upper( <ls_statement>-tokens[ lv_type_idx ]-lexeme ).

      " Generic scalars
      IF    lv_tok = 'ANY'       OR lv_tok = 'DATA'      OR lv_tok = 'CLIKE'
         OR lv_tok = 'CSEQUENCE' OR lv_tok = 'XSEQUENCE'
         OR lv_tok = 'NUMERIC'   OR lv_tok = 'SIMPLE'    OR lv_tok = 'DECFLOAT'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-generic_field_symbols ).
        CONTINUE.
      ENDIF.

      " Generic tables (ANY TABLE, INDEX TABLE, or STANDARD TABLE without OF)
      IF lv_tok = 'TABLE' OR lv_tok = 'INDEX'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-generic_field_symbols ).
        CONTINUE.
      ENDIF.

      IF lv_tok = 'STANDARD' OR lv_tok = 'SORTED' OR lv_tok = 'HASHED'.
        " Check if OF is missing
        lv_has_of = abap_false.
        lv_i = lv_type_idx + 1.
        WHILE lv_i <= lv_len.
          IF to_upper( <ls_statement>-tokens[ lv_i ]-lexeme ) = 'OF'.
            lv_has_of = abap_true.
            EXIT.
          ENDIF.
          lv_i += 1.
        ENDWHILE.

        IF lv_has_of = abap_false.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-generic_field_symbols ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
