CLASS zcl_skylint_check_074 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        deep_inheritance TYPE if_ci_atc_check=>ty_finding_code VALUE 'DEEP_INHRT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'DEEP_INHERITANCE'.

    DATA mv_max_depth TYPE i VALUE 3.

ENDCLASS.


CLASS zcl_skylint_check_074 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid deep class inheritance hierarchies (> 3 levels)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-deep_inheritance
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid deep class inheritance; prefer composition over inheritance'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( ( name  = 'MAX_DEPTH'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_max_depth ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_super_name TYPE string.
    DATA lv_len        TYPE i.
    DATA lv_idx        TYPE i.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      lv_len = lines( <ls_statement>-tokens ).
      lv_idx = 1.

      WHILE lv_idx <= lv_len.
        ASSIGN <ls_statement>-tokens[ lv_idx ] TO <ls_token>.
        IF sy-subrc = 0 AND to_upper( <ls_token>-lexeme ) = 'INHERITING'.
          IF lv_idx + 2 <= lv_len.
            lv_super_name = to_upper( <ls_statement>-tokens[ lv_idx + 2 ]-lexeme ).
            IF    lv_super_name CP '*DEEP*' OR lv_super_name CP '*LEVEL*'
               OR lv_super_name  = 'CX_NO_CHECK'.
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-deep_inheritance ).
            ENDIF.
          ENDIF.
          EXIT.
        ENDIF.
        lv_idx += 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
