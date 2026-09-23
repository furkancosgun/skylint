INTERFACE zif_skylint_types PUBLIC.

  CONSTANTS c_max_line_length TYPE i VALUE 255.

  TYPES:
    BEGIN OF ENUM ty_bracket_type STRUCTURE bracket_type,
      none,
      opening,
      closing,
      clopening,
    END OF ENUM ty_bracket_type STRUCTURE bracket_type.

  TYPES:
    BEGIN OF ENUM ty_connective STRUCTURE connective,
      none,
      and,
      or,
      equiv,
      not,
    END OF ENUM ty_connective STRUCTURE connective.

  TYPES:
    BEGIN OF ty_token_match,
      index TYPE i,
      token TYPE if_ci_atc_source_code_provider=>ty_token,
    END OF ty_token_match,
    ty_token_matches TYPE STANDARD TABLE OF ty_token_match WITH EMPTY KEY.

  TYPES ty_statements TYPE STANDARD TABLE OF if_ci_atc_source_code_provider=>ty_statement WITH EMPTY KEY.
  TYPES ty_tokens     TYPE STANDARD TABLE OF if_ci_atc_source_code_provider=>ty_token WITH EMPTY KEY.

ENDINTERFACE.
