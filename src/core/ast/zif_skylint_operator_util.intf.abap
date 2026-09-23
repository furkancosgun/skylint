INTERFACE zif_skylint_operator_util PUBLIC.


  METHODS is_comparison_operator
    IMPORTING iv_token      TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_yes) TYPE abap_bool.


  METHODS is_logical_connective
    IMPORTING iv_token       TYPE if_ci_atc_source_code_provider=>ty_token
    RETURNING VALUE(rv_type) TYPE zif_skylint_types=>ty_connective.


  METHODS negate_operator
    IMPORTING iv_operator       TYPE string
    RETURNING VALUE(rv_negated) TYPE string
    RAISING   zcx_skylint_error.

ENDINTERFACE.
