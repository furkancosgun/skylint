CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_class TYPE if_ci_atc_check=>ty_finding_code VALUE 'STAT_CLASS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_STATIC_CLS'.

ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid static-only classes; prefer instantiable interface-based design'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-static_class
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid static-only classes; declare instance methods and interfaces'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_has_instance_meth TYPE abap_bool.
    DATA lv_static_meth_cnt   TYPE i.
    DATA ls_first_class_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_found_class       TYPE abap_bool.

    lv_has_instance_meth = abap_false.
    lv_static_meth_cnt = 0.
    lv_found_class = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword = 'CLASS' AND lv_found_class = abap_false.
        ls_first_class_stmt = <ls_statement>.
        lv_found_class = abap_true.
      ELSEIF <ls_statement>-keyword = 'METHODS'.
        IF <ls_statement>-tokens[ 2 ]-lexeme <> 'CONSTRUCTOR'.
          lv_has_instance_meth = abap_true.
        ENDIF.
      ELSEIF <ls_statement>-keyword = 'CLASS-METHODS'.
        lv_static_meth_cnt += 1.
      ENDIF.
    ENDLOOP.

    IF lv_static_meth_cnt > 0 AND lv_has_instance_meth = abap_false AND lv_found_class = abap_true.
      report_statement( is_statement    = ls_first_class_stmt
                        iv_finding_code = c_finding_codes-static_class ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
