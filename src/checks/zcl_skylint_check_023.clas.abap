CLASS zcl_skylint_check_023 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_exception_new TYPE zif_skylint_types=>ty_finding_code VALUE 'RAISEEXCNEW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RAISE_EXC_NEW'.

    METHODS is_raise_exception_type
      IMPORTING is_statement  TYPE zif_skylint_types=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_023 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-raise_exception_new
                       severity       = zif_skylint_types=>severities-warning
                       text           = 'Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      IF is_raise_exception_type( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_exception_new ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_exception_type.
    rv_res = xsdbool( zcl_skylint_ast_util=>find_token_sequence(
                          is_statement = is_statement
                          it_expected  = VALUE #( ( `RAISE` ) ( `EXCEPTION` ) ( `TYPE` ) ) ) > 0 ).
  ENDMETHOD.
ENDCLASS.
