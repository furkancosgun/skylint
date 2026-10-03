CLASS zcl_skylint_check_037 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        try_without_catch TYPE zif_skylint_types=>ty_finding_code VALUE 'TRYWITHOUTC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TRY_WITHOUT_CATCH'.

    TYPES:
      BEGIN OF ty_try_block,
        statement TYPE zif_skylint_types=>ty_statement,
        has_catch TYPE abap_bool,
      END OF ty_try_block,
      ty_try_blocks TYPE STANDARD TABLE OF ty_try_block WITH EMPTY KEY.

ENDCLASS.


CLASS zcl_skylint_check_037 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect TRY without CATCH'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-try_without_catch
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'TRY block without CATCH is superfluous'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lt_try_stack   TYPE ty_try_blocks.
    DATA ls_try         TYPE ty_try_block.
    DATA lv_stack_lines TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_top_try>   TYPE ty_try_block.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TRY'.
          ls_try-statement = <ls_statement>.
          ls_try-has_catch = abap_false.
          INSERT ls_try INTO lt_try_stack INDEX 1.

        WHEN 'CATCH'.
          IF lines( lt_try_stack ) > 0.
            ASSIGN lt_try_stack[ 1 ] TO <ls_top_try>.
            IF sy-subrc = 0.
              <ls_top_try>-has_catch = abap_true.
            ENDIF.
          ENDIF.

        WHEN 'ENDTRY'.
          lv_stack_lines = lines( lt_try_stack ).
          IF lv_stack_lines > 0.
            READ TABLE lt_try_stack INDEX 1 INTO ls_try.
            IF sy-subrc = 0.
              IF ls_try-has_catch = abap_false.
                report_statement( is_statement    = ls_try-statement
                                  iv_finding_code = c_finding_codes-try_without_catch ).
              ENDIF.
              DELETE lt_try_stack INDEX 1.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
