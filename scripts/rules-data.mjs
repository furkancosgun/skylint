// Skylint Rules Catalog Database (133 Rules)
// Domain-driven categorizations, rich SEO metadata, and Clean ABAP enterprise standards.

export const CATEGORIES = {
  "clean-abap": {
    "title": "Clean ABAP & Modern Syntax",
    "description": "Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices."
  },
  "anti-patterns": {
    "title": "Anti-Patterns & Bad Practices",
    "description": "Discouraged language constructs, legacy statements, and redundant syntax."
  },
  "performance": {
    "title": "Performance & Database",
    "description": "Database query efficiency, buffer protection, and internal table operation guidelines."
  },
  "security": {
    "title": "Security & Robustness",
    "description": "Authorizations, dynamic execution sanitation, error handling, and runtime safety."
  },
  "metrics": {
    "title": "Metrics & Complexity Limits",
    "description": "Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity."
  }
};

export const RULES = [
  {
    "ruleId": "pref-downport",
    "title": "Check Downport Compatibility (7.40+ Modern Constructs)",
    "rationale": "Modern ABAP constructs such as constructor expressions, table expressions, inline declarations, string templates, and functional method chaining do not compile on legacy NetWeaver releases. When a project must remain downport-compatible, these constructs silently raise the required kernel and syntax level. The check keeps that incompatibility visible by reporting each modern construct; it is disabled by default so modern development is unaffected.",
    "className": "ZCL_SKYLINT_PREF_DOWNPORT",
    "pseudoComment": "PREF_DOWNPORT",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_name) = lt_customers[ 1 ]-name.",
      "good": "DATA lv_name TYPE string.\nDATA ls_customer TYPE ty_customer.\nREAD TABLE lt_customers INTO ls_customer INDEX 1.\nIF sy-subrc = 0.\n  lv_name = ls_customer-name.\nENDIF."
    },
    "parameters": {
      "CHECK_CONSTRUCTORS": "Check constructor expressions (NEW, VALUE, CORRESPONDING, COND, SWITCH)",
      "CHECK_TABLE_EXPR": "Check table expressions (lt_tab[ ... ]) incompatible with legacy releases",
      "CHECK_INLINE_DECL": "Check inline declarations (DATA(...), FIELD-SYMBOL(...))",
      "CHECK_STRING_TEMPL": "Check string templates (|...|)",
      "CHECK_CHAINING": "Check functional method call chaining (lo->m1( )->m2( ))",
      "CHECK_EMPTY_KEY": "Check WITH EMPTY KEY additions on internal tables",
      "CHECK_CALC_ASSIGN": "Check calculation assignment operators (+=, -=, *=, /=)",
      "CHECK_LINE_FUNCS": "Check built-in line functions (line_exists, line_index, lines)",
      "CHECK_STRICT_SQL": "Check modern OpenSQL syntax (@ escaping and comma-separated projection)",
      "CHECK_RAISE_MESSAGE": "Check modern RAISE EXCEPTION MESSAGE syntax"
    },
    "seo": {
      "description": "Check Downport Compatibility (7.40+ Modern Constructs) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-downport",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-reduce",
    "title": "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP",
    "rationale": "A loop that only accumulates a sum or builds a single aggregated value mixes imperative control flow with a simple calculation and hides the real intent. Such loops are longer to read and easy to break when the accumulator initialization or the loop body changes. REDUCE #( ) expresses the aggregation declaratively inside one expression and removes the mutable helper state. Use REDUCE for straightforward sums, counts, and string concatenation, and keep a loop only when it performs additional side effects.",
    "className": "ZCL_SKYLINT_PREF_REDUCE",
    "pseudoComment": "PREF_REDUCE",
    "category": "clean-abap",
    "example": {
      "bad": "LOOP AT lt_orders INTO ls_order.\n  lv_total = lv_total + ls_order-amount.\nENDLOOP.",
      "good": "lv_total = REDUCE i( INIT total = 0\n  FOR ls_order IN lt_orders\n  NEXT total = total + ls_order-amount )."
    },
    "seo": {
      "description": "Prefer REDUCE #( ) Expression over Simple Aggregation LOOP - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-reduce",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-read-table",
    "title": "Modernize READ TABLE (Table Expressions & line_exists)",
    "rationale": "Legacy READ TABLE requires procedural work areas, field symbols, and error-prone sy-subrc checks. Modern ABAP provides table expressions (itab[ ... ]) for direct value and reference retrieval, and line_exists( ... ) for existence checks. Modernizing READ TABLE simplifies code, avoids mutable intermediary variables, and embeds seamlessly into functional expressions.",
    "className": "ZCL_SKYLINT_PREF_READ_TABLE",
    "pseudoComment": "PREF_TAB_EXPR",
    "category": "clean-abap",
    "example": {
      "bad": "READ TABLE lt_orders INTO ls_order WITH KEY order_id = lv_id.\nREAD TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer_id = lv_id.\nIF sy-subrc = 0.\n  process( ).\nENDIF.",
      "good": "ls_order = VALUE #( lt_orders[ order_id = lv_id ] OPTIONAL ).\nIF line_exists( lt_customers[ customer_id = lv_id ] ).\n  process( ).\nENDIF."
    },
    "parameters": {
      "USE_OPTIONAL": "Suggest OPTIONAL addition in table expressions to prevent CX_SY_ITAB_LINE_NOT_FOUND dumps",
      "CHECK_TAB_EXPR": "Suggest table expressions (lt_tab[ ... ]) instead of READ TABLE INTO",
      "CHECK_LINE_EXISTS": "Suggest line_exists( ) instead of READ TABLE TRANSPORTING NO FIELDS"
    },
    "seo": {
      "description": "Modernize READ TABLE (Table Expressions & line_exists) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-read-table",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-cond",
    "title": "Prefer COND #( ) Expression over IF/ELSEIF/ELSE",
    "rationale": "An IF/ELSEIF chain that only assigns different values to the same variable duplicates the assignment target and spreads one decision over many lines. COND #( ) turns the whole mapping into a single expression, so the target is assigned exactly once and cannot be left uninitialized. It also composes with assignments and method calls. Keep IF when branches perform multiple statements or side effects.",
    "className": "ZCL_SKYLINT_PREF_COND",
    "pseudoComment": "PREF_COND",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_score >= 90.\n  lv_grade = 'A'.\nELSEIF lv_score >= 80.\n  lv_grade = 'B'.\nELSE.\n  lv_grade = 'C'.\nENDIF.",
      "good": "lv_grade = COND string(\n  WHEN lv_score >= 90 THEN 'A'\n  WHEN lv_score >= 80 THEN 'B'\n  ELSE 'C' )."
    },
    "parameters": {
      "REQUIRE_ELSE": "Require explicit ELSE branch in COND #( ... ) to guarantee total coverage"
    },
    "seo": {
      "description": "Prefer COND #( ) Expression over IF/ELSEIF/ELSE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-cond",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-switch",
    "title": "Prefer SWITCH #( ) Expression over CASE Statement",
    "rationale": "A CASE statement whose branches only assign a result is a verbose value mapping: it repeats the assignment variable in every branch. SWITCH #( ) makes the input value and all possible results visible in one expression and avoids temporary state. Use SWITCH for pure mappings and CASE when a branch contains several statements or side effects.",
    "className": "ZCL_SKYLINT_PREF_SWITCH",
    "pseudoComment": "PREF_SWITCH",
    "category": "clean-abap",
    "example": {
      "bad": "CASE lv_status.\n  WHEN 'O'.\n    lv_text = 'Open'.\n  WHEN 'C'.\n    lv_text = 'Closed'.\n  WHEN OTHERS.\n    lv_text = 'Unknown'.\nENDCASE.",
      "good": "lv_text = SWITCH string( lv_status\n  WHEN 'O' THEN 'Open'\n  WHEN 'C' THEN 'Closed'\n  ELSE 'Unknown' )."
    },
    "parameters": {
      "REQUIRE_OTHERS": "Require explicit WHEN OTHERS branch in SWITCH #( ... ) to handle missing states"
    },
    "seo": {
      "description": "Prefer SWITCH #( ) Expression over CASE Statement - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-switch",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-lines",
    "title": "Prefer lines( ) over DESCRIBE TABLE",
    "rationale": "DESCRIBE TABLE LINES requires an extra variable and separates the question about table size from the code that uses the answer. The lines( ) built-in returns the row count as a value and can be embedded directly in conditions and expressions. This reduces temporary variables and makes the intent obvious at the call site.",
    "className": "ZCL_SKYLINT_PREF_LINES",
    "pseudoComment": "PREF_LINES",
    "category": "clean-abap",
    "example": {
      "bad": "DESCRIBE TABLE lt_items LINES lv_count.\nIF lv_count = 0.\n  RETURN.\nENDIF.",
      "good": "IF lines( lt_items ) = 0.\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Prefer lines( ) over DESCRIBE TABLE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-lines",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-call-method",
    "title": "Avoid Obsolete CALL METHOD",
    "rationale": "CALL METHOD is the procedural call syntax from early ABAP Objects and needs explicit EXPORTING and RECEIVING sections. Functional syntax is shorter, can be used inside expressions, and removes visual clutter around parameter lists. Use ref->method( ) or class=>method( ) for all method calls.",
    "className": "ZCL_SKYLINT_NO_CALL_METHOD",
    "pseudoComment": "NO_CALL_METHOD",
    "category": "anti-patterns",
    "example": {
      "bad": "CALL METHOD lo_service->calculate_tax\n  EXPORTING\n    iv_amount = lv_amount\n  RECEIVING\n    rv_tax    = lv_tax.",
      "good": "lv_tax = lo_service->calculate_tax( lv_amount )."
    },
    "seo": {
      "description": "Avoid Obsolete CALL METHOD - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-call-method",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-default-key",
    "title": "Avoid WITH DEFAULT KEY",
    "rationale": "WITH DEFAULT KEY makes every non-numeric field part of the implicit table key, so which rows count as duplicates depends on the structure definition. Adding a field later silently changes the key and can introduce unexpected duplicates or sort behavior. Use WITH EMPTY KEY for standard tables that are accessed by index, or declare an explicit key for sorted and hashed tables.",
    "className": "ZCL_SKYLINT_NO_DEFAULT_KEY",
    "pseudoComment": "NO_DEFAULT_KEY",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lt_open_orders TYPE STANDARD TABLE OF ty_open_order WITH DEFAULT KEY.",
      "good": "DATA lt_open_orders TYPE STANDARD TABLE OF ty_open_order WITH EMPTY KEY."
    },
    "seo": {
      "description": "Avoid WITH DEFAULT KEY - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-default-key",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-is-not",
    "title": "Prefer IS NOT over NOT ... IS",
    "rationale": "Writing NOT before a complete IS expression forces the reader to negate the condition mentally and can be misread in compound logic. IS NOT keeps the subject first and reads in natural order, as in lo_instance IS NOT BOUND. Prefer IS NOT for predicates such as IS BOUND, IS INITIAL, and IS ASSIGNED.",
    "className": "ZCL_SKYLINT_PREF_IS_NOT",
    "pseudoComment": "PREF_IS_NOT",
    "category": "clean-abap",
    "example": {
      "bad": "IF NOT lt_items IS INITIAL.\n  process_items( lt_items ).\nENDIF.",
      "good": "IF lt_items IS NOT INITIAL.\n  process_items( lt_items ).\nENDIF."
    },
    "seo": {
      "description": "Prefer IS NOT over NOT ... IS - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-is-not",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-me-reference",
    "title": "Avoid Redundant ME-> Self Reference",
    "rationale": "Member variables and methods are already accessible inside an instance method, so prefixing every access with me-> only adds noise. Removing the prefix keeps attention on the member itself and makes genuine shadowing easier to spot. Keep me-> only where a parameter or local variable shadows the member, typically in constructors and setters.",
    "className": "ZCL_SKYLINT_NO_ME_REFERENCE",
    "pseudoComment": "NO_ME_REFERENCE",
    "category": "anti-patterns",
    "example": {
      "bad": "me->mv_order_count = me->mv_order_count + 1.\nme->save( ).",
      "good": "mv_order_count = mv_order_count + 1.\nsave( )."
    },
    "parameters": {
      "ALLOW_IN_CONSTRUCTORS": "Allow me-> in CONSTRUCTOR methods when assigning parameters with identical names to attributes"
    },
    "seo": {
      "description": "Avoid Redundant ME-> Self Reference - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-me-reference",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-call-receiving",
    "title": "Omit RECEIVING in Method Invocations",
    "rationale": "The RECEIVING clause in a method call is legacy syntax that forces a functional call into a statement format. In modern ABAP, capture the return value directly on the left-hand side of an assignment (e.g. result = obj->meth( )) to enable clean nesting and expression-oriented programming.",
    "className": "ZCL_SKYLINT_NO_CALL_RECEIVING",
    "pseudoComment": "NO_CALL_RECEIVING",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_order->calculate_total( RECEIVING rv_total = lv_total ).",
      "good": "lv_total = lo_order->calculate_total( )."
    },
    "seo": {
      "description": "Omit RECEIVING in Method Invocations - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-call-receiving",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-call-exporting",
    "title": "Omit Redundant EXPORTING in Method Calls",
    "rationale": "In functional ABAP method calls, the EXPORTING keyword is redundant when no other clauses (such as IMPORTING, CHANGING, or EXCEPTIONS) are present. Removing EXPORTING reduces syntax noise and simplifies signature reading.",
    "className": "ZCL_SKYLINT_NO_CALL_EXPORTING",
    "pseudoComment": "NO_CALL_EXPORTING",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_pricing->apply_discount( EXPORTING iv_percent = 10 ).",
      "good": "lo_pricing->apply_discount( iv_percent = 10 )."
    },
    "seo": {
      "description": "Omit Redundant EXPORTING in Method Calls - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-call-exporting",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-param-name",
    "title": "Method Call Parameter Naming Style (Omit or Require)",
    "rationale": "Methods with a single importing parameter can be invoked positionally without naming the parameter, reducing verbosity for self-explanatory methods. Alternatively, teams requiring explicit naming can enable REQUIRE_PARAM_NAME to enforce explicit parameter naming for clarity and future signature extension.",
    "className": "ZCL_SKYLINT_PREF_PARAM_NAME",
    "pseudoComment": "PREF_PARAM_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "lo_pricing->apply_discount( iv_percent = 10 ).",
      "good": "lo_pricing->apply_discount( 10 )."
    },
    "parameters": {
      "CHECK_PARAM_NAME": "Suggest omitting parameter name when invoking single-parameter methods",
      "REQUIRE_PARAM_NAME": "Require explicit parameter names when calling multi-parameter methods"
    },
    "seo": {
      "description": "Method Call Parameter Naming Style (Omit or Require) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-param-name",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-chained-decl",
    "title": "Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)",
    "rationale": "Chained declarations combine multiple definitions behind a colon and commas, obscuring types and causing noisy version control diffs for single-variable modifications. In modern Clean ABAP, each variable, constant, or type definition should be an independent, fully qualified statement for maximum readability and clean diff tracking.",
    "className": "ZCL_SKYLINT_NO_CHAINED_DECL",
    "pseudoComment": "NO_CHAINED_DECL",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA: lv_order_id TYPE string,\n      lv_status   TYPE string.",
      "good": "DATA lv_order_id TYPE string.\nDATA lv_status TYPE string."
    },
    "parameters": {
      "ALLOW_STRUCTURE_CHAINS": "Allow chained declarations exclusively inside BEGIN OF ... END OF structure definitions"
    },
    "seo": {
      "description": "Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-chained-decl",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-chained-assign",
    "title": "Avoid Chained Assignments (a = b = c = 1)",
    "rationale": "Chained assignments evaluate right-to-left and bind multiple targets in a single statement, making code execution order difficult to follow and debug. Split chained assignments into distinct, explicit assignment statements.",
    "className": "ZCL_SKYLINT_NO_CHAINED_ASSIGN",
    "pseudoComment": "NO_CHAINED_ASSIGN",
    "category": "anti-patterns",
    "example": {
      "bad": "lv_a = lv_b = lv_c = 0.",
      "good": "lv_c = 0.\nlv_b = lv_c.\nlv_a = lv_b."
    },
    "seo": {
      "description": "Avoid Chained Assignments (a = b = c = 1) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-chained-assign",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-str-tmpl",
    "title": "Prefer String Templates over CONCATENATE",
    "rationale": "CONCATENATE with SEPARATED BY is a procedural statement that splits a message into literals and variables and cannot be nested in expressions. String templates interpolate values directly, preserve spaces, and support formatting options for numbers, dates, and alignment. Use a template for readable text composition and reserve CONCATENATE only for legacy downport code.",
    "className": "ZCL_SKYLINT_PREF_STR_TMPL",
    "pseudoComment": "PREF_STR_TMPL",
    "category": "clean-abap",
    "example": {
      "bad": "CONCATENATE 'Order' lv_order_id 'created' INTO lv_message SEPARATED BY space.",
      "good": "lv_message = |Order { lv_order_id } created|."
    },
    "seo": {
      "description": "Prefer String Templates over CONCATENATE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-str-tmpl",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-bool-compare",
    "title": "Avoid Comparing to abap_true / abap_false",
    "rationale": "A boolean expression already evaluates to true or false, so comparing it to abap_true is redundant. The comparison hides predicate intent and can mask a missing method call or an accidental assignment. Test the expression directly and use NOT when the negative case is needed.",
    "className": "ZCL_SKYLINT_NO_BOOL_COMPARE",
    "pseudoComment": "NO_BOOL_COMPARE",
    "category": "anti-patterns",
    "example": {
      "bad": "IF is_valid( ) = abap_false.\n  RETURN.\nENDIF.",
      "good": "IF NOT is_valid( ).\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Avoid Comparing to abap_true / abap_false - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-bool-compare",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-return",
    "title": "Prefer RETURN over EXIT in Methods",
    "rationale": "EXIT has loop-specific meaning and can leave a method at a point that is easy to overlook when the surrounding code changes. RETURN explicitly ends the current procedure and cannot be confused with loop control. Use RETURN for method exit and LEAVE LOOP or CONTINUE for loop control.",
    "className": "ZCL_SKYLINT_PREF_RETURN",
    "pseudoComment": "PREF_RETURN",
    "category": "clean-abap",
    "example": {
      "bad": "IF is_invalid( ).\n  EXIT.\nENDIF.\nprocess( ).",
      "good": "IF is_invalid( ).\n  RETURN.\nENDIF.\nprocess( )."
    },
    "seo": {
      "description": "Prefer RETURN over EXIT in Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-return",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-check-stmt",
    "title": "Avoid CHECK Statements",
    "rationale": "CHECK behaves like CONTINUE inside a loop but like RETURN outside a loop, so moving the statement between contexts silently changes control flow. That dual meaning makes refactoring and reviews hazardous. Replace it with an explicit IF ... CONTINUE or IF ... RETURN that states the intended behavior.",
    "className": "ZCL_SKYLINT_NO_CHECK_STMT",
    "pseudoComment": "NO_CHECK_IN_LOOP",
    "category": "anti-patterns",
    "example": {
      "bad": "LOOP AT lt_orders INTO ls_order.\n  CHECK ls_order-status = 'OPEN'.\n  process_order( ls_order ).\nENDLOOP.",
      "good": "LOOP AT lt_orders INTO ls_order.\n  IF ls_order-status <> 'OPEN'.\n    CONTINUE.\n  ENDIF.\n  process_order( ls_order ).\nENDLOOP."
    },
    "parameters": {
      "CHECK_IN_LOOP": "Detect CHECK inside loops and suggest IF NOT ... CONTINUE guard clause",
      "CHECK_OUTSIDE_LOOP": "Detect CHECK outside loops and suggest IF NOT ... RETURN guard clause"
    },
    "seo": {
      "description": "Avoid CHECK Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-check-stmt",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-empty-block",
    "title": "Avoid Empty Control Blocks",
    "rationale": "An empty branch usually signals unfinished logic, forgotten code, or an inverted condition. Readers must search for hidden behavior and may assume the branch does something. Restructure the condition so every branch has a purpose, or remove the empty block entirely.",
    "className": "ZCL_SKYLINT_NO_EMPTY_BLOCK",
    "pseudoComment": "NO_EMPTY_BLOCK",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_is_active = abap_true.\n  \" no processing yet\nELSE.\n  process( ).\nENDIF.",
      "good": "IF NOT lv_is_active.\n  process( ).\nENDIF."
    },
    "parameters": {
      "CHECK_IF": "Detect empty IF / ELSEIF / ELSE blocks",
      "CHECK_LOOP": "Detect empty LOOP blocks",
      "CHECK_CASE": "Detect empty CASE / WHEN blocks",
      "CHECK_TRY": "Detect empty TRY blocks",
      "CHECK_CATCH": "Detect empty CATCH blocks with no handling or comments",
      "CHECK_TRY_NO_CATCH": "Detect TRY blocks that have no CATCH or CLEANUP clause",
      "CHECK_DO": "Detect empty DO blocks",
      "CHECK_WHILE": "Detect empty WHILE blocks"
    },
    "seo": {
      "description": "Avoid Empty Control Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-empty-block",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-ident-cont",
    "title": "Avoid Identical Statements in IF Branches",
    "rationale": "Statements repeated in every branch of an IF/ELSEIF/ELSE carry no branch-specific meaning and duplicate maintenance. If the same statement starts or ends every branch, extract it before or after the IF so it is written once and stays in sync.",
    "className": "ZCL_SKYLINT_NO_IDENT_CONT",
    "pseudoComment": "NO_IDENT_CONT",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_is_active = abap_true.\n  process( ).\nELSE.\n  process( ).\nENDIF.",
      "good": "IF lv_is_active = abap_true.\n  process_active( ).\nELSE.\n  process_inactive( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Identical Statements in IF Branches - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-ident-cont",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-dup-cond",
    "title": "Avoid Duplicate Branch Conditions",
    "rationale": "A repeated IF/ELSEIF or WHEN condition can never be reached because the earlier branch already handles it. This is usually a copy-paste error and can leave the intended branch permanently dead. Remove the duplicate or correct the condition so every branch has a distinct purpose.",
    "className": "ZCL_SKYLINT_NO_DUP_COND",
    "pseudoComment": "NO_DUP_COND",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_status = 'A'.\n  process_a( ).\nELSEIF lv_status = 'A'.\n  process_b( ).\nENDIF.",
      "good": "IF lv_status = 'A'.\n  process_a( ).\nELSEIF lv_status = 'B'.\n  process_b( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Duplicate Branch Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-dup-cond",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-merge-ifs",
    "title": "Merge Nested IF Statements",
    "rationale": "Nested IF statements without intermediate statements add indentation without adding meaning. Merging them with AND or converting a nested IF in an ELSE block into ELSEIF flattens the control flow and makes the combined condition explicit. Less nesting reduces cyclomatic complexity and makes the happy path easier to test.",
    "className": "ZCL_SKYLINT_PREF_MERGE_IFS",
    "pseudoComment": "PREF_MERGE_IFS",
    "category": "clean-abap",
    "example": {
      "bad": "IF is_active( ).\n  IF is_authorized( ).\n    process_order( ).\n  ENDIF.\nENDIF.",
      "good": "IF is_active( ) AND is_authorized( ).\n  process_order( ).\nENDIF."
    },
    "seo": {
      "description": "Merge Nested IF Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-merge-ifs",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-unreachable",
    "title": "Avoid Dead / Unreachable Code",
    "rationale": "Statements after an unconditional RETURN, RAISE EXCEPTION, or EXIT can never execute and often remain from debugging or an earlier design. They mislead maintainers and inflate apparent method size and coverage. Remove the statements or move them before the terminating statement if they are still needed.",
    "className": "ZCL_SKYLINT_NO_UNREACHABLE",
    "pseudoComment": "NO_UNREACHABLE",
    "category": "anti-patterns",
    "example": {
      "bad": "RETURN.\nlv_count = lv_count + 1.",
      "good": "lv_count = lv_count + 1.\nRETURN."
    },
    "seo": {
      "description": "Avoid Dead / Unreachable Code - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-unreachable",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-single-when",
    "title": "Avoid CASE with a Single WHEN Branch",
    "rationale": "CASE implies that a value is compared against several alternatives, so a single WHEN makes readers look for missing branches. An IF with the same condition is shorter and states the intent directly. Use CASE only when there are multiple distinct branches or when a value mapping is genuinely clearer.",
    "className": "ZCL_SKYLINT_NO_SINGLE_WHEN",
    "pseudoComment": "NO_SINGLE_WHEN",
    "category": "anti-patterns",
    "example": {
      "bad": "CASE lv_order_status.\n  WHEN 'C'.\n    close_order( ).\nENDCASE.",
      "good": "IF lv_order_status = 'C'.\n  close_order( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid CASE with a Single WHEN Branch - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-single-when",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-yoda-cond",
    "title": "Avoid Yoda Conditions",
    "rationale": "Yoda conditions place the literal or constant on the left side of a comparison and break the natural ABAP reading order of subject, operator, and value. The habit comes from languages where an accidental assignment in a condition is possible, which is not the case for ABAP comparisons. Keep the variable or expression on the left so conditions read like plain language.",
    "className": "ZCL_SKYLINT_NO_YODA_COND",
    "pseudoComment": "NO_YODA_COND",
    "category": "anti-patterns",
    "example": {
      "bad": "IF 'ACTIVE' = lv_status.\n  process( ).\nENDIF.",
      "good": "IF lv_status = 'ACTIVE'.\n  process( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Yoda Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-yoda-cond",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-symbol-op",
    "title": "Prefer Symbol Comparison Operators (=, <>, <, >)",
    "rationale": "Text comparison operators such as EQ, NE, GT, LT, GE, and LE are legacy synonyms for the symbolic operators. Symbols are shorter, match mathematical notation, and are the Clean ABAP standard. Consistent symbols also make boolean expressions easier to scan in conditions and constructor expressions.",
    "className": "ZCL_SKYLINT_PREF_SYMBOL_OP",
    "pseudoComment": "PREF_SYMBOL_OP",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_total GT 100 AND lv_status NE 'X'.\n  process( ).\nENDIF.",
      "good": "IF lv_total > 100 AND lv_status <> 'X'.\n  process( ).\nENDIF."
    },
    "seo": {
      "description": "Prefer Symbol Comparison Operators (=, <>, <, >) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-symbol-op",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-new-op",
    "title": "Prefer NEW #( ) over CREATE OBJECT",
    "rationale": "CREATE OBJECT is the procedural object-creation statement and requires a separate declaration and assignment. NEW #( ) infers the class from the target, can be used inside expressions, and keeps construction close to where the reference is needed. Use NEW for object creation in modern ABAP and reserve CREATE OBJECT for legacy downport code.",
    "className": "ZCL_SKYLINT_PREF_NEW_OP",
    "pseudoComment": "PREF_NEW_OPERATOR",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lo_customer TYPE REF TO cl_customer.\nCREATE OBJECT lo_customer EXPORTING iv_name = lv_name.",
      "good": "DATA lo_customer TYPE REF TO cl_customer.\nlo_customer = NEW #( iv_name = lv_name )."
    },
    "parameters": {
      "CHECK_CREATE_OBJECT": "Suggest NEW #( ... ) over CREATE OBJECT",
      "CHECK_RAISE_EXCEPTION": "Suggest RAISE EXCEPTION NEW over CREATE OBJECT followed by RAISE"
    },
    "seo": {
      "description": "Prefer NEW #( ) over CREATE OBJECT - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-new-op",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-xsdbool",
    "title": "Prefer xsdbool( ) for Boolean Assignments",
    "rationale": "An IF/ELSE whose only task is to assign abap_true or abap_false uses many lines for a single boolean conversion. xsdbool( ) expresses the condition directly and assigns the result in one statement. This removes duplicated branches and makes the relationship between condition and flag obvious.",
    "className": "ZCL_SKYLINT_PREF_XSDBOOL",
    "pseudoComment": "PREF_XSDBOOL",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_discount > 0.\n  lv_has_discount = abap_true.\nELSE.\n  lv_has_discount = abap_false.\nENDIF.",
      "good": "lv_has_discount = xsdbool( lv_discount > 0 )."
    },
    "seo": {
      "description": "Prefer xsdbool( ) for Boolean Assignments - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-xsdbool",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-static-arrow",
    "title": "Avoid Calling Static Methods via Instance References (->)",
    "rationale": "Calling a static method through an instance reference uses the instance arrow and suggests polymorphic dispatch that is not happening. It also creates an unnecessary dependency on a live object. Use the class name with => so readers immediately see that the method is static and cannot be overridden.",
    "className": "ZCL_SKYLINT_NO_STATIC_ARROW",
    "pseudoComment": "NO_STATIC_ARROW",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lo_helper TYPE REF TO cl_helper.\nlo_helper->format_date( lv_date ).",
      "good": "cl_helper=>format_date( lv_date )."
    },
    "seo": {
      "description": "Avoid Calling Static Methods via Instance References (->) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-static-arrow",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-exposed-data",
    "title": "Avoid Exposed Mutable Data in Classes and Interfaces",
    "rationale": "Public mutable attributes in classes and DATA declarations in interfaces breach object-oriented encapsulation by allowing external callers to directly mutate internal state without invariant validation. Exposing state leaks implementation details and prevents clean contract evolution. Restrict data to PRIVATE/PROTECTED sections with getters (or READ-ONLY), and keep interfaces strictly stateless with methods and CONSTANTS.",
    "className": "ZCL_SKYLINT_NO_EXPOSED_DATA",
    "pseudoComment": "PUBLIC_ATTR",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS cl_model DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_state TYPE i.\nENDCLASS.\nINTERFACE if_customer.\n  DATA mv_balance TYPE i.\nENDINTERFACE.",
      "good": "CLASS cl_model DEFINITION PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_state TYPE i READ-ONLY.\nENDCLASS.\nINTERFACE if_customer.\n  CONSTANTS c_default_status TYPE i VALUE 1.\n  METHODS get_balance RETURNING VALUE(rv_balance) TYPE i.\nENDINTERFACE."
    },
    "parameters": {
      "CHECK_PUBLIC_ATTR": "Report public data attributes in classes (encapsulation violation)",
      "CHECK_INTF_DATA": "Report data variable declarations inside interfaces (should contain only types, constants, methods)"
    },
    "seo": {
      "description": "Avoid Exposed Mutable Data in Classes and Interfaces - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-exposed-data",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-obs-arith",
    "title": "Avoid Obsolete Arithmetic and Assignment Statements",
    "rationale": "Legacy calculation statements (ADD, SUBTRACT, MULTIPLY, DIVIDE, ADD-CORRESPONDING, and COMPUTE) and verbose assignments (MOVE ... TO, GET REFERENCE OF ... INTO) clutter code and hinder readability. Modern ABAP provides clean functional expressions, compound arithmetic, and standard assignment operators (=, +, -, *, /, REF #()) that are strictly required in Clean ABAP and ABAP Cloud.",
    "className": "ZCL_SKYLINT_NO_OBS_ARITH",
    "pseudoComment": "NO_OBS_ARITH",
    "category": "anti-patterns",
    "example": {
      "bad": "ADD 1 TO lv_count.\nMOVE lv_source TO lv_target.\nGET REFERENCE OF lv_val INTO lr_ref.",
      "good": "lv_count = lv_count + 1.\nlv_target = lv_source.\nlr_ref = REF #( lv_val )."
    },
    "parameters": {
      "CHECK_ADD": "Detect obsolete ADD ... TO and SUBTRACT ... FROM statements",
      "CHECK_ADD_CORR": "Detect obsolete ADD-CORRESPONDING statements",
      "CHECK_COMPUTE": "Detect obsolete COMPUTE keyword",
      "CHECK_MOVE": "Detect obsolete MOVE ... TO statements (prefer =)",
      "CHECK_GET_REF": "Detect obsolete GET REFERENCE OF statement (prefer REF #( ))"
    },
    "seo": {
      "description": "Avoid Obsolete Arithmetic and Assignment Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-obs-arith",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-obs-decl",
    "title": "Avoid Obsolete Declarations and Table Headers",
    "rationale": "Legacy declaration statements like TABLES, RANGES, TYPE-POOLS, and internal tables defined WITH HEADER LINE, OCCURS, or INITIAL SIZE carry significant technical debt and implicit global state. In modern Clean ABAP and ABAP Cloud, use explicit TYPES, DATA statements with modern table types, standard RANGE OF types, and CLEAR instead of REFRESH.",
    "className": "ZCL_SKYLINT_NO_OBS_DECL",
    "pseudoComment": "NO_OBS_DECL",
    "category": "anti-patterns",
    "example": {
      "bad": "TABLES mara.\nRANGES lr_matnr FOR mara-matnr.\nDATA lt_items TYPE STANDARD TABLE OF i WITH HEADER LINE.",
      "good": "DATA lt_items TYPE STANDARD TABLE OF i WITH EMPTY KEY.\nDATA lr_matnr TYPE RANGE OF matnr."
    },
    "parameters": {
      "CHECK_TABLES": "Detect obsolete TABLES declaration statement",
      "CHECK_TYPE_POOLS": "Detect obsolete TYPE-POOLS declaration statement",
      "CHECK_RANGES": "Detect obsolete RANGES declaration statement",
      "CHECK_HEADER_LINE": "Detect internal tables with obsolete header lines (WITH HEADER LINE)",
      "CHECK_OCCURS": "Detect obsolete INITIAL SIZE / OCCURS syntax",
      "CHECK_INITIAL_SIZE": "Detect obsolete INITIAL SIZE additions",
      "CHECK_COMMON_PART": "Detect obsolete DATA COMMON PART statements",
      "CHECK_STATICS": "Detect STATICS declarations inside instance methods",
      "CHECK_FS_STRUCTURE": "Detect FIELD-SYMBOLS with obsolete structure typing",
      "CHECK_LOAD": "Detect obsolete LOAD-OF-PROGRAM statements",
      "CHECK_PARAMETER": "Detect obsolete PARAMETER additions in selection screens",
      "CHECK_REFRESH": "Detect obsolete REFRESH statement (prefer CLEAR)"
    },
    "seo": {
      "description": "Avoid Obsolete Declarations and Table Headers - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-obs-decl",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-obs-control",
    "title": "Avoid Obsolete Control Flow and Procedural Forms",
    "rationale": "Subroutines (FORM / PERFORM), macro definitions (DEFINE), hardcoded break points (BREAK-POINT / BREAK), control break statements (AT NEW, AT END, ON CHANGE OF, SUM), and SET EXTENDED CHECK belong to legacy procedural programming. They lack proper scope isolation, cause unpredictable side effects, and are completely prohibited in modern ABAP Cloud. Encapsulate all logic within methods, modern LOOP GROUP BY syntax, and unit tests.",
    "className": "ZCL_SKYLINT_NO_OBS_CONTROL",
    "pseudoComment": "NO_OBS_CONTROL",
    "category": "anti-patterns",
    "example": {
      "bad": "PERFORM calculate_total USING lv_subtotal.\nAT NEW order_id.\n  SUM.\nENDAT.",
      "good": "calculate_total( iv_subtotal = lv_subtotal ).\nLOOP AT lt_orders INTO DATA(ls_order) GROUP BY ls_order-order_id ..."
    },
    "parameters": {
      "CHECK_FORM": "Detect obsolete PERFORM / FORM subroutine routines",
      "CHECK_LOOP_CTL": "Detect obsolete control break statements (ON CHANGE OF, EXIT FROM STEP-LOOP)",
      "CHECK_BREAK": "Detect unconditioned BREAK-POINT statements in non-test code",
      "CHECK_DEFINE": "Detect DEFINE macro declarations",
      "CHECK_TEST_SEAMS": "Detect TEST-SEAM injection blocks in production logic",
      "CHECK_CATCH_SYSTEM": "Detect obsolete CATCH SYSTEM-EXCEPTIONS syntax",
      "CHECK_SET_EXT_CHECK": "Detect obsolete SET EXTENDED CHECK statements",
      "CHECK_SELECT_NO_INTO": "Detect obsolete SELECT without INTO statements",
      "CHECK_EXIT_SQL": "Detect obsolete EXIT FROM SQL statements",
      "CHECK_SORT_BY_FS": "Detect obsolete dynamic SORT BY field symbol syntax"
    },
    "seo": {
      "description": "Avoid Obsolete Control Flow and Procedural Forms - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-obs-control",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-obs-memory",
    "title": "Avoid Obsolete ABAP Memory and Context Statements",
    "rationale": "ABAP memory and database cluster statements (EXPORT ... TO MEMORY / DATABASE, FREE MEMORY) and Context commands (CONTEXTS, DEMAND, SUPPLY, PROVIDE) rely on hidden shared memory regions that break statelessness, multi-tenancy, and testability. In cloud systems, communicate explicitly via method parameters, database repositories, or session services.",
    "className": "ZCL_SKYLINT_NO_OBS_MEMORY",
    "pseudoComment": "NO_OBS_MEMORY",
    "category": "anti-patterns",
    "example": {
      "bad": "EXPORT user_id = lv_user TO MEMORY ID 'USR_CTX'.\nFREE MEMORY ID 'USR_CTX'.",
      "good": "\" Pass user context explicitly via method arguments or a dedicated context provider service."
    },
    "parameters": {
      "CHECK_EXPORT_MEMORY": "Detect obsolete EXPORT TO MEMORY statements",
      "CHECK_FREE_MEMORY": "Detect obsolete FREE MEMORY statements",
      "CHECK_PROVIDE": "Detect obsolete PROVIDE statements",
      "CHECK_CONTEXTS": "Detect obsolete CONTEXTS statements",
      "CHECK_INFOTYPES": "Detect obsolete INFOTYPES statements",
      "CHECK_COMMUNICATION": "Detect obsolete COMMUNICATION statements",
      "CHECK_CALL_TRANSF": "Detect obsolete CALL TRANSFORMATION XML statements"
    },
    "seo": {
      "description": "Avoid Obsolete ABAP Memory and Context Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-obs-memory",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-obs-strings",
    "title": "Avoid Obsolete String and POSIX Regex Statements",
    "rationale": "Statements such as PACK, UNPACK, REPLACE ... INTO, and FIND/REPLACE with REGEX / OCCURENCES (along with POSIX regular expression classes like CL_ABAP_REGEX=>CREATE_POSIX) are legacy constructs superseded by modern PCRE (Perl-Compatible Regular Expressions via PCRE keywords / XCO regex) and standard string expressions / built-ins.",
    "className": "ZCL_SKYLINT_NO_OBS_STRINGS",
    "pseudoComment": "NO_OBS_STRINGS",
    "category": "anti-patterns",
    "example": {
      "bad": "PACK lv_source TO lv_packed.\nFIND REGEX 'pattern' IN lv_text.",
      "good": "FIND PCRE 'pattern' IN lv_text."
    },
    "parameters": {
      "CHECK_PACK": "Detect obsolete PACK statement (prefer numeric assignment)",
      "CHECK_UNPACK": "Detect obsolete UNPACK statement",
      "CHECK_REGEX": "Detect obsolete POSIX regex statements in favour of PCRE",
      "CHECK_OCCURENCES": "Detect obsolete OCCURRENCES addition syntax",
      "CHECK_REPLACE_INTO": "Detect obsolete REPLACE ... WITH ... INTO syntax"
    },
    "seo": {
      "description": "Avoid Obsolete String and POSIX Regex Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-obs-strings",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-list-proc",
    "title": "Avoid Classic List Processing Statements",
    "rationale": "Classic list processing with WRITE, ULINE, FORMAT, and READ LINE only works in SAP GUI list reports and is unavailable in ABAP Cloud. It couples business logic to screen output and makes the code impossible to test independently. Use application logging or a modern UI framework instead of writing directly to a list.",
    "className": "ZCL_SKYLINT_NO_LIST_PROC",
    "pseudoComment": "NO_LIST_PROC",
    "category": "anti-patterns",
    "example": {
      "bad": "WRITE / 'Order processed:'.\nULINE.",
      "good": "mo_logger->info( 'Order processed:' )."
    },
    "parameters": {
      "CHECK_WRITE": "Detect classic list processing WRITE statements",
      "CHECK_ULINE": "Detect classic ULINE statements",
      "CHECK_SKIP": "Detect classic SKIP statements",
      "CHECK_OTHER": "Detect BACK, FORMAT, and classic print formatting statements",
      "IGN_WRITE_TO": "Ignore WRITE ... TO ... string formatting statements (use string templates instead)",
      "CHECK_LEAVE": "Detect LEAVE LIST-PROCESSING statements",
      "CHECK_REJECT": "Detect REJECT statements in logical databases"
    },
    "seo": {
      "description": "Avoid Classic List Processing Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-list-proc",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-params",
    "title": "Limit Method Parameter Count and Require Multi-Line Signatures",
    "rationale": "Methods with excessive parameter signatures (more than 3-5 parameters) are a sign of weak abstraction. Callers struggle to remember parameter order, optional flags multiply, and method calls become unreadable. Furthermore, declaring multiple parameters on a single line clutters Git diffs and hinders peer review.\n\n**Clean ABAP Guideline:** Prefer 0 to 3 parameters. If more data is needed, bundle logically related fields into a dedicated parameter structure or options object. Place each parameter on its own line.",
    "className": "ZCL_SKYLINT_MAX_PARAMS",
    "pseudoComment": "MAX_PARAMS_COUNT",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: 7 primitive parameters declared on one cramped line\nMETHODS create_invoice IMPORTING iv_cust TYPE kunnr iv_amt TYPE netpr iv_cur TYPE waers iv_date TYPE datum iv_tax TYPE mwskz iv_type TYPE fkart iv_desc TYPE string.",
      "good": "\" Clean ABAP: Clean parameter structure, each parameter on a dedicated line\nMETHODS create_invoice\n  IMPORTING\n    is_invoice_request TYPE ty_invoice_request\n  RETURNING\n    VALUE(rv_invoice_id) TYPE ty_invoice_id."
    },
    "seo": {
      "description": "Enforce clean method signatures in ABAP. Limit parameter count and format signatures with one parameter per line for readable Git diffs.",
      "keywords": [
        "ABAP Method Parameters Limit",
        "Clean ABAP Signatures",
        "Parameter Object Pattern SAP",
        "ATC Clean Code Metrics"
      ]
    },
    "parameters": {
      "MAX_PARAMETERS": "Maximum allowed total parameters (IMPORTING, EXPORTING, CHANGING, RETURNING)",
      "CHECK_PARAM_LINE": "Enforce one parameter per line in method definitions and invocations"
    },
    "references": [
      {
        "title": "Clean ABAP: Take No More Than 3 to 5 Parameters",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#take-no-more-than-3-to-5-parameters"
      },
      {
        "title": "Clean ABAP: One Parameter per Line",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#one-parameter-per-line"
      }
    ]
  },
  {
    "ruleId": "no-db-in-loop",
    "title": "Avoid Database Access Inside Loops (N+1 Query Antipattern)",
    "rationale": "Executing OpenSQL queries (SELECT, INSERT, UPDATE, DELETE) inside loops causes the notorious **N+1 query antipattern**. Every iteration incurs network latency, context switches between application server and database, and query compilation overhead. In high-volume production systems, this degrades transaction throughput by orders of magnitude and causes database connection pool saturation.\n\n**Best Practice:** Pre-fetch all necessary records in bulk before entering the loop using `FOR ALL ENTRIES` or SQL `JOIN`. Index the retrieved records in a hashed or sorted internal table and access them inside the loop in memory in $O(1)$ or $O(\\log N)$ time.",
    "className": "ZCL_SKYLINT_NO_DB_IN_LOOP",
    "pseudoComment": "NO_DB_IN_LOOP",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: N+1 Network roundtrips to database\nLOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>).\n  SELECT SINGLE customer_name, country\n    FROM zcustomers\n    WHERE customer_id = @<ls_order>-customer_id\n    INTO @DATA(ls_customer).\n\n  <ls_order>-customer_name = ls_customer-customer_name.\nENDLOOP.",
      "good": "\" Clean ABAP: Bulk read outside loop with in-memory lookup\nIF lt_sales_orders IS NOT INITIAL.\n  SELECT customer_id, customer_name, country\n    FROM zcustomers\n    FOR ALL ENTRIES IN @lt_sales_orders\n    WHERE customer_id = @lt_sales_orders-customer_id\n    INTO TABLE @DATA(lt_customers).\n\n  SORT lt_customers BY customer_id.\n\n  LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>).\n    IF line_exists( lt_customers[ customer_id = <ls_order>-customer_id ] ).\n      <ls_order>-customer_name = lt_customers[ customer_id = <ls_order>-customer_id ]-customer_name.\n    ENDIF.\n  ENDLOOP.\nENDIF."
    },
    "seo": {
      "description": "Eliminate N+1 database queries in SAP ABAP. Optimize performance by pre-fetching data in bulk with FOR ALL ENTRIES or SQL Joins before processing in loops.",
      "keywords": [
        "ABAP Performance",
        "N+1 Query SAP",
        "SELECT in LOOP",
        "Clean ABAP Database",
        "S/4HANA SQL Optimization",
        "ATC Check Database"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Prefer Bulk Reads Over Reads in Loop",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#prefer-bulk-reads-over-reads-in-loop"
      },
      {
        "title": "SAP Help: Open SQL Performance Considerations",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-empty-fae",
    "title": "Prevent Empty Driver Tables in FOR ALL ENTRIES (Full Table Scan Bug)",
    "rationale": "In ABAP OpenSQL, if the internal table specified in `FOR ALL ENTRIES IN @lt_tab` is empty at runtime, **the database drops the WHERE clause entirely** and executes an unrestricted full-table scan (`SELECT * FROM dbtab`). This is a well-known legacy behavior in SAP NetWeaver and ABAP Cloud that can lock massive production tables, exhaust application server memory, and result in catastrophic runtime dumps (`TSV_TNEW_PAGE_ALLOC_FAILED`).\n\n**Best Practice:** Always guard any `FOR ALL ENTRIES` query with an explicit `IF itab IS NOT INITIAL` condition before invoking the database.",
    "className": "ZCL_SKYLINT_NO_EMPTY_FAE",
    "pseudoComment": "NO_EMPTY_FAE",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: If lt_items is empty, WHERE is ignored -> Entire ZINVOICES read!\nSELECT invoice_id, amount, status\n  FROM zinvoices\n  FOR ALL ENTRIES IN @lt_items\n  WHERE item_id = @lt_items-item_id\n  INTO TABLE @DATA(lt_invoices).",
      "good": "\" Clean ABAP: Guard check guarantees safety and avoids full table scan\nIF lt_items IS NOT INITIAL.\n  SELECT invoice_id, amount, status\n    FROM zinvoices\n    FOR ALL ENTRIES IN @lt_items\n    WHERE item_id = @lt_items-item_id\n    INTO TABLE @DATA(lt_invoices).\nELSE.\n  CLEAR lt_invoices.\nENDIF."
    },
    "seo": {
      "description": "Avoid full table scan database crashes in SAP ABAP by ensuring FOR ALL ENTRIES driver tables are checked for initial state before querying.",
      "keywords": [
        "SAP FOR ALL ENTRIES empty",
        "Full Table Scan ABAP",
        "TSV_TNEW_PAGE_ALLOC_FAILED",
        "Clean ABAP FAE Check",
        "S/4HANA Database Stability"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Check Before FOR ALL ENTRIES",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#check-before-for-all-entries"
      },
      {
        "title": "SAP Note 48230: FOR ALL ENTRIES with empty table",
        "url": "https://me.sap.com/notes/48230"
      }
    ]
  },
  {
    "ruleId": "no-select-star",
    "title": "Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)",
    "rationale": "Using `SELECT *` forces the SAP database interface and database engine to retrieve and transfer every single column defined on the database table, including heavy text fields, binary blobs, and irrelevant business attributes. In modern columnar databases like SAP HANA, fetching unneeded columns defeats column-store compression, inflates application server heap usage, and causes unnecessary memory allocations.\n\n**Best Practice:** Explicitly project only the exact fields required by your business process into a typed structure or inline table expression.",
    "className": "ZCL_SKYLINT_NO_SELECT_STAR",
    "pseudoComment": "NO_SELECT_STAR",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Pulls all 80+ fields of MARA including binary blobs and administrative logs\nSELECT *\n  FROM mara\n  WHERE matnr = @lv_matnr\n  INTO @DATA(ls_material).",
      "good": "\" Clean ABAP: Project only required business fields\nSELECT matnr, mtart, meins\n  FROM mara\n  WHERE matnr = @lv_matnr\n  INTO @DATA(ls_material)."
    },
    "seo": {
      "description": "Optimize SAP HANA column store performance in ABAP by avoiding SELECT * and explicitly declaring required columns in OpenSQL queries.",
      "keywords": [
        "Avoid SELECT star ABAP",
        "SAP HANA Column Store Optimization",
        "Clean ABAP Query Guidelines",
        "Memory Footprint Reduction SAP"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Select Only Needed Columns",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#select-only-needed-columns"
      },
      {
        "title": "SAP HANA Performance Guide for ABAP",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "no-endselect",
    "title": "Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops",
    "rationale": "The `SELECT ... ENDSELECT` construct establishes a persistent server-side database cursor and streams rows individually back to the application server one by one. This causes massive network chatter, holds open database transaction locks, and blocks database connection pool resources. If long-running logic or exception dumps occur inside the loop, the database cursor may leak.\n\n**Best Practice:** Use package fetches or array array operations (`SELECT ... INTO TABLE`) to retrieve records in bulk, utilizing fast block-based network transfers.",
    "className": "ZCL_SKYLINT_NO_ENDSELECT",
    "pseudoComment": "NO_ENDSELECT",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Holds DB cursor open across every row iteration\nSELECT order_id, order_date, status\n  FROM zorders\n  WHERE status = 'OPEN'\n  INTO @DATA(ls_order).\n\n  process_order( ls_order ).\nENDSELECT.",
      "good": "\" Clean ABAP: Bulk array fetch into memory, cursor closed immediately\nSELECT order_id, order_date, status\n  FROM zorders\n  WHERE status = 'OPEN'\n  INTO TABLE @DATA(lt_orders).\n\nLOOP AT lt_orders INTO DATA(ls_order).\n  process_order( ls_order ).\nENDLOOP."
    },
    "seo": {
      "description": "Eliminate database cursor leaks and slow row-by-row fetching by replacing SELECT ... ENDSELECT with array fetches into internal tables.",
      "keywords": [
        "SELECT ENDSELECT ABAP",
        "Database Cursor Leak SAP",
        "Array Fetch OpenSQL",
        "Clean ABAP Database Best Practices"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Avoid SELECT ... ENDSELECT",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#avoid-select--endselect"
      }
    ]
  },
  {
    "ruleId": "no-scope-leak",
    "title": "Avoid Variable Scope Leaking from Inner Blocks",
    "rationale": "A variable declared inside an IF or LOOP block is still visible after the block ends, so using it later creates a hidden dependency on whether the branch executed. This makes behavior hard to reason about and can leave the variable uninitialized. Declare the variable in the enclosing scope and assign it explicitly inside the branch.",
    "className": "ZCL_SKYLINT_NO_SCOPE_LEAK",
    "pseudoComment": "NO_SCOPE_LEAK",
    "category": "anti-patterns",
    "example": {
      "bad": "IF is_valid( ).\n  DATA(lv_message) = |Order { lv_id }|.\nENDIF.\nlog_message( lv_message ).",
      "good": "DATA lv_message TYPE string.\nIF is_valid( ).\n  lv_message = |Order { lv_id }|.\nENDIF.\nlog_message( lv_message )."
    },
    "seo": {
      "description": "Avoid Variable Scope Leaking from Inner Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-scope-leak",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-redun-assign",
    "title": "Remove Redundant Self-Assignments and CLEAR Statements",
    "rationale": "Self-assignments (e.g. a = a or MOVE a TO a) and superfluous CLEAR/FREE operations have zero net effect on program execution state. Clearing variables immediately after declaration is unnecessary because ABAP automatically initializes variables to their type defaults. Similarly, clearing variables at procedure exit when they are never read again is dead code. Remove these redundant statements to improve clarity and reduce noise.",
    "className": "ZCL_SKYLINT_NO_REDUN_ASSIGN",
    "pseudoComment": "SELF_ASSIGN",
    "category": "anti-patterns",
    "example": {
      "bad": "ls_order-id = ls_order-id.\nDATA lt_items TYPE string_table.\nCLEAR lt_items.",
      "good": "ls_order-id = iv_id.\nDATA lt_items TYPE string_table."
    },
    "parameters": {
      "CHECK_SELF_ASSIGN": "Detect identical assignments where variable is assigned to itself (a = a)",
      "CHECK_BEFORE_WRITE": "Detect redundant CLEAR statements immediately followed by variable write/overwrite",
      "CHECK_WITHOUT_READ": "Detect redundant CLEAR at the very end of procedure where variable is never read again"
    },
    "seo": {
      "description": "Remove Redundant Self-Assignments and CLEAR Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-redun-assign",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-shadow",
    "title": "Avoid Local Variables Shadowing Class Attributes",
    "rationale": "A local variable that repeats a class attribute name silently hides the member inside the method. Readers can no longer tell whether the code changes the object state or only a temporary copy, and a later refactoring may keep the wrong reference. Rename the local or use a distinct name that states its purpose.",
    "className": "ZCL_SKYLINT_NO_SHADOW",
    "pseudoComment": "NO_SHADOW",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA mv_status TYPE string.\nmv_status = 'OPEN'.",
      "good": "DATA lv_status TYPE string.\nlv_status = 'OPEN'."
    },
    "seo": {
      "description": "Avoid Local Variables Shadowing Class Attributes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-shadow",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-useless-concat",
    "title": "Avoid Concatenating Adjacent String Literals",
    "rationale": "Joining two or more literals with && produces one constant value at runtime, so the operator adds no information and only fragments the text. Folding the literals makes the final string visible and removes a pointless expression. Keep && only when at least one operand is dynamic.",
    "className": "ZCL_SKYLINT_NO_USELESS_CONCAT",
    "pseudoComment": "NO_USELESS_CONCAT",
    "category": "anti-patterns",
    "example": {
      "bad": "lv_path = 'orders' && '/' && 'open'.",
      "good": "lv_path = 'orders/open'."
    },
    "seo": {
      "description": "Avoid Concatenating Adjacent String Literals - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-useless-concat",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-full-typed",
    "title": "Require Fully Typed Variables and Parameters",
    "rationale": "Untyped constants and data objects receive an implicit type whose length and value range are easy to misjudge. A later change to the literal can silently truncate data or alter comparisons. Declare explicit TYPE and LENGTH so the contract is visible to readers and checked by the compiler.",
    "className": "ZCL_SKYLINT_PREF_FULL_TYPED",
    "pseudoComment": "PREF_FULL_TYPED",
    "category": "clean-abap",
    "example": {
      "bad": "CONSTANTS c_status VALUE 'A'.",
      "good": "CONSTANTS c_status TYPE c LENGTH 1 VALUE 'A'."
    },
    "seo": {
      "description": "Require Fully Typed Variables and Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-full-typed",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-corresp",
    "title": "Prefer CORRESPONDING #( ) Operator",
    "rationale": "MOVE-CORRESPONDING is a procedural statement that copies same-named fields implicitly and cannot be nested in expressions. CORRESPONDING #( ) is expression-capable and supports EXCEPT, MAPPING, and DISCARDING to control the mapping explicitly. Use it to make structure transfers visible and type-safe.",
    "className": "ZCL_SKYLINT_PREF_CORRESP",
    "pseudoComment": "PREF_CORRESP",
    "category": "clean-abap",
    "example": {
      "bad": "MOVE-CORRESPONDING ls_customer_api TO ls_customer_db.",
      "good": "ls_customer_db = CORRESPONDING #( ls_customer_api )."
    },
    "seo": {
      "description": "Prefer CORRESPONDING #( ) Operator - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-corresp",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-method-len",
    "title": "Limit Method and Constructor Statement Length",
    "rationale": "Methods that contain hundreds of statements violate the **Single Responsibility Principle (SRP)**. They are difficult to comprehend, impossible to unit test thoroughly, and conceal copy-pasted business logic branches. Constructors are especially sensitive: heavy business logic or loops in constructors make dependency injection and mock testing impossible.\n\n**Clean ABAP Guideline:** A clean method should do one thing, do it well, and do it only. Keep regular methods under 20-30 statements and keep constructors minimal (dependency assignment only).",
    "className": "ZCL_SKYLINT_MAX_METHOD_LEN",
    "pseudoComment": "MAX_METHOD_LEN",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: Overly long method combining validation, calculation, DB updates, and logging\nMETHOD process_sales_order.\n  \" 150+ lines of mixed concerns...\n  \" Validation logic\n  \" Database reads\n  \" Currency conversion\n  \" Pricing calculations\n  \" Direct database updates\n  \" Email dispatch\nENDMETHOD.",
      "good": "\" Clean ABAP: Short, focused methods delegating to dedicated domain services\nMETHOD process_sales_order.\n  validate_order_data( is_order ).\n  DATA(ls_pricing) = mo_pricing_service->calculate( is_order ).\n  mo_order_repository->save( is_order = is_order is_pricing = ls_pricing ).\n  mo_notifier->send_confirmation( is_order-order_id ).\nENDMETHOD."
    },
    "seo": {
      "description": "Enforce Clean ABAP method length limits and keep constructors minimal. Prevent God Methods and improve testability in SAP ABAP.",
      "keywords": [
        "Method length limit ABAP",
        "Clean ABAP Method Size",
        "Constructor Logic Antipattern",
        "Single Responsibility ABAP",
        "ATC Code Metrics"
      ]
    },
    "parameters": {
      "MAX_STATEMENTS": "Maximum executable ABAP statements allowed in regular method bodies",
      "MAX_CTOR_STATEMENTS": "Maximum statements allowed in CONSTRUCTOR methods (guards against heavy setup logic)"
    },
    "references": [
      {
        "title": "Clean ABAP: Keep Methods Small",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#keep-methods-small"
      },
      {
        "title": "Clean ABAP: Do Not Put Logic in Constructors",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#do-not-put-logic-in-constructors"
      }
    ]
  },
  {
    "ruleId": "max-nesting",
    "title": "Limit Control Flow Nesting Depth (Guard Clause Enforcement)",
    "rationale": "Deeply nested control structures (`IF`, `LOOP`, `CASE`, `DO`, `TRY`) create the dreaded \"Arrow Antipattern\". Code drifts to the right edge of the editor, mental stack load increases exponentially, and error handling branches become difficult to trace.\n\n**Clean ABAP Guideline:** Invert conditional checks and use **Guard Clauses** (`RETURN`, `CONTINUE`) at the top of methods and loops. Aim for a maximum nesting depth of 2 to 3 levels.",
    "className": "ZCL_SKYLINT_MAX_NESTING",
    "pseudoComment": "MAX_NESTING",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: 4 levels deep nesting (Arrow Pattern)\nMETHOD process_item.\n  IF is_item-active = abap_true.\n    IF is_item-quantity > 0.\n      IF is_customer_eligible( is_item-customer_id ) = abap_true.\n        execute_booking( is_item ).\n      ENDIF.\n    ENDIF.\n  ENDIF.\nENDMETHOD.",
      "good": "\" Clean ABAP: Flat, linear flow using early return guard clauses\nMETHOD process_item.\n  IF is_item-active = abap_false.\n    RETURN.\n  ENDIF.\n\n  IF is_item-quantity <= 0.\n    RETURN.\n  ENDIF.\n\n  IF is_customer_eligible( is_item-customer_id ) = abap_false.\n    RETURN.\n  ENDIF.\n\n  execute_booking( is_item ).\nENDMETHOD."
    },
    "seo": {
      "description": "Eliminate arrow antipattern in ABAP by enforcing control flow nesting depth limits and adopting guard clauses.",
      "keywords": [
        "Control flow nesting ABAP",
        "Arrow Antipattern SAP",
        "Guard Clauses ABAP",
        "Clean ABAP Nesting Limits"
      ]
    },
    "parameters": {
      "MAX_DEPTH": "Maximum allowable nesting depth of IF/CASE/LOOP/DO/WHILE/TRY control blocks"
    },
    "references": [
      {
        "title": "Clean ABAP: Keep Nesting Depth Low",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#keep-nesting-depth-low"
      }
    ]
  },
  {
    "ruleId": "no-sy-modify",
    "title": "Avoid Directly Modifying System Fields (sy-subrc, sy-tabix)",
    "rationale": "System fields in the `sy` structure (`sy-subrc`, `sy-tabix`, `sy-index`, `sy-mandt`) are maintained exclusively by the ABAP C-kernel. Directly overwriting them in application code (e.g., `sy-subrc = 0.`) creates deceptive illusion of successful operations, hides runtime failures from subsequent check tools, and produces erratic debugger state.",
    "className": "ZCL_SKYLINT_NO_SY_MODIFY",
    "pseudoComment": "NO_SY_MODIFY",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Overwrites kernel state to trick caller\nCALL FUNCTION 'SOME_LEGACY_FUNC'.\nsy-subrc = 0. \" Masked error!",
      "good": "\" Clean ABAP: Return explicit boolean flag or raise exception\nDATA lv_success TYPE abap_bool.\nlv_success = call_legacy_func( )."
    },
    "seo": {
      "description": "Preserve kernel integrity in SAP ABAP by forbidding direct assignment to system fields like sy-subrc and sy-tabix.",
      "keywords": [
        "sy-subrc assignment ABAP",
        "System fields modification SAP",
        "Clean ABAP Code Integrity"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Do Not Overwrite System Fields",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-returning",
    "title": "Prefer Functional RETURNING Parameters",
    "rationale": "A single EXPORTING parameter forces callers to declare a target and invoke the method as a statement. A RETURNING parameter makes the method usable directly in assignments, expressions, and assertions. Prefer RETURNING for value-producing methods and reserve EXPORTING for methods that genuinely return several outputs.",
    "className": "ZCL_SKYLINT_PREF_RETURNING",
    "pseudoComment": "PREF_RETURNING",
    "category": "clean-abap",
    "example": {
      "bad": "METHODS get_total\n  EXPORTING ev_total TYPE i.",
      "good": "METHODS get_total\n  RETURNING VALUE(rv_total) TYPE i."
    },
    "seo": {
      "description": "Prefer Functional RETURNING Parameters - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-returning",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-class-exc",
    "title": "Prefer Class-Based Exceptions over Classic EXCEPTIONS",
    "rationale": "Classic exceptions report failure through sy-subrc and cannot carry a message object, stack trace, or context data. They are easy to ignore and do not propagate cleanly through call stacks. Use CX_ROOT subclasses with RAISING and CATCH so errors are explicit, typed, and carry useful information.",
    "className": "ZCL_SKYLINT_PREF_CLASS_EXC",
    "pseudoComment": "PREF_CLASS_EXC",
    "category": "clean-abap",
    "example": {
      "bad": "METHODS execute\n  EXCEPTIONS not_found failed.",
      "good": "METHODS execute\n  RAISING cx_not_found cx_failed."
    },
    "seo": {
      "description": "Prefer Class-Based Exceptions over Classic EXCEPTIONS - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-class-exc",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-prod-assert",
    "title": "Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)",
    "rationale": "The ABAP statement `ASSERT condition` immediately raises an uncatchable short dump (`ASSERTION_FAILED`) if the condition evaluates to false. While useful in unit test classes, using unconditioned assertions in production application logic abruptly terminates end-user sessions, loses uncommitted data, and creates emergency incidents.\n\n**Best Practice:** Check conditions gracefully and raise recoverable class-based exceptions with informative error messages. Reserve `ASSERT` strictly for ABAP Unit test includes (`LCL_TEST`).",
    "className": "ZCL_SKYLINT_NO_PROD_ASSERT",
    "pseudoComment": "NO_PROD_ASSERT",
    "category": "security",
    "example": {
      "bad": "\" Dangerous: Causes catastrophic user session crash in production\nASSERT iv_amount > 0.",
      "good": "\" Clean ABAP: Graceful validation with recoverable domain exception\nIF iv_amount <= 0.\n  RAISE EXCEPTION NEW zcx_invalid_amount( iv_amount ).\nENDIF."
    },
    "seo": {
      "description": "Prevent production short dumps in SAP ABAP by replacing uncatchable ASSERT statements with structured exception handling.",
      "keywords": [
        "ASSERTION_FAILED dump ABAP",
        "Avoid ASSERT in production SAP",
        "Clean ABAP Exception Handling"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Use Assertions Only in Tests",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "no-raise-shortdump",
    "title": "Avoid Explicit RAISE SHORTDUMP in Application Logic",
    "rationale": "The statement `RAISE SHORTDUMP` deliberately triggers an instant runtime crash and short dump in transaction ST22. Triggering intentional crashes bypasses standard cleanup handlers, cancels asynchronous update tasks, and leaves database locks dangling.\n\n**Best Practice:** Raise standard class-based exceptions inheriting from `CX_STATIC_CHECK` or `CX_NO_CHECK`. Allow the caller or global exception boundary to handle the incident gracefully.",
    "className": "ZCL_SKYLINT_NO_RAISE_SHORTDUMP",
    "pseudoComment": "NO_RAISE_SHORTDUMP",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Forces instant ST22 crash\nRAISE SHORTDUMP TYPE zcx_fatal_error.",
      "good": "\" Clean ABAP: Structured exception allowing caller recovery\nRAISE EXCEPTION NEW zcx_fatal_error( textid = zcx_fatal_error=>c_system_unavailable )."
    },
    "seo": {
      "description": "Eliminate deliberate crash statements in ABAP by replacing RAISE SHORTDUMP with structured class-based exceptions.",
      "keywords": [
        "RAISE SHORTDUMP ABAP",
        "ST22 Dump Elimination",
        "Clean ABAP Resilience"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Prefer Exceptions Over Shortdumps",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "no-metaprogramming",
    "title": "Avoid Dynamic Metaprogramming and Code Generation (Remote Code Execution Risk)",
    "rationale": "Statements like `GENERATE SUBROUTINE POOL`, `INSERT REPORT`, and dynamic `SYNTAX-CHECK` create and execute uncompiled ABAP code at runtime. Metaprogramming introduces severe **Remote Code Execution (RCE)** vulnerabilities (CWE-94), defeats static analysis in ATC, and is completely blocked in ABAP Cloud and SAP BTP.\n\n**Cloud Standard:** Use object-oriented polymorphism, strategy design patterns, or BAdIs instead of generating code dynamically.",
    "className": "ZCL_SKYLINT_NO_METAPROGRAMMING",
    "pseudoComment": "NO_METAPROGRAMMING",
    "category": "security",
    "example": {
      "bad": "\" Critical Security Vulnerability: Dynamic code execution from string buffer\nGENERATE SUBROUTINE POOL lt_source_code NAME DATA(lv_prog).\nPERFORM execute IN PROGRAM (lv_prog).",
      "good": "\" Clean ABAP Cloud: Object-oriented strategy pattern\nDATA(lo_calculator) = zcl_calculator_factory=>get_strategy( iv_calc_type ).\nDATA(lv_result) = lo_calculator->compute( it_data )."
    },
    "seo": {
      "description": "Mitigate CWE-94 code injection vulnerabilities in SAP ABAP by avoiding GENERATE SUBROUTINE POOL and dynamic code execution.",
      "keywords": [
        "CWE-94 ABAP",
        "GENERATE SUBROUTINE POOL vulnerability",
        "Code Injection SAP",
        "ABAP Cloud Security"
      ]
    },
    "references": [
      {
        "title": "CWE-94: Improper Control of Generation of Code",
        "url": "https://cwe.mitre.org/data/definitions/94.html"
      },
      {
        "title": "SAP Clean Core Cloud Guidelines",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "no-kernel-call",
    "title": "Avoid Kernel and Native Database Calls (SYSTEM-CALL, EXEC SQL)",
    "rationale": "Executing internal SAP kernel commands (`SYSTEM-CALL`) or native database procedures (`EXEC SQL`) bypasses the OpenSQL syntax layer, authorization buffers, and client separation. Kernel calls are undocumented, internal SAP proprietary instructions that break across kernel upgrades and are strictly forbidden in ABAP Cloud.",
    "className": "ZCL_SKYLINT_NO_KERNEL_CALL",
    "pseudoComment": "NO_KERNEL_CALL",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Undocumented kernel instruction\nSYSTEM-CALL rfc_clone_connection.",
      "good": "\" Clean ABAP Cloud: Use official released SAP APIs\ncl_rfc_connection_factory=>create( )->clone( )."
    },
    "seo": {
      "description": "Ensure cross-platform compatibility and cloud compliance by avoiding SYSTEM-CALL and native EXEC SQL in ABAP.",
      "keywords": [
        "SYSTEM-CALL ABAP",
        "EXEC SQL SAP Security",
        "Clean Core Cloud Compliance"
      ]
    },
    "references": [
      {
        "title": "SAP Clean Core Guide for ABAP Cloud",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "pref-auth-check",
    "title": "Ensure AUTHORITY-CHECK Precedes Sensitive Business Operations",
    "rationale": "Accessing or modifying sensitive business entities (such as financials, HR master data, and sales pricing) without prior authorization verification allows unauthorized users to read or tamper with protected company assets. Every business service, remote-enabled function module, or RAP BO handler must enforce an explicit authorization check at the entry point of sensitive operations.",
    "className": "ZCL_SKYLINT_PREF_AUTH_CHECK",
    "pseudoComment": "PREF_AUTH_CHECK",
    "category": "security",
    "example": {
      "bad": "\" Insecure: Direct update to payroll records without verifying user permissions\nUPDATE pa0008 SET betrg = @iv_new_salary WHERE pernr = @iv_employee_id.",
      "good": "\" Secure: Authorization check precedes data modification\nAUTHORITY-CHECK OBJECT 'P_ORGIN'\n  ID 'INFTY' FIELD '0008'\n  ID 'AUTHC' FIELD 'W'.\nIF sy-subrc <> 0.\n  RAISE EXCEPTION NEW zcx_no_authorization( ).\nENDIF.\n\nUPDATE pa0008 SET betrg = @iv_new_salary WHERE pernr = @iv_employee_id."
    },
    "seo": {
      "description": "Ensure role-based authorization checks precede sensitive database modifications and financial records in SAP ABAP.",
      "keywords": [
        "SAP Authorization Check",
        "Role-Based Access Control ABAP",
        "Data Security SAP",
        "ATC Security Check"
      ]
    },
    "references": [
      {
        "title": "SAP Help: Implementing Authorization Checks",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "pref-order-by",
    "title": "Require Explicit ORDER BY for Deterministic SELECT Queries",
    "rationale": "In modern relational databases, particularly SAP HANA column store, rows in a table have no intrinsic physical order. Executing queries with `SELECT SINGLE` or `SELECT ... UP TO 1 ROWS` without an explicit `ORDER BY` clause leads to **non-deterministic results**: identical queries executed multiple times can return completely different records depending on parallel query execution, index fragmentation, or cache state.\n\n**Best Practice:** Always provide an explicit `ORDER BY` clause specifying the primary key or unique business keys when picking subset records or singular values.",
    "className": "ZCL_SKYLINT_PREF_ORDER_BY",
    "pseudoComment": "PREF_ORDER_BY",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Non-deterministic - returns random record on parallel HANA partitions\nSELECT SINGLE price\n  FROM zprice_history\n  WHERE product_id = @lv_product_id\n  INTO @DATA(lv_price).",
      "good": "\" Clean ABAP: Explicit sorting guarantees predictable, deterministic business result\nSELECT price\n  FROM zprice_history\n  WHERE product_id = @lv_product_id\n  ORDER BY valid_from DESCENDING\n  INTO @DATA(lv_price)\n  UP TO 1 ROWS.\nENDSELECT.\" (or SELECT SINGLE with primary key)"
    },
    "seo": {
      "description": "Ensure deterministic query results on SAP S/4HANA by enforcing explicit ORDER BY clauses in ABAP queries that limit rows.",
      "keywords": [
        "ORDER BY ABAP",
        "Deterministic SQL SAP HANA",
        "UP TO 1 ROWS bug",
        "Clean ABAP Sorting Guidelines"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Order by in Queries",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#order-by-in-queries"
      }
    ]
  },
  {
    "ruleId": "max-cyclo-comp",
    "title": "Limit Cyclomatic Complexity (McCabe Complexity Metric)",
    "rationale": "Cyclomatic Complexity measures the number of linearly independent paths through a procedure's source code (branch points like `IF`, `ELSEIF`, `WHEN`, `WHILE`, `AND`, `OR`, `CATCH`). High complexity correlates directly with high defect density, regression risks during refactoring, and poor unit test branch coverage.\n\n**Clean ABAP Guideline:** Keep cyclomatic complexity under 10 (or maximum 15 for large state dispatches). Extract branches into polymorphically dispatched strategy classes or smaller helper methods.",
    "className": "ZCL_SKYLINT_MAX_CYCLO_COMP",
    "pseudoComment": "MAX_CYCLO_COMP",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: Massive branching complexity score (>20) with nested conditionals\nMETHOD calculate_discount.\n  IF iv_region = 'EU'.\n    IF iv_cust_tier = 'VIP' AND iv_amount > 1000.\n      rv_disc = 20.\n    ELSEIF iv_cust_tier = 'GOLD' OR iv_amount > 500.\n      rv_disc = 15.\n    ...\n  ENDIF.\nENDMETHOD.",
      "good": "\" Clean ABAP: Delegate calculations to cohesive strategy pattern or rule table\nMETHOD calculate_discount.\n  DATA(lo_strategy) = mo_discount_factory->get_strategy( iv_region ).\n  rv_disc = lo_strategy->calculate( iv_tier = iv_cust_tier iv_amount = iv_amount ).\nENDMETHOD."
    },
    "seo": {
      "description": "Control McCabe cyclomatic complexity in ABAP code to reduce defect density and improve automated unit test coverage.",
      "keywords": [
        "Cyclomatic Complexity ABAP",
        "McCabe Metric SAP",
        "Clean ABAP Code Quality",
        "Branch Coverage ATC"
      ]
    },
    "parameters": {
      "MAX_COMPLEXITY": "Maximum allowed cyclomatic complexity score per method (default threshold: 10)"
    },
    "references": [
      {
        "title": "Clean ABAP: Keep Complexity Low",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-final-cls",
    "title": "Design for Inheritance or Prohibit It (FINAL)",
    "rationale": "A class that is not designed for inheritance can still be subclassed, and subclasses may depend on internal behavior that later changes. Marking the class FINAL prevents fragile base class problems and documents that no extension is intended. Remove FINAL only when the class has documented extension points.",
    "className": "ZCL_SKYLINT_PREF_FINAL_CLS",
    "pseudoComment": "PREF_FINAL_CLASS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS cl_customer_service DEFINITION\n  PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS.",
      "good": "CLASS cl_customer_service DEFINITION\n  PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS."
    },
    "parameters": {
      "CHECK_CLASSES": "Enforce FINAL on classes not designed for inheritance",
      "CHECK_METHODS": "Enforce FINAL on methods not designed to be redefined"
    },
    "seo": {
      "description": "Design for Inheritance or Prohibit It (FINAL) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-final-cls",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-magic-numbers",
    "title": "Avoid Magic Numbers; Use Named Constants",
    "rationale": "A numeric literal in logic does not explain what it represents, and the same value repeated in several places must be changed consistently. Named constants turn business rules into readable intent and give the value a single source of truth. Declare typed constants and reuse them instead of scattering numbers through the code.",
    "className": "ZCL_SKYLINT_NO_MAGIC_NUMBERS",
    "pseudoComment": "NO_MAGIC_NUMBERS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_retry_count >= 3.\n  process( ).\nENDIF.",
      "good": "CONSTANTS c_max_retries TYPE i VALUE 3.\nIF lv_retry_count >= c_max_retries.\n  process( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Magic Numbers; Use Named Constants - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-magic-numbers",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-insert",
    "title": "Prefer INSERT ... INTO TABLE over APPEND",
    "rationale": "APPEND only works for index tables and implies sequential insertion, so changing the table type to sorted or hashed later breaks the code. INSERT ... INTO TABLE works with every table category and states the intent generically. Use INSERT for table handling that should remain independent of the concrete table kind.",
    "className": "ZCL_SKYLINT_PREF_INSERT",
    "pseudoComment": "PREF_INSERT",
    "category": "clean-abap",
    "example": {
      "bad": "APPEND ls_order_item TO lt_order_items.",
      "good": "INSERT ls_order_item INTO TABLE lt_order_items."
    },
    "seo": {
      "description": "Prefer INSERT ... INTO TABLE over APPEND - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-insert",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-like-objects",
    "title": "Avoid LIKE Typing on Global Dictionary Objects",
    "rationale": "LIKE copies the type of a data object, which couples the new declaration to an implementation detail rather than to a type contract. For Dictionary objects, TYPE references the type directly and stays stable when the referenced object changes. Use LIKE only for local data objects whose type is intentionally shared.",
    "className": "ZCL_SKYLINT_NO_LIKE_OBJECTS",
    "pseudoComment": "NO_LIKE_OBJECTS",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_material LIKE mara-matnr.",
      "good": "DATA lv_material TYPE mara-matnr."
    },
    "seo": {
      "description": "Avoid LIKE Typing on Global Dictionary Objects - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-like-objects",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-static-cls",
    "title": "Avoid Purely Static Utility Classes",
    "rationale": "A class made only of static methods cannot be mocked through an interface, so every caller is tightly coupled to the implementation. Static state also leaks between tests and makes behavior order-dependent. Inject an instance through an interface and use instance methods instead.",
    "className": "ZCL_SKYLINT_NO_STATIC_CLS",
    "pseudoComment": "NO_STATIC_CLS",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.\n    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.\nENDCLASS.",
      "good": "CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    INTERFACES if_math_util.\nENDCLASS."
    },
    "seo": {
      "description": "Avoid Purely Static Utility Classes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-static-cls",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-pred-name",
    "title": "Use Predicate Naming for Boolean Methods (is_, has_, can_)",
    "rationale": "A boolean method reads best as a yes/no question, especially when it appears inside an IF condition. Names such as check_active or get_active leave the return type ambiguous and can suggest a side effect. Use is_, has_, or can_ prefixes for methods that return abap_bool.",
    "className": "ZCL_SKYLINT_PREF_PRED_NAME",
    "pseudoComment": "PREF_PRED_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "METHODS check_active\n  RETURNING VALUE(rv_active) TYPE abap_bool.",
      "good": "METHODS is_active\n  RETURNING VALUE(rv_active) TYPE abap_bool."
    },
    "seo": {
      "description": "Use Predicate Naming for Boolean Methods (is_, has_, can_) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-pred-name",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-inherit",
    "title": "Limit Class Inheritance Depth (Favor Composition over Inheritance)",
    "rationale": "Deep class inheritance hierarchies (more than 2-3 levels) create tight coupling, brittle base class syndromes, and hidden dependencies. Subclasses inherit private state and side-effects from ancestors, making changes to base classes unpredictable across the entire codebase.\n\n**Clean ABAP Guideline:** Favor **Object Composition** over Class Inheritance. Use interfaces to define contracts and inject dependencies instead of extending deep abstract class hierarchies.",
    "className": "ZCL_SKYLINT_MAX_INHERIT",
    "pseudoComment": "MAX_INHERIT",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: 5 levels of concrete inheritance\nCLASS zcl_entity DEFINITION ...\nCLASS zcl_persisted_entity DEFINITION INHERITING FROM zcl_entity ...\nCLASS zcl_sales_document DEFINITION INHERITING FROM zcl_persisted_entity ...\nCLASS zcl_order DEFINITION INHERITING FROM zcl_sales_document ...\nCLASS zcl_rush_order DEFINITION INHERITING FROM zcl_order ...",
      "good": "\" Clean ABAP: Shallow hierarchy with composition and role-based interfaces\nCLASS zcl_rush_order DEFINITION FINAL.\n  PUBLIC SECTION.\n    INTERFACES zif_sales_order.\n    METHODS constructor\n      IMPORTING\n        io_persistence TYPE REF TO zif_order_persistence\n        io_pricing     TYPE REF TO zif_pricing_strategy.\nENDCLASS."
    },
    "seo": {
      "description": "Prevent fragile base class antipatterns in ABAP OOP by limiting inheritance depth and favoring object composition.",
      "keywords": [
        "Inheritance depth limit ABAP",
        "Favor composition over inheritance SAP",
        "Clean ABAP OOP Design",
        "ATC OOP Metrics"
      ]
    },
    "parameters": {
      "MAX_DEPTH": "Maximum allowable inheritance depth levels from standard root object"
    },
    "references": [
      {
        "title": "Clean ABAP: Favor Composition Over Inheritance",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#favor-composition-over-inheritance"
      }
    ]
  },
  {
    "ruleId": "max-attributes",
    "title": "Limit Class Member Attribute Count (Prevent God Classes)",
    "rationale": "Classes with dozens of member variables (`DATA mv_*`) almost always suffer from low cohesion. Such classes become stateful \"God Objects\" that manage unrelated responsibilities, leading to concurrency race conditions and untraceable state mutations.\n\n**Clean ABAP Guideline:** Classes should have a small number of instance attributes that directly represent the core identity or essential collaborators of the object. Split bloated classes into focused domain components.",
    "className": "ZCL_SKYLINT_MAX_ATTRIBUTES",
    "pseudoComment": "MAX_ATTRIBUTES",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: Class holding 40+ attributes for UI, DB, configuration, and logging\nCLASS zcl_invoice_manager DEFINITION.\n  PRIVATE SECTION.\n    DATA mv_inv_id TYPE string.\n    DATA mv_cust_name TYPE string.\n    DATA mv_ui_theme TYPE string.\n    DATA mv_db_connection TYPE string.\n    DATA mv_log_handle TYPE balloghndl.\n    \" ... 35 more attributes ...\nENDCLASS.",
      "good": "\" Clean ABAP: Small, cohesive class delegating to specialized services\nCLASS zcl_invoice_processor DEFINITION FINAL.\n  PRIVATE SECTION.\n    DATA mv_invoice_id   TYPE ty_invoice_id.\n    DATA mo_repository   TYPE REF TO zif_invoice_repo.\n    DATA mo_tax_service  TYPE REF TO zif_tax_calculator.\nENDCLASS."
    },
    "seo": {
      "description": "Prevent God Object antipatterns in ABAP by restricting member attribute counts and promoting cohesive domain class design.",
      "keywords": [
        "God Class ABAP",
        "Class member attributes limit",
        "Clean ABAP Cohesion",
        "Single Responsibility Principle SAP"
      ]
    },
    "parameters": {
      "MAX_ATTRIBUTES": "Maximum allowed instance and static attributes per class"
    },
    "references": [
      {
        "title": "Clean ABAP: Keep Classes Small and Cohesive",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "no-catch-root",
    "title": "Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)",
    "rationale": "Catching the root exception class `CX_ROOT` indiscriminately traps all exceptions, including catastrophic system resource exhaustion (`CX_SY_RESOURCE_FAILURE`), database disconnections, and critical assertion failures. Catching `CX_ROOT` without re-raising creates the \"Black Hole Exception Antipattern\", masking fatal bugs and allowing corrupted processes to continue running.\n\n**Best Practice:** Always catch specific, expected exception classes (`CATCH zcx_order_not_found zcx_pricing_failed`).",
    "className": "ZCL_SKYLINT_NO_CATCH_ROOT",
    "pseudoComment": "NO_CATCH_ROOT",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Swallows fatal database disconnection and memory errors silently\nTRY.\n    process_order( ).\n  CATCH cx_root.\n    \" Swallowed! Program continues with corrupt state.\nENDTRY.",
      "good": "\" Clean ABAP: Catch specific anticipated domain exceptions only\nTRY.\n    process_order( ).\n  CATCH zcx_invalid_order_status INTO DATA(lx_status).\n    mo_logger->warn( lx_status->get_text( ) ).\n  CATCH zcx_credit_limit_exceeded INTO DATA(lx_credit).\n    mo_order_queue->hold( is_order ).\nENDTRY."
    },
    "seo": {
      "description": "Eliminate black hole exception handling in SAP ABAP by catching specific domain exceptions instead of generic CX_ROOT.",
      "keywords": [
        "CATCH CX_ROOT ABAP",
        "Black Hole Exception SAP",
        "Clean ABAP Exception Handling"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Catch Specific Exceptions",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#catch-specific-exceptions"
      }
    ]
  },
  {
    "ruleId": "no-msg-raising",
    "title": "Avoid Obsolete MESSAGE ... RAISING in Methods",
    "rationale": "MESSAGE ... RAISING mixes UI message output with exception propagation and depends on classic exception numbers. It separates poorly from business logic and is unsuitable for APIs that should return typed failures. Raise a class-based exception that references the message class text instead.",
    "className": "ZCL_SKYLINT_NO_MSG_RAISING",
    "pseudoComment": "NO_MSG_RAISING",
    "category": "anti-patterns",
    "example": {
      "bad": "MESSAGE e002(zorder) RAISING not_found.",
      "good": "RAISE EXCEPTION NEW cx_order_not_found( textid = cx_order_not_found=>c_order_missing )."
    },
    "seo": {
      "description": "Avoid Obsolete MESSAGE ... RAISING in Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-msg-raising",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-nested-try",
    "title": "Avoid Deeply Nested TRY ... CATCH Blocks",
    "rationale": "A TRY block inside another TRY block makes it unclear which handler owns which failure and often duplicates cleanup logic. The inner operation should have its own exception contract behind a method boundary. Extract it into a focused helper and keep one TRY per responsibility.",
    "className": "ZCL_SKYLINT_NO_NESTED_TRY",
    "pseudoComment": "NO_NESTED_TRY",
    "category": "anti-patterns",
    "example": {
      "bad": "TRY.\n  step1( ).\n  TRY.\n    step2( ).\n  CATCH cx_step2_error.\n    handle_step2( ).\n  ENDTRY.\nCATCH cx_step1_error.\n  handle_step1( ).\nENDTRY.",
      "good": "TRY.\n  step1( ).\n  execute_step2( ).\nCATCH cx_step1_error.\n  handle_step1( ).\nENDTRY."
    },
    "seo": {
      "description": "Avoid Deeply Nested TRY ... CATCH Blocks - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-nested-try",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-raise-cx-sy",
    "title": "Avoid Raising System Exceptions Directly (CX_SY_*)",
    "rationale": "Classes in the `CX_SY_*` namespace (such as `CX_SY_ZERODIVIDE`, `CX_SY_REF_IS_INITIAL`) are reserved for the ABAP runtime engine and virtual machine. Raising them manually in business application logic confuses callers, pollutes error logs, and obscures the true origin of technical errors.\n\n**Best Practice:** Define dedicated domain exception classes inheriting from `CX_STATIC_CHECK` or `zcx_application_error`.",
    "className": "ZCL_SKYLINT_NO_RAISE_CX_SY",
    "pseudoComment": "NO_RAISE_CX_SY",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Raising internal kernel exception\nRAISE EXCEPTION TYPE cx_sy_itab_line_not_found.",
      "good": "\" Clean ABAP: Custom domain exception expressing business context\nRAISE EXCEPTION NEW zcx_customer_not_found( iv_customer_id )."
    },
    "seo": {
      "description": "Maintain clear exception boundaries in ABAP by defining custom domain exceptions instead of raising internal CX_SY_* classes.",
      "keywords": [
        "CX_SY_* exceptions ABAP",
        "Clean ABAP Domain Exceptions",
        "Error Handling Best Practices SAP"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Define Dedicated Exception Classes",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-check-subrc",
    "title": "Verify sy-subrc Promptly After Data Retrieval and Search",
    "rationale": "Statements such as SELECT SINGLE, READ TABLE, FIND, and SEARCH report success through sy-subrc. If intervening statements execute before inspection, sy-subrc is overwritten and failure states are silently ignored. Check sy-subrc immediately after execution.",
    "className": "ZCL_SKYLINT_PREF_CHECK_SUBRC",
    "pseudoComment": "PREF_CHECK_SUBRC",
    "category": "clean-abap",
    "example": {
      "bad": "SELECT SINGLE customer_id FROM /dmo/customer\n  WHERE customer_id = @lv_id\n  INTO @lv_customer_id.\nprocess_customer( lv_customer_id ).",
      "good": "SELECT SINGLE customer_id FROM /dmo/customer\n  WHERE customer_id = @lv_id\n  INTO @lv_customer_id.\nIF sy-subrc = 0.\n  process_customer( lv_customer_id ).\nENDIF."
    },
    "parameters": {
      "CHECK_SELECT_SINGLE": "Require sy-subrc check after SELECT SINGLE",
      "CHECK_READ_TABLE": "Require sy-subrc check after READ TABLE",
      "CHECK_FIND_SEARCH": "Require sy-subrc check after FIND or SEARCH",
      "CHECK_ASSIGN": "Require sy-subrc check after dynamic ASSIGN"
    },
    "seo": {
      "description": "Verify sy-subrc Promptly After Data Retrieval and Search - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-check-subrc",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-auth-subrc",
    "title": "Check sy-subrc Promptly After AUTHORITY-CHECK (CWE-862 Authorization Bypass)",
    "rationale": "Executing `AUTHORITY-CHECK` without verifying `sy-subrc` immediately afterwards is one of the most critical security vulnerabilities in SAP ABAP (CWE-862: Missing Authorization Check). The SAP kernel evaluates the user's authorizations and sets `sy-subrc` to 0 on success or a non-zero code on failure. If intermediate statements execute before evaluating `sy-subrc`, another statement might overwrite `sy-subrc`, resulting in unauthorized privilege escalation.\n\n**Security Standard:** Always check `IF sy-subrc <> 0` immediately on the statement following `AUTHORITY-CHECK` and raise an authorization exception or terminate execution.",
    "className": "ZCL_SKYLINT_PREF_AUTH_SUBRC",
    "pseudoComment": "PREF_AUTH_SUBRC",
    "category": "security",
    "example": {
      "bad": "\" Critical Vulnerability: sy-subrc is NOT checked immediately; overwritten by subsequent SELECT\nAUTHORITY-CHECK OBJECT 'S_TABU_DIS'\n  ID 'ACTVT' FIELD '02'.\n\nSELECT SINGLE * FROM zsens_data INTO @DATA(ls_data). \" Overwrites sy-subrc!\nIF sy-subrc <> 0. \" Checks SELECT, not the authorization check!\n  MESSAGE 'Not authorized' TYPE 'E'.\nENDIF.",
      "good": "\" Secure: Immediate verification prevents authorization bypass\nAUTHORITY-CHECK OBJECT 'S_TABU_DIS'\n  ID 'ACTVT' FIELD '02'.\nIF sy-subrc <> 0.\n  RAISE EXCEPTION NEW zcx_auth_exception( textid = zcx_auth_exception=>c_not_authorized ).\nENDIF.\n\nSELECT SINGLE * FROM zsens_data INTO @DATA(ls_data)."
    },
    "seo": {
      "description": "Prevent CWE-862 authorization bypass vulnerabilities in SAP ABAP by verifying sy-subrc immediately following AUTHORITY-CHECK statements.",
      "keywords": [
        "CWE-862 ABAP",
        "AUTHORITY-CHECK sy-subrc",
        "SAP Security Audit Log",
        "Clean ABAP Authorization",
        "Privilege Escalation SAP"
      ]
    },
    "references": [
      {
        "title": "CWE-862: Missing Authorization",
        "url": "https://cwe.mitre.org/data/definitions/862.html"
      },
      {
        "title": "Clean ABAP: Check sy-subrc Promptly",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#check-sy-subrc-promptly"
      }
    ]
  },
  {
    "ruleId": "no-client-spec",
    "title": "Avoid CLIENT SPECIFIED / USING CLIENT in Cloud (Multi-Tenant Isolation)",
    "rationale": "The clauses `CLIENT SPECIFIED` and `USING CLIENT` override automatic client handling in OpenSQL. In multi-tenant cloud architectures (SAP BTP ABAP Environment, SAP S/4HANA Cloud), querying data across tenants violates multi-tenant data privacy laws (GDPR) and breaks tenant sandbox isolation.",
    "className": "ZCL_SKYLINT_NO_CLIENT_SPEC",
    "pseudoComment": "NO_CLIENT_SPEC",
    "category": "security",
    "example": {
      "bad": "\" Insecure: Reads data across client boundaries\nSELECT * FROM zorders CLIENT SPECIFIED WHERE mandt = '200'.",
      "good": "\" Secure: Native automatic client handling preserves tenant sandbox\nSELECT order_id, status FROM zorders WHERE status = 'OPEN'."
    },
    "seo": {
      "description": "Preserve multi-tenant data privacy in SAP BTP by avoiding CLIENT SPECIFIED and USING CLIENT in OpenSQL.",
      "keywords": [
        "CLIENT SPECIFIED ABAP Cloud",
        "Multi-tenant isolation SAP BTP",
        "GDPR Data Isolation ABAP"
      ]
    },
    "references": [
      {
        "title": "SAP Help: Client Handling in ABAP Cloud",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "pref-transport",
    "title": "Specify TRANSPORTING in Internal Table MODIFY and READ Operations",
    "rationale": "When updating internal table rows using `MODIFY itab FROM workarea`, ABAP by default copies every single field from the work area into the internal table row. If the table row contains wide structures, nested tables, or large string fields, copying unchanged fields incurs severe CPU cache misses and memory reallocation overhead.\n\n**Best Practice:** Use the `TRANSPORTING` addition to explicitly specify only the specific columns being modified.",
    "className": "ZCL_SKYLINT_PREF_TRANSPORT",
    "pseudoComment": "PREF_TRANSPORT",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Deep copies all 60 columns of ls_customer back into the table row\nls_customer-status = 'ACTIVE'.\nMODIFY lt_customers FROM ls_customer INDEX lv_tabix.",
      "good": "\" Clean ABAP: Only transfers the modified status column (zero overhead on other fields)\nls_customer-status = 'ACTIVE'.\nMODIFY lt_customers FROM ls_customer INDEX lv_tabix TRANSPORTING status.\n\n\" Even better: Mutate directly in-place via field symbol (zero copy)\n<ls_customer>-status = 'ACTIVE'."
    },
    "seo": {
      "description": "Speed up internal table updates in ABAP by specifying TRANSPORTING fields in MODIFY statements to prevent full-structure copy overhead.",
      "keywords": [
        "MODIFY itab TRANSPORTING",
        "Internal Table Performance ABAP",
        "Clean ABAP Table Mutations",
        "SAP Memory Optimization"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Use TRANSPORTING when Modifying Internal Tables",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-str-func",
    "title": "Prefer Built-in String Functions over SEARCH/SHIFT",
    "rationale": "Statements such as CONDENSE, TRANSLATE, SHIFT, and SEARCH mutate a variable and cannot be used inside expressions. Built-in functions return values, compose cleanly, and make the intended transformation explicit. Use functions such as to_upper, to_lower, find, substring, and shift_left instead.",
    "className": "ZCL_SKYLINT_PREF_STR_FUNC",
    "pseudoComment": "PREF_STR_FUNC",
    "category": "clean-abap",
    "example": {
      "bad": "SHIFT lv_code LEFT BY 2 PLACES.\nTRANSLATE lv_country TO UPPER CASE.",
      "good": "lv_code = shift_left( val = lv_code places = 2 ).\nlv_country = to_upper( lv_country )."
    },
    "parameters": {
      "CHECK_CONDENSE": "Suggest condense( ) function over CONDENSE statement",
      "CHECK_TRANSLATE": "Suggest to_upper( ) / to_lower( ) over TRANSLATE statement",
      "CHECK_SHIFT": "Suggest substring / shift functions over SHIFT statement",
      "CHECK_SEARCH": "Suggest find( ) function over SEARCH statement",
      "CHECK_OVERLAY": "Suggest string templates over OVERLAY statement",
      "CHECK_REPLACE": "Suggest replace( ) function over REPLACE statement",
      "CHECK_DESCRIBE": "Suggest describe_by_data( ) over DESCRIBE FIELD"
    },
    "seo": {
      "description": "Prefer Built-in String Functions over SEARCH/SHIFT - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-str-func",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-calc-op",
    "title": "Prefer Calculation Assignment Operators (+=, -=, *=)",
    "rationale": "Assignments such as lv_total = lv_total + 1 repeat the target variable and make the update harder to scan. Compound operators +=, -=, and *= express the change directly and avoid duplicating the left-hand side. Use them for simple arithmetic updates where the target is both source and result.",
    "className": "ZCL_SKYLINT_PREF_CALC_OP",
    "pseudoComment": "PREF_CALC_OP",
    "category": "clean-abap",
    "example": {
      "bad": "lv_stock = lv_stock - 1.\nlv_price = lv_price * 1.19.",
      "good": "lv_stock -= 1.\nlv_price *= 1.19."
    },
    "seo": {
      "description": "Prefer Calculation Assignment Operators (+=, -=, *=) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-calc-op",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-early-ret",
    "title": "Prefer Early Return to Reduce Nesting (Guard Clauses)",
    "rationale": "Wrapping the whole method body in IF is_valid( ) creates unnecessary nesting and pushes the happy path to the right. Guard clauses reject invalid input at the top and leave the main logic flat and easy to read. Return early for preconditions and error cases instead of indenting the successful path.",
    "className": "ZCL_SKYLINT_PREF_EARLY_RET",
    "pseudoComment": "PREF_GUARD_METHOD",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD process_order.\n  IF is_valid( ).\n    execute_order( ).\n    log_order( ).\n  ENDIF.\nENDMETHOD.",
      "good": "METHOD process_order.\n  IF NOT is_valid( ).\n    RETURN.\n  ENDIF.\n  execute_order( ).\n  log_order( ).\nENDMETHOD."
    },
    "parameters": {
      "CHECK_METHOD_RETURN": "Suggest early RETURN guard clause for top-level method validation IFs",
      "CHECK_LOOP_CONTINUE": "Suggest early CONTINUE guard clause for loop item validation IFs"
    },
    "seo": {
      "description": "Prefer Early Return to Reduce Nesting (Guard Clauses) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-early-ret",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-unused-vars",
    "title": "Eliminate Unused Local Variables and Symbols",
    "rationale": "An unused variable or field symbol adds noise and suggests incomplete refactoring or a missing assignment. It keeps dead objects alive longer than necessary and makes reviews harder. Remove the declaration, or mark it with ##NEEDED when an external contract requires it.",
    "className": "ZCL_SKYLINT_NO_UNUSED_VARS",
    "pseudoComment": "NO_UNUSED_VARS",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_message TYPE string.\nprocess_order( ).",
      "good": "DATA lv_message TYPE string.\nlv_message = |Order { lv_id }|.\nlog_message( lv_message )."
    },
    "seo": {
      "description": "Eliminate Unused Local Variables and Symbols - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-unused-vars",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-param-escape",
    "title": "Avoid Obsolete ! Escape Prefix in Parameter Names",
    "rationale": "The ! escape prefix is legacy syntax used to force a parameter name to be treated literally. It adds noise to signatures and is unnecessary in modern ABAP, where parameter names are unambiguous. Remove the ! and use a clear parameter name instead.",
    "className": "ZCL_SKYLINT_NO_PARAM_ESCAPE",
    "pseudoComment": "NO_PARAM_ESCAPE",
    "category": "anti-patterns",
    "example": {
      "bad": "METHODS process\n  IMPORTING !iv_data TYPE string.",
      "good": "METHODS process\n  IMPORTING iv_data TYPE string."
    },
    "seo": {
      "description": "Avoid Obsolete ! Escape Prefix in Parameter Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-param-escape",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-case",
    "title": "Prefer CASE over Multiple IF / ELSEIF on the Same Variable",
    "rationale": "A chain of ELSEIF statements that compares the same variable to different values is harder to scan than a CASE statement. CASE groups all alternatives under one subject and makes a missing OTHERS branch visible. Use CASE for multi-value dispatch on a single expression.",
    "className": "ZCL_SKYLINT_PREF_CASE",
    "pseudoComment": "PREF_CASE",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_payment_method = 'CARD'.\n  process_card( ).\nELSEIF lv_payment_method = 'CASH'.\n  process_cash( ).\nELSEIF lv_payment_method = 'TRANSFER'.\n  process_transfer( ).\nENDIF.",
      "good": "CASE lv_payment_method.\n  WHEN 'CARD'.\n    process_card( ).\n  WHEN 'CASH'.\n    process_cash( ).\n  WHEN 'TRANSFER'.\n    process_transfer( ).\nENDCASE."
    },
    "parameters": {
      "MIN_BRANCHES": "Minimum number of ELSEIF branches on the same variable before suggesting CASE (default: 2)"
    },
    "seo": {
      "description": "Prefer CASE over Multiple IF / ELSEIF on the Same Variable - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-case",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-inline-len",
    "title": "Avoid Obsolete Inline Length Specifications (var(len))",
    "rationale": "The legacy lv_name(10) syntax mixes the identifier and its length and is easy to misread as a substring or function call. Modern ABAP writes the type and length as separate, explicit tokens. Use TYPE c LENGTH n or a named type so the declaration is unambiguous.",
    "className": "ZCL_SKYLINT_NO_INLINE_LEN",
    "pseudoComment": "NO_INLINE_LEN",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_country(2) TYPE c.",
      "good": "DATA lv_country TYPE c LENGTH 2."
    },
    "seo": {
      "description": "Avoid Obsolete Inline Length Specifications (var(len)) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-inline-len",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-one-stmt",
    "title": "Limit One Statement per Source Code Line (No Inline Colon Chains)",
    "rationale": "Placing multiple statements on a single line (either via semicolons, colons, or simple chaining like `a = 1. b = 2.`) compromises readability, impairs debugger single-stepping, and destroys Git line-by-line diff precision. When a runtime error occurs, the debugger stops on the line without clarifying which of the statements failed.\n\n**Clean ABAP Guideline:** Write exactly one ABAP statement per source code line.",
    "className": "ZCL_SKYLINT_MAX_ONE_STMT",
    "pseudoComment": "MAX_ONE_STMT",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: Multiple statements on one line\nlv_status = 'OPEN'. lv_count = 0. CLEAR ls_header.",
      "good": "\" Clean ABAP: Dedicated line for each statement\nlv_status = 'OPEN'.\nlv_count = 0.\nCLEAR ls_header."
    },
    "seo": {
      "description": "Improve code readability and Git diff clarity in ABAP by requiring exactly one statement per source line.",
      "keywords": [
        "One statement per line ABAP",
        "Colon chaining Clean ABAP",
        "Debugger Line Stepping SAP",
        "Clean Code Formatting"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: One Statement per Line",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#one-statement-per-line"
      }
    ]
  },
  {
    "ruleId": "no-dash-in-form",
    "title": "Avoid Obsolete Dash (-) in Form Names",
    "rationale": "A hyphen inside a form name is legacy ABAP and is easily confused with the component selector for structures. Use underscores in form names and reserve hyphens for component access.",
    "className": "ZCL_SKYLINT_NO_DASH_IN_FORM",
    "pseudoComment": "NO_DASH_IN_FORM",
    "category": "anti-patterns",
    "example": {
      "bad": "FORM check-auth.\nENDFORM.",
      "good": "FORM check_auth.\nENDFORM."
    },
    "seo": {
      "description": "Avoid Obsolete Dash (-) in Form Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-dash-in-form",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-inline",
    "title": "Prefer Modern Inline Declarations in ABAP 7.40+",
    "rationale": "Declaring a variable at the top and assigning it in the very next statement separates the declaration from its first use. Inline DATA( ) keeps the variable close to where it is needed and shortens its lifetime in the reader mind. Use inline declarations when the type is obvious from the initial value.",
    "className": "ZCL_SKYLINT_PREF_INLINE",
    "pseudoComment": "PREF_INLINE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_name TYPE string.\nlv_name = |Order { lv_id }|.",
      "good": "DATA(lv_name) = |Order { lv_id }|."
    },
    "seo": {
      "description": "Prefer Modern Inline Declarations in ABAP 7.40+ - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-inline",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-final-data",
    "title": "Prefer FINAL( ) over DATA( ) when the variable is never written again",
    "rationale": "An inline variable that is assigned once and never changed should be declared FINAL so the compiler enforces immutability. This prevents accidental later writes and documents that the value is a constant for the rest of the method. Use FINAL( ) for single-assignment locals.",
    "className": "ZCL_SKYLINT_PREF_FINAL_DATA",
    "pseudoComment": "PREF_FINAL_DATA",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_count) = lines( lt_items ).\nprocess( lv_count ).",
      "good": "FINAL(lv_count) = lines( lt_items ).\nprocess( lv_count )."
    },
    "seo": {
      "description": "Prefer FINAL( ) over DATA( ) when the variable is never written again - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-final-data",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-friends",
    "title": "Avoid FRIENDS in class definitions",
    "rationale": "FRIENDS exposes private and protected members to another class and creates a hidden bidirectional dependency. It defeats encapsulation and makes both classes harder to change independently. Expose a public method or interface instead of granting friendship.",
    "className": "ZCL_SKYLINT_NO_FRIENDS",
    "pseudoComment": "NO_FRIENDS",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS lcl_service DEFINITION PUBLIC FINAL FRIENDS lcl_helper CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS.",
      "good": "CLASS lcl_service DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS."
    },
    "seo": {
      "description": "Avoid FRIENDS in class definitions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-friends",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-msg-cls",
    "title": "Use a message class (SE91) instead of inline message text",
    "rationale": "Inline message texts are not translatable through SE91 and are scattered across the codebase. A message class centralizes text, numbering, and translation for all consumers. Raise messages with MESSAGE e001(zmsg) or a class-based exception that references the message text.",
    "className": "ZCL_SKYLINT_PREF_MSG_CLS",
    "pseudoComment": "PREF_MSG_CLS",
    "category": "clean-abap",
    "example": {
      "bad": "MESSAGE 'Something went wrong' TYPE 'E'.",
      "good": "MESSAGE e001(zmsg)."
    },
    "seo": {
      "description": "Use a message class (SE91) instead of inline message text - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-msg-cls",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-exc-overlap",
    "title": "Classic EXCEPTIONS must not map two errors to the same number",
    "rationale": "When two classic exceptions map to the same sy-subrc number, the caller cannot tell which failure occurred. This makes error handling guesswork and can hide the real cause. Assign distinct numbers and reserve OTHERS for unexpected failures.",
    "className": "ZCL_SKYLINT_NO_EXC_OVERLAP",
    "pseudoComment": "NO_EXC_OVERLAP",
    "category": "anti-patterns",
    "example": {
      "bad": "CALL FUNCTION 'Z_PROCESS_ORDER'\n  EXCEPTIONS\n    system_failure        = 1 MESSAGE lv_message\n    communication_failure = 1 MESSAGE lv_message\n    OTHERS                = 1.",
      "good": "CALL FUNCTION 'Z_PROCESS_ORDER'\n  EXCEPTIONS\n    system_failure        = 1 MESSAGE lv_message\n    communication_failure = 2 MESSAGE lv_message\n    OTHERS                = 3."
    },
    "seo": {
      "description": "Classic EXCEPTIONS must not map two errors to the same number - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-exc-overlap",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-rfc-err",
    "title": "Handle System and Communication Failures in Remote Function Calls (RFC)",
    "rationale": "When invoking remote SAP systems via `CALL FUNCTION ... DESTINATION`, network timeouts, gateway unreachability, target kernel crashes, and authorization rejections trigger classic exceptions `COMMUNICATION_FAILURE` and `SYSTEM_FAILURE`. Omitting these exception handlers causes the local caller to crash with an unhandled short dump (`CALL_FUNCTION_NOT_FOUND` or `RFC_COMMUNICATION_ERROR`).\n\n**Reliability Standard:** Always catch and log both `COMMUNICATION_FAILURE` and `SYSTEM_FAILURE` with `MESSAGE lv_msg` when calling remote destinations.",
    "className": "ZCL_SKYLINT_NO_RFC_ERR",
    "pseudoComment": "NO_RFC_ERR",
    "category": "security",
    "example": {
      "bad": "\" Fragile: Network glitch crashes the entire batch job with short dump\nCALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'\n  DESTINATION lv_rfcdest\n  EXPORTING\n    order_header_in = ls_header.",
      "good": "\" Resilient: Catches network and remote kernel failures gracefully\nCALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'\n  DESTINATION lv_rfcdest\n  EXPORTING\n    order_header_in       = ls_header\n  EXCEPTIONS\n    communication_failure = 1 MESSAGE lv_comm_error\n    system_failure        = 2 MESSAGE lv_sys_error\n    OTHERS                = 3.\n\nIF sy-subrc <> 0.\n  mo_logger->error( |Remote RFC failed: { lv_comm_error } { lv_sys_error }| ).\n  RAISE EXCEPTION NEW zcx_rfc_connection_failed( ).\nENDIF."
    },
    "seo": {
      "description": "Prevent short dumps during remote SAP integration by handling COMMUNICATION_FAILURE and SYSTEM_FAILURE in RFC calls.",
      "keywords": [
        "RFC Exception Handling ABAP",
        "COMMUNICATION_FAILURE SAP",
        "SYSTEM_FAILURE RFC",
        "Resilient SAP Integration"
      ]
    },
    "references": [
      {
        "title": "SAP Help: Reliable RFC Invocations",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "no-many-parens",
    "title": "Remove redundant parentheses",
    "rationale": "Parentheses that wrap an entire condition or arithmetic expression do not change evaluation order but add visual noise. They often remain after refactoring and make expressions look more complex than they are. Remove redundant outer parentheses and keep only those needed for precedence.",
    "className": "ZCL_SKYLINT_NO_MANY_PARENS",
    "pseudoComment": "NO_MANY_PARENS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF ( lv_status = 'A' ).\n  process_a( ).\nENDIF.",
      "good": "IF lv_status = 'A'.\n  process_a( ).\nENDIF."
    },
    "seo": {
      "description": "Remove redundant parentheses - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-many-parens",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-pass-by-ref",
    "title": "Prefer Pass-by-Reference for Internal Tables in Method Signatures",
    "rationale": "Declaring method parameters with `VALUE(it_table)` forces the ABAP runtime to perform an immediate deep copy of the entire table into a new memory allocation upon invocation. If an internal table containing thousands of rows is passed across multiple layers, memory consumption multiplies rapidly and garbage collection pressure causes latency spikes.\n\n**Best Practice:** Pass internal tables by reference (`it_table TYPE ...` without the `VALUE` keyword). In ABAP, parameters are passed by reference by default, which passes only a pointer ($O(1)$ cost).",
    "className": "ZCL_SKYLINT_PREF_PASS_BY_REF",
    "pseudoComment": "PREF_PASS_BY_REF",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Deep-copies the entire table buffer on every method invocation\nMETHODS calculate_totals\n  IMPORTING\n    VALUE(it_items) TYPE ty_item_table.",
      "good": "\" Clean ABAP: Zero-copy pointer reference passed instantly\nMETHODS calculate_totals\n  IMPORTING\n    it_items TYPE ty_item_table."
    },
    "seo": {
      "description": "Eliminate deep copy memory overhead in SAP ABAP methods by passing internal tables by reference instead of by value.",
      "keywords": [
        "Pass by reference ABAP",
        "Pass by value memory copy",
        "Clean ABAP Method Parameters",
        "SAP Memory Management"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Pass by Reference for Performance",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#pass-by-reference-for-performance"
      }
    ]
  },
  {
    "ruleId": "no-mod-std-table",
    "title": "Only Modify Tables Defined in Your Own Package/Component",
    "rationale": "Directly executing `INSERT`, `UPDATE`, `MODIFY`, or `DELETE` statements on SAP standard tables (like `VBAK`, `BKPF`, `EKKO`, `BUT000`) bypasses core SAP document locking, document numbering, consistency validations, and business events. Such direct updates corrupt standard SAP database integrity and void SAP enterprise support agreements.\n\n**Clean Core Standard:** Always use released SAP Business APIs (BAPIs), standard Business Objects, or RAP transactional interfaces to create or update SAP standard data.",
    "className": "ZCL_SKYLINT_NO_MOD_STD_TABLE",
    "pseudoComment": "NO_MOD_STD_TABLE",
    "category": "security",
    "example": {
      "bad": "\" Highly Dangerous: Direct modification of standard SAP Financials header table\nUPDATE bkpf SET bstat = 'V' WHERE belnr = @lv_doc_num.",
      "good": "\" Clean Core: Modification via official released BAPI / RAP interface\nCALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'\n  EXPORTING\n    documentheader = ls_header\n  TABLES\n    accountgl      = lt_gl\n    return         = lt_return."
    },
    "seo": {
      "description": "Protect SAP database integrity and preserve Clean Core support by updating standard tables via official BAPIs and RAP interfaces.",
      "keywords": [
        "Modify SAP standard tables",
        "Clean Core ABAP",
        "Direct Table Mutation Integrity",
        "SAP S/4HANA Support Guidelines"
      ]
    },
    "parameters": {
      "OWN_TABLES": "Regex pattern matching custom namespace tables permitted for direct mutation (default: ^[yz/])",
      "REPORT_DYNAMIC": "Report dynamic database statements targeting unverified table variables"
    },
    "references": [
      {
        "title": "Clean Core Extensibility Guide",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "no-dynamic-stmt",
    "title": "Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)",
    "rationale": "Dynamic ABAP statements (like dynamic SQL `SELECT (lt_fields) FROM (lv_table) WHERE (lv_cond)`, dynamic method calls `CALL METHOD (lv_class)=>(lv_meth)`, or dynamic assignments `ASSIGN (lv_var) TO <fs>`) bypass compile-time syntax checks, cannot be analyzed by static ATC security tools, and introduce severe **SQL Injection (CWE-89)** risks.\n\n**Security Standard:** Write static, strongly-typed OpenSQL and OOP code wherever possible. When dynamic SQL is unavoidable (e.g. in generic analytics engines), escape input variables thoroughly using `cl_abap_dyn_prg`.",
    "className": "ZCL_SKYLINT_NO_DYNAMIC_STMT",
    "pseudoComment": "NO_DYNAMIC_STMT",
    "category": "security",
    "example": {
      "bad": "\" Critical Security Vulnerability: SQL Injection via unsanitized WHERE string\nDATA(lv_where) = |CUSTOMER_ID = '{ iv_user_input }'|.\nSELECT * FROM zcustomers WHERE (lv_where) INTO TABLE @DATA(lt_cust).",
      "good": "\" Secure: Static typed OpenSQL with host variable binding\nSELECT customer_id, customer_name\n  FROM zcustomers\n  WHERE customer_id = @iv_user_input\n  INTO TABLE @DATA(lt_cust)."
    },
    "seo": {
      "description": "Prevent SQL injection and runtime type mismatches in SAP ABAP by avoiding unverified dynamic programming constructs.",
      "keywords": [
        "CWE-89 SQL Injection ABAP",
        "Dynamic SQL Security SAP",
        "cl_abap_dyn_prg",
        "Clean ABAP Static Typing"
      ]
    },
    "parameters": {
      "CHECK_DYNAMIC_SQL": "Detect dynamic table names, column projections, and WHERE clauses in OpenSQL",
      "IGNORE_RAP_QUERY_PROVIDER": "Allow dynamic queries inside custom RAP query provider implementations (IF_RAP_QUERY_PROVIDER)"
    },
    "references": [
      {
        "title": "CWE-89: SQL Injection",
        "url": "https://cwe.mitre.org/data/definitions/89.html"
      },
      {
        "title": "Clean ABAP: Prefer Static Over Dynamic",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-pub-ctor",
    "title": "Declare Constructor in PUBLIC SECTION",
    "rationale": "Even when a class uses CREATE PRIVATE or CREATE PROTECTED, its instance constructor must be declared in the public section so the runtime and frameworks can instantiate it. Declaring the constructor privately makes reflection and framework integration harder. Keep the constructor in PUBLIC and control creation through the CREATE addition.",
    "className": "ZCL_SKYLINT_PREF_PUB_CTOR",
    "pseudoComment": "PREF_PUB_CTOR",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_order_service DEFINITION PUBLIC CREATE PRIVATE.\n  PRIVATE SECTION.\n    METHODS constructor.\nENDCLASS.",
      "good": "CLASS zcl_order_service DEFINITION PUBLIC CREATE PRIVATE.\n  PUBLIC SECTION.\n    METHODS constructor.\nENDCLASS."
    },
    "seo": {
      "description": "Declare Constructor in PUBLIC SECTION - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-pub-ctor",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-declarations",
    "title": "Routine Declaration Hygiene (Top Placement & Order)",
    "rationale": "Declarations placed in the middle of executable code interrupt reading flow and conceal variable scope. Moreover, arbitrary ordering can place a DATA declaration before the TYPE it references. Maintain clean routine hygiene by placing all local declarations at the beginning of the routine in strict hierarchical order: TYPES before CONSTANTS before DATA before FIELD-SYMBOLS.",
    "className": "ZCL_SKYLINT_PREF_DECLARATIONS",
    "pseudoComment": "DEF_TOP",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD process_order.\n  lv_total = 100.\n  DATA lv_tax TYPE i.\n  FIELD-SYMBOLS <fs> TYPE i.\n  TYPES ty_status TYPE c LENGTH 1.\nENDMETHOD.",
      "good": "METHOD process_order.\n  TYPES ty_status TYPE c LENGTH 1.\n  CONSTANTS lc_rate TYPE i VALUE 18.\n  DATA lv_tax TYPE i.\n  FIELD-SYMBOLS <fs> TYPE i.\n  lv_total = 100.\nENDMETHOD."
    },
    "parameters": {
      "CHECK_DEF_TOP": "Enforce all local declarations (DATA, TYPES, CONSTANTS) at top of method body",
      "CHECK_DECL_ORDER": "Enforce declaration order: TYPES first, then CONSTANTS, then DATA"
    },
    "seo": {
      "description": "Routine Declaration Hygiene (Top Placement & Order) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-declarations",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-unnec-return",
    "title": "Omit Unnecessary RETURN Statement",
    "rationale": "A RETURN as the final statement of a method, form, or function changes nothing because the routine ends at ENDMETHOD, ENDFORM, or ENDFUNCTION anyway. It adds a line that implies a special exit and can obscure the real control flow. Remove trailing RETURN statements and keep early returns only where they are meaningful.",
    "className": "ZCL_SKYLINT_NO_UNNEC_RETURN",
    "pseudoComment": "NO_UNNEC_RETURN",
    "category": "anti-patterns",
    "example": {
      "bad": "METHOD get_total.\n  rv_total = lv_subtotal + lv_tax.\n  RETURN.\nENDMETHOD.",
      "good": "METHOD get_total.\n  rv_total = lv_subtotal + lv_tax.\nENDMETHOD."
    },
    "seo": {
      "description": "Omit Unnecessary RETURN Statement - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-unnec-return",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-mix-returning",
    "title": "Do Not Mix RETURNING with EXPORTING or CHANGING",
    "rationale": "A method that returns a value and also exports or changes parameters has a mixed contract: callers must capture the result and provide extra targets. This complicates expression use and suggests the method does more than one thing. Split it into a functional query and a separate command.",
    "className": "ZCL_SKYLINT_NO_MIX_RETURNING",
    "pseudoComment": "NO_MIX_RETURNING",
    "category": "anti-patterns",
    "example": {
      "bad": "METHODS get_data\n  EXPORTING ev_count TYPE i\n  RETURNING VALUE(rv_result) TYPE string.",
      "good": "METHODS get_data\n  RETURNING VALUE(rv_result) TYPE string."
    },
    "seo": {
      "description": "Do Not Mix RETURNING with EXPORTING or CHANGING - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-mix-returning",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-overw-builtin",
    "title": "Avoid Method Names That Overwrite Built-in Functions",
    "rationale": "Naming a method LINES, STRLEN, or XSDBOOL shadows a well-known built-in and makes the call site ambiguous. Readers cannot tell whether the built-in or the method is intended. Use a descriptive verb that does not collide with language functions.",
    "className": "ZCL_SKYLINT_NO_OVERW_BUILTIN",
    "pseudoComment": "NO_OVERW_BUILTIN",
    "category": "anti-patterns",
    "example": {
      "bad": "METHODS matches\n  RETURNING VALUE(rv_result) TYPE abap_bool.",
      "good": "METHODS matches_pattern\n  RETURNING VALUE(rv_result) TYPE abap_bool."
    },
    "seo": {
      "description": "Avoid Method Names That Overwrite Built-in Functions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-overw-builtin",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-is-initial",
    "title": "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons",
    "rationale": "Comparing lines( ) to zero or a string to an empty literal asks an indirect question. IS INITIAL states emptiness directly and works for tables, strings, structures, and elementary values. It also avoids counting overhead and literal edge cases.",
    "className": "ZCL_SKYLINT_PREF_IS_INITIAL",
    "pseudoComment": "PREF_IS_INITIAL",
    "category": "clean-abap",
    "example": {
      "bad": "IF lines( lt_items ) > 0.\n  process( ).\nENDIF.",
      "good": "IF lt_items IS NOT INITIAL.\n  process( ).\nENDIF."
    },
    "seo": {
      "description": "Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-is-initial",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-ignored-return",
    "title": "Do Not Ignore Return Value of Functional Methods",
    "rationale": "A functional method is called for its RETURNING value, so discarding that value usually means the call is pointless or the method hides side effects. If the method intentionally has side effects, it should not return a value. Assign or consume the result, or refactor the method into a command.",
    "className": "ZCL_SKYLINT_NO_IGNORED_RETURN",
    "pseudoComment": "NO_IGNORED_RETURN",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_calculator->get_total( ).",
      "good": "lv_total = lo_calculator->get_total( )."
    },
    "seo": {
      "description": "Do Not Ignore Return Value of Functional Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-ignored-return",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-downcast",
    "title": "Modernize Downcasting (CAST #( ) Expression & Inlining)",
    "rationale": "The legacy ?= and MOVE ?TO operators are obsolete downcast statements that cannot be chained or used in modern expressions. The modern CAST #( ) expression creates cleanly typed references that can be used directly in chained calls or assignments. Furthermore, single-use downcast helper variables should be inlined into the consuming expression to prevent clutter and unnecessary temporary state.",
    "className": "ZCL_SKYLINT_PREF_DOWNCAST",
    "pseudoComment": "PREF_CAST",
    "category": "clean-abap",
    "example": {
      "bad": "lo_child ?= lo_parent.\nDATA(lo_node) = CAST lcl_node( io_obj ).\nresult = lo_node->get_tokens( ).",
      "good": "lo_child = CAST #( lo_parent ).\nresult = CAST lcl_node( io_obj )->get_tokens( )."
    },
    "parameters": {
      "CHECK_CAST_SYNTAX": "Suggest modern ?= over obsolete downcast syntax",
      "CHECK_INLINE_CAST": "Suggest CAST #( ... ) constructor expression over intermediate temporary reference"
    },
    "seo": {
      "description": "Modernize Downcasting (CAST #( ) Expression & Inlining) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-downcast",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-mod-loop-tab",
    "title": "Do Not Mutate the Internal Table Currently Being Looped (Iterator Invalidation)",
    "rationale": "Modifying, deleting, inserting, or sorting the internal table currently being traversed inside a `LOOP AT itab` block invalidates the loop iterator. Sorting during a loop breaks binary search indexes and causes infinite loops or skipped rows. Deleting rows alters `sy-tabix` dynamically, leading to silent data corruption.\n\n**Best Practice:** To update row values, use field-symbols (`ASSIGNING FIELD-SYMBOL(<row>)`) which mutates memory directly in-place without altering table layout. For filtering or structural reshaping, use modern constructor expressions (`FILTER #( ... )`) or build a new secondary table.",
    "className": "ZCL_SKYLINT_NO_MOD_LOOP_TAB",
    "pseudoComment": "NO_MOD_LOOP_TAB",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Modifying and sorting inside loop invalidates table indexes\nLOOP AT lt_items INTO ls_item.\n  ls_item-price = ls_item-price * 1.1.\n  MODIFY lt_items FROM ls_item.\n  SORT lt_items BY item_id.\nENDLOOP.",
      "good": "\" Clean ABAP: Direct in-place mutation via field symbol without table re-indexing\nLOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).\n  <ls_item>-price = <ls_item>-price * 1.1.\nENDLOOP."
    },
    "seo": {
      "description": "Prevent internal table iterator corruption in ABAP by avoiding APPEND, INSERT, DELETE, or SORT on tables currently being traversed.",
      "keywords": [
        "MODIFY in LOOP ABAP",
        "SORT in LOOP Bug",
        "Iterator Invalidation SAP",
        "Clean ABAP Loop Integrity"
      ]
    },
    "parameters": {
      "CHECK_APPEND": "Detect APPEND statements targeting the loop table",
      "CHECK_INSERT": "Detect INSERT statements targeting the loop table",
      "CHECK_MODIFY": "Detect MODIFY statements targeting the loop table",
      "CHECK_DELETE": "Detect DELETE statements targeting the loop table",
      "CHECK_CLEAR": "Detect CLEAR or FREE statements targeting the loop table",
      "CHECK_SORT": "Detect SORT statements targeting the loop table",
      "CHECK_SORT_ANY": "Detect SORT statements on any table inside a loop",
      "CHECK_COLLECT": "Detect COLLECT statements targeting the loop table"
    },
    "references": [
      {
        "title": "Clean ABAP: Do Not Change the Table You Are Looping",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#do-not-change-the-table-you-are-looping"
      }
    ]
  },
  {
    "ruleId": "no-hardcoded-env",
    "title": "Avoid Hardcoding System & Tenant Environment Checks (sy-sysid, sy-mandt)",
    "rationale": "Branching business logic on hardcoded SAP System IDs (`sy-sysid = 'PRD'`), client numbers (`sy-mandt = '100'`), or server hostnames makes ABAP code fragile, untestable in sandbox environments, and incompatible with cloud transports. In multi-tenant ABAP Cloud systems (BTP), hardcoding client numbers breaks tenant isolation and violates SAP Clean Core guidelines.\n\n**Best Practice:** Encapsulate environment configurations in feature toggles, custom configuration tables, or standard SAP BPF/BTP environment services.",
    "className": "ZCL_SKYLINT_NO_HARDCODED_ENV",
    "pseudoComment": "NO_HARDCODED_ENV",
    "category": "security",
    "example": {
      "bad": "\" Anti-pattern: Hardcoded environment and client checks\nIF sy-sysid = 'PRD' AND sy-mandt = '100'.\n  send_live_bank_order( is_payment ).\nELSEIF sy-sysid = 'DEV'.\n  mock_bank_response( ).\nENDIF.",
      "good": "\" Clean ABAP: Feature toggle or environment service configuration\nIF mo_env_service->is_live_payment_active( ) = abap_true.\n  send_live_bank_order( is_payment ).\nELSE.\n  mock_bank_response( ).\nENDIF."
    },
    "seo": {
      "description": "Eliminate hardcoded sy-sysid and sy-mandt checks in ABAP. Ensure Clean Core cloud readiness and multi-tenant isolation.",
      "keywords": [
        "Hardcoded sy-sysid ABAP",
        "Tenant Isolation BTP",
        "sy-mandt Clean Core",
        "SAP S/4HANA Cloud Readiness"
      ]
    },
    "parameters": {
      "CHECK_SYSID": "Detect hardcoded checks against sy-sysid",
      "CHECK_MANDT": "Detect hardcoded client number comparisons against sy-mandt",
      "CHECK_HOST": "Detect hardcoded server hostnames (sy-host)",
      "CHECK_DBSYS": "Detect database system checks (sy-dbsys)",
      "CHECK_OPSYS": "Detect operating system checks (sy-opsys)",
      "CHECK_UNAME": "Detect hardcoded user names (sy-uname) in conditional branches",
      "ONLY_CONDITIONAL": "Only flag occurrences when used inside conditional comparisons (IF, CASE)"
    },
    "references": [
      {
        "title": "SAP Clean Core Strategy Guide",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "max-line-len",
    "title": "Limit Source Code Line Length (Avoid Horizontal Scrolling)",
    "rationale": "Excessively long code lines (beyond 120 characters) force developers to scroll horizontally during code reviews and side-by-side Git diff inspections in Eclipse ADT and web repositories. Long lines also obscure trailing conditions and operators.\n\n**Clean ABAP Guideline:** Wrap statements intelligently across multiple lines before reaching 120 characters, indenting subsequent continuation lines under the parent operator or assignment.",
    "className": "ZCL_SKYLINT_MAX_LINE_LEN",
    "pseudoComment": "MAX_LINE_LEN",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: 160+ characters stretching past standard monitor width\nDATA(lo_order) = zcl_order_factory=>get_instance( )->create_from_request( is_request = ls_req iv_validate = abap_true iv_commit = abap_false ).",
      "good": "\" Clean ABAP: Formatted across logical continuation lines under 120 characters\nDATA(lo_order) = zcl_order_factory=>get_instance( )->create_from_request(\n  is_request  = ls_req\n  iv_validate = abap_true\n  iv_commit   = abap_false )."
    },
    "seo": {
      "description": "Ensure clean side-by-side Git diffs in SAP ABAP by enforcing a 120-character line length limit.",
      "keywords": [
        "ABAP Line length limit",
        "Horizontal scrolling code review",
        "Clean ABAP Formatting",
        "Eclipse ADT Formatting Rules"
      ]
    },
    "parameters": {
      "MAX_LENGTH": "Maximum allowed character length per source code line (industry standard: 120)"
    },
    "references": [
      {
        "title": "Clean ABAP: Keep Line Length Reasonable",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "pref-naming-vars",
    "title": "Enforce Local Variable and Field-Symbol Naming Conventions",
    "rationale": "Local variables, constants, statics, and field-symbols must follow distinct naming conventions (such as `lv_*`, `lc_*`, `sv_*`, `<ls_*>`, `<lv_*>`) to ensure clear scope boundaries, prevent unintended variable shadowing, and eliminate ambiguity during code reviews and debugging.",
    "className": "ZCL_SKYLINT_PREF_NAMING_VARS",
    "pseudoComment": "PREF_NAMING_VARS",
    "category": "clean-abap",
    "example": {
      "bad": "DATA customer_name TYPE string.\nFIELD-SYMBOLS <item> TYPE any.",
      "good": "DATA lv_customer_name TYPE string.\nFIELD-SYMBOLS <ls_item> TYPE any."
    },
    "parameters": {
      "LOCAL_DATA": "Regex pattern for local variables (default: ^L._.+$)",
      "LOCAL_CONST": "Regex pattern for local constants (default: ^LC_.+$)",
      "LOCAL_FS": "Regex pattern for field-symbols (default: ^<L._.+>$)",
      "LOCAL_STATICS": "Regex pattern for local static variables (default: ^S._.+$)"
    },
    "seo": {
      "description": "Enforce Local Variable and Field-Symbol Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-naming-vars",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-name-members",
    "title": "Enforce Class Attribute and Method Parameter Naming Conventions",
    "rationale": "Member variables and method signatures communicate the contract of object-oriented components. Enforcing prefixes (mv_* for instance attributes, gv_* for static attributes, iv_* for importing, ev_* for exporting, cv_* for changing, and rv_* for returning parameters) clarifies usage semantics across callers.",
    "className": "ZCL_SKYLINT_PREF_NAME_MEMBERS",
    "pseudoComment": "PREF_NAME_MEMBERS",
    "category": "clean-abap",
    "example": {
      "bad": "METHODS execute\n  IMPORTING data TYPE i\n  RETURNING VALUE(result) TYPE i.",
      "good": "METHODS execute\n  IMPORTING iv_data TYPE i\n  RETURNING VALUE(rv_result) TYPE i."
    },
    "parameters": {
      "ATTR_IGN_EXC": "Ignore exception class attributes (cx_*)",
      "ATTR_IGN_LOCAL": "Ignore attributes in local test classes",
      "ATTR_IGN_INTF": "Ignore interface component naming",
      "ATTR_STATICS": "Regex pattern for static class attributes (default: ^G._.+$)",
      "ATTR_INSTANCE": "Regex pattern for instance class attributes (default: ^M._.+$)",
      "ATTR_CONSTANTS": "Regex pattern for class constants (default: ^C._.+$)",
      "PARAM_IGN_EXC": "Ignore parameter naming in exception classes",
      "PARAM_IMPORTING": "Regex pattern for importing parameters (default: ^I._.+$)",
      "PARAM_RETURNING": "Regex pattern for returning parameters (default: ^R._.+$)",
      "PARAM_CHANGING": "Regex pattern for changing parameters (default: ^C._.+$)",
      "PARAM_EXPORTING": "Regex pattern for exporting parameters (default: ^E._.+$)",
      "SSCR_PARAM": "Regex pattern for selection screen parameters (default: ^P_.+$)",
      "SSCR_SELOPT": "Regex pattern for select-options (default: ^S_.+$)"
    },
    "seo": {
      "description": "Enforce Class Attribute and Method Parameter Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-name-members",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-name-objects",
    "title": "Enforce Class, Interface, Type and Object Naming Conventions",
    "rationale": "Object-oriented entities and global artifacts must maintain standardized prefixes (such as zcl_ / lcl_ for classes, zif_ / lif_ for interfaces, ty_ for type definitions, and on_* for event handlers). This standard maintains harmony across packages, enhances IDE searchability, and reinforces Clean ABAP architecture.",
    "className": "ZCL_SKYLINT_PREF_NAME_OBJECTS",
    "pseudoComment": "PREF_NAME_OBJECTS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS my_service DEFINITION.\nINTERFACE my_contract.\nTYPES item_type TYPE string.",
      "good": "CLASS lcl_my_service DEFINITION.\nINTERFACE lif_my_contract.\nTYPES ty_item TYPE string."
    },
    "parameters": {
      "CLASS_LOCAL": "Regex pattern for local class names (default: ^LC(L|X)_.+$)",
      "CLASS_TEST": "Regex pattern for test class names (default: ^LTCL_.+$)",
      "CLASS_GLOBAL": "Regex pattern for global class names (default: ^ZC(L|X)_.+$)",
      "INTF_LOCAL": "Regex pattern for local interface names (default: ^LIF_.+$)",
      "INTF_GLOBAL": "Regex pattern for global interface names (default: ^ZIF_.+$)",
      "TYPES_PATTERN": "Regex pattern for type definitions (default: ^TY_.+$)",
      "MACRO_PATTERN": "Regex pattern for macros (default: ^_.+$)",
      "FORM_PATTERN": "Regex pattern for form routines (default: ^F_.+$)",
      "FUNCTION_PATTERN": "Regex pattern for function modules (default: ^Z.*$)",
      "EVENT_NAME": "Regex pattern for event names",
      "EVENT_HANDLER": "Regex pattern for event handlers (default: ^ON_.+$)",
      "TEST_METHOD": "Regex pattern for test method names (default: ^(TEST|SHOULD)_.+$)",
      "PROG_PATTERN": "Regex pattern for program names (default: ^Z.+$)",
      "FUGR_PATTERN": "Regex pattern for function groups (default: ^Z.+$)"
    },
    "seo": {
      "description": "Enforce Class, Interface, Type and Object Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-name-objects",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-expand-macro",
    "title": "Expand Macro Calls into Explicit Statements",
    "rationale": "Macros expand textually, so the debugger cannot step into them and syntax errors point at the invocation rather than the definition. They are obsolete and unsupported in ABAP Cloud. Replace each macro call with explicit statements or a method.",
    "className": "ZCL_SKYLINT_PREF_EXPAND_MACRO",
    "pseudoComment": "PREF_EXPAND_MACRO",
    "category": "anti-patterns",
    "example": {
      "bad": "DEFINE set_status.\n  lv_status = &1.\nEND-OF-DEFINITION.\nDATA lv_status TYPE string.\nset_status 'A'.",
      "good": "DATA lv_status TYPE string.\nlv_status = 'A'."
    },
    "seo": {
      "description": "Expand Macro Calls into Explicit Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-expand-macro",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-bad-indent",
    "title": "Statement Indentation Must Match Block Nesting",
    "rationale": "Indentation is the fastest visual cue for block nesting, so inconsistent indentation misleads readers about which statements belong together. It also creates noisy diffs when a formatter runs. Indent each block level consistently.",
    "className": "ZCL_SKYLINT_NO_BAD_INDENT",
    "pseudoComment": "NO_BAD_INDENT",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD calculate.\nDATA lv_total TYPE i.\n  LOOP AT lt_items INTO ls_item.\nlv_total = lv_total + ls_item-amount.\n  ENDLOOP.\nENDMETHOD.",
      "good": "METHOD calculate.\n  DATA lv_total TYPE i.\n  LOOP AT lt_items INTO ls_item.\n    lv_total = lv_total + ls_item-amount.\n  ENDLOOP.\nENDMETHOD."
    },
    "parameters": {
      "INDENT_STEP": "Standard indentation step per nested block level (default: 2 spaces)"
    },
    "seo": {
      "description": "Statement Indentation Must Match Block Nesting - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-bad-indent",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-dead-code",
    "title": "Avoid Dead Code with Constant Conditions",
    "rationale": "A condition that is always false, such as 1 = 2 or abap_false, makes the branch impossible to reach. Dead branches hide unfinished logic and can contain declarations that confuse scope analysis. Remove the branch or replace the constant with the real runtime condition.",
    "className": "ZCL_SKYLINT_NO_DEAD_CODE",
    "pseudoComment": "NO_DEAD_CODE",
    "category": "anti-patterns",
    "example": {
      "bad": "IF 1 = 2.\n  process( ).\nENDIF.",
      "good": "IF is_enabled( ).\n  process( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Dead Code with Constant Conditions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-dead-code",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-keyword-name",
    "title": "Avoid Using ABAP Keywords as Identifier Names",
    "rationale": "Using a language keyword such as class, type, or data as an identifier shadows the keyword and forces readers to disambiguate from context. It also complicates searching and can confuse tooling. Prefix identifiers with their role, for example lv_type.",
    "className": "ZCL_SKYLINT_NO_KEYWORD_NAME",
    "pseudoComment": "NO_KEYWORD_NAME",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA interface TYPE string.\nDATA report TYPE i.",
      "good": "DATA lv_interface TYPE string.\nDATA lv_report TYPE i."
    },
    "seo": {
      "description": "Avoid Using ABAP Keywords as Identifier Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-keyword-name",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-join-type",
    "title": "Prefer an Explicit JOIN Type",
    "rationale": "A bare JOIN defaults to INNER JOIN, but the default is invisible at the call site and easy to misread as an outer join. Explicit join types document cardinality and make reviews safer. Always write INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, or CROSS JOIN.",
    "className": "ZCL_SKYLINT_PREF_JOIN_TYPE",
    "pseudoComment": "PREF_JOIN_TYPE",
    "category": "clean-abap",
    "example": {
      "bad": "SELECT mara~matnr, makt~maktx\n  FROM mara JOIN makt ON mara~matnr = makt~matnr\n  INTO TABLE @lt_result.",
      "good": "SELECT mara~matnr, makt~maktx\n  FROM mara INNER JOIN makt ON mara~matnr = makt~matnr\n  INTO TABLE @lt_result."
    },
    "seo": {
      "description": "Prefer an Explicit JOIN Type - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-join-type",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-std-table",
    "title": "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF",
    "rationale": "TYPE TABLE OF implicitly means a standard table, so the reader must know the default to understand access costs. Spelling out STANDARD makes the table kind and its linear search behavior explicit. It also keeps declarations consistent when tables are later changed to sorted or hashed.",
    "className": "ZCL_SKYLINT_PREF_STD_TABLE",
    "pseudoComment": "PREF_STD_TABLE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lt_customers TYPE TABLE OF ty_customer.",
      "good": "DATA lt_customers TYPE STANDARD TABLE OF ty_customer."
    },
    "seo": {
      "description": "Prefer TYPE STANDARD TABLE OF over TYPE TABLE OF - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-std-table",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-is-supplied",
    "title": "Prefer IS SUPPLIED over IS REQUESTED",
    "rationale": "IS REQUESTED is obsolete and only reports whether an output parameter was requested by the caller, not whether an input was actually supplied. IS SUPPLIED works for every parameter direction and states the real condition. Replace IS REQUESTED with IS SUPPLIED.",
    "className": "ZCL_SKYLINT_PREF_IS_SUPPLIED",
    "pseudoComment": "PREF_IS_SUPPLIED",
    "category": "clean-abap",
    "example": {
      "bad": "IF iv_currency IS REQUESTED.\n  convert_amount( iv_currency ).\nENDIF.",
      "good": "IF iv_currency IS SUPPLIED.\n  convert_amount( iv_currency ).\nENDIF."
    },
    "seo": {
      "description": "Prefer IS SUPPLIED over IS REQUESTED - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-is-supplied",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-sy",
    "title": "Prefer the Short System Field Alias SY over SYST",
    "rationale": "SYST and SY address the same system structure, so mixing both aliases makes code look inconsistent and complicates searching. SY is the conventional short form used throughout Clean ABAP. Use sy- consistently for system field access.",
    "className": "ZCL_SKYLINT_PREF_SY",
    "pseudoComment": "PREF_SY",
    "category": "clean-abap",
    "example": {
      "bad": "lv_user = syst-uname.",
      "good": "lv_user = sy-uname."
    },
    "seo": {
      "description": "Prefer the Short System Field Alias SY over SYST - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-sy",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-unfilt-dml",
    "title": "Avoid UPDATE or DELETE Without a WHERE Condition (Catastrophic Data Wipe Prevention)",
    "rationale": "Executing an `UPDATE` or `DELETE` statement targeting a database table without an explicit `WHERE` clause modifies or truncates every single record in the entire table. In production environments, this causes catastrophic data loss, brings business operations to a halt, and requires emergency point-in-time database restoration.\n\n**Safety Standard:** Always provide a restrictive `WHERE` condition on every database DML statement. If a full-table operation is genuinely required (e.g., in staging tables), enforce it through explicit administrative procedures.",
    "className": "ZCL_SKYLINT_NO_UNFILT_DML",
    "pseudoComment": "NO_UNFILT_DML",
    "category": "security",
    "example": {
      "bad": "\" Disaster: Wipes all customer purchase history in the entire system!\nDELETE FROM zorder_items.",
      "good": "\" Safe: Scoped deletion with mandatory WHERE condition\nDELETE FROM zorder_items\n  WHERE order_id = @iv_order_id.\nIF sy-subrc <> 0.\n  \" Handle not found or log\nENDIF."
    },
    "seo": {
      "description": "Prevent catastrophic full-table deletion and modification in SAP ABAP by requiring WHERE clauses on all OpenSQL UPDATE and DELETE statements.",
      "keywords": [
        "Unfiltered UPDATE ABAP",
        "DELETE without WHERE SAP",
        "Catastrophic Data Loss Prevention",
        "OpenSQL Data Integrity"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Safe DML Operations",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "no-concat-loop",
    "title": "Avoid String Concatenation Inside Loops (Quadratic Memory Allocation)",
    "rationale": "Performing string concatenation (`lv_result = lv_result && lv_chunk` or `CONCATENATE`) inside a loop causes **quadratic memory allocation ($O(N^2)$)**. In each iteration, ABAP allocates a new heap memory buffer, copies the entire existing accumulator plus the new chunk, and marks the old buffer for garbage collection. As the iteration count increases, execution time and memory usage skyrocket.\n\n**Best Practice:** Collect string fragments into an internal table of strings (`string_table`) and join them in a single native operation using `concat_lines_of( it_strings, sep )`.",
    "className": "ZCL_SKYLINT_NO_CONCAT_LOOP",
    "pseudoComment": "NO_CONCAT_LOOP",
    "category": "performance",
    "example": {
      "bad": "\" Anti-pattern: Re-allocates and copies full string buffer on every iteration (O(N^2))\nDATA lv_csv TYPE string.\nLOOP AT lt_records INTO ls_record.\n  lv_csv = lv_csv && ls_record-id && ',' && ls_record-name && cl_abap_char_utilities=>newline.\nENDLOOP.",
      "good": "\" Clean ABAP: Collect lines and join in a single lightning-fast operation (O(N))\nDATA lt_lines TYPE string_table.\nLOOP AT lt_records INTO ls_record.\n  INSERT |{ ls_record-id },{ ls_record-name }| INTO TABLE lt_lines.\nENDLOOP.\n\nDATA(lv_csv) = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline )."
    },
    "seo": {
      "description": "Prevent quadratic memory allocation in ABAP string loops by collecting fragments in string tables and using concat_lines_of.",
      "keywords": [
        "String concatenation in loop ABAP",
        "Quadratic Memory Allocation SAP",
        "concat_lines_of Clean ABAP",
        "String Buffer Performance"
      ]
    },
    "references": [
      {
        "title": "Clean ABAP: Avoid String Concatenation in Loops",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      }
    ]
  },
  {
    "ruleId": "no-dup-literals",
    "title": "Avoid Repeating the Same String Literal",
    "rationale": "Repeating the same string literal in several places couples unrelated code to an unnamed value and makes a later change error-prone. Define a constant with a meaningful name and reuse it. The check focuses on fixed string literals that occur at least three times.",
    "className": "ZCL_SKYLINT_NO_DUP_LITERALS",
    "pseudoComment": "NO_DUP_LITERALS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_status = 'ACTIVE'.\n  lv_text = 'ACTIVE'.\nENDIF.",
      "good": "CONSTANTS c_active TYPE string VALUE 'ACTIVE'.\nIF lv_status = c_active.\n  lv_text = c_active.\nENDIF."
    },
    "parameters": {
      "MIN_OCCURRENCES": "Minimum occurrences of identical string literal before reporting (default: 3)",
      "MIN_LENGTH": "Minimum character length of string literal to inspect (default: 3)"
    },
    "seo": {
      "description": "Avoid Repeating the Same String Literal - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-dup-literals",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-filter",
    "title": "Prefer FILTER for a Simple LOOP with IF and APPEND",
    "rationale": "A LOOP that only copies rows matching one condition into another table is a filter expressed as imperative control flow. FILTER builds the result directly and states the intent without a work area. This rule only targets the simple LOOP AT, IF, APPEND pattern; keep loops that contain extra logic, indexes, or multiple statements.",
    "className": "ZCL_SKYLINT_PREF_FILTER",
    "pseudoComment": "PREF_FILTER",
    "category": "clean-abap",
    "example": {
      "bad": "LOOP AT lt_orders INTO ls_order.\n  IF ls_order-status = 'O'.\n    APPEND ls_order TO lt_open.\n  ENDIF.\nENDLOOP.",
      "good": "lt_open = FILTER #( lt_orders USING KEY primary_key WHERE status = 'O' )."
    },
    "seo": {
      "description": "Prefer FILTER for a Simple LOOP with IF and APPEND - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-filter",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-neg-cond",
    "title": "Avoid Negated IF Conditions with ELSE",
    "rationale": "A negated condition with an ELSE branch forces readers to negate the expression mentally before understanding the main path. Invert the condition and swap the branches, so the positive case comes first. This rule ignores ELSEIF chains and IS NOT predicates handled by the dedicated rule.",
    "className": "ZCL_SKYLINT_NO_NEG_COND",
    "pseudoComment": "NO_NEG_COND",
    "category": "clean-abap",
    "example": {
      "bad": "IF NOT lv_is_valid.\n  handle_error( ).\nELSE.\n  process( ).\nENDIF.",
      "good": "IF lv_is_valid.\n  process( ).\nELSE.\n  handle_error( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid Negated IF Conditions with ELSE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-neg-cond",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-bool-expr",
    "title": "Limit Boolean Expression Complexity in Conditional Statements",
    "rationale": "Boolean conditions combining more than 3 to 4 `AND` and `OR` operators in a single `IF` or `WHILE` statement are notoriously prone to precedence bugs. Developers misinterpret operator binding order, and unit tests fail to cover all combinations in the truth table.\n\n**Clean ABAP Guideline:** Extract complex boolean conditions into well-named **boolean helper methods (predicate methods)** like `is_delivery_allowed( )` or `has_valid_credit_limit( )`.",
    "className": "ZCL_SKYLINT_MAX_BOOL_EXPR",
    "pseudoComment": "MAX_BOOL_EXPR",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: Complex multi-term boolean condition\nIF ( is_order-status = 'O' OR is_order-status = 'P' )\n   AND is_order-total_amount > 500\n   AND is_customer_active( is_order-cust_id ) = abap_true\n   AND NOT ( is_order-blocked = abap_true OR is_order-on_hold = abap_true ).",
      "good": "\" Clean ABAP: Self-documenting predicate method call\nIF is_order_ready_for_dispatch( is_order ) = abap_true.\n  dispatch_order( is_order ).\nENDIF."
    },
    "seo": {
      "description": "Simplify complex boolean logic in ABAP IF statements. Extract intricate conditions into named predicate methods.",
      "keywords": [
        "Boolean expression complexity ABAP",
        "Predicate methods Clean ABAP",
        "Operator Precedence SAP",
        "Clean Code Logic"
      ]
    },
    "parameters": {
      "MAX_BOOLEAN_EXPRESSIONS": "Maximum allowed boolean operators (AND, OR, NOT) in a single condition"
    },
    "references": [
      {
        "title": "Clean ABAP: Decompose Complex Conditions",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#decompose-complex-conditions"
      }
    ]
  },
  {
    "ruleId": "no-late-sys-idx",
    "title": "Avoid Late Access to sy-tabix or sy-index Outside Loops",
    "rationale": "System fields sy-tabix and sy-index are global and mutable. Reading them outside their originating LOOP, DO, or WHILE blocks creates fragile temporal coupling that breaks easily when refactoring. Inside loops, capture index into an explicit local variable, or use line_index( ) instead of relying on sy-tabix outside.",
    "className": "ZCL_SKYLINT_NO_LATE_SYS_IDX",
    "pseudoComment": "NO_LATE_SYS_IDX",
    "category": "anti-patterns",
    "example": {
      "bad": "LOOP AT lt_items INTO ls_item.\nENDLOOP.\nlv_last_idx = sy-tabix.",
      "good": "DATA lv_last_idx TYPE i.\nLOOP AT lt_items INTO ls_item.\n  lv_last_idx = sy-tabix.\nENDLOOP."
    },
    "seo": {
      "description": "Avoid Late Access to sy-tabix or sy-index Outside Loops - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-late-sys-idx",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-unhandled-eml",
    "title": "Provide FAILED and REPORTED in RAP EML Statements (Silent Transaction Failure Prevention)",
    "rationale": "In the ABAP RESTful Application Programming Model (RAP), Entity Manipulation Language (EML) statements process transactional data across Business Objects. Omitting `FAILED` and `REPORTED` clauses causes business exceptions, validation errors, and lock rejections to fail silently. The caller assumes success while the transactional buffer remains unsaved, resulting in severe data inconsistency.\n\n**RAP Standard:** Always provide both response parameters (`FAILED DATA(lt_failed) REPORTED DATA(lt_reported)`) and check `IF lt_failed IS NOT INITIAL` before proceeding or committing.",
    "className": "ZCL_SKYLINT_NO_UNHANDLED_EML",
    "pseudoComment": "NO_UNHANDLED_EML",
    "category": "security",
    "example": {
      "bad": "\" Dangerous: Omits response structures; silent failure on lock or validation error\nMODIFY ENTITIES OF z_root_travel\n  ENTITY travel\n  UPDATE FIELDS ( description total_price )\n  WITH lt_travel_updates.",
      "good": "\" Clean RAP: Inspects failed keys and propagates messages to caller\nMODIFY ENTITIES OF z_root_travel\n  ENTITY travel\n  UPDATE FIELDS ( description total_price )\n  WITH lt_travel_updates\n  FAILED DATA(lt_failed)\n  REPORTED DATA(lt_reported).\n\nIF lt_failed IS NOT INITIAL.\n  mo_message_handler->propagate_errors( lt_reported ).\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Prevent silent data corruption in ABAP RAP by requiring FAILED and REPORTED clauses in all EML statements.",
      "keywords": [
        "ABAP RAP EML Statements",
        "FAILED REPORTED RAP",
        "Silent Transaction Failure SAP",
        "Clean ABAP Cloud RAP"
      ]
    },
    "parameters": {
      "CHECK_MODIFY": "Enforce FAILED and REPORTED on MODIFY ENTITY / ENTITIES statements",
      "CHECK_READ": "Enforce FAILED and REPORTED on READ ENTITY / ENTITIES statements"
    },
    "references": [
      {
        "title": "SAP Help: Handling Responses in RAP EML",
        "url": "https://help.sap.com"
      }
    ]
  },
  {
    "ruleId": "no-empty-override",
    "title": "Avoid Method Override That Only Delegates to Super",
    "rationale": "Redefining a method only to immediately call the superclass method without performing any additional initialization, logging, argument transformation, or side effect is redundant. It clutters the method implementation, adds needless call stack overhead, and requires maintenance whenever super signatures change. Omit the empty override and let polymorphism delegate to the superclass naturally.",
    "className": "ZCL_SKYLINT_NO_EMPTY_OVERRIDE",
    "pseudoComment": "NO_EMPTY_OVERRIDE",
    "category": "anti-patterns",
    "example": {
      "bad": "METHOD do_work.\n  super->do_work( ).\nENDMETHOD.",
      "good": "\" Omit method redefinition and let superclass handle execution naturally"
    },
    "parameters": {
      "IGNORE_CTOR": "Ignore empty constructor redefinitions (when only calling super->constructor)",
      "IGNORE_CHECK": "Ignore empty redefinitions in test classes or abstract interfaces"
    },
    "seo": {
      "description": "Avoid Method Override That Only Delegates to Super - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-empty-override",
        "anti-patterns"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-composition",
    "title": "Prefer Composition over Inheritance",
    "rationale": "Inheritance creates tight coupling between subclasses and parent implementations, exposes internal state, and complicates refactoring. With the exception of exception hierarchies (CX_* classes) which require inheritance to participate in ABAP error handling, business objects should favor composition by holding references to collaborating classes and delegating tasks.",
    "className": "ZCL_SKYLINT_PREF_COMPOSITION",
    "pseudoComment": "PREF_COMPOSITION",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_order_processor DEFINITION INHERITING FROM lcl_order_validator.\nENDCLASS.",
      "good": "CLASS lcl_order_processor DEFINITION.\n  PUBLIC SECTION.\n    METHODS constructor IMPORTING io_validator TYPE REF TO lif_order_validator.\nENDCLASS."
    },
    "parameters": {
      "ALLOW_TEST_CLASSES": "Allow class inheritance inside ABAP Unit test includes"
    },
    "seo": {
      "description": "Prefer Composition over Inheritance - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-composition",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-intf-segreg",
    "title": "Prefer Interface Segregation (Small, Focused Interfaces)",
    "rationale": "Fat interfaces force implementers to depend on methods they do not need and make test mock creation cumbersome. Break large interfaces into small, cohesive, role-based contracts adhering to the Interface Segregation Principle (ISP).",
    "className": "ZCL_SKYLINT_PREF_INTF_SEGREG",
    "pseudoComment": "PREF_INTF_SEGREG",
    "category": "clean-abap",
    "example": {
      "bad": "INTERFACE lif_everything.\n  METHODS: read, write, print, send_email, archive, validate.\nENDINTERFACE.",
      "good": "INTERFACE lif_reader.\n  METHODS read.\nENDINTERFACE.\nINTERFACE lif_writer.\n  METHODS write.\nENDINTERFACE."
    },
    "parameters": {
      "MAX_METHODS": "Maximum number of methods allowed in a single interface (Interface Segregation Principle, default: 5)"
    },
    "seo": {
      "description": "Prefer Interface Segregation (Small, Focused Interfaces) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-intf-segreg",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-single-letter",
    "title": "Avoid Single-Letter Variable Names",
    "rationale": "Single-letter variables (e.g. i, x, lv_i, ls_x) obscure the meaning of code, make text searching difficult, and increase cognitive load. Use intention-revealing names such as index, customer, or total_amount.",
    "className": "ZCL_SKYLINT_NO_SINGLE_LETTER",
    "pseudoComment": "NO_SINGLE_LETTER",
    "category": "clean-abap",
    "example": {
      "bad": "DATA i TYPE i.\nDATA lv_i TYPE i.",
      "good": "DATA line_index TYPE i.\nDATA count TYPE i."
    },
    "parameters": {
      "MIN_NAME_LEN": "Minimum allowable identifier length (default: 2, excludes i, j, x, y loop indices)"
    },
    "seo": {
      "description": "Avoid Single-Letter Variable Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-single-letter",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "pref-factory-name",
    "title": "Prefer CREATE_* Prefix for Factory Methods Returning Own Class",
    "rationale": "Static factory methods returning an instance of their enclosing class should clearly communicate instantiation intent by following standard naming conventions starting with CREATE_ (e.g. create, create_instance).",
    "className": "ZCL_SKYLINT_PREF_FACTORY_NAME",
    "pseudoComment": "PREF_FACTORY_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS-METHODS build RETURNING VALUE(ro_obj) TYPE REF TO lcl_service.",
      "good": "CLASS-METHODS create_instance RETURNING VALUE(ro_obj) TYPE REF TO lcl_service."
    },
    "parameters": {
      "PREFIX": "Required prefix for static factory constructor methods (default: CREATE_)"
    },
    "seo": {
      "description": "Prefer CREATE_* Prefix for Factory Methods Returning Own Class - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "pref-factory-name",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "no-hungarian",
    "title": "Avoid Hungarian Notation and Type Prefixes",
    "rationale": "Hungarian notation prefixes (such as lv_, ls_, lt_, mv_, iv_, rv_) add visual clutter, encode technical types that frequently change, and conflict with modern Clean ABAP principles. Name variables and parameters after their domain meaning instead.",
    "className": "ZCL_SKYLINT_NO_HUNGARIAN",
    "pseudoComment": "NO_HUNGARIAN",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_count TYPE i.\nDATA mv_value TYPE string.\nMETHODS process IMPORTING iv_input TYPE string.",
      "good": "DATA count TYPE i.\nDATA value TYPE string.\nMETHODS process IMPORTING input TYPE string."
    },
    "parameters": {
      "CHECK_ATTR": "Report legacy Hungarian notation type prefixes on class attributes",
      "CHECK_LOCAL": "Report legacy Hungarian notation type prefixes on local variables",
      "CHECK_PARAM": "Report legacy Hungarian notation type prefixes on method parameters"
    },
    "seo": {
      "description": "Avoid Hungarian Notation and Type Prefixes - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-hungarian",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  },
  {
    "ruleId": "max-returns",
    "title": "Limit Multiple Return Statements per Method Body",
    "rationale": "While early return guard clauses at the top of a method are encouraged by Clean ABAP, scattering a dozen `RETURN` or `EXIT` statements throughout the middle and end of a long procedure makes control flow unpredictable. It becomes difficult to ensure that cleanup logic or post-conditions are reliably reached.\n\n**Clean ABAP Guideline:** Use early returns strictly for parameter and state validation guards at the entry point of the method. Keep the core execution flow to a single, predictable exit point.",
    "className": "ZCL_SKYLINT_MAX_RETURNS",
    "pseudoComment": "MAX_RETURNS",
    "category": "metrics",
    "example": {
      "bad": "\" Anti-pattern: 8 scattered return points throughout 100 lines of logic\nMETHOD calculate_tax.\n  ...\n  IF condition_a. RETURN. ENDIF.\n  ...\n  IF condition_b. RETURN. ENDIF.\n  ...\n  IF condition_c. RETURN. ENDIF.\n  ...\nENDMETHOD.",
      "good": "\" Clean ABAP: Grouped guard clauses at top, single deterministic computation exit\nMETHOD calculate_tax.\n  IF is_tax_exempt( is_customer ).\n    rv_tax = 0.\n    RETURN.\n  ENDIF.\n\n  rv_tax = compute_standard_rate( is_customer ).\nENDMETHOD."
    },
    "seo": {
      "description": "Balance guard clauses with predictable method exits in ABAP. Prevent scattered return statements across large procedures.",
      "keywords": [
        "Multiple return statements ABAP",
        "Guard Clauses vs Single Exit",
        "Clean ABAP Control Flow",
        "ATC Metrics"
      ]
    },
    "parameters": {
      "MAX_RETURNS": "Maximum allowed total return points (RETURN, EXIT) within a single method"
    },
    "references": [
      {
        "title": "Clean ABAP: Return Early When Nothing Else to Do",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md#return-early-when-nothing-else-to-do"
      }
    ]
  },
  {
    "ruleId": "no-instance-of",
    "title": "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests",
    "rationale": "Checking concrete object types at runtime via IS INSTANCE OF or CASE TYPE OF breaks polymorphism, violates the Open-Closed Principle, and introduces fragile type coupling. Instead of conditional type inspection, introduce polymorphic methods on common interfaces.",
    "className": "ZCL_SKYLINT_NO_INSTANCE_OF",
    "pseudoComment": "NO_INSTANCE_OF",
    "category": "clean-abap",
    "example": {
      "bad": "IF io_shape IS INSTANCE OF cl_circle.\n  render_circle( ).\nENDIF.",
      "good": "io_shape->render( )."
    },
    "parameters": {
      "CHECK_CASE_TYPE": "Report CASE TYPE OF type tests in addition to IS INSTANCE OF"
    },
    "seo": {
      "description": "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "Clean ABAP",
        "SAP ATC Check",
        "ABAP Cloud",
        "S/4HANA Readiness",
        "no-instance-of",
        "clean-abap"
      ]
    },
    "references": [
      {
        "title": "Official SAP Clean ABAP Style Guide",
        "url": "https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md"
      },
      {
        "title": "SAP ABAP Keyword Documentation",
        "url": "https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm"
      }
    ]
  }
];

export const RULE_BY_RULE_ID = new Map(RULES.map(r => [r.ruleId, r]));
export const RULE_BY_CLASS = new Map(RULES.map(r => [r.className.toUpperCase(), r]));
export const RULE_BY_CLASS_LOWER = new Map(RULES.map(r => [r.className.toLowerCase(), r]));
export const RULE_BY_SHORT_CLASS = new Map(RULES.map(r => [r.className.toLowerCase().replace(/^zcl_skylint_/, ''), r]));

/**
 * Resolve rule strictly by ruleId (kebab-case), ABAP class name, or short class name
 */
export function resolveRule(input) {
  if (!input) return null;
  const raw = String(input).trim();
  const kebab = raw.toLowerCase().replace(/_/g, '-');
  if (RULE_BY_RULE_ID.has(kebab)) return RULE_BY_RULE_ID.get(kebab);
  const upper = raw.toUpperCase();
  if (RULE_BY_CLASS.has(upper)) return RULE_BY_CLASS.get(upper);
  const lower = raw.toLowerCase();
  if (RULE_BY_CLASS_LOWER.has(lower)) return RULE_BY_CLASS_LOWER.get(lower);
  const shortName = lower.replace(/^zcl_skylint_/, '');
  if (RULE_BY_SHORT_CLASS.has(shortName)) return RULE_BY_SHORT_CLASS.get(shortName);
  return null;
}
