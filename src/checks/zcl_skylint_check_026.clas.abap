CLASS zcl_skylint_check_026 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        static_call_via_instance TYPE if_ci_atc_check=>ty_finding_code VALUE 'STATICVIAINST',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'STATIC_CALL'.

    DATA mt_static_methods TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    METHODS collect_static_methods
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS inspect_procedure
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure.

    METHODS is_static_call
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_reference_to_static_method
      IMPORTING is_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS parse_full_name
      IMPORTING iv_full_name  TYPE string
      EXPORTING ev_class_name TYPE string
                ev_meth_name  TYPE string.

ENDCLASS.


CLASS zcl_skylint_check_026 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid calling static methods via instance arrow (->)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-static_call_via_instance
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Call static method using => instead of ->'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      collect_static_methods( is_procedure ).
    ELSE.
      inspect_procedure( is_procedure ).
    ENDIF.
  ENDMETHOD.

  METHOD collect_static_methods.
    DATA ls_stmt      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name      TYPE string.
    DATA lv_class     TYPE string.
    DATA lv_found     TYPE abap_bool.
    DATA lo_descr     TYPE REF TO cl_abap_typedescr.
    DATA lo_class     TYPE REF TO cl_abap_classdescr.
    FIELD-SYMBOLS <ls_meth> TYPE abap_methdescr.

    lv_class = is_procedure-id-main_unit-name.
    IF lv_class IS INITIAL.
      lv_class = is_procedure-id-name.
    ENDIF.

    IF lv_class IS NOT INITIAL.
      cl_abap_typedescr=>describe_by_name(
        EXPORTING
          p_name         = lv_class
        RECEIVING
          type           = lo_descr
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2 ).
      IF sy-subrc = 0 AND lo_descr IS BOUND AND lo_descr->kind = cl_abap_typedescr=>kind_class.
        lo_class ?= lo_descr.
        LOOP AT lo_class->methods ASSIGNING <ls_meth> WHERE is_class = abap_true.
          lv_name = <ls_meth>-name.
          INSERT lv_name INTO TABLE mt_static_methods.
        ENDLOOP.
      ENDIF.
    ENDIF.

    LOOP AT is_procedure-statements INTO ls_stmt WHERE keyword = 'CLASS-METHODS'.
      IF lines( ls_stmt-tokens ) >= 2.
        get_token_safe( EXPORTING is_statement = ls_stmt
                                  iv_index     = 2
                        IMPORTING es_token     = ls_tok
                                  ev_found     = lv_found ).
        IF lv_found = abap_true.
          lv_name = to_upper( ls_tok-lexeme ).
          IF lv_name IS NOT INITIAL.
            INSERT lv_name INTO TABLE mt_static_methods.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_procedure.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements INTO ls_stmt.
      LOOP AT ls_stmt-tokens INTO ls_tok.
        IF is_static_call( ls_tok ) = abap_true.
          report_statement( is_statement    = ls_stmt
                            iv_finding_code = c_finding_codes-static_call_via_instance ).
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_static_call.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    rv_res = abap_false.

    IF is_token-lexeme NS '->'.
      RETURN.
    ENDIF.

    LOOP AT is_token-references INTO ls_ref
         WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
      IF is_reference_to_static_method( ls_ref ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_reference_to_static_method.
    DATA lv_class TYPE string.
    DATA lv_meth  TYPE string.
    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lo_class TYPE REF TO cl_abap_classdescr.
    FIELD-SYMBOLS <ls_meth> TYPE abap_methdescr.

    rv_res = abap_false.
    parse_full_name( EXPORTING iv_full_name  = is_ref-full_name
                     IMPORTING ev_class_name = lv_class
                               ev_meth_name  = lv_meth ).

    IF lv_meth IS INITIAL.
      lv_meth = to_upper( is_ref-full_name ).
    ENDIF.

    IF line_exists( mt_static_methods[ table_line = lv_meth ] ).
      rv_res = abap_true.
      RETURN.
    ENDIF.

    IF lv_class IS NOT INITIAL.
      TRY.
          lo_descr = cl_abap_typedescr=>describe_by_name( lv_class ).
          IF lo_descr->kind = cl_abap_typedescr=>kind_class.
            lo_class ?= lo_descr.
            ASSIGN lo_class->methods[ name = lv_meth ] TO <ls_meth>.
            IF sy-subrc = 0 AND <ls_meth>-is_class = abap_true.
              rv_res = abap_true.
            ENDIF.
          ENDIF.
        CATCH cx_root.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD parse_full_name.
    DATA lv_str   TYPE string.
    DATA lt_parts TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLEAR: ev_class_name,
           ev_meth_name.
    lv_str = to_upper( iv_full_name ).

    IF lv_str CS '->'.
      SPLIT lv_str AT '->' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str CS '=>'.
      SPLIT lv_str AT '=>' INTO ev_class_name ev_meth_name.
      IF ev_meth_name CS '('.
        SPLIT ev_meth_name AT '(' INTO ev_meth_name lv_str.
      ENDIF.
      RETURN.
    ENDIF.

    IF lv_str CS '\'.
      SPLIT lv_str AT '\' INTO TABLE lt_parts.
      LOOP AT lt_parts INTO lv_str.
        IF lv_str CP 'CLASS=*'.
          ev_class_name = lv_str+6.
        ELSEIF lv_str CP 'TY:*'.
          ev_class_name = lv_str+3.
        ELSEIF lv_str CP 'METHOD=*'.
          ev_meth_name = lv_str+7.
        ELSEIF lv_str CP 'ME:*'.
          ev_meth_name = lv_str+3.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
