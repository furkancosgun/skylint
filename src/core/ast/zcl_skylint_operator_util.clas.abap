CLASS zcl_skylint_operator_util DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_skylint_operator_util.

    CLASS-METHODS class_constructor.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_negation,
        operator TYPE string,
        negated  TYPE string,
      END OF ty_negation.

    CLASS-DATA gt_negations     TYPE HASHED TABLE OF ty_negation WITH UNIQUE KEY operator.
    CLASS-DATA gt_cmp_operators TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

ENDCLASS.


CLASS zcl_skylint_operator_util IMPLEMENTATION.
  METHOD class_constructor.
    gt_negations = VALUE #( ( operator = 'IN'  negated = 'NOT IN' )
                            ( operator = 'IS'  negated = 'NOT IS' )
                            ( operator = '>'   negated = '<=' )
                            ( operator = 'GT'  negated = 'LE' )
                            ( operator = '<'   negated = '>=' )
                            ( operator = 'LT'  negated = 'GE' )
                            ( operator = '='   negated = '<>' )
                            ( operator = 'EQ'  negated = 'NE' )
                            ( operator = '<>'  negated = '=' )
                            ( operator = 'NE'  negated = 'EQ' )
                            ( operator = '<='  negated = '>' )
                            ( operator = 'LE'  negated = 'GT' )
                            ( operator = '>='  negated = '<' )
                            ( operator = 'GE'  negated = 'LT' ) ).

    gt_cmp_operators = VALUE #( ( |IS| )
                                ( |IN| )
                                ( |>| )
                                ( |GT| )
                                ( |<| )
                                ( |LT| )
                                ( |>=| )
                                ( |GE| )
                                ( |<=| )
                                ( |LE| )
                                ( |=| )
                                ( |EQ| )
                                ( |<>| )
                                ( |NE| ) ).
  ENDMETHOD.

  METHOD zif_skylint_operator_util~is_comparison_operator.
    rv_yes = xsdbool( line_exists( gt_cmp_operators[ table_line = to_upper( iv_token-lexeme ) ] ) ).
  ENDMETHOD.

  METHOD zif_skylint_operator_util~is_logical_connective.
    IF iv_token-references IS NOT INITIAL.
      rv_type = zif_skylint_types=>connective-none.
      RETURN.
    ENDIF.
    rv_type = SWITCH #( iv_token-lexeme
                        WHEN 'AND'   THEN zif_skylint_types=>connective-and
                        WHEN 'OR'    THEN zif_skylint_types=>connective-or
                        WHEN 'EQUIV' THEN zif_skylint_types=>connective-equiv
                        WHEN 'NOT'   THEN zif_skylint_types=>connective-not
                        ELSE              zif_skylint_types=>connective-none ).
  ENDMETHOD.

  METHOD zif_skylint_operator_util~negate_operator.
    DATA(lv_upper) = to_upper( iv_operator ).
    ASSIGN gt_negations[ operator = lv_upper ] TO FIELD-SYMBOL(<ls_neg>).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_skylint_error( message = |Not a valid comparison operator: { iv_operator }| ).
    ENDIF.
    rv_negated = <ls_neg>-negated.
  ENDMETHOD.
ENDCLASS.
