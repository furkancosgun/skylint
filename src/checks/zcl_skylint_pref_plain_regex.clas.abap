CLASS zcl_skylint_pref_plain_regex DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        plain_regex TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PREGX',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_PLAIN_REGEX'.

    METHODS inspect_statement
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS pattern_has_meta
      IMPORTING iv_pattern    TYPE string
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_plain_regex IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer Simpler String Functions to Regex'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-plain_regex
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Regex pattern contains no metacharacters - use the simple sub / case parameter instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      " FIND/REPLACE REGEX statements are the domain of no-obs-strings
      IF <ls_statement>-keyword = 'FIND' OR <ls_statement>-keyword = 'REPLACE'.
        CONTINUE.
      ENDIF.

      inspect_statement( <ls_statement> ).
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_statement.
    DATA lv_index     TYPE i.
    DATA lv_eq_index  TYPE i.
    DATA ls_value     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_pattern   TYPE string.
    DATA lv_length    TYPE i.
    DATA lv_inner     TYPE i.

    lv_index = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'REGEX' ).
    IF lv_index = 0.
      RETURN.
    ENDIF.

    lv_eq_index = zcl_skylint_ast_util=>find_token( is_statement    = is_statement
                                                    iv_lexeme       = '='
                                                    iv_start_index  = lv_index + 1 ).
    IF lv_eq_index <> lv_index + 1.
      RETURN.
    ENDIF.

    ls_value = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_index + 2 ).
    IF zcl_skylint_ast_util=>token_is_literal( ls_value ) = abap_false.
      RETURN.
    ENDIF.
    " String templates can embed arbitrary expressions - not examined
    IF ls_value-lexeme(1) = '|'.
      RETURN.
    ENDIF.

    lv_length = strlen( ls_value-lexeme ).
    IF lv_length <= 2.
      RETURN.
    ENDIF.

    lv_inner = lv_length - 2.
    lv_pattern = substring( val = ls_value-lexeme
                            off = 1
                            len = lv_inner ).

    IF pattern_has_meta( lv_pattern ) = abap_true.
      RETURN.
    ENDIF.

    report_statement( is_statement    = is_statement
                      iv_finding_code = c_finding_codes-plain_regex ).
  ENDMETHOD.

  METHOD pattern_has_meta.
    DATA lv_meta_chars TYPE string VALUE `.[{()*+?^$|\`.
    DATA lv_length     TYPE i.
    DATA lv_offset     TYPE i.
    DATA lv_char       TYPE c LENGTH 1.

    rv_has = abap_false.
    lv_length = strlen( lv_meta_chars ).
    WHILE lv_offset < lv_length.
      lv_char = lv_meta_chars+lv_offset(1).
      IF contains( val = iv_pattern
                   sub = lv_char ).
        rv_has = abap_true.
        RETURN.
      ENDIF.
      lv_offset += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
