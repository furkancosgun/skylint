CLASS zcl_skylint_check_015 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        constants_interface TYPE if_ci_atc_check=>ty_finding_code VALUE 'CONSTINTF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'CONS_INTF'.

    METHODS is_other_keyword
      IMPORTING iv_keyword   TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_015 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid interfaces containing only constants'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-constants_interface
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Interface contains only CONSTANTS; use global classes or domain types'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_constant TYPE abap_bool.
    DATA lv_has_other    TYPE abap_bool.
    DATA lv_is_interface TYPE abap_bool.
    DATA lv_chain_kw     TYPE string.
    FIELD-SYMBOLS <ls_first_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement>  TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_has_constant = abap_false.
    lv_has_other    = abap_false.
    lv_is_interface = abap_false.
    lv_chain_kw     = ''.

    ASSIGN is_procedure-statements[ 1 ] TO <ls_first_stmt>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF <ls_first_stmt>-keyword = 'INTERFACE'.
      lv_is_interface = abap_true.
    ENDIF.

    IF is_procedure-id-main_unit-kind = if_ci_atc_source_code_provider=>compilation_unit_kinds-interface.
      lv_is_interface = abap_true.
    ENDIF.

    IF lv_is_interface = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword IS NOT INITIAL.
        lv_chain_kw = <ls_statement>-keyword.
      ENDIF.

      CASE lv_chain_kw.
        WHEN 'INTERFACE' OR 'ENDINTERFACE'.
          CONTINUE.

        WHEN 'CONSTANTS'.
          lv_has_constant = abap_true.

        WHEN OTHERS.
          IF is_other_keyword( lv_chain_kw ) = abap_true.
            lv_has_other = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF lv_has_constant = abap_true AND lv_has_other = abap_false.
      report_statement( is_statement    = <ls_first_stmt>
                        iv_finding_code = c_finding_codes-constants_interface ).
    ENDIF.
  ENDMETHOD.

  METHOD is_other_keyword.
    DATA lv_upper TYPE string.

    lv_upper = to_upper( iv_keyword ).
    CASE lv_upper.
      WHEN 'METHODS' OR 'CLASS-METHODS' OR 'DATA' OR 'CLASS-DATA'
        OR 'TYPES' OR 'INTERFACES' OR 'ALIASES' OR 'EVENTS' OR 'CLASS-EVENTS'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
