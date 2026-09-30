CLASS zcl_skylint_check_025 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_operator TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFEROP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_OPERATORS'.

    METHODS is_legacy_operator
      IMPORTING iv_lexeme    TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS is_declaration_keyword
      IMPORTING iv_keyword   TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_025 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_operator
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer modern comparison operators (=, <>, <, >, <=, >=) over legacy keywords'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.

    "TODO COMPILER SEVIYESINDE cozebiliriz gibi duruyor kontrol edelim
    "ABAPLINT kontrol edelim nasıl yapmış
    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_declaration_keyword( <ls_statement>-keyword ) = abap_true.
        CONTINUE.
      ENDIF.

      LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
        IF is_legacy_operator( <ls_token>-lexeme ) = abap_true.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-prefer_operator ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_legacy_operator.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_lexeme ).
    CASE lv_upper.
      WHEN 'EQ' OR 'NE' OR 'GT' OR 'LT' OR 'GE' OR 'LE'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_declaration_keyword.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_keyword ).
    CASE lv_upper.
      WHEN 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS'
        OR 'PARAMETERS' OR 'FIELD-SYMBOLS' OR 'METHODS' OR 'CLASS-METHODS'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
