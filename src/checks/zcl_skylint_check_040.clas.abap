CLASS zcl_skylint_check_040 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nesting_depth TYPE zif_skylint_types=>ty_finding_code VALUE 'NESTING_DP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NESTING_DEPTH'.

    DATA mv_max_depth TYPE i VALUE 3.

    METHODS is_block_opener
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_block_closer
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_040 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Nesting Depth Limit (excessive control block nesting)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-nesting_depth
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Control block nesting depth exceeds maximum allowed limit'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                                kind  = zif_skylint_types=>attribute_kinds-elementary
                                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max   TYPE i.
    DATA lv_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'MAX_DEPTH'
                   IMPORTING ev_value = lv_max ).
    IF lv_max <= 0.
      lv_max = mv_max_depth.
    ENDIF.

    lv_depth = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_block_opener( <ls_statement>-keyword ) = abap_true.
        lv_depth += 1.
        IF lv_depth > lv_max.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-nesting_depth ).
        ENDIF.
      ELSEIF is_block_closer( <ls_statement>-keyword ) = abap_true.
        IF lv_depth > 0.
          lv_depth -= 1.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_block_opener.
    CASE iv_keyword.
      WHEN 'IF' OR 'CASE' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'TRY'.
        rv_res = abap_true.
      WHEN OTHERS.
        rv_res = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_block_closer.
    CASE iv_keyword.
      WHEN 'ENDIF' OR 'ENDCASE' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDTRY'.
        rv_res = abap_true.
      WHEN OTHERS.
        rv_res = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
