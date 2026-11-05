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
    "ruleId": "pref-func-module",
    "title": "Replace Obsolete Function Modules with Class-Based APIs",
    "rationale": "The check compares the literal after CALL FUNCTION with a curated table of 67 legacy modules and reports PREF_FM together with the recommended replacement. Function modules keep state in global function groups, cannot be mocked as easily as class methods and are usually not released for ABAP Cloud, so every call keeps the calling code procedural and hard to unit test. The listed modules all have class-based successors (CL_SYSTEM_UUID, CL_ABAP_TSTMP, CL_ABAP_MESSAGE_DIGEST, CL_SALV_TABLE, CL_BCS, ...) that offer typed signatures and are available in S/4HANA and Steampunk.",
    "className": "/SKYL/CL_PREF_FUNC_MODULE",
    "pseudoComment": "PREF_FUNC_MOD",
    "category": "clean-abap",
    "example": {
      "bad": "CALL FUNCTION 'GUID_CREATE'\n  IMPORTING\n    ev_guid_32 = lv_document_id.",
      "good": "lv_document_id = cl_system_uuid=>create_uuid_c32_static( )."
    },
    "seo": {
      "description": "Replace obsolete CALL FUNCTION modules such as GUID_CREATE, GUI_DOWNLOAD and ROUND with released class-based APIs for ABAP Cloud and S/4HANA.",
      "keywords": [
        "pref-func-module",
        "CALL FUNCTION",
        "obsolete function module",
        "CL_SYSTEM_UUID",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-call-method",
      "pref-class-exc",
      "no-obs-control"
    ],
    "customSection": "## Detected Function Modules\n\nOnly a literal name is resolved, so dynamic calls such as `CALL FUNCTION lv_function_name` are ignored. The table below is the complete list evaluated by the check; `CALL FUNCTION` statements with any other name are not reported.\n\n| Obsolete function module | Recommended replacement |\n|---|---|\n| `CALCULATE_HASH_FOR_CHAR` | `CL_ABAP_MESSAGE_DIGEST` |\n| `CALCULATE_HASH_FOR_RAW` | `CL_ABAP_HMAC or CL_ABAP_MESSAGE_DIGEST` |\n| `CCU_TIMESTAMP_DIFFERENCE` | `CL_ABAP_TSTMP` |\n| `CLPB_EXPORT` | `CL_GUI_FRONTEND_SERVICES` |\n| `CLPB_IMPORT` | `CL_GUI_FRONTEND_SERVICES` |\n| `CONVERT_DATE_TO_EXTERNAL` | `CL_ABAP_DATFM` |\n| `CONVERT_TIME_INPUT` | `CL_ABAP_TIMEFM` |\n| `DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `ECATT_CONV_XSTRING_TO_STRING` | `CL_BINARY_CONVERT` |\n| `F4_FILENAME` | `CL_GUI_FRONTEND_SERVICES` |\n| `FUNCTION_EXISTS` | `TRY..CATCH cx_sy_dyn_call_illegal_func` |\n| `GUI_CREATE_DIRECTORY` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_DELETE_FILE` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_EXEC` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_FB_USAGE` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_FILE_LOAD_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_FILE_SAVE_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_GET_DESKTOP_INFO` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_GET_FILE_INFO` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_GET_REGVALUE` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_MULTIPLE_FILE_LOAD_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_REMOVE_DIRECTORY` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_RUN` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_SET_REGVALUE` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_VSS_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUI_VSS_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `GUID_CREATE` | `CL_SYSTEM_UUID` |\n| `IGN_TIMESTAMP_DIFFERENCE` | `CL_ABAP_TSTMP` |\n| `IGN_TIMESTAMP_PLUSMINUS` | `CL_ABAP_TSTMP` |\n| `ISM_SD_GET_PRICING_CONDITIONS` | `CL_PRC_RESULT_FACTORY (SAP Note 2220005)` |\n| `JOB_CREATE` | `CL_BP_ABAP_JOB` |\n| `JOB_SUBMIT` | `CL_BP_ABAP_JOB` |\n| `MD5_CALCULATE_HASH_FOR_CHAR` | `CL_ABAP_MESSAGE_DIGEST` |\n| `MD5_CALCULATE_HASH_FOR_RAW` | `CL_ABAP_MESSAGE_DIGEST` |\n| `POPUP_TO_CONFIRM_LOSS_OF_DATA` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_CONFIRM_STEP` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_CONFIRM_WITH_MESSAGE` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_CONFIRM_WITH_VALUE` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_CONFIRM_WITH_VALUE_2` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_DECIDE` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_DECIDE_INFO` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_DECIDE_WITH_MESSAGE` | `POPUP_TO_CONFIRM` |\n| `POPUP_TO_GET_VALUE` | `POPUP_GET_VALUES` |\n| `QF05_RANDOM_INTEGER` | `CL_ABAP_RANDOM_INT` |\n| `REGISTRY_GET` | `CL_GUI_FRONTEND_SERVICES` |\n| `REGISTRY_SET` | `CL_GUI_FRONTEND_SERVICES` |\n| `REUSE_ALV_GRID_DISPLAY` | `CL_SALV_TABLE=>FACTORY or CL_GUI_ALV_GRID` |\n| `ROUND` | `built-in function round( )` |\n| `SAPGUI_PROGRESS_INDICATOR` | `CL_PROGRESS_INDICATOR` |\n| `SCMS_BASE64_DECODE_STR` | `CL_HTTP_UTILITY` |\n| `SCMS_STRING_TO_XSTRING` | `CL_BINARY_CONVERT` |\n| `SO_NEW_DOCUMENT_ATT_SEND_API1` | `CL_BCS` |\n| `SSFC_BASE64_DECODE` | `CL_HTTP_UTILITY` |\n| `SSFC_BASE64_ENCODE` | `CL_HTTP_UTILITY` |\n| `SUBST_GET_FILE_LIST` | `SAP Note 1686357` |\n| `SYSTEM_GET_UNIQUE_ID` | `CL_SYSTEM_UUID` |\n| `SYSTEM_UUID_C_CREATE` | `CL_SYSTEM_UUID` |\n| `UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_EXECUTE` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_FILENAME_GET` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_FILE_ATTRIB` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_FILE_COPY` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_FILE_DELETE` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_QUERY` | `CL_GUI_FRONTEND_SERVICES` |\n| `WS_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |\n\nSuppress a single finding with the pseudo comment `\"#EC PREF_FUNC_MOD`."
  },
  {
    "ruleId": "no-custom-pattern",
    "title": "Disallow Prohibited Naming Patterns and Terminology via Regular Expressions",
    "rationale": "Enterprise governance standards and Clean ABAP guidelines often forbid temporary naming prefixes (such as TMP_* or DEBUG_*), placeholder terms, obsolete package references, or sensitive terminology. The check evaluates every statement token against a configurable regular expression pattern and reports NO_CUSTOM for any match. Enforcing consistent vocabulary across teams prevents incomplete prototypes from entering production releases and maintains clean compliance across ABAP Cloud and SAP S/4HANA solutions.",
    "className": "/SKYL/CL_NO_CUSTOM_PATTERN",
    "pseudoComment": "NO_CUSTOM_PATTERN",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_todo_customer_id TYPE c LENGTH 10.",
      "good": "DATA lv_verified_customer_id TYPE c LENGTH 10."
    },
    "parameters": {
      "PATTERN": "Regular expression pattern of forbidden lexemes or identifiers to disallow (defaults to TODO|FIXME|XXX)."
    },
    "seo": {
      "description": "Detect and restrict forbidden custom naming patterns, temporary variables, and banned terminology using regex in SAP ATC for ABAP Cloud.",
      "keywords": [
        "no-custom-pattern",
        "regex pattern",
        "Clean ABAP",
        "naming conventions",
        "SAP ATC",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-keyword-name",
      "no-hardcoded-env",
      "no-dead-code"
    ],
    "customSection": "### Configuration and Pattern Matching\n\nThe check scans every token within procedure statements and applies case-insensitive regular expression matching against the configured `PATTERN` attribute.\n\n| Default Pattern | Purpose |\n|---|---|\n| `TODO|FIXME|XXX` | Prevents technical debt markers and temporary prototype identifiers from reaching production code. |\n\nA finding can be suppressed on an individual statement using the pseudo-comment `\"#EC NO_CUSTOM_PATTERN`. Set `PATTERN` to an empty string in ATC variant configuration to disable scanning."
  },
  {
    "ruleId": "pref-paren-and-or",
    "title": "Parenthesize Mixed AND/OR Conditions Explicitly",
    "rationale": "ABAP evaluates AND before OR, but SQL, JavaScript and most other languages a developer reads daily do not share that intuition, and long conditions are routinely misread. The check scans IF, ELSEIF, CHECK and WHILE conditions at each parenthesis depth and reports PREF_PAREN as soon as one depth mixes AND with OR or EQUIV. Explicit parentheses turn implicit precedence into visible grouping, which prevents bugs when a condition is later extended with one more term. The ADD_PAREN quickfix rewrites the condition with a parenthesized AND group.",
    "className": "/SKYL/CL_PREF_PAREN_AND_OR",
    "pseudoComment": "PREF_PAREN_AND_OR",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_is_approved = abap_true AND lv_amount > lv_limit OR lv_is_escalated = abap_true.\n  release_purchase_order( ).\nENDIF.",
      "good": "IF ( lv_is_approved = abap_true AND lv_amount > lv_limit ) OR lv_is_escalated = abap_true.\n  release_purchase_order( ).\nENDIF."
    },
    "seo": {
      "description": "Parenthesize mixed AND/OR conditions in IF, ELSEIF, CHECK and WHILE so operator precedence is explicit and reviewable in Clean ABAP code.",
      "keywords": [
        "pref-paren-and-or",
        "AND OR precedence",
        "IF condition",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-bool-expr",
      "no-dup-cond",
      "no-bool-compare"
    ],
    "customSection": "## Detection Details\n\nConditions are evaluated separately per parenthesis depth, so a mixed outer clause is reported even when an inner group already uses parentheses. A `BETWEEN ... AND ...` pair is not counted as a conjunction and therefore never produces a finding on its own. The `ADD_PAREN` quickfix wraps every `AND` group of the condition in parentheses while keeping the indentation of the original statement."
  },
  {
    "ruleId": "no-useless-cont",
    "title": "Remove CONTINUE Immediately Before a Loop End",
    "rationale": "A CONTINUE that directly precedes ENDLOOP, ENDWHILE or ENDDO never changes behaviour, because the loop would cycle at that point anyway. Leaving it in the code adds a dead statement that suggests additional logic was removed or is still missing, and reviewers spend time proving that nothing is skipped. The check reports NO_USE_CNT and the RMCONT quickfix deletes the statement, keeping loop bodies minimal and honest. Early CONTINUE statements that guard further processing remain untouched.",
    "className": "/SKYL/CL_NO_USELESS_CONT",
    "pseudoComment": "NO_USELESS_CONT",
    "category": "clean-abap",
    "example": {
      "bad": "LOOP AT lt_order_items ASSIGNING <ls_order_item>.\n  IF <ls_order_item>-quantity = 0.\n    CONTINUE.\n  ENDIF.\n  accumulate_net_value( <ls_order_item> ).\n  CONTINUE.\nENDLOOP.",
      "good": "LOOP AT lt_order_items ASSIGNING <ls_order_item>.\n  IF <ls_order_item>-quantity = 0.\n    CONTINUE.\n  ENDIF.\n  accumulate_net_value( <ls_order_item> ).\nENDLOOP."
    },
    "seo": {
      "description": "Detect CONTINUE statements directly before ENDLOOP, ENDWHILE or ENDDO and remove the dead loop control with an ATC quickfix.",
      "keywords": [
        "no-useless-cont",
        "CONTINUE",
        "ENDLOOP",
        "dead code",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-single-iter",
      "no-dead-code",
      "no-unreachable"
    ],
    "customSection": ""
  },
  {
    "ruleId": "no-nested-cond",
    "title": "Avoid Nesting COND and SWITCH Constructor Expressions",
    "rationale": "A COND or SWITCH inside the parentheses of another constructor expression forces the reader to resolve an expression tree instead of a decision table, and every nesting level multiplies the number of branches a reviewer has to verify. The check walks the tokens of each statement, locates COND/SWITCH followed by an opening parenthesis and reports NO_NEST_CD for every COND/SWITCH found inside that group. Flattening the mapping into additional WHEN branches, or extracting a small helper method, keeps the logic testable and readable.",
    "className": "/SKYL/CL_NO_NESTED_COND",
    "pseudoComment": "NO_NESTED_COND",
    "category": "clean-abap",
    "example": {
      "bad": "lv_delivery_priority = COND string(\n  WHEN lv_is_express = abap_true\n    THEN COND string( WHEN lv_is_priority_customer = abap_true THEN 'P1' ELSE 'P2' )\n  ELSE 'P3' ).",
      "good": "lv_delivery_priority = COND string(\n  WHEN lv_is_express = abap_true AND lv_is_priority_customer = abap_true THEN 'P1'\n  WHEN lv_is_express = abap_true                                     THEN 'P2'\n  ELSE                                                                    'P3' )."
    },
    "seo": {
      "description": "Flag COND and SWITCH expressions nested inside another constructor expression and flatten them into readable WHEN branches.",
      "keywords": [
        "no-nested-cond",
        "COND",
        "SWITCH",
        "constructor expression",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-cond",
      "pref-switch",
      "max-nesting"
    ],
    "customSection": "## Reported Nesting\n\nOnly COND and SWITCH expressions that appear inside the parentheses of another COND or SWITCH are reported. A COND nested in a `VALUE #( )`, `CORRESPONDING #( )` or in a method argument is out of scope, because those are separate expressions rather than branches of the same mapping. When flattening is not possible without repeating long conditions, extract a private helper method and call it from the WHEN branch."
  },
  {
    "ruleId": "no-single-iter",
    "title": "Avoid Loops That Execute At Most Once Due to Unconditional Exit",
    "rationale": "A LOOP, WHILE, or DO statement containing an unconditional EXIT or RETURN at its top nesting level executes at most once, defeating the purpose of an iterative control structure. This anti-pattern typically stems from incomplete refactoring, abandoned prototyping code, or misusing a loop to read the first entry of an internal table. In ABAP Cloud and Clean ABAP, single-element lookups must use explicit table expressions with index 1 or line_exists( ), while conditional execution belongs in IF blocks or helper procedures. The check reports NO_1_LOOP on the early terminating statement.",
    "className": "/SKYL/CL_NO_SINGLE_ITER",
    "pseudoComment": "NO_SINGLE_ITER",
    "category": "anti-patterns",
    "example": {
      "bad": "LOOP AT lt_sales_orders ASSIGNING <ls_sales_order>.\n  process_order( <ls_sales_order> ).\n  EXIT.\nENDLOOP.",
      "good": "IF line_exists( lt_sales_orders[ 1 ] ).\n  process_order( lt_sales_orders[ 1 ] ).\nENDIF."
    },
    "seo": {
      "description": "Detect loops executing at most once due to unconditional EXIT or RETURN statements in Clean ABAP and SAP ATC.",
      "keywords": [
        "no-single-iter",
        "single iteration loop",
        "unconditional EXIT",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dead-code",
      "no-unreachable",
      "pref-early-ret"
    ],
    "customSection": "### Control Flow Inspection\n\nThe rule tracks control flow depth inside loop blocks (`LOOP`, `WHILE`, `DO`). If an unconditional `EXIT` or `RETURN` statement occurs outside any conditional branch (`IF`, `CASE`, `TRY`), finding `NO_1_LOOP` is reported.\n\n| Construct | Issue | Recommended Alternative |\n|---|---|---|\n| `LOOP AT itab ... EXIT. ENDLOOP.` | Reads at most first element | Use table expression `itab[ 1 ]` or `READ TABLE ... INDEX 1` |\n| `DO 1 TIMES ... EXIT. ENDDO.` | Pseudo-block used for jumps | Refactor into private helper method with early `RETURN` |\n\nSuppress deliberate single-pass loop constructs using the pseudo-comment `\"#EC NO_SINGLE_ITER`."
  },
  {
    "ruleId": "pref-downport",
    "title": "Detect 7.40+ Syntax in Downport-Compatible Code",
    "rationale": "Table expressions, inline declarations, constructor expressions, string templates and strict Open SQL silently raise the kernel and syntax level required by a program, which breaks as soon as the code is transported to a 7.31 or early 7.40 system. The check exposes every such construct behind ten independent switches, each implemented as a concrete token pattern, and reports PREF_DWNPT for the first modern construct found in a statement. All switches default to false so modern ABAP Cloud development is never disturbed, and only a real downport target enables the ones it needs.",
    "className": "/SKYL/CL_PREF_DOWNPORT",
    "pseudoComment": "PREF_DOWNPORT",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_amount) = lt_open_items[ 1 ]-amount.",
      "good": "DATA lv_amount TYPE ty_open_item-amount.\nDATA ls_open_item TYPE ty_open_item.\nREAD TABLE lt_open_items INTO ls_open_item INDEX 1.\nIF sy-subrc = 0.\n  lv_amount = ls_open_item-amount.\nENDIF."
    },
    "parameters": {
      "CHECK_CONSTRUCTORS": "Report constructor expressions (NEW, VALUE, COND, SWITCH, REDUCE, FILTER, CORRESPONDING, CONV, REF, CAST). Enable only for targets older than 7.40.",
      "CHECK_TABLE_EXPR": "Report table expressions (itab[ ... ]). Enable for target releases below 7.40 SP08, where table expressions do not exist.",
      "CHECK_INLINE_DECL": "Report inline declarations DATA(...), FINAL(...) and FIELD-SYMBOL(...). Enable when the downport target predates 7.40.",
      "CHECK_STRING_TEMPL": "Report string templates (|...|) in any statement. Enable when the target kernel cannot compile templates.",
      "CHECK_CHAINING": "Report functional method chaining such as lo_service->create( )->run( ). Enable when method chain expressions are unavailable.",
      "CHECK_EMPTY_KEY": "Report WITH EMPTY KEY table definitions. Enable when the target release cannot declare an empty secondary key.",
      "CHECK_CALC_ASSIGN": "Report calculation assignment operators +=, -=, *=, /= and &&=. Enable for releases before 7.40.",
      "CHECK_LINE_FUNCS": "Report the LINE_EXISTS( ) and LINE_INDEX( ) built-ins. The lines( ) function is not evaluated, so enable this switch only when line functions are missing downport.",
      "CHECK_STRICT_SQL": "Report @-escaped host expressions in Open SQL statements. Enable when only legacy Open SQL is supported by the target.",
      "CHECK_RAISE_MESSAGE": "Report RAISE EXCEPTION ... MESSAGE ... additions. Enable when the target release lacks the MESSAGE addition."
    },
    "seo": {
      "description": "Detect 7.40+ syntax such as table expressions, inline declarations, string templates and strict Open SQL when code must stay downport compatible.",
      "keywords": [
        "pref-downport",
        "downport compatibility",
        "7.40 syntax",
        "ABAP Cloud",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-calc-op",
      "pref-symbol-op",
      "pref-sy"
    ],
    "customSection": "## Configuration Switches\n\nEvery switch is a boolean and defaults to `abap_false`. Each statement is inspected in a fixed order and stops at the first matching check, so a statement that combines several modern constructs produces exactly one finding.\n\n| Attribute | Modern construct detected |\n|---|---|\n| `CHECK_CONSTRUCTORS` | `NEW`, `VALUE`, `COND`, `SWITCH`, `REDUCE`, `FILTER`, `CORRESPONDING`, `EXACT`, `CONV`, `REF`, `CAST` followed by `(` |\n| `CHECK_TABLE_EXPR` | Any `[` or `]` token, that is a table expression |\n| `CHECK_INLINE_DECL` | `DATA(...)`, `FINAL(...)` and `FIELD-SYMBOL(...)` inline declarations |\n| `CHECK_STRING_TEMPL` | Any token containing `|`, that is a string template |\n| `CHECK_CHAINING` | Method calls whose tokens contain `)->` |\n| `CHECK_EMPTY_KEY` | `WITH EMPTY KEY` |\n| `CHECK_CALC_ASSIGN` | `+=`, `-=`, `*=`, `/=` and `&&=` |\n| `CHECK_LINE_FUNCS` | `LINE_EXISTS(` and `LINE_INDEX(`; `lines(` is not evaluated by this switch |\n| `CHECK_STRICT_SQL` | `@`-escaped host expressions in database statements |\n| `CHECK_RAISE_MESSAGE` | `RAISE EXCEPTION ... MESSAGE ...` |\n\nEnable only the switches that correspond to the oldest release you still support; mixing them all produces noise in code that is already downport-clean."
  },
  {
    "ruleId": "pref-reduce",
    "title": "Replace Single-Statement Aggregation LOOP with REDUCE",
    "rationale": "A LOOP whose body is one self-referential assignment such as total = total + line-amount carries mutable state, an explicit work area and three lines of control flow to express a single calculation. REDUCE states the same aggregation as one expression, cannot leak an uninitialized accumulator and makes the iteration variable local to the expression. The check reports PREF_REDUC only when the loop body is exactly one such assignment, so loops with side effects or filtering stay untouched.",
    "className": "/SKYL/CL_PREF_REDUCE",
    "pseudoComment": "PREF_REDUCE",
    "category": "clean-abap",
    "example": {
      "bad": "LOOP AT lt_order_items INTO ls_order_item.\n  lv_total_amount = lv_total_amount + ls_order_item-amount.\nENDLOOP.",
      "good": "lv_total_amount = REDUCE #( INIT lv_sum = CONV ty_amount( 0 )\n                            FOR ls_order_item IN lt_order_items\n                            NEXT lv_sum = lv_sum + ls_order_item-amount )."
    },
    "seo": {
      "description": "Replace a LOOP that only accumulates a running total with a single REDUCE expression and remove mutable accumulator variables.",
      "keywords": [
        "pref-reduce",
        "REDUCE",
        "LOOP AT",
        "aggregation",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-lines",
      "pref-read-table",
      "no-loop-into"
    ],
    "customSection": "## Narrow Trigger Conditions\n\nA LOOP is reported only when all of the following hold:\n\n- the loop reads `LOOP AT itab INTO ls_line` or `LOOP AT itab ASSIGNING <ls_line>`,\n- the body consists of a single assignment with the shape `total = total + ...`,\n- that assignment references the loop work area or field symbol,\n- no `WHERE` or `GROUP BY` addition is present,\n- the loop closes immediately with `ENDLOOP`.\n\nAdditional statements, a second accumulator, an `APPEND` or `COLLECT` aggregation, or a filtered loop keep the statement unflagged. Those cases are better served by a dedicated helper method than by squeezing side effects into `REDUCE`."
  },
  {
    "ruleId": "pref-read-table",
    "title": "Replace READ TABLE with Table Expressions and line_exists",
    "rationale": "READ TABLE forces a work area or field symbol plus a sy-subrc branch before the value can be used, and the check reports PREF_TABEX for those value reads and PREF_LNEXS for existence checks with TRANSPORTING NO FIELDS. Table expressions return the row directly inside an expression and line_exists( ) makes an existence test a boolean value, so mutable helper variables and forgotten sy-subrc resets disappear. Both constructs require unique keys and throw CX_SY_ITAB_LINE_NOT_FOUND on a miss, which is why the OPTIONAL or DEFAULT addition is part of the modern replacement.",
    "className": "/SKYL/CL_PREF_READ_TABLE",
    "pseudoComment": "PREF_TAB_EXPR",
    "category": "clean-abap",
    "example": {
      "bad": "READ TABLE lt_sales_orders INTO ls_sales_order WITH KEY order_id = lv_order_id.\nIF sy-subrc = 0.\n  process_order( ls_sales_order ).\nENDIF.\nREAD TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer_id = lv_customer_id.\nIF sy-subrc = 0.\n  authorize_customer( lv_customer_id ).\nENDIF.",
      "good": "ls_sales_order = VALUE #( lt_sales_orders[ order_id = lv_order_id ] OPTIONAL ).\nIF ls_sales_order IS NOT INITIAL.\n  process_order( ls_sales_order ).\nENDIF.\nIF line_exists( lt_customers[ customer_id = lv_customer_id ] ).\n  authorize_customer( lv_customer_id ).\nENDIF."
    },
    "parameters": {
      "CHECK_TAB_EXPR": "Report READ TABLE INTO/ASSIGNING/REFERENCE INTO that can become a table expression itab[ ... ]. Disable to keep procedural value reads while existence checks are modernized.",
      "CHECK_LINE_EXISTS": "Report READ TABLE and LOOP AT with TRANSPORTING NO FIELDS that can become line_exists( ). Disable if the codebase still relies on sy-subrc based existence checks."
    },
    "seo": {
      "description": "Modernize READ TABLE INTO with table expressions and READ TABLE TRANSPORTING NO FIELDS with line_exists( ) in ABAP Cloud code.",
      "keywords": [
        "pref-read-table",
        "READ TABLE",
        "table expression",
        "line_exists",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-lines",
      "no-default-key",
      "no-loop-into"
    ],
    "customSection": "## Finding Codes and Replacements\n\n| Finding code | Trigger | Modern replacement |\n|---|---|---|\n| `PREF_TABEX` | `READ TABLE ... INTO`, `ASSIGNING` or `REFERENCE INTO` with `INDEX` or `WITH [TABLE] KEY` | `ls_line = VALUE #( itab[ ... ] OPTIONAL ).` or `ASSIGN itab[ ... ] TO <ls_line>.` |\n| `PREF_LNEXS` | `READ TABLE` or `LOOP AT` with `TRANSPORTING NO FIELDS` | `IF line_exists( itab[ ... ] ).` |\n\n`BINARY SEARCH` and `WHERE` variants are never reported: a table expression cannot reproduce their semantics. The two finding codes use their own pseudo comments, `PREF_TABLE_EXPR` and `PREF_LINE_EXISTS`, so a single case can be suppressed without silencing the whole rule. Disable `CHECK_TAB_EXPR` while a legacy work-area API is still in place and keep `CHECK_LINE_EXISTS` enabled to modernize existence checks only."
  },
  {
    "ruleId": "pref-cond",
    "title": "Collapse Value-Mapping IF Chains into COND",
    "rationale": "An IF/ELSEIF chain in which every branch only assigns the same variable spreads one decision over many lines, repeats the target and can leave it uninitialized when no branch matches. The check detects exactly that shape and reports PREF_COND, then offers a USECOND quickfix that rewrites the entire IF..ENDIF block into one COND expression. Assigning the result once makes the value mapping verifiable at a glance, composable in expressions and safe against a forgotten ELSE branch.",
    "className": "/SKYL/CL_PREF_COND",
    "pseudoComment": "PREF_COND",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_credit_score >= 800.\n  lv_credit_rating = 'A'.\nELSEIF lv_credit_score >= 600.\n  lv_credit_rating = 'B'.\nELSE.\n  lv_credit_rating = 'C'.\nENDIF.",
      "good": "lv_credit_rating = COND string(\n  WHEN lv_credit_score >= 800 THEN 'A'\n  WHEN lv_credit_score >= 600 THEN 'B'\n  ELSE                             'C' )."
    },
    "parameters": {
      "REQUIRE_ELSE": "Only report IF chains that already contain an explicit ELSE branch. Enable when every COND replacement must define a total mapping; partial IF chains stay untouched."
    },
    "seo": {
      "description": "Convert IF/ELSEIF/ELSE chains that only assign one variable into a single COND constructor expression, with an automatic quickfix.",
      "keywords": [
        "pref-cond",
        "COND",
        "IF ELSEIF",
        "constructor expression",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-neg-cond",
      "pref-case",
      "pref-switch"
    ],
    "customSection": "## When the Rule Fires\n\n`PREF_COND` is raised only when the whole IF block is a pure value mapping:\n\n- every branch contains exactly one statement,\n- that statement is a plain assignment `target = expression`,\n- every branch assigns the same target variable,\n- the block ends directly with `ENDIF`.\n\nA branch with a method call, `APPEND`, `RAISE`, several assignments or a nested block keeps the IF statement, because a COND expression cannot carry side effects. With `REQUIRE_ELSE` enabled only chains that already contain an explicit `ELSE` are reported, so a partial mapping is never silently completed by an implied ELSE."
  },
  {
    "ruleId": "pref-switch",
    "title": "Convert Pure CASE Mappings into SWITCH Expressions",
    "rationale": "A CASE statement whose WHEN branches only assign the same variable is a lookup table disguised as control flow: the operand, the branches and the ENDCASE all add noise around one value. The check verifies that every branch holds exactly one assignment to the same target and reports PREF_SWTCH, then the USESWITCH quickfix rewrites the complete CASE..ENDCASE block into a SWITCH expression. The result assigns once, cannot fall through and can be passed directly to a method or constructor expression.",
    "className": "/SKYL/CL_PREF_SWITCH",
    "pseudoComment": "PREF_SWITCH",
    "category": "clean-abap",
    "example": {
      "bad": "CASE lv_delivery_status.\n  WHEN 'O'.\n    lv_status_text = 'Open'.\n  WHEN 'S'.\n    lv_status_text = 'Shipped'.\n  WHEN OTHERS.\n    lv_status_text = 'Unknown'.\nENDCASE.",
      "good": "lv_status_text = SWITCH string( lv_delivery_status\n  WHEN 'O' THEN 'Open'\n  WHEN 'S' THEN 'Shipped'\n  ELSE 'Unknown' )."
    },
    "parameters": {
      "REQUIRE_OTHERS": "Only report CASE blocks that already contain a WHEN OTHERS branch. Enable when the SWITCH replacement must be total and unhandled states must stay visible."
    },
    "seo": {
      "description": "Replace CASE blocks whose WHEN branches only assign one variable with a compact SWITCH constructor expression.",
      "keywords": [
        "pref-switch",
        "SWITCH",
        "CASE WHEN",
        "constructor expression",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-case",
      "pref-cond",
      "no-single-when"
    ],
    "customSection": "## When the Rule Fires\n\nThe CASE block must consist only of `WHEN` branches, each containing exactly one assignment to the same target variable, followed directly by `ENDCASE`. Branches with several statements, method calls or different targets keep the CASE statement, which remains the correct tool for statement sequences and side effects.\n\nWith `REQUIRE_OTHERS` enabled only blocks that already contain `WHEN OTHERS` are reported, so the migration cannot hide an unhandled state behind an implicit ELSE. The `USESWITCH` quickfix replaces the entire block, including the fallback."
  },
  {
    "ruleId": "pref-lines",
    "title": "Use lines( ) Instead of DESCRIBE TABLE LINES",
    "rationale": "DESCRIBE TABLE ... LINES writes the row count into a helper variable, so the question about the table size and the code that uses the answer are separated by an extra declaration and an extra statement. The lines( ) built-in returns the count as a value, which can be tested inline in IF or WHILE and passed to any expression without a temporary variable. The check reports PREF_LINES and the TOLINES quickfix replaces the statement with an equivalent lines( ) assignment.",
    "className": "/SKYL/CL_PREF_LINES",
    "pseudoComment": "PREF_LINES",
    "category": "clean-abap",
    "example": {
      "bad": "DESCRIBE TABLE lt_order_items LINES lv_item_count.\nIF lv_item_count = 0.\n  RETURN.\nENDIF.",
      "good": "IF lines( lt_order_items ) = 0.\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Replace DESCRIBE TABLE LINES with the lines( ) built-in to drop temporary counters and obsolete statements in ABAP Cloud.",
      "keywords": [
        "pref-lines",
        "lines( )",
        "DESCRIBE TABLE",
        "obsolete statement",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-read-table",
      "pref-reduce",
      "pref-std-table"
    ],
    "customSection": "## Scope\n\n`DESCRIBE TABLE ... KIND` and `... OCCURS` are not reported, because `lines( )` only replaces the row count. The `TOLINES` quickfix always produces the assignment form `target = lines( itab ).`; inline it manually when the count is used only once, as in the good example."
  },
  {
    "ruleId": "no-call-method",
    "title": "Replace Obsolete CALL METHOD Statements with Functional Invocations",
    "rationale": "The explicit CALL METHOD syntax is a legacy holdover from early ABAP Objects releases that introduces excessive syntactic verbosity. In modern Clean ABAP and ABAP Cloud, methods should always be invoked functionally as ref->method( ) or class=>method( ), enabling clean chaining, expression embedding, and streamlined parameter passing. The check reports NO_CALL_MT for static invocations, and the CALL2FUNC quickfix automatically transforms the statement into modern functional syntax.",
    "className": "/SKYL/CL_NO_CALL_METHOD",
    "pseudoComment": "NO_CALL_METHOD",
    "category": "anti-patterns",
    "example": {
      "bad": "CALL METHOD lo_invoice_service->calculate_tax\n  EXPORTING\n    iv_net_amount = lv_net_amount\n  RECEIVING\n    rv_tax_amount = lv_tax_amount.",
      "good": "lv_tax_amount = lo_invoice_service->calculate_tax( iv_net_amount = lv_net_amount )."
    },
    "seo": {
      "description": "Eliminate legacy CALL METHOD statements in favor of modern functional method calls in Clean ABAP and SAP ATC.",
      "keywords": [
        "no-call-method",
        "CALL METHOD",
        "functional method call",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-call-exporting",
      "no-call-receiving",
      "no-me-reference"
    ],
    "customSection": "### Scope and Dynamic Calls\n\nStatic `CALL METHOD` statements are reported with finding `NO_CALL_MT`. Dynamic method calls are intentionally exempted:\n\n- `CALL METHOD lo_instance->(lv_method_name)` (dynamic method name) is ignored.\n- `PARAMETER-TABLE` and `EXCEPTION-TABLE` additions are ignored.\n\nThe `CALL2FUNC` quickfix automatically strips the `CALL METHOD` keywords and converts parameter clauses into modern parenthesis-enclosed argument lists. Findings can be suppressed with `\"#EC NO_CALL_METHOD`."
  },
  {
    "ruleId": "no-default-key",
    "title": "Avoid WITH DEFAULT KEY in Internal Table Declarations",
    "rationale": "WITH DEFAULT KEY creates an implicit table key consisting of all non-numeric character fields in the line type. Adding or modifying fields in the underlying structure silently alters the table key, leading to unexpected duplicate handling in COLLECT or INSERT and unintended sort orders. In modern Clean ABAP and ABAP Cloud, internal tables must declare their key explicitly with WITH UNIQUE/NON-UNIQUE KEY or use WITH EMPTY KEY for index-accessed collections. The check flags DEFAULT KEY with finding NO_DEF_KEY and provides the USEEMPTY quickfix.",
    "className": "/SKYL/CL_NO_DEFAULT_KEY",
    "pseudoComment": "NO_DEFAULT_KEY",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lt_sales_orders TYPE STANDARD TABLE OF ty_sales_order WITH DEFAULT KEY.",
      "good": "DATA lt_sales_orders TYPE STANDARD TABLE OF ty_sales_order WITH EMPTY KEY."
    },
    "seo": {
      "description": "Avoid WITH DEFAULT KEY declarations in internal tables and specify EMPTY KEY or explicit keys in Clean ABAP.",
      "keywords": [
        "no-default-key",
        "WITH DEFAULT KEY",
        "WITH EMPTY KEY",
        "internal table key",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-std-table",
      "no-mod-std-table",
      "pref-lines"
    ],
    "customSection": "### Key Semantics and Migration\n\nIn classic ABAP, `WITH DEFAULT KEY` included all text-like fields in the table key. This behavior often produces brittle code:\n\n| Declaration | Key Behavior | Recommended Scenario |\n|---|---|---|\n| `WITH DEFAULT KEY` | Brittle implicit key over all non-numeric columns | Deprecated in Clean ABAP |\n| `WITH EMPTY KEY` | No primary key; access strictly by index or iteration | Standard tables without key lookup requirements |\n| `WITH UNIQUE / NON-UNIQUE KEY ...` | Explicit component list | Sorted, hashed, or keyed standard tables |\n\nThe `USEEMPTY` quickfix replaces `DEFAULT` with `EMPTY`. Statements can be suppressed using `\"#EC NO_DEFAULT_KEY`."
  },
  {
    "ruleId": "pref-is-not",
    "title": "Rewrite NOT ... IS Predicates as IS NOT",
    "rationale": "A leading NOT forces the reader to negate the whole predicate mentally, and in compound conditions the negation is easily attached to the wrong term. IS NOT keeps the subject first and reads in natural order, for example lo_instance IS NOT BOUND. The check inspects IF, ELSEIF, CHECK and WHILE statements for NOT followed by IS plus a supported predicate, reports PREF_ISNOT and offers an ISNOT quickfix that swaps the tokens in place.",
    "className": "/SKYL/CL_PREF_IS_NOT",
    "pseudoComment": "PREF_IS_NOT",
    "category": "clean-abap",
    "example": {
      "bad": "IF NOT lt_open_items IS INITIAL.\n  process_open_items( lt_open_items ).\nENDIF.",
      "good": "IF lt_open_items IS NOT INITIAL.\n  process_open_items( lt_open_items ).\nENDIF."
    },
    "seo": {
      "description": "Rewrite negated predicates such as NOT lt_items IS INITIAL into the natural reading IS NOT INITIAL in IF, CHECK and WHILE.",
      "keywords": [
        "pref-is-not",
        "IS NOT INITIAL",
        "negated condition",
        "predicate",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-is-initial",
      "pref-case",
      "pref-cond"
    ],
    "customSection": "## Supported Predicates\n\nThe rewrite is offered for `IS INITIAL`, `IS BOUND`, `IS ASSIGNED`, `IS SUPPLIED`, `IS REQUESTED` and `IS INSTANCE`. Only keyword tokens are inspected, so a variable or component that happens to be named `not` or `is` never triggers a finding. The `ISNOT` quickfix is only created for the adjacent pattern `NOT x IS INITIAL`; longer negations are reported without a quickfix."
  },
  {
    "ruleId": "no-me-reference",
    "title": "Avoid Redundant ME-> Self-References to Instance Members",
    "rationale": "In ABAP Objects, instance methods and member attributes are directly visible within instance methods without requiring the me-> prefix. Adding me-> to everyday variable access or helper method calls introduces visual noise, distracts reviewers, and runs counter to Clean ABAP style guidelines. The self-reference should be reserved for disambiguating shadowed member attributes inside constructors or setters. The check flags redundant me-> tokens with NO_ME_REF and provides the OMITME quickfix.",
    "className": "/SKYL/CL_NO_ME_REFERENCE",
    "pseudoComment": "NO_ME_REFERENCE",
    "category": "anti-patterns",
    "example": {
      "bad": "me->mv_total_amount = me->mv_total_amount + lv_item_amount.\nme->persist_invoice( ).",
      "good": "mv_total_amount = mv_total_amount + lv_item_amount.\npersist_invoice( )."
    },
    "parameters": {
      "ALLOW_IN_CONSTRUCTORS": "Allow me-> self-references within CONSTRUCTOR methods to resolve shadowed parameter names."
    },
    "seo": {
      "description": "Remove redundant ME-> self-references from instance method calls and attribute accesses in Clean ABAP.",
      "keywords": [
        "no-me-reference",
        "ME self-reference",
        "Clean ABAP",
        "ABAP Objects",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-call-method",
      "pref-name-members",
      "no-static-arrow"
    ],
    "customSection": "### Disambiguation and QuickFix\n\nClean ABAP advises omitting `me->` unless an imported parameter or local variable shares the exact name of a member attribute:\n\n- In normal methods, `me->do_something( )` and `me->mv_status` are reported.\n- When `ALLOW_IN_CONSTRUCTORS` is set to `abap_true` (default), constructor methods (`*=>CONSTRUCTOR`) are exempt to facilitate parameter assignments such as `me->mv_id = iv_id`.\n\nThe `OMITME` quickfix strips `me->` from the statement automatically. Suppress findings using `\"#EC NO_ME_REFERENCE`."
  },
  {
    "ruleId": "no-call-receiving",
    "title": "Omit Explicit RECEIVING Keyword in Functional Method Invocations",
    "rationale": "The explicit RECEIVING clause inside a method invocation forces functional calls into procedural statement syntax, preventing the returned value from participating in larger expressions or inline assignments. In Clean ABAP and ABAP Cloud, returning values should be assigned directly to the left-hand side of an assignment (e.g. result = obj->calc( )). The check identifies RECEIVING clauses in functional calls and flags them with NO_CALL_RC, while the OMITRECV quickfix hoists the receiving target variable to the LHS.",
    "className": "/SKYL/CL_NO_CALL_RECEIVING",
    "pseudoComment": "NO_CALL_RECEIVING",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_order_service->calculate_total_price( RECEIVING rv_total = lv_total_price ).",
      "good": "lv_total_price = lo_order_service->calculate_total_price( )."
    },
    "seo": {
      "description": "Omit redundant RECEIVING keywords and capture method results via direct left-hand side assignments in Clean ABAP.",
      "keywords": [
        "no-call-receiving",
        "RECEIVING clause",
        "functional method call",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-call-method",
      "no-call-exporting",
      "pref-returning"
    ],
    "customSection": "### Syntax Modernization and QuickFix\n\nIn functional ABAP method calls, the `RECEIVING` keyword is an obsolete verbosity from procedural styles:\n\n```abap\n\" Legacy procedural style:\nlo_calculator->get_factor( RECEIVING rv_factor = lv_factor ).\n\n\" Modern Clean ABAP style:\nlv_factor = lo_calculator->get_factor( ).\n```\n\nMethods with non-class-based `EXCEPTIONS` clauses are ignored because classic exceptions cannot be captured on the left-hand side of an expression. The `OMITRECV` quickfix extracts the receiving variable and rewrites the statement into an LHS assignment. Suppress findings with `\"#EC NO_CALL_RECEIVING`."
  },
  {
    "ruleId": "no-call-exporting",
    "title": "Omit Redundant EXPORTING Keyword in Method Invocations",
    "rationale": "When invoking a method functionally, the EXPORTING keyword is entirely optional unless another clause (such as IMPORTING, CHANGING, or EXCEPTIONS) is present. Writing out EXPORTING adds redundant boilerplate, clutters method parameter lists, and violates Clean ABAP conciseness principles. The check detects standalone EXPORTING clauses and reports NO_CALL_EX, while the OMIT_EXP quickfix directly deletes the superfluous keyword.",
    "className": "/SKYL/CL_NO_CALL_EXPORTING",
    "pseudoComment": "NO_CALL_EXPORTING",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_pricing_engine->apply_discount( EXPORTING iv_discount_rate = 15 ).",
      "good": "lo_pricing_engine->apply_discount( iv_discount_rate = 15 )."
    },
    "seo": {
      "description": "Omit redundant EXPORTING keywords in functional ABAP method calls for cleaner and more readable syntax.",
      "keywords": [
        "no-call-exporting",
        "EXPORTING keyword",
        "functional method call",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-call-method",
      "no-call-receiving",
      "pref-returning"
    ],
    "customSection": "### Redundant vs. Mandatory EXPORTING\n\nIn functional ABAP method calls, parameters passed without a section header are implicitly treated as `EXPORTING`:\n\n| Syntax Pattern | Status | QuickFix |\n|---|---|---|\n| `lo_obj->method( EXPORTING iv_val = 1 ).` | Redundant | `OMIT_EXP` removes `EXPORTING` |\n| `lo_obj->method( iv_val = 1 ).` | Clean ABAP Standard | Clean |\n| `lo_obj->method( EXPORTING iv_val = 1 IMPORTING ev_res = lv_res ).` | Required (multi-section) | Exempt |\n\nThe rule ignores calls that contain `IMPORTING`, `CHANGING`, `RECEIVING`, or `EXCEPTIONS`. Suppress findings with `\"#EC NO_CALL_EXPORTING`."
  },
  {
    "ruleId": "pref-param-name",
    "title": "Omit or Require Parameter Names in Method Calls",
    "rationale": "For a method with exactly one IMPORTING parameter, writing the parameter name at every call site adds noise without adding information. For teams that prefer explicit names, the opposite style is enforced instead. The check reads the method signature with RTTI to confirm the single-parameter case and reports PREF_OMIT or PREF_REQ_P accordingly, each with its own quickfix that edits the call in place. Because the signature must be resolved at runtime, the rule is not remote enabled and only runs locally.",
    "className": "/SKYL/CL_PREF_PARAM_NAME",
    "pseudoComment": "PREF_PARAM_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lo_pricing_service) = NEW zcl_pricing_service( ).\nlo_pricing_service->apply_discount( iv_percent = 15 ).",
      "good": "DATA(lo_pricing_service) = NEW zcl_pricing_service( ).\nlo_pricing_service->apply_discount( 15 )."
    },
    "parameters": {
      "CHECK_PARAM_NAME": "Report single-IMPORTING-parameter calls that still pass the parameter name and suggest the positional form. Ignored while REQUIRE_PARAM_NAME is active.",
      "REQUIRE_PARAM_NAME": "Report positional calls to single-IMPORTING-parameter methods and add the parameter name. Takes precedence over CHECK_PARAM_NAME."
    },
    "seo": {
      "description": "Enforce one method call style: omit the parameter name for single-parameter methods or require explicit names via REQUIRE_PARAM_NAME.",
      "keywords": [
        "pref-param-name",
        "parameter name",
        "functional method call",
        "RTTI",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "max-params",
      "no-call-method"
    ],
    "customSection": "## Two Modes, One Rule\n\n| Attribute | Finding code | Effect |\n|---|---|---|\n| `CHECK_PARAM_NAME` (default) | `PREF_OMIT` | A method with exactly one IMPORTING parameter called as `method( iv_param = value )` is reported; the name should be dropped. |\n| `REQUIRE_PARAM_NAME` | `PREF_REQ_P` | A positional call `method( value )` is reported and the parameter name is added. Takes precedence over `CHECK_PARAM_NAME` when both are enabled. |\n\nSignatures are resolved through RTTI (`/skyl/cl_rtti_util=>get_single_importing_param`), so the check sets `remote_enablement = abap_false` and cannot run in a remote ATC scenario. Classic `CALL METHOD` statements and calls that use explicit parameter sections are skipped, and the pseudo comment `PREF_PARAM_NAME` suppresses both finding codes."
  },
  {
    "ruleId": "no-unused-param",
    "title": "Detect Declared But Unused Procedure Parameters",
    "rationale": "A parameter that is never read or written clutters the signature, misleads callers into supplying data that is ignored and often marks an implementation that was never finished. The check collects the declared parameters of methods, FORM routines and function modules and compares them with the data references actually used in the body, then reports NO_UNUS_PR listing every unused name at once. Method signatures are read with RTTI, so interface, abstract, redefined, inherited and event-handler methods are skipped instead of producing false positives.",
    "className": "/SKYL/CL_NO_UNUSED_PARAM",
    "pseudoComment": "NO_UNUSED_PARAM",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD post_material_document IMPORTING is_document TYPE ty_material_doc iv_post_date TYPE d.\n  DATA lv_posting_date TYPE d.\n  lv_posting_date = iv_post_date.\nENDMETHOD.",
      "good": "METHOD post_material_document IMPORTING is_document TYPE ty_material_doc iv_post_date TYPE d.\n  DATA lv_posting_date TYPE d.\n  lv_posting_date = iv_post_date.\n  post_document( is_document ).\nENDMETHOD."
    },
    "parameters": {
      "CHECK_METHODS": "Inspect method implementations through RTTI. Interface, abstract, redefined, inherited methods and event handlers are always skipped.",
      "CHECK_FORMS": "Inspect FORM routine signatures. Disable when legacy form routines are out of scope for the cleanup.",
      "CHECK_FUNCS": "Inspect function module signatures. Disable when function modules are maintained by another team."
    },
    "seo": {
      "description": "Find parameters declared in methods, FORM routines and function modules that are never used, and keep procedure signatures honest.",
      "keywords": [
        "no-unused-param",
        "unused parameter",
        "method signature",
        "RTTI",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-param-name",
      "max-params",
      "no-unused-vars"
    ],
    "customSection": "## Scope and Exceptions\n\n| Aspect | Behaviour |\n|---|---|\n| Procedures | Methods (`CHECK_METHODS`), FORM routines (`CHECK_FORMS`) and function modules (`CHECK_FUNCS`) |\n| Always skipped | `RETURNING` parameters and parameters whose name starts with `_` |\n| Methods skipped | interface, abstract, redefined, inherited methods and event handlers |\n| Finding | `NO_UNUS_PR` on the first statement of the procedure, listing all unused names |\n\nMethod signatures are resolved through RTTI, therefore `remote_enablement = abap_false`. Prefix a deliberately unused parameter with an underscore to document the intent instead of deleting it, for example a callback signature that must match an interface."
  },
  {
    "ruleId": "no-chained-decl",
    "title": "Avoid Chained Declarations for Variables, Types, and Constants",
    "rationale": "Chained declarations (such as DATA:, TYPES:, and CONSTANTS:) combine multiple independent statements behind a single colon and commas, obscuring individual types and producing noisy git diffs when adding or modifying lines. Furthermore, chained declarations encourage upfront variable dumping at the start of a procedure rather than declaring variables close to first use. In Clean ABAP and ABAP Cloud, declare each variable or constant as an individual, fully qualified statement. The check reports NO_CHN_DCL and resolves the chain via the PREFINLDCL quickfix.",
    "className": "/SKYL/CL_NO_CHAINED_DECL",
    "pseudoComment": "NO_CHAINED_DECL",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA: lv_sales_order_id TYPE string,\n      lv_delivery_block TYPE string.",
      "good": "DATA lv_sales_order_id TYPE string.\nDATA lv_delivery_block TYPE string."
    },
    "parameters": {
      "ALLOW_STRUCTURE_CHAINS": "Allow chained statements exclusively for BEGIN OF ... END OF structure definitions."
    },
    "seo": {
      "description": "Avoid chained declarations (DATA:, TYPES:, CONSTANTS:) and use individual statements for clean git diffs in ABAP.",
      "keywords": [
        "no-chained-decl",
        "chained declarations",
        "DATA colon",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-chained-assign",
      "pref-inline",
      "pref-final-data"
    ],
    "customSection": "### Single Declarations vs. Structure Chains\n\nClean ABAP advocates individual statement declarations over colon-chained blocks:\n\n```abap\n\" Anti-pattern: Chained declaration obscures diffs\nDATA: lv_status TYPE bstat,\n      lv_amount TYPE dmbtr.\n\n\" Recommended: Independent statements\nDATA lv_status TYPE bstat.\nDATA lv_amount TYPE dmbtr.\n```\n\nStructure definitions beginning with `BEGIN OF` are exempt when `ALLOW_STRUCTURE_CHAINS` is enabled (the default). The `PREFINLDCL` quickfix splits each chained entry into an independent statement prefixed by the appropriate declaration keyword. Suppress findings using `\"#EC NO_CHAINED_DECL`."
  },
  {
    "ruleId": "no-chained-assign",
    "title": "Avoid Chained Assignments Binding Multiple Targets Simultaneously",
    "rationale": "Chained assignments such as target_a = target_b = value evaluate from right to left, assigning intermediate evaluation results across multiple targets in a single statement. This construct reduces code clarity, complicates runtime debugging in the ABAP Debugger where step-by-step target inspection is hindered, and creates subtle bugs when types differ between variables. Split chained assignments into explicit, sequential assignment statements to ensure transparent execution order and straightforward refactoring. The check reports NO_CHN_ASG and splits assignments with the SPLITASG quickfix.",
    "className": "/SKYL/CL_NO_CHAINED_ASSIGN",
    "pseudoComment": "NO_CHAINED_ASSIGN",
    "category": "anti-patterns",
    "example": {
      "bad": "lv_order_status = lv_header_status = lv_default_status.",
      "good": "lv_header_status = lv_default_status.\nlv_order_status = lv_header_status."
    },
    "seo": {
      "description": "Avoid chained assignments across multiple variables and use sequential assignment statements in Clean ABAP.",
      "keywords": [
        "no-chained-assign",
        "chained assignments",
        "multiple assignment",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-chained-decl",
      "no-redun-assign",
      "no-unused-vars"
    ],
    "customSection": "### Execution Order and Debugging\n\nChained assignments evaluate right-to-left:\n\n```abap\n\" Anti-pattern: Chained assignment hides step-wise evaluation\nlv_invoice_total = lv_cleared_total = 0.\n\n\" Recommended: Explicit sequential assignments\nlv_cleared_total = 0.\nlv_invoice_total = lv_cleared_total.\n```\n\nEqual signs inside parentheses (such as `xsdbool( lv_status = 'X' )` or method parameter bindings `compute( iv_param = 1 )`) are recognized as nested expressions and are not flagged. The `SPLITASG` quickfix unrolls chained assignments in right-to-left evaluation order. Suppress findings with `\"#EC NO_CHAINED_ASSIGN`."
  },
  {
    "ruleId": "pref-str-tmpl",
    "title": "Compose Messages with String Templates Instead of CONCATENATE",
    "rationale": "CONCATENATE needs a target variable and an optional SEPARATED BY addition, splits one message into a list of operands and cannot be nested in an expression. A string template keeps the text and the embedded values together, supports formatting options for dates, numbers and alignment, and composes directly inside method calls and constructor expressions. The check reports PREF_STMPL and the TOTEMPLATE quickfix rewrites the statement, including the CONCATENATE LINES OF variant which becomes concat_lines_of( ).",
    "className": "/SKYL/CL_PREF_STR_TMPL",
    "pseudoComment": "PREF_STR_TMPL",
    "category": "clean-abap",
    "example": {
      "bad": "CONCATENATE 'Order' lv_order_id 'was created on' lv_creation_date INTO lv_message SEPARATED BY space.",
      "good": "lv_message = |Order { lv_order_id } was created on { lv_creation_date }|."
    },
    "seo": {
      "description": "Replace CONCATENATE and SEPARATED BY with |...| string templates or concat_lines_of for readable, Cloud-ready text composition.",
      "keywords": [
        "pref-str-tmpl",
        "CONCATENATE",
        "string template",
        "concat_lines_of",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-str-func",
      "no-useless-concat",
      "no-obs-strings"
    ],
    "customSection": "## Conversion Notes\n\n- `CONCATENATE ... BYTE MODE` is ignored: binary concatenation has no string template equivalent.\n- `CONCATENATE LINES OF itab INTO target [SEPARATED BY sep]` is rewritten to `concat_lines_of( table = itab [sep = sep] )`.\n- All other statements become `target = |operand{ sep }operand|`; the `TOTEMPLATE` quickfix applies exactly that rewrite so the resulting statement stays valid ABAP.\n- `CONCATENATE` is not released for ABAP Cloud, so migrating is also a Cloud-readiness requirement."
  },
  {
    "ruleId": "no-bool-compare",
    "title": "Avoid Comparing Boolean Method Calls to abap_true or abap_false",
    "rationale": "Predicate methods that return a boolean flag (abap_bool) can be called directly within IF, ELSEIF, CHECK, and WHILE conditions. Comparing such method invocations to abap_true or abap_false is redundant, adds unnecessary syntax clutter, and obscures the predicate intent of the call. In Clean ABAP and ABAP Cloud, invoke the boolean-returning method directly as a predicate expression, using NOT when asserting the false condition. The check flags redundant comparisons with NO_BOOL_CM and offers the DROPBOOL quickfix to remove the literal.",
    "className": "/SKYL/CL_NO_BOOL_COMPARE",
    "pseudoComment": "NO_BOOL_COMPARE",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lo_permission_checker->is_authorized( ) = abap_true.\n  process_payment( ).\nENDIF.",
      "good": "IF lo_permission_checker->is_authorized( ).\n  process_payment( ).\nENDIF."
    },
    "seo": {
      "description": "Avoid comparing boolean predicate method calls to abap_true or abap_false in Clean ABAP conditions.",
      "keywords": [
        "no-bool-compare",
        "predicate method",
        "boolean comparison",
        "abap_true",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "max-bool-expr",
      "no-single-when",
      "no-check-stmt"
    ],
    "customSection": "### Predicate Expressions and QuickFix\n\nIn ABAP Cloud and modern kernel versions, methods returning an `abap_bool` parameter serve directly as conditional predicates:\n\n| Redundant Comparison | Clean ABAP Replacement |\n|---|---|\n| `IF lo_auth->is_valid( ) = abap_true.` | `IF lo_auth->is_valid( ).` |\n| `IF lo_auth->is_valid( ) <> abap_false.` | `IF lo_auth->is_valid( ).` |\n| `IF lo_auth->is_valid( ) = abap_false.` | `IF NOT lo_auth->is_valid( ).` |\n\nThe `DROPBOOL` quickfix automatically removes `= abap_true` or `<> abap_false`. Variable comparisons (`IF lv_flag = abap_true.`) are not reported because bare variable predicates (`IF lv_flag.`) are restricted in ABAP Cloud. Suppress findings using `\"#EC NO_BOOL_COMPARE`."
  },
  {
    "ruleId": "pref-return",
    "title": "Use RETURN Instead of EXIT Outside Loops",
    "rationale": "EXIT is overloaded: inside a loop it terminates the iteration, outside a loop it leaves the whole procedure, and from inside a loop it even leaves the procedure as well. That context sensitivity makes EXIT easy to misjudge when surrounding code moves. The check tracks loop nesting across LOOP, DO, WHILE and row-by-row SELECT, reports PREF_RET only for an EXIT outside every loop and offers the EXIT2RET quickfix that keeps the indentation of the original statement.",
    "className": "/SKYL/CL_PREF_RETURN",
    "pseudoComment": "PREF_RETURN",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_order_is_locked = abap_true.\n  EXIT.\nENDIF.\nprocess_order( lv_order_id ).",
      "good": "IF lv_order_is_locked = abap_true.\n  RETURN.\nENDIF.\nprocess_order( lv_order_id )."
    },
    "seo": {
      "description": "Report EXIT statements that leave a procedure instead of a loop and offer a RETURN quickfix for explicit control flow.",
      "keywords": [
        "pref-return",
        "EXIT",
        "RETURN",
        "loop control",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-ignored-return",
      "no-unnec-return",
      "pref-early-ret"
    ],
    "customSection": "## Loop Detection\n\n`EXIT` is treated as loop control while inside `LOOP`, `DO`, `WHILE` or a row-by-row `SELECT`; a `SELECT SINGLE`, `SELECT ... INTO TABLE` or `SELECT ... APPENDING TABLE` does not open a loop. Only an `EXIT` outside that nesting is reported as `PREF_RET`. The `EXIT2RET` quickfix is created for a standalone `EXIT.` statement; an `EXIT` with an addition is reported without a quickfix."
  },
  {
    "ruleId": "no-check-stmt",
    "title": "Avoid CHECK Statements Inside and Outside Iteration Loops",
    "rationale": "The CHECK statement exhibits dual, context-dependent semantics in ABAP: inside a loop (LOOP, DO, WHILE) it functions as CONTINUE to cycle iteration, whereas outside loops it abruptly acts as RETURN from the procedure. This duality creates subtle defects during code refactoring when code containing CHECK is extracted into or moved outside a loop block. Clean ABAP rules strictly prohibit CHECK, recommending explicit guard clauses such as IF NOT ( ... ) CONTINUE inside loops or IF NOT ( ... ) RETURN outside loops. The check reports NO_CHK_LP or NO_CHK_OUT and provides automated quickfixes for both scenarios.",
    "className": "/SKYL/CL_NO_CHECK_STMT",
    "pseudoComment": "NO_CHECK_IN_LOOP",
    "category": "anti-patterns",
    "example": {
      "bad": "LOOP AT lt_invoices INTO ls_invoice.\n  CHECK ls_invoice-payment_status = 'PAID'.\n  process_settlement( ls_invoice ).\nENDLOOP.",
      "good": "LOOP AT lt_invoices INTO ls_invoice.\n  IF ls_invoice-payment_status <> 'PAID'.\n    CONTINUE.\n  ENDIF.\n  process_settlement( ls_invoice ).\nENDLOOP."
    },
    "parameters": {
      "CHECK_IN_LOOP": "Detect CHECK statements within loops (LOOP, DO, WHILE) and propose IF NOT ... CONTINUE guard clauses.",
      "CHECK_OUTSIDE_LOOP": "Detect CHECK statements outside loops and propose IF NOT ... RETURN guard clauses."
    },
    "seo": {
      "description": "Avoid ambiguous CHECK statements and replace them with explicit IF CONTINUE or IF RETURN guard clauses in Clean ABAP.",
      "keywords": [
        "no-check-stmt",
        "CHECK statement",
        "guard clause",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-single-when",
      "no-bool-compare",
      "no-yoda-cond"
    ],
    "customSection": "### Contextual Semantics and QuickFixes\n\n`CHECK` has unpredictable behavior when moved between contexts:\n\n| Context | CHECK Behavior | Clean ABAP Replacement | QuickFix |\n|---|---|---|---|\n| Inside Loop (`LOOP`, `DO`, `WHILE`) | Cycles to next iteration | `IF NOT ( cond ). CONTINUE. ENDIF.` | `IFGUARD` |\n| Outside Loop (Method Body) | Exits current procedure | `IF NOT ( cond ). RETURN. ENDIF.` | `IFRET` |\n\nThe check provides two distinct finding codes: `NO_CHK_LP` (suppress with `\"#EC NO_CHECK_IN_LOOP`) and `NO_CHK_OUT` (suppress with `\"#EC NO_CHECK_OUTSIDE_LOOP`). Both behaviors are configurable via attributes `CHECK_IN_LOOP` and `CHECK_OUTSIDE_LOOP`."
  },
  {
    "ruleId": "no-empty-block",
    "title": "Avoid Empty Control Blocks in Branching and Looping Statements",
    "rationale": "Empty control blocks in IF, ELSEIF, ELSE, CASE, LOOP, DO, WHILE, or TRY constructs typically signal forgotten business logic, incomplete error handling, or abandoned prototypes. Leaving vacant blocks confuses reviewers and maintainers, who must verify whether the lack of action was intentional or a bug. In Clean ABAP, invert or simplify the condition to remove the empty branch entirely, or remove unused loops and TRY blocks that have no CATCH handling. The check flags empty blocks with NO_EMPTY_B or NO_TRY_WO and removes redundant control blocks via the RMBLOCK quickfix.",
    "className": "/SKYL/CL_NO_EMPTY_BLOCK",
    "pseudoComment": "NO_EMPTY_BLOCK",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_is_contract_active = abap_true.\nELSE.\n  terminate_subscription( ).\nENDIF.",
      "good": "IF lv_is_contract_active = abap_false.\n  terminate_subscription( ).\nENDIF."
    },
    "parameters": {
      "CHECK_IF": "Detect empty IF, ELSEIF, or ELSE branches.",
      "CHECK_LOOP": "Detect empty LOOP blocks containing no executable statements.",
      "CHECK_CASE": "Detect empty CASE or WHEN blocks.",
      "CHECK_TRY": "Detect empty TRY blocks containing no protected statements.",
      "CHECK_CATCH": "Detect empty CATCH blocks containing no exception handling.",
      "CHECK_TRY_NO_CATCH": "Detect TRY blocks that do not specify any CATCH or CLEANUP clause.",
      "CHECK_DO": "Detect empty DO iteration blocks.",
      "CHECK_WHILE": "Detect empty WHILE iteration blocks."
    },
    "seo": {
      "description": "Detect and remove empty control blocks in IF, CASE, LOOP, and TRY statements in Clean ABAP and SAP ATC.",
      "keywords": [
        "no-empty-block",
        "empty control block",
        "Clean ABAP",
        "empty CATCH",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-nesting",
      "no-single-when",
      "no-check-stmt"
    ],
    "customSection": "### Supported Control Structures and Findings\n\nThe rule flags empty bodies across all standard ABAP control flow statements:\n\n| Statement | Trigger Condition | Finding Code |\n|---|---|---|\n| `IF` / `ELSEIF` / `ELSE` | Consecutive boundary keywords (e.g. `IF ... ELSE`, `ELSE ... ENDIF`) | `NO_EMPTY_B` |\n| `LOOP` / `DO` / `WHILE` | Consecutive start and end loop keywords without body statements | `NO_EMPTY_B` |\n| `CASE` / `WHEN` | Consecutive `WHEN` without statements or empty `CASE ... ENDCASE` | `NO_EMPTY_B` |\n| `TRY` / `CATCH` | Empty `CATCH` block without error handling | `NO_EMPTY_B` |\n| `TRY` without `CATCH` | `TRY` block lacking any `CATCH` or `CLEANUP` handler | `NO_TRY_WO` |\n\nThe `RMBLOCK` quickfix deletes empty blocks automatically. Suppress findings using `\"#EC NO_EMPTY_BLOCK`."
  },
  {
    "ruleId": "no-ident-cont",
    "title": "Extract Identical Statements Shared Across All IF and ELSE Branches",
    "rationale": "When the first or last statement of every branch in an IF / ELSEIF / ELSE structure is identical, the logic is being executed unconditionally regardless of which branch evaluates to true. Duplicating statements across branches clutters control structures, obscures which operations are truly branch-dependent, and creates maintenance overhead when the common operation must be changed. In Clean ABAP, hoist identical leading statements before the IF block and trailing statements after the ENDIF. The check flags duplicate branch boundaries with finding NO_IDN_CNT.",
    "className": "/SKYL/CL_NO_IDENT_CONT",
    "pseudoComment": "NO_IDENT_CONT",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_order_status = 'APPROVED'.\n  persist_order_changes( ).\n  log_order_event( 'Approved' ).\nELSE.\n  persist_order_changes( ).\n  log_order_event( 'Rejected' ).\nENDIF.",
      "good": "persist_order_changes( ).\nIF lv_order_status = 'APPROVED'.\n  log_order_event( 'Approved' ).\nELSE.\n  log_order_event( 'Rejected' ).\nENDIF."
    },
    "seo": {
      "description": "Extract identical statements shared across all IF and ELSE branches in Clean ABAP and SAP ATC.",
      "keywords": [
        "no-ident-cont",
        "identical branch statements",
        "code duplication",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-single-when",
      "no-check-stmt",
      "no-bool-compare"
    ],
    "customSection": "### Common Statement Extraction\n\nThe rule inspects all branches (`IF`, `ELSEIF`, and `ELSE`). If every branch begins with the exact same statement, or if every branch ends with the exact same statement, finding `NO_IDN_CNT` is reported on the opening `IF`.\n\n```abap\n\" Anti-pattern: Common statement duplicated in all branches\nIF lv_is_expedited = abap_true.\n  send_notification( ).\n  lv_priority = 1.\nELSE.\n  send_notification( ).\n  lv_priority = 2.\nENDIF.\n\n\" Clean ABAP: Extracted outside the conditional block\nsend_notification( ).\nIF lv_is_expedited = abap_true.\n  lv_priority = 1.\nELSE.\n  lv_priority = 2.\nENDIF.\n```\n\nControl structure boundary keywords (`IF`, `LOOP`, `CASE`, `TRY`) are excluded from extraction. Suppress findings using `\"#EC NO_IDENT_CONT`."
  },
  {
    "ruleId": "no-dup-cond",
    "title": "Avoid Duplicate Conditions in Branching Statements and Logical Operators",
    "rationale": "A duplicated condition in an ELSEIF or WHEN branch can never be executed because the earlier branch with the identical condition always intercepts control first. Similarly, repeating the same operand within a single logical expression (such as cond OR cond or cond AND cond) is redundant and often masks a typographical error where an intended alternative condition was omitted. In Clean ABAP, every conditional branch must possess a distinct predicate and logical expressions must contain unique operands. The check reports NO_DUP_CND or NO_DUP_OPR and provides the REM_DUP_BR quickfix.",
    "className": "/SKYL/CL_NO_DUP_COND",
    "pseudoComment": "NO_DUP_COND",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_delivery_status = 'DELIVERED'.\n  complete_order( ).\nELSEIF lv_delivery_status = 'DELIVERED'.\n  archive_order( ).\nENDIF.",
      "good": "IF lv_delivery_status = 'DELIVERED'.\n  complete_order( ).\nELSEIF lv_delivery_status = 'RETURNED'.\n  archive_order( ).\nENDIF."
    },
    "seo": {
      "description": "Detect duplicate branch conditions in IF/CASE and identical operands in boolean expressions in SAP ATC.",
      "keywords": [
        "no-dup-cond",
        "duplicate condition",
        "unreachable branch",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-yoda-cond",
      "no-neg-cond",
      "pref-cond"
    ],
    "customSection": "### Finding Codes and Detection Modes\n\nThe check inspects both branching structures and compound boolean expressions:\n\n| Finding Code | Trigger Condition | QuickFix |\n|---|---|---|\n| `NO_DUP_CND` | Duplicate condition in `ELSEIF` or duplicate value in `WHEN` | `REM_DUP_BR` removes unreachable branch |\n| `NO_DUP_OPR` | Duplicate operand within `IF`, `WHILE`, `CHECK`, or `ELSEIF` joined by same operator (`AND`/`OR`) | Manual review required |\n\nOuter parentheses are stripped before comparing expressions, so `ELSEIF ( lv_status = 'A' )` correctly matches `IF lv_status = 'A'`. Suppress findings using `\"#EC NO_DUP_COND`."
  },
  {
    "ruleId": "pref-merge-ifs",
    "title": "Merge Redundant Nested IF Blocks",
    "rationale": "A nested IF that immediately follows the outer IF and closes right before the outer ENDIF adds indentation without adding a decision: the two conditions can be combined with AND. An IF that is the only statement of an ELSE block is the same story, where ELSEIF expresses the alternative in one line. The check reports PREF_MRGIF and PREF_ELSIF and offers the USE_ELSEIF quickfix that rewrites ELSE plus IF into ELSEIF and removes the inner ENDIF, lowering nesting and cyclomatic complexity.",
    "className": "/SKYL/CL_PREF_MERGE_IFS",
    "pseudoComment": "PREF_MERGE_IFS",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_is_active = abap_true.\n  IF lv_is_authorized = abap_true.\n    release_sales_order( lv_order_id ).\n  ENDIF.\nENDIF.",
      "good": "IF lv_is_active = abap_true AND lv_is_authorized = abap_true.\n  release_sales_order( lv_order_id ).\nENDIF."
    },
    "seo": {
      "description": "Flatten nested IF blocks with boolean AND and convert an IF inside ELSE into ELSEIF to reduce cyclomatic complexity.",
      "keywords": [
        "pref-merge-ifs",
        "nested IF",
        "ELSEIF",
        "cyclomatic complexity",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-case",
      "pref-cond",
      "pref-switch"
    ],
    "customSection": "## Finding Codes\n\n| Finding code | Pattern | Fix |\n|---|---|---|\n| `PREF_MRGIF` | The inner IF is the first statement of the outer IF and closes immediately before the outer ENDIF | Combine both conditions with `AND` |\n| `PREF_ELSIF` | The outer ELSE block contains exactly one IF that closes immediately before the outer ENDIF | Change `ELSE` + `IF` to `ELSEIF` (quickfix `USE_ELSEIF`) |\n\nBlocks where the inner IF has its own `ELSE` or `ELSEIF`, or where further statements follow it, are not reported because merging would change semantics."
  },
  {
    "ruleId": "no-unreachable",
    "title": "Avoid Unreachable Statements Following Unconditional Exit or Jump Operations",
    "rationale": "Statements positioned directly after an unconditional RETURN, EXIT, CONTINUE, RAISE EXCEPTION, or RAISE SHORTDUMP can never be reached by program execution flow. Such dead code typically remains from earlier debugging sessions, unfinished refactoring, or copy-paste errors, creating confusion for future maintainers and distorting unit test coverage calculations. Clean ABAP mandates removing dead code or moving statements prior to the terminating statement if their execution is required. The check reports NO_UNREACH and provides the DELSTMT quickfix to delete unreachable statements.",
    "className": "/SKYL/CL_NO_UNREACHABLE",
    "pseudoComment": "NO_UNREACHABLE",
    "category": "anti-patterns",
    "example": {
      "bad": "RETURN.\nlv_processed_count = lv_processed_count + 1.",
      "good": "lv_processed_count = lv_processed_count + 1.\nRETURN."
    },
    "seo": {
      "description": "Detect and remove unreachable dead statements after unconditional RETURN, EXIT, or RAISE in Clean ABAP.",
      "keywords": [
        "no-unreachable",
        "unreachable code",
        "dead code",
        "unconditional RETURN",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dead-code",
      "no-magic-numbers",
      "max-method-len"
    ],
    "customSection": "### Unconditional Jump Recognition\n\nThe rule identifies statements directly following any of the following unconditional jump operations at the same block depth:\n\n| Unconditional Jump | Scope of Unreachable Code | QuickFix |\n|---|---|---|\n| `RETURN` | Statements following until `ENDMETHOD` / `ENDFORM` | `DELSTMT` |\n| `EXIT` | Statements following until `ENDLOOP` / `ENDDO` / `ENDWHILE` | `DELSTMT` |\n| `CONTINUE` | Statements following until `ENDLOOP` / `ENDDO` / `ENDWHILE` | `DELSTMT` |\n| `RAISE EXCEPTION` (non-resumable) | Statements following until enclosing block end | `DELSTMT` |\n| `RAISE SHORTDUMP` | Statements following until enclosing block end | `DELSTMT` |\n\n`RAISE RESUMABLE EXCEPTION` is recognized as resumable and does not mark subsequent statements unreachable. Suppress findings using `\"#EC NO_UNREACHABLE`."
  },
  {
    "ruleId": "no-single-when",
    "title": "Replace Single-Branch CASE Statements with IF Conditions",
    "rationale": "A CASE construct signals to readers that a variable is matched against multiple mutually exclusive values, so a CASE with only one WHEN branch creates false complexity and unnecessary indentation. Clean ABAP rules recommend using IF for binary or single-value evaluations, which express the conditional logic directly and clearly. In ABAP Cloud and SAP S/4HANA codebases, reserving CASE for three or more alternatives keeps decision tables focused and simplifies subsequent maintenance. Suppress valid exceptions with #EC NO_SINGLE_WHEN.",
    "className": "/SKYL/CL_NO_SINGLE_WHEN",
    "pseudoComment": "NO_SINGLE_WHEN",
    "category": "anti-patterns",
    "example": {
      "bad": "CASE lv_order_status.\n  WHEN 'C'.\n    close_sales_order( ).\nENDCASE.",
      "good": "IF lv_order_status = 'C'.\n  close_sales_order( ).\nENDIF."
    },
    "seo": {
      "description": "Detect CASE statements with only one WHEN branch and convert them into direct IF conditions in ABAP Cloud.",
      "keywords": [
        "no-single-when",
        "CASE statement",
        "IF condition",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dup-cond",
      "pref-case",
      "pref-switch"
    ],
    "customSection": "### Detection Details\n\nThe check scans all CASE structures within executable procedures and counts non-OTHERS WHEN branches:\n\n- Any CASE statement containing zero WHEN branches or exactly one WHEN branch (even if accompanied by a WHEN OTHERS branch) is flagged with finding code `NO_SGL_WHN`.\n- CASE blocks inside type or class definitions are skipped.\n- When multiple alternatives exist (two or more WHEN branches), the statement is considered a genuine decision table and passes.\n\nSuppress individual occurrences using the pseudo-comment `\"#EC NO_SINGLE_WHEN`."
  },
  {
    "ruleId": "no-yoda-cond",
    "title": "Avoid Yoda Conditions by Placing Variables Before Literals",
    "rationale": "Yoda conditions place literals or constants on the left side of comparison operators, reversing the natural subject-verb-object reading order of ABAP logic. While originally adopted in C-family languages to prevent accidental assignment in conditional expressions, ABAP syntax strictly prohibits assignment inside IF or WHILE conditions, rendering Yoda conditions obsolete and confusing. Clean ABAP mandates variable-first comparisons to maintain idiomatic readability across ABAP Cloud and modern ATC-inspected programs.",
    "className": "/SKYL/CL_NO_YODA_COND",
    "pseudoComment": "NO_YODA_COND",
    "category": "anti-patterns",
    "example": {
      "bad": "IF 'CONFIRMED' = lv_delivery_status.\n  ship_sales_order( ).\nENDIF.",
      "good": "IF lv_delivery_status = 'CONFIRMED'.\n  ship_sales_order( ).\nENDIF."
    },
    "seo": {
      "description": "Prevent Yoda conditions in comparisons by placing variables before constants in ABAP Cloud.",
      "keywords": [
        "no-yoda-cond",
        "Yoda conditions",
        "comparison expressions",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dup-cond",
      "no-neg-cond",
      "pref-cond"
    ],
    "customSection": "### QuickFix Operator Inversion\n\nThe `UNYODA` QuickFix automatically transposes the operands and inverts directional comparison operators where required:\n\n| Original Operator | Transposed Operator |\n|---|---|\n| `=` / `EQ` | `=` / `EQ` |\n| `<>` / `NE` | `<>` / `NE` |\n| `<` / `LT` | `>` / `GT` |\n| `>` / `GT` | `<` / `LT` |\n| `<=` / `LE` | `>=` / `GE` |\n| `>=` / `GE` | `<=` / `LE` |\n\nThe rule inspects executable statements where a literal is followed by a comparison operator and a non-literal token. Suppress with `\"#EC NO_YODA_COND`."
  },
  {
    "ruleId": "pref-symbol-op",
    "title": "Replace Textual Comparison Operators (EQ, NE, GT) with Symbols",
    "rationale": "EQ, NE, GT, LT, GE and LE are legacy aliases for =, <>, >, <, >= and <=, and the check also catches the outdated => and =< spellings. Symbolic operators are shorter, follow mathematical notation, and are the only form Clean ABAP allows, so every condition in the code base reads the same way. The check inspects plain keyword tokens in executable statements, therefore the migration is mechanical and the PREFEROP QuickFix can rewrite the affected line without touching anything else.",
    "className": "/SKYL/CL_PREF_SYMBOL_OP",
    "pseudoComment": "PREF_SYMBOL_OP",
    "category": "clean-abap",
    "example": {
      "bad": "IF ls_order_header-total_amount GT ls_customer-credit_limit\n   OR ls_order_header-payment_status NE 'PAID'.\n  reject_sales_order( ).\nENDIF.",
      "good": "IF ls_order_header-total_amount > ls_customer-credit_limit\n   OR ls_order_header-payment_status <> 'PAID'.\n  reject_sales_order( ).\nENDIF."
    },
    "seo": {
      "description": "Replace legacy EQ, NE, GT, LT, GE and LE comparison keywords with the symbolic =, <>, >, <, >= and <= operators in ABAP Cloud and S/4HANA code.",
      "keywords": [
        "pref-symbol-op",
        "Clean ABAP",
        "comparison operators",
        "SAP ATC",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-calc-op",
      "pref-downport",
      "pref-sy"
    ],
    "customSection": "### Replacement table\n\n| Legacy | Symbol |\n| --- | --- |\n| `EQ` | `=` |\n| `NE`, `><` | `<>` |\n| `GT` | `>` |\n| `LT` | `<` |\n| `GE`, `=>` | `>=` |\n| `LE`, `=<` | `<=` |\n\nThe check only inspects executable statements: `DATA`, `TYPES`, `CONSTANTS`, `STATICS`, `PARAMETER`, `PARAMETERS`, `FIELD-SYMBOLS`, `METHODS` and `CLASS-METHODS` are skipped so that a type or parameter that happens to be spelled `EQ` is never reported. Findings can be suppressed per statement with `\"#EC PREF_SYMBOL_OP`; the `PREFEROP` QuickFix rewrites the whole line with the symbolic operator."
  },
  {
    "ruleId": "pref-new-op",
    "title": "Prefer NEW #( ) for Object Creation and RAISE EXCEPTION NEW",
    "rationale": "CREATE OBJECT is a procedural statement that cannot appear inside an expression, and RAISE EXCEPTION TYPE needs a separate class reference plus EXPORTING. NEW #( ) and RAISE EXCEPTION NEW ... ( ) infer the class from the context, can be nested in constructor expressions, method arguments and RETURNING values, and remove the uninitialized-reference window between declaration and creation. The check reports PREF_NEW and PREF_RSNEW and offers a drop-in replacement line as QuickFix whenever the parameter passing is simple enough to rewrite mechanically.",
    "className": "/SKYL/CL_PREF_NEW_OP",
    "pseudoComment": "PREF_NEW_OPERATOR",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lo_invoice_service TYPE REF TO zcl_invoice_service.\nCREATE OBJECT lo_invoice_service EXPORTING iv_company_code = lv_company_code.",
      "good": "DATA(lo_invoice_service) = NEW zcl_invoice_service( iv_company_code = lv_company_code )."
    },
    "parameters": {
      "CHECK_CREATE_OBJECT": "Report CREATE OBJECT statements that can be replaced by a NEW #( ) expression. Disable only for legacy frameworks that insist on CREATE OBJECT.",
      "CHECK_RAISE_EXCEPTION": "Report RAISE EXCEPTION TYPE statements that can be rewritten as RAISE EXCEPTION NEW zcx_error( ... ). Disable when exception classes are created dynamically."
    },
    "seo": {
      "description": "Modernize object creation: replace CREATE OBJECT with the NEW #( ) expression and RAISE EXCEPTION TYPE with RAISE EXCEPTION NEW in ABAP Cloud.",
      "keywords": [
        "pref-new-op",
        "CREATE OBJECT",
        "NEW operator",
        "RAISE EXCEPTION NEW",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-pub-ctor",
      "pref-factory-name",
      "pref-final-cls"
    ],
    "customSection": "### Finding codes\n\n| Code | Trigger | QuickFix |\n| --- | --- | --- |\n| `PREF_NEW` | `CREATE OBJECT lo_ref EXPORTING ...` | `TONEW` rewrites it to `lo_ref = NEW #( ... )` |\n| `PREF_RSNEW` | `RAISE EXCEPTION TYPE zcx_error EXPORTING ...` | `RAISENEW` rewrites it to `RAISE EXCEPTION NEW zcx_error( ... )` |\n\nThe rewrite is only produced for a static class name and a flat `EXPORTING name = value` list. `CREATE OBJECT ... TYPE (lv_class)`, `PARAMETER-TABLE`, `EXCEPTIONS`, `MESSAGE`, `MESSAGE-ID` and `FOR TESTING` are left untouched, so inherited or dynamic creation keeps reporting nothing but the finding. The two checks are switched independently through `CHECK_CREATE_OBJECT` and `CHECK_RAISE_EXCEPTION`, and can be suppressed with `\"#EC PREF_NEW_OPERATOR` / `\"#EC PREF_RAISE_EXC_NEW`."
  },
  {
    "ruleId": "pref-xsdbool",
    "title": "Replace IF/ELSE Boolean Assignments with xsdbool( )",
    "rationale": "When both branches of an IF only assign abap_true and abap_false to the same variable, the whole block is a single boolean expression written the long way. xsdbool( ) evaluates the condition once, returns a type-correct flag, and removes the duplicated branches so the two assignments can never drift apart during maintenance. The check only fires for the exact IF/assignment/ELSE/assignment/ENDIF shape, and its TOXSDBOOL QuickFix inverts the condition with NOT when the true branch holds the false literal.",
    "className": "/SKYL/CL_PREF_XSDBOOL",
    "pseudoComment": "PREF_XSDBOOL",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_available_quantity > lv_reorder_threshold.\n  lv_is_reorder_required = abap_true.\nELSE.\n  lv_is_reorder_required = abap_false.\nENDIF.",
      "good": "lv_is_reorder_required = xsdbool( lv_available_quantity > lv_reorder_threshold )."
    },
    "seo": {
      "description": "Convert duplicated IF/ELSE flag assignments into a single xsdbool( ) expression to shorten boolean guards and remove dead branches in ABAP.",
      "keywords": [
        "pref-xsdbool",
        "xsdbool",
        "boolean expression",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-bool-expr",
      "pref-case",
      "pref-cond"
    ],
    "customSection": "### Detected pattern\n\nThe rule only fires when the block consists of exactly five statements:\n\n```abap\nIF <condition>.\n  <target> = abap_true.\nELSE.\n  <target> = abap_false.\nENDIF.\n```\n\nBoth assignments must target the same variable with opposite literals; an extra statement, a missing `ELSE`, or two different targets keep the `IF` untouched. When the true branch assigns `abap_false`, the QuickFix wraps the condition in `NOT ( ... )`. The finding code is `PREF_XSDBL` and the pseudo-comment is `\"#EC PREF_XSDBOOL`."
  },
  {
    "ruleId": "no-static-arrow",
    "title": "Call Static Methods with Class Component Selector (=>)",
    "rationale": "Invoking a static method through an instance dereference arrow (->) gives the misleading impression that polymorphic dynamic dispatch is occurring, even though the call is bound statically at compile time. It also introduces an unnecessary dependency on an instantiated object reference that could be initial, obscuring actual program architecture and confusing static call-graph analyzers. Clean ABAP requires using the class component selector (=>) directly on the defining class name, which clarifies static binding and improves ABAP Cloud readiness.",
    "className": "/SKYL/CL_NO_STATIC_ARROW",
    "pseudoComment": "NO_STATIC_ARROW",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lo_tax_calculator TYPE REF TO zcl_tax_calculator.\nlo_tax_calculator->calculate_vat_amount( iv_net_amount = lv_net_amount ).",
      "good": "zcl_tax_calculator=>calculate_vat_amount( iv_net_amount = lv_net_amount )."
    },
    "seo": {
      "description": "Avoid invoking static methods via instance arrow (->); call directly via class selector (=>) in ABAP Cloud.",
      "keywords": [
        "no-static-arrow",
        "static methods",
        "class component selector",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-static-cls",
      "pref-factory-name",
      "no-instance-of"
    ],
    "customSection": "### Static Method Resolution\n\nThe check inspects method call tokens containing `->` and uses ABAP Run-Time Type Identification (RTTI) to verify whether the target method is declared as a static `CLASS-METHODS`. Because RTTI requires local type descriptor resolution, this rule operates with `remote_enablement = abap_false`.\n\nThe `STATICCL` QuickFix resolves the defining class name and replaces the instance dereference with `class_name=>method_name( )`. Suppress false positives with `\"#EC NO_STATIC_ARROW`."
  },
  {
    "ruleId": "no-exposed-data",
    "title": "Encapsulate Public Class Attributes and Interface Variables",
    "rationale": "Exposing mutable DATA attributes in class PUBLIC sections or declaring DATA inside interfaces breaches core object-oriented encapsulation by allowing external consumers to directly mutate internal state without validation or invariant enforcement. In ABAP Cloud and Clean ABAP architecture, classes must protect internal representation using PRIVATE or PROTECTED sections accompanied by dedicated accessor methods or READ-ONLY declarations. Interfaces must represent pure contracts containing only method definitions, types, and immutable CONSTANTS.",
    "className": "/SKYL/CL_NO_EXPOSED_DATA",
    "pseudoComment": "PUBLIC_ATTR",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS zcl_customer_profile DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2.\nENDCLASS.",
      "good": "CLASS zcl_customer_profile DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2 READ-ONLY.\nENDCLASS."
    },
    "parameters": {
      "CHECK_PUBLIC_ATTR": "Report public class attributes that lack the READ-ONLY addition to prevent unrestricted mutation.",
      "CHECK_INTF_DATA": "Report mutable DATA and CLASS-DATA variable declarations inside interfaces; use methods or CONSTANTS."
    },
    "seo": {
      "description": "Enforce encapsulation by prohibiting mutable public class attributes and interface DATA in ABAP Cloud.",
      "keywords": [
        "no-exposed-data",
        "encapsulation",
        "READ-ONLY",
        "interface data",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-static-cls",
      "pref-intf-segreg",
      "no-instance-of"
    ],
    "customSection": "### Finding Codes and Configuration\n\n| Finding Code | Description | Pseudo-Comment |\n|---|---|---|\n| `NO_PUB_ATR` | Mutable `DATA` or `CLASS-DATA` attribute declared in `PUBLIC SECTION` without `READ-ONLY` | `\"#EC NO_PUBLIC_ATTR` |\n| `NO_INTF_DA` | Mutable `DATA` or `CLASS-DATA` declaration located inside an `INTERFACE` | `\"#EC NO_INTERFACE_DATA` |\n\nBoth checks are enabled by default and can be configured independently through rule parameters."
  },
  {
    "ruleId": "no-obs-arith",
    "title": "Replace Obsolete Arithmetic Statements with Modern Operators",
    "rationale": "Legacy arithmetic statements such as ADD, SUBTRACT, MULTIPLY, DIVIDE, and ADD-CORRESPONDING originate from early procedural ABAP and clutter code compared to standard mathematical expressions (=, +, -, *, /). Similarly, COMPUTE is redundant before assignment, MOVE ... TO is superseded by =, and GET REFERENCE OF ... INTO is replaced by REF #( ). In modern ABAP Cloud (Contract C1), these obsolete statements are deprecated or syntax errors, and replacing them with concise functional expressions significantly enhances code readability.",
    "className": "/SKYL/CL_NO_OBS_ARITH",
    "pseudoComment": "NO_OBS_ARITH",
    "category": "anti-patterns",
    "example": {
      "bad": "ADD 1 TO lv_item_counter.\nMOVE ls_order_item-gross_amount TO lv_total_amount.\nGET REFERENCE OF lv_total_amount INTO lr_total_ref.",
      "good": "lv_item_counter = lv_item_counter + 1.\nlv_total_amount = ls_order_item-gross_amount.\nlr_total_ref = REF #( lv_total_amount )."
    },
    "parameters": {
      "CHECK_ADD": "Detect obsolete ADD ... TO, SUBTRACT ... FROM, MULTIPLY ... BY, and DIVIDE ... BY statements.",
      "CHECK_ADD_CORR": "Detect obsolete ADD-CORRESPONDING, SUBTRACT-CORRESPONDING, and related CORRESPONDING arithmetic.",
      "CHECK_COMPUTE": "Detect redundant COMPUTE keywords preceding calculation assignments.",
      "CHECK_MOVE": "Detect obsolete MOVE ... TO assignment statements in favor of the equal (=) operator.",
      "CHECK_GET_REF": "Detect obsolete GET REFERENCE OF ... INTO statements in favor of modern REF #( ) expressions."
    },
    "seo": {
      "description": "Replace obsolete arithmetic and assignment statements like ADD, MOVE, and COMPUTE with modern operators in ABAP Cloud.",
      "keywords": [
        "no-obs-arith",
        "obsolete arithmetic",
        "MOVE TO",
        "REF operator",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-obs-control",
      "no-obs-decl",
      "no-obs-memory"
    ],
    "customSection": "### Modern Replacements\n\n| Obsolete Statement | Modern Syntax | QuickFix Code |\n|---|---|---|\n| `ADD x TO y.` | `y = y + x.` | `REPLACE_AR` |\n| `SUBTRACT x FROM y.` | `y = y - x.` | `REPLACE_AR` |\n| `MULTIPLY y BY x.` | `y = y * x.` | `REPLACE_AR` |\n| `DIVIDE y BY x.` | `y = y / x.` | `REPLACE_AR` |\n| `COMPUTE y = x + 1.` | `y = x + 1.` | `REPLACE_AR` |\n| `MOVE x TO y.` | `y = x.` | `REPLACE_AR` |\n| `GET REFERENCE OF x INTO y.` | `y = REF #( x ).` | `REPLACE_AR` |\n\nSuppress findings using `\"#EC NO_OBS_ARITH`."
  },
  {
    "ruleId": "no-unclosed-res",
    "title": "Close Opened Datasets and Database Cursors Explicitly",
    "rationale": "Resources opened on the application server (OPEN DATASET) or database (OPEN CURSOR) must always be explicitly closed with CLOSE DATASET or CLOSE CURSOR before procedure completion. Leaving resources open causes operating system file descriptor leaks, persistent file locks, and risks triggering the fatal runtime error DBSQL_TOO_MANY_OPEN_CURSOR when reaching the SAP session limit of 17 open database cursors. In modern ABAP Cloud, legacy file and cursor operations are replaced with set-based ABAP SQL queries or released streaming APIs.",
    "className": "/SKYL/CL_NO_UNCLOSED_RES",
    "pseudoComment": "NO_UNCLOSED_RES",
    "category": "security",
    "example": {
      "bad": "OPEN CURSOR @DATA(lv_cursor) FOR\n  SELECT partner, name_first, name_last\n    FROM but000\n    WHERE type = '1'.\nFETCH NEXT CURSOR @lv_cursor INTO TABLE @DATA(lt_partners).\n\" Anti-pattern: Database cursor remains unclosed without CLOSE CURSOR!",
      "good": "SELECT partner, name_first, name_last\n  FROM but000\n  WHERE type = '1'\n  INTO TABLE @DATA(lt_partners)\n  UP TO 500 ROWS."
    },
    "parameters": {
      "CHECK_DATASET": "Report OPEN DATASET statements that lack a subsequent CLOSE DATASET statement in the same procedure.",
      "CHECK_CURSOR": "Report OPEN CURSOR statements that lack a matching CLOSE CURSOR statement in the same procedure."
    },
    "seo": {
      "description": "Prevent resource leaks in SAP ABAP by verifying that all OPEN DATASET and OPEN CURSOR statements are explicitly paired with CLOSE operations.",
      "keywords": [
        "no-unclosed-res",
        "OPEN DATASET",
        "OPEN CURSOR",
        "DBSQL_TOO_MANY_OPEN_CURSOR",
        "ABAP resource management"
      ]
    },
    "relatedRules": [
      "no-db-in-loop",
      "no-obs-memory"
    ],
    "customSection": "### Finding Codes\n\n| Finding Code | Description |\n|---|---|\n| `NO_UNCL_DS` | Reports an `OPEN DATASET` statement without a subsequent `CLOSE DATASET` targeting the same file. |\n| `NO_UNCL_CR` | Reports an `OPEN CURSOR` statement without a subsequent `CLOSE CURSOR` targeting the same cursor variable. |\n\n### Configuration Attributes\n\n- `CHECK_DATASET` (Boolean, default `abap_true`): Enables or disables detection of unclosed application server datasets.\n- `CHECK_CURSOR` (Boolean, default `abap_true`): Enables or disables detection of unclosed database cursors.\n\nFindings can be suppressed using the pseudo-comment `\"#EC NO_UNCLOSED_RES`. In ABAP Cloud development, use set-based Open SQL with `UP TO n ROWS` or released file storage APIs instead of low-level cursor and dataset operations."
  },
  {
    "ruleId": "no-obs-decl",
    "title": "Replace Obsolete Data Declarations with Explicit Types",
    "rationale": "Legacy declaration constructs such as TABLES, RANGES, TYPE-POOLS, and internal tables defined WITH HEADER LINE, OCCURS, or INITIAL SIZE introduce implicit global state, obsolete paging mechanisms, and ambiguous identifier semantics. Modern ABAP Cloud and Clean ABAP strictly require explicit type definitions, standard RANGE OF types, explicit table keys (WITH EMPTY KEY or WITH UNIQUE KEY), and CLEAR instead of REFRESH. Eliminating these obsolete declarations guarantees compatibility with S/4HANA Cloud and clean object-oriented scopes.",
    "className": "/SKYL/CL_NO_OBS_DECL",
    "pseudoComment": "NO_OBS_DECL",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lt_sales_items TYPE STANDARD TABLE OF string WITH HEADER LINE.\nREFRESH lt_sales_items.",
      "good": "DATA lt_sales_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.\nCLEAR lt_sales_items."
    },
    "parameters": {
      "CHECK_TABLES": "Detect obsolete TABLES declarations that define global table work areas.",
      "CHECK_TYPE_POOLS": "Detect obsolete TYPE-POOLS statements; type pools are loaded automatically in modern ABAP.",
      "CHECK_RANGES": "Detect obsolete RANGES declarations in favor of modern RANGE OF types.",
      "CHECK_HEADER_LINE": "Detect internal tables defined with obsolete header lines (WITH HEADER LINE).",
      "CHECK_OCCURS": "Detect legacy OCCURS additions in internal table declarations.",
      "CHECK_INITIAL_SIZE": "Detect obsolete INITIAL SIZE additions on internal table declarations.",
      "CHECK_COMMON_PART": "Detect obsolete DATA COMMON PART statements that share memory across programs.",
      "CHECK_STATICS": "Detect STATICS declarations in methods; persist state in object attributes instead.",
      "CHECK_FS_STRUCTURE": "Detect obsolete FIELD-SYMBOLS declarations typed with the STRUCTURE addition.",
      "CHECK_LOAD": "Detect obsolete CLASS ... LOAD or INTERFACE ... LOAD statements.",
      "CHECK_PARAMETER": "Detect obsolete PARAMETER keyword (singular) in selection screens; use PARAMETERS.",
      "CHECK_REFRESH": "Detect obsolete REFRESH statements on internal tables in favor of CLEAR."
    },
    "seo": {
      "description": "Eliminate obsolete ABAP declarations including TABLES, RANGES, and WITH HEADER LINE for ABAP Cloud.",
      "keywords": [
        "no-obs-decl",
        "WITH HEADER LINE",
        "TABLES declaration",
        "RANGES",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-control",
      "no-obs-memory"
    ],
    "customSection": "### Supported Replacements and QuickFixes\n\n| Legacy Declaration | Modern Replacement | QuickFix |\n|---|---|---|\n| `REFRESH itab.` | `CLEAR itab.` | `REPLACE_DC` |\n| `PARAMETER p_param.` | `PARAMETERS p_param.` | `REPLACE_DC` |\n| `TABLES dbtab.` | Explicit work area `DATA ls_row TYPE dbtab.` | None |\n| `RANGES lr_range FOR field.` | `DATA lr_range TYPE RANGE OF field.` | None |\n| `... WITH HEADER LINE` | Separate table and work area declarations | None |\n| `... OCCURS n` / `INITIAL SIZE n` | Modern internal table declaration | None |\n| `TYPE-POOLS pool.` | Remove statement; type pools are automatic | None |\n\nSuppress findings with `\"#EC NO_OBS_DECL`."
  },
  {
    "ruleId": "no-obs-control",
    "title": "Eliminate Obsolete Control Flow and Procedural Statements",
    "rationale": "Procedural control flow constructs—including subroutines (FORM / PERFORM), macro expansions (DEFINE), unconditioned BREAK-POINT, control breaks (AT NEW, AT END, ON CHANGE OF, SUM), and SET EXTENDED CHECK—violate modern lexical scoping and are prohibited in ABAP Cloud (Contract C1). Subroutines lack typed interfaces and leak global variables, while control break statements inside loops rely on brittle field positioning in work areas. Encapsulating logic in modular class methods and modern LOOP AT ... GROUP BY expressions creates robust, testable code.",
    "className": "/SKYL/CL_NO_OBS_CONTROL",
    "pseudoComment": "NO_OBS_CONTROL",
    "category": "anti-patterns",
    "example": {
      "bad": "BREAK-POINT.\nSET EXTENDED CHECK OFF.",
      "good": "calculate_subtotal( )."
    },
    "parameters": {
      "CHECK_FORM": "Report obsolete FORM definitions and PERFORM subroutine calls in favor of methods.",
      "CHECK_LOOP_CTL": "Report legacy control break statements like AT NEW, AT END, ON CHANGE OF, and SUM.",
      "CHECK_BREAK": "Report hardcoded BREAK-POINT and BREAK statements in non-test production source code.",
      "CHECK_DEFINE": "Report DEFINE macro blocks; macros hide control flow and cannot be debugged cleanly.",
      "CHECK_TEST_SEAMS": "Report TEST-SEAM and TEST-INJECT statements; use dependency injection and interfaces instead.",
      "CHECK_CATCH_SYSTEM": "Report obsolete CATCH SYSTEM-EXCEPTIONS syntax in favor of TRY ... CATCH blocks.",
      "CHECK_SET_EXT_CHECK": "Report obsolete SET EXTENDED CHECK statements that suppress code inspector checks.",
      "CHECK_SELECT_NO_INTO": "Report obsolete SELECT statements without an INTO or APPENDING clause.",
      "CHECK_EXIT_SQL": "Report obsolete EXIT FROM SQL statements that terminate open SQL loops.",
      "CHECK_SORT_BY_FS": "Report obsolete dynamic SORT itab BY `<fs>` field symbol syntax."
    },
    "seo": {
      "description": "Prevent obsolete control statements including FORM, BREAK-POINT, AT NEW, and macros in ABAP Cloud.",
      "keywords": [
        "no-obs-control",
        "FORM PERFORM",
        "BREAK-POINT",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-decl",
      "no-obs-memory"
    ],
    "customSection": "### Reported Obsolete Constructs\n\n| Construct | Category | QuickFix |\n|---|---|---|\n| `BREAK-POINT` / `BREAK` | Unconditioned debugging stop | `RMBRK` (removes statement) |\n| `SET EXTENDED CHECK` | Inspection suppression | `RMEXTCHK` (removes statement) |\n| `FORM` / `PERFORM` | Procedural subroutines | None (refactor to methods) |\n| `DEFINE` | Preprocessor macros | None (refactor to methods) |\n| `AT NEW/END/FIRST/LAST` | Positional loop control breaks | None (use `GROUP BY`) |\n| `ON CHANGE OF` / `SUM` | Legacy loop calculations | None |\n| `TEST-SEAM` / `TEST-INJECT` | Legacy test seams | None (use test injection) |\n| `CATCH SYSTEM-EXCEPTIONS` | Obsolete catch syntax | None (use `TRY..CATCH`) |\n| `EXIT FROM SQL` | SQL loop termination | None |\n| `SORT itab BY <fs>` | Obsolete dynamic sort | None |\n\nSuppress findings with `\"#EC NO_OBS_CONTROL`."
  },
  {
    "ruleId": "no-obs-memory",
    "title": "Prohibit Obsolete ABAP Memory and Cluster Statements",
    "rationale": "Statements interacting with internal ABAP memory or database clusters (EXPORT ... TO MEMORY / DATABASE, FREE MEMORY) and obsolete Context modules (CONTEXTS, DEMAND, SUPPLY, PROVIDE) rely on hidden shared memory regions that break statelessness, multi-tenancy, and test isolation. In ABAP Cloud and cloud-native applications, state must never be stashed in implicit session memory. Instead, exchange data explicitly via method parameters, dependency-injected services, or modern database persistence models.",
    "className": "/SKYL/CL_NO_OBS_MEMORY",
    "pseudoComment": "NO_OBS_MEMORY",
    "category": "anti-patterns",
    "example": {
      "bad": "EXPORT order_id = lv_order_id TO MEMORY ID 'ORDER_BUFFER'.\nFREE MEMORY ID 'ORDER_BUFFER'.",
      "good": "mo_order_repository->store_order_id( iv_order_id = lv_order_id )."
    },
    "parameters": {
      "CHECK_EXPORT_MEMORY": "Report obsolete EXPORT ... TO MEMORY and EXPORT ... TO DATABASE statements.",
      "CHECK_FREE_MEMORY": "Report obsolete FREE MEMORY statements that clear shared ABAP memory buffers.",
      "CHECK_PROVIDE": "Report obsolete PROVIDE and ENDPROVIDE statements for interval processing.",
      "CHECK_CONTEXTS": "Report obsolete CONTEXTS, DEMAND, and SUPPLY statements for legacy context objects.",
      "CHECK_INFOTYPES": "Report obsolete INFOTYPES declarations used in classic HR programming.",
      "CHECK_COMMUNICATION": "Report obsolete COMMUNICATION statements used in legacy CPI-C connections.",
      "CHECK_CALL_TRANSF": "Report obsolete CALL TRANSFORMATION ... OBJECTS statements."
    },
    "seo": {
      "description": "Prohibit obsolete ABAP memory, database clusters, and Context statements in ABAP Cloud.",
      "keywords": [
        "no-obs-memory",
        "EXPORT TO MEMORY",
        "FREE MEMORY",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-control",
      "no-obs-decl"
    ],
    "customSection": "### Prohibited Memory Statements\n\n- `EXPORT ... TO MEMORY` / `EXPORT ... TO DATABASE`: Breaks encapsulation and leaks state across transactions.\n- `FREE MEMORY`: Clears global session buffers without lifecycle management.\n- `PROVIDE` / `ENDPROVIDE`: Legacy interval evaluation on internal tables.\n- `CONTEXTS`, `DEMAND`, `SUPPLY`: Obsolete context objects replaced by core data services (CDS) and classes.\n- `INFOTYPES`: Legacy HR infotype declarations.\n- `COMMUNICATION`: Obsolete CPI-C communication interface.\n- `CALL TRANSFORMATION ... OBJECTS`: Legacy transformation syntax.\n\nSuppress findings with `\"#EC NO_OBS_MEMORY`."
  },
  {
    "ruleId": "no-obs-strings",
    "title": "Replace Obsolete String Statements and POSIX Regular Expressions",
    "rationale": "Legacy string manipulation statements such as PACK, UNPACK, REPLACE ... INTO, and POSIX regular expressions (FIND/REPLACE ... REGEX or CL_ABAP_REGEX POSIX methods) have been superseded by modern string built-in functions, templates, and Perl-Compatible Regular Expressions (PCRE). POSIX regular expressions suffer from quadratic backtracking performance and inconsistent Unicode support, whereas PCRE (via FIND PCRE or XCO regex APIs) is optimized, secure, and standardized across ABAP Cloud.",
    "className": "/SKYL/CL_NO_OBS_STRINGS",
    "pseudoComment": "NO_OBS_STRINGS",
    "category": "anti-patterns",
    "example": {
      "bad": "FIND REGEX '^[0-9]+$' IN lv_postal_code.\nPACK lv_customer_number TO lv_packed_id.",
      "good": "FIND PCRE '^[0-9]+$' IN lv_postal_code.\nlv_packed_id = lv_customer_number."
    },
    "parameters": {
      "CHECK_PACK": "Report obsolete PACK statements in favor of modern numeric assignment expressions.",
      "CHECK_UNPACK": "Report obsolete UNPACK statements in favor of string padding and format functions.",
      "CHECK_REGEX": "Report obsolete POSIX regular expressions in FIND/REPLACE statements in favor of PCRE.",
      "CHECK_OCCURENCES": "Report obsolete OCCURENCES addition syntax (misspelled variant) in string operations.",
      "CHECK_REPLACE_INTO": "Report obsolete REPLACE ... WITH ... INTO statements in favor of assignment expressions."
    },
    "seo": {
      "description": "Detect obsolete string statements like PACK, UNPACK, and POSIX regex in ABAP Cloud.",
      "keywords": [
        "no-obs-strings",
        "POSIX regex",
        "PCRE",
        "PACK UNPACK",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-control",
      "no-obs-decl"
    ],
    "customSection": "### Monitored String Constructs\n\n| Legacy Syntax | Modern Replacement |\n|---|---|\n| `FIND REGEX ...` | `FIND PCRE ...` or XCO Regex APIs |\n| `REPLACE REGEX ...` | `REPLACE PCRE ...` |\n| `PACK source TO dest.` | Direct numeric assignment `dest = source.` |\n| `UNPACK source TO dest.` | String formatting functions or string templates |\n| `REPLACE ... WITH ... INTO ...` | String functions `replace( )` or assignment |\n| `OCCURENCES` (misspelled) | Use `ALL OCCURRENCES` |\n| `CL_ABAP_REGEX=>CREATE_POSIX` | Use PCRE-enabled regex classes |\n\nSuppress with `\"#EC NO_OBS_STRINGS`."
  },
  {
    "ruleId": "no-list-proc",
    "title": "Prohibit Dynpro List Processing Statements in ABAP Cloud",
    "rationale": "Classic dynpro list processing statements—including WRITE, ULINE, SKIP, FORMAT, and LEAVE LIST-PROCESSING—tightly couple business logic with archaic screen list buffers. These statements are fundamentally incompatible with ABAP Cloud (Language Version 5) and cannot function in background processing, headless REST APIs, or OData services. Application logic should format data through string templates and output messages via modern logging frameworks (such as cl_bali_log) or SAP Fiori / RAP consumption models.",
    "className": "/SKYL/CL_NO_LIST_PROC",
    "pseudoComment": "NO_LIST_PROC",
    "category": "anti-patterns",
    "example": {
      "bad": "WRITE / 'Customer invoice processed successfully'.\nULINE.\nSKIP 1.",
      "good": "mo_logger->add_info( 'Customer invoice processed successfully' )."
    },
    "parameters": {
      "CHECK_WRITE": "Report classic list output WRITE statements that target dynpro list buffers.",
      "CHECK_ULINE": "Report classic ULINE statements that output horizontal lines on screen lists.",
      "CHECK_SKIP": "Report classic SKIP statements that insert blank lines into dynpro lists.",
      "CHECK_OTHER": "Report formatting and list control statements like FORMAT, BACK, HIDE, and READ LINE.",
      "IGN_WRITE_TO": "Ignore WRITE ... TO ... string formatting statements (prefer string templates instead).",
      "CHECK_LEAVE": "Report LEAVE LIST-PROCESSING statements that exit dynpro screen list processing.",
      "CHECK_REJECT": "Report obsolete REJECT statements used in classic logical database processing."
    },
    "seo": {
      "description": "Prohibit legacy dynpro list processing statements like WRITE, ULINE, and SKIP in ABAP Cloud.",
      "keywords": [
        "no-list-proc",
        "WRITE statement",
        "ULINE",
        "list processing",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-control",
      "no-obs-decl"
    ],
    "customSection": "### Prohibited List Processing Commands\n\n- `WRITE` (excluding `WRITE ... TO ...` when `IGN_WRITE_TO` is enabled)\n- `ULINE`, `SKIP`, `NEW-LINE`, `NEW-PAGE`\n- `FORMAT`, `POSITION`, `RESERVE`, `BACK`, `HIDE`\n- `READ LINE`, `MODIFY LINE`, `SCROLL LIST`\n- `LEAVE LIST-PROCESSING`, `REJECT`\n\nIn modern ABAP Cloud, replace all classic list statements with structured application logging (`cl_bali_log`) or SAP Fiori UI services. Suppress findings with `\"#EC NO_LIST_PROC`."
  },
  {
    "ruleId": "max-params",
    "title": "Limit Method Parameter Count and Keep One Parameter per Line",
    "rationale": "Methods with extensive parameter signatures violate Clean ABAP design principles by obscuring method intent and inflating coupling between callers and providers. In ABAP Cloud and SAP S/4HANA programming (Contract C1), wide parameter lists containing more than 3 to 5 elementary parameters make unit test mocking tedious and increase invocation error rates. Furthermore, declaring multiple parameters on the same line hampers Git line-by-line blame and code review diffs. Grouping related parameters into coherent flat structures or parameter objects streamlines signatures and makes future interface extensions backward compatible without altering method signatures.",
    "className": "/SKYL/CL_MAX_PARAMS",
    "pseudoComment": "MAX_PARAMS_COUNT",
    "category": "metrics",
    "example": {
      "bad": "CLASS zcl_billing_service DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS process_invoice\n      IMPORTING iv_customer_id TYPE string iv_document_type TYPE string iv_posting_date TYPE d.\nENDCLASS.",
      "good": "CLASS zcl_billing_service DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS process_invoice\n      IMPORTING\n        is_invoice_request TYPE ty_invoice_request\n      RETURNING\n        VALUE(rv_invoice_id) TYPE string.\nENDCLASS."
    },
    "parameters": {
      "MAX_PARAMETERS": "Maximum allowable total method parameters across IMPORTING, EXPORTING, CHANGING, and RETURNING clauses before reporting (default: 8).",
      "CHECK_PARAM_LINE": "Enforce at most one parameter declaration per line in method signatures to ensure readable Git diffs (default: true)."
    },
    "seo": {
      "description": "Enforce Clean ABAP method parameter limits and multi-line formatting to ensure maintainable signatures, cleaner Git diffs, and testable interfaces.",
      "keywords": [
        "max-params",
        "Clean ABAP",
        "method parameters",
        "SAP ATC",
        "parameter object"
      ]
    },
    "relatedRules": [
      "max-method-len",
      "pref-param-name",
      "max-returns"
    ],
    "customSection": "## Detection Details\n\nThis check inspects method definitions within `CLASS ... DEFINITION` sections (`procedure_kinds-class_definition`) for both instance and static methods (`METHODS` and `CLASS-METHODS`).\n\n| Finding Code | Severity | Description | Suppression |\n|---|---|---|---|\n| `MAX_PARAMS` | Warning | Total parameter count exceeds `MAX_PARAMETERS` (default 8) | `##MAX_PARAMS_COUNT` or `\"#EC MAX_PARAMS_COUNT` |\n| `MAX_PARM_L` | Warning | Two or more parameters are declared on the same source code line | `##MAX_PARAMS_LINE` or `\"#EC MAX_PARAMS_LINE` |\n\n### Clean ABAP Best Practice\nPrefer between 0 and 3 parameters per method. When a business process requires more attributes, encapsulate them into a dedicated parameter structure (e.g., `ty_invoice_request`) or a state object. This ensures backward compatibility when adding new fields in Cloud Contract C1 environments without breaking existing callers."
  },
  {
    "ruleId": "no-db-in-loop",
    "title": "Avoid Database Queries Inside Loops (N+1 Query Antipattern)",
    "rationale": "Executing Open SQL queries (SELECT, INSERT, UPDATE, DELETE, or MODIFY) inside loops creates the notorious N+1 query antipattern. Every iteration forces an independent network round trip between the ABAP application server and the database engine, incurring severe latency, thread contention, and connection pool saturation. In high-throughput S/4HANA systems and ABAP Cloud environments, this degrades transaction throughput exponentially. Clean ABAP mandates pre-fetching data in bulk before entering the loop using FOR ALL ENTRIES or SQL JOINs, indexing records in hashed or sorted internal tables, and querying them in memory.",
    "className": "/SKYL/CL_NO_DB_IN_LOOP",
    "pseudoComment": "NO_DB_IN_LOOP",
    "category": "performance",
    "example": {
      "bad": "LOOP AT lt_sales_orders INTO DATA(ls_order).\n  SELECT SINGLE customer_name, country\n    FROM zcustomers\n    WHERE customer_id = @ls_order-customer_id\n    INTO (@DATA(lv_customer_name), @DATA(lv_country)).\nENDLOOP.",
      "good": "IF lt_sales_orders IS NOT INITIAL.\n  SELECT customer_id, customer_name, country\n    FROM zcustomers\n    FOR ALL ENTRIES IN @lt_sales_orders\n    WHERE customer_id = @lt_sales_orders-customer_id\n    INTO TABLE @DATA(lt_customers).\n\n  SORT lt_customers BY customer_id.\n\n  LOOP AT lt_sales_orders INTO DATA(ls_order).\n    READ TABLE lt_customers INTO DATA(ls_customer)\n      WITH KEY customer_id = ls_order-customer_id BINARY SEARCH.\n    IF sy-subrc = 0.\n      \" Process customer data in memory\n    ENDIF.\n  ENDLOOP.\nENDIF."
    },
    "seo": {
      "description": "Eliminate N+1 database queries in SAP ABAP and ABAP Cloud. Prevent latency spikes and database contention by pre-fetching data in bulk before loops.",
      "keywords": [
        "no-db-in-loop",
        "N+1 query ABAP",
        "Open SQL in loop",
        "Clean ABAP database",
        "SAP ATC performance"
      ]
    },
    "relatedRules": [
      "no-select-star",
      "no-unfilt-dml",
      "no-empty-fae"
    ],
    "customSection": "### Detection Details\n\nThe check tracks nesting depth across `LOOP`, `DO`, and `WHILE` control blocks. Any Open SQL statement (`SELECT`, `INSERT`, `UPDATE`, `DELETE`, `MODIFY`, or `OPEN CURSOR`) detected inside an active loop body is reported with finding code `NO_DB_LOOP`.\n\n### Optimization Strategies\n\n- **Bulk Retrieval:** Extract all required lookup values beforehand using `SELECT ... FOR ALL ENTRIES IN @lt_keys` or an explicit SQL `JOIN`.\n- **In-Memory Buffering:** Store retrieved records in a `HASHED TABLE` with a unique key ($O(1)$ lookup) or a `SORTED TABLE` with `BINARY SEARCH` ($O(\\log N)$ lookup).\n- **Bulk DML:** Replace individual row writes with array modifications such as `INSERT dbtab FROM TABLE @lt_records` or `MODIFY dbtab FROM TABLE @lt_records`.\n\nSuppress legitimate single-record reads with the pseudo comment `\"#EC NO_DB_IN_LOOP`."
  },
  {
    "ruleId": "no-empty-fae",
    "title": "Guard FOR ALL ENTRIES Against Empty Driving Tables",
    "rationale": "In SAP Open SQL, if the driving internal table specified in a FOR ALL ENTRIES clause is initial (empty) at runtime, the database interface silently strips the entire WHERE condition. This transforms a targeted query into a catastrophic full-table scan (SELECT * FROM dbtab), retrieving millions of unintended rows, exhausting application server memory with TSV_TNEW_PAGE_ALLOC_FAILED runtime errors, and exhausting database shared locks. In Clean ABAP and ABAP Cloud, every FOR ALL ENTRIES query must be guarded by an explicit empty check on the driving internal table before invoking the database.",
    "className": "/SKYL/CL_NO_EMPTY_FAE",
    "pseudoComment": "NO_EMPTY_FAE",
    "category": "performance",
    "example": {
      "bad": "SELECT order_id, item_id, material_number, net_amount\n  FROM zorder_items\n  FOR ALL ENTRIES IN @lt_orders\n  WHERE order_id = @lt_orders-order_id\n  INTO TABLE @DATA(lt_items).",
      "good": "IF lt_orders IS NOT INITIAL.\n  SELECT order_id, item_id, material_number, net_amount\n    FROM zorder_items\n    FOR ALL ENTRIES IN @lt_orders\n    WHERE order_id = @lt_orders-order_id\n    INTO TABLE @DATA(lt_items).\nELSE.\n  CLEAR lt_items.\nENDIF."
    },
    "seo": {
      "description": "Prevent disastrous full table scans and TSV_TNEW_PAGE_ALLOC_FAILED dumps in ABAP by guarding FOR ALL ENTRIES queries with an empty table check.",
      "keywords": [
        "no-empty-fae",
        "FOR ALL ENTRIES",
        "full table scan",
        "Clean ABAP Open SQL",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-order-by",
      "no-db-in-loop",
      "no-select-star"
    ],
    "customSection": "### Detection Details\n\nThe check inspects `SELECT` statements containing `FOR ALL ENTRIES IN`, resolves the driving table identifier (handling `@`, `ME->`, and `[]`), and scans preceding statements to confirm an active guard. Finding code `NO_EMPTFAE` is raised when the query is unguarded.\n\n### Recognized Guards\n\n- `IF lt_table IS NOT INITIAL.` enclosing the query.\n- `CHECK lt_table IS NOT INITIAL.` prior to the query.\n- `IF lines( lt_table ) > 0.` or `IF line_exists( lt_table[ ... ] ).`\n- Early exit blocks: `IF lt_table IS INITIAL. RETURN. ENDIF.` (also `EXIT` or `RAISE`).\n\n### Quickfix\n\nThe `FAEGUARD` quickfix automatically wraps the offending `SELECT` statement inside an `IF <driving_tab> IS NOT INITIAL.` / `ENDIF.` block with matching indentation.\n\nSuppress intentional full scans with the pseudo comment `\"#EC NO_EMPTY_FAE`."
  },
  {
    "ruleId": "no-select-star",
    "title": "Avoid SELECT * and Project Columns Explicitly",
    "rationale": "Using SELECT * or table~* instructs the database interface to retrieve and transmit every column defined on a table or view, including long character strings, BLOBs, and unused administrative timestamps. On modern columnar databases such as SAP HANA, performance is driven by column-store compression and vectorized memory scans; selecting unneeded columns breaks column pruning, inflates network payload between the database and application server, and wastes heap memory in internal table buffers. Clean ABAP requires explicit column projection to fetch only the exact fields required by business logic.",
    "className": "/SKYL/CL_NO_SELECT_STAR",
    "pseudoComment": "NO_SELECT_STAR",
    "category": "performance",
    "example": {
      "bad": "SELECT *\n  FROM zmaterials\n  WHERE material_type = 'FERT'\n  INTO TABLE @DATA(lt_materials).",
      "good": "SELECT material_number, material_type, base_unit_of_measure, net_weight\n  FROM zmaterials\n  WHERE material_type = 'FERT'\n  INTO TABLE @DATA(lt_materials)."
    },
    "seo": {
      "description": "Enforce explicit column projection in ABAP Open SQL to optimize SAP HANA column store performance and reduce memory consumption.",
      "keywords": [
        "no-select-star",
        "SELECT star",
        "HANA column store",
        "Clean ABAP SQL",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-db-in-loop",
      "no-endselect",
      "pref-order-by"
    ],
    "customSection": "### Detection Details\n\nThe check scans the field list between `SELECT` (or `FIELDS`) and the subsequent query clauses (`FROM`, `WHERE`, `INTO`). Finding code `NO_SEL_STR` is reported when an unadorned `*` or a qualified `table~*` pattern is detected.\n\n### Architectural Benefits\n\n- **HANA Column Store Optimization:** Vector engines only load columns referenced in the query.\n- **Network Reduction:** Dramatically decreases packet payload across the network layer.\n- **Resilience to Table Extensions:** Prevents unexpected structure growth or typing conflicts when new append structures are added to database tables.\n\nSuppress specialized full-row retrievals with the pseudo comment `\"#EC NO_SELECT_STAR`."
  },
  {
    "ruleId": "no-endselect",
    "title": "Avoid SELECT ... ENDSELECT Row-by-Row Cursor Loops",
    "rationale": "The SELECT ... ENDSELECT construct opens an active server-side database cursor and streams rows individually across the network on every iteration. This pattern causes continuous network round trips, holds transactional database locks open, and blocks database connection pool resources. If an unhandled exception or early exit occurs within the loop body, the database cursor can leak or delay parallel application tasks. Clean ABAP mandates bulk array fetches (SELECT ... INTO TABLE) to transfer records in high-speed blocks, or using PACKAGE SIZE when processing massive data sets that cannot fit in memory.",
    "className": "/SKYL/CL_NO_ENDSELECT",
    "pseudoComment": "NO_ENDSELECT",
    "category": "performance",
    "example": {
      "bad": "SELECT customer_id, company_name, city\n  FROM zcustomers\n  WHERE country = 'DE'\n  INTO @DATA(ls_customer).\n  process_customer_record( ls_customer ).\nENDSELECT.",
      "good": "SELECT customer_id, company_name, city\n  FROM zcustomers\n  WHERE country = 'DE'\n  INTO TABLE @DATA(lt_customers).\n\nLOOP AT lt_customers ASSIGNING FIELD-SYMBOL(<ls_customer>).\n  process_customer_record( <ls_customer> ).\nENDLOOP."
    },
    "seo": {
      "description": "Eliminate SELECT ... ENDSELECT database cursor loops in ABAP. Replace row-by-row fetching with high-performance array operations and PACKAGE SIZE batches.",
      "keywords": [
        "no-endselect",
        "SELECT ENDSELECT",
        "database cursor",
        "array fetch",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-db-in-loop",
      "no-select-star",
      "pref-order-by"
    ],
    "customSection": "### Detection Details\n\nThe check evaluates `ENDSELECT` statements. When a `SELECT` loop executes without a `PACKAGE SIZE` clause, finding code `NO_ENDSEL` is reported on the `ENDSELECT` boundary.\n\n### Batch Processing with PACKAGE SIZE\n\nUsing `PACKAGE SIZE` within `SELECT ... ENDSELECT` is explicitly permitted by the check. When processing millions of records in batch workloads, streaming package-by-package into an internal table prevents out-of-memory errors while keeping network round trips minimal.\n\nSuppress single-row cursor loops with the pseudo comment `\"#EC NO_ENDSELECT`."
  },
  {
    "ruleId": "no-scope-leak",
    "title": "Prevent Variable Scope Leakage Outside Control Blocks",
    "rationale": "Unlike languages with block-level lexical scoping, ABAP variables declared inside an IF, LOOP, or TRY block remain visible throughout the remainder of the procedure. Referencing a variable outside the block in which it was declared creates an implicit temporal coupling on whether that specific branch executed, frequently causing uninitialized data defects or race conditions. Clean ABAP rules mandate declaring variables in the outer enclosing scope and assigning them explicitly inside inner control blocks.",
    "className": "/SKYL/CL_NO_SCOPE_LEAK",
    "pseudoComment": "NO_SCOPE_LEAK",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_is_verified = abap_true.\n  DATA(lv_token_value) = get_authorization_token( ).\nENDIF.\ntransmit_payload( lv_token_value ).",
      "good": "DATA lv_token_value TYPE string.\nIF lv_is_verified = abap_true.\n  lv_token_value = get_authorization_token( ).\nENDIF.\ntransmit_payload( lv_token_value )."
    },
    "seo": {
      "description": "Prevent variable scope leaking where variables declared inside control blocks are used outside in ABAP Cloud.",
      "keywords": [
        "no-scope-leak",
        "variable scoping",
        "inline declaration",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-final-data",
      "pref-naming-vars",
      "no-single-letter"
    ],
    "customSection": "### Block Stack Analysis\n\nThe check tracks nesting depth across all major control structures:\n\n- Blocks tracked: `IF`, `LOOP`, `DO`, `WHILE`, `CASE`, and `TRY` (including branch statements `ELSE`, `ELSEIF`, `WHEN`, `CATCH`, `CLEANUP`).\n- Any variable defined inside an active block that is subsequently consumed after that block terminates raises finding code `NO_SCP_LEK`.\n- To resolve the finding, declare the variable explicitly above the control structure and assign its value inside the conditional branch.\n\nSuppress findings with `\"#EC NO_SCOPE_LEAK`."
  },
  {
    "ruleId": "no-redun-assign",
    "title": "Remove Redundant Self-Assignments and Identity Moves",
    "rationale": "Identical self-assignments (such as a = a or MOVE a TO a) perform no real work and indicate copy-paste mistakes, aborted refactorings, or accidentally overlooked target variables. Leaving redundant assignments in production logic introduces noise that confuses automated linters and human code reviewers. In Clean ABAP and ABAP Cloud codebases, removing identical moves eliminates dead code and ensures that all statements contribute meaningfully to business outcomes. Suppress with #EC NO_IDENTICAL_MOVE.",
    "className": "/SKYL/CL_NO_REDUN_ASSIGN",
    "pseudoComment": "NO_IDENTICAL_MOVE",
    "category": "anti-patterns",
    "example": {
      "bad": "ls_sales_order-customer_id = ls_sales_order-customer_id.",
      "good": "ls_sales_order-customer_id = iv_target_customer_id."
    },
    "parameters": {},
    "seo": {
      "description": "Detect and delete redundant self-assignments and identity moves with automated ATC quickfixes in ABAP Cloud.",
      "keywords": [
        "no-redun-assign",
        "self-assignment",
        "redundant assignment",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-chained-assign",
      "no-unused-vars",
      "no-self-compare"
    ],
    "customSection": "### QuickFix Details\n\nThe rule evaluates assignment statements (`COMPUTE` operator `=` and `?=` as well as `MOVE ... TO` and `MOVE ... ?TO`). When the compiler symbol resolution for the target matches the source symbol, finding `NO_IDN_MOV` is reported.\n\nThe `DELIDENT` QuickFix deletes the redundant self-assignment statement completely without altering surrounding code. Suppress with `\"#EC NO_IDENTICAL_MOVE`."
  },
  {
    "ruleId": "no-shadow",
    "title": "Prevent Local Variables from Shadowing Class Attributes",
    "rationale": "Declaring a local variable with the exact same name as an instance or static attribute of the enclosing class silently shadows the member attribute inside that method. This creates ambiguity during code reviews, as readers cannot readily distinguish between local variables and persistent class state, and increases the likelihood of serious bugs when refactoring logic. Clean ABAP requires distinct variable naming conventions (e.g. prefixing local variables with lv_ or using unique domain identifiers) to maintain transparent scoping in ABAP Cloud.",
    "className": "/SKYL/CL_NO_SHADOW",
    "pseudoComment": "NO_SHADOW",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA mv_delivery_date TYPE d.\nmv_delivery_date = sy-datum.",
      "good": "DATA lv_delivery_date TYPE d.\nlv_delivery_date = sy-datum."
    },
    "seo": {
      "description": "Prevent local variables from shadowing class attributes to maintain clean variable scoping in ABAP Cloud.",
      "keywords": [
        "no-shadow",
        "variable shadowing",
        "class attributes",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-unused-vars",
      "pref-naming-vars",
      "pref-name-members"
    ],
    "customSection": "### Shadowing Detection via RTTI\n\nThe check inspects data definitions inside method procedures and queries class attribute names via ABAP Run-Time Type Identification (RTTI):\n\n- Resolves the containing class descriptor using `cl_abap_classdescr`.\n- Compares local `DATA` and inline `DATA(...)` definitions against member attributes.\n- Because RTTI requires local type descriptor resolution, this rule operates with `remote_enablement = abap_false`.\n\nSuppress findings with `\"#EC NO_SHADOW`."
  },
  {
    "ruleId": "no-useless-concat",
    "title": "Fold Adjacent Static String Literals Concatenated with &&",
    "rationale": "Concatenating multiple static character or string literals with the chaining operator && (such as 'api/v1/' && 'orders') computes at runtime a value that is fully known at design time. Pointless literal concatenation adds runtime overhead, fragments text into confusing segments, and increases cognitive load during code reviews. Clean ABAP rules recommend combining adjacent static literals into a single string literal, reserving the && operator strictly for dynamic expressions, variables, and string functions.",
    "className": "/SKYL/CL_NO_USELESS_CONCAT",
    "pseudoComment": "NO_USELESS_CONCAT",
    "category": "anti-patterns",
    "example": {
      "bad": "lv_endpoint_url = 'https://api.gateway.internal' && '/v1/orders/' && 'status'.",
      "good": "lv_endpoint_url = 'https://api.gateway.internal/v1/orders/status'."
    },
    "seo": {
      "description": "Fold adjacent string literals concatenated with && into a single literal in ABAP Cloud.",
      "keywords": [
        "no-useless-concat",
        "string concatenation",
        "literal folding",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-obs-strings",
      "no-dup-literals",
      "pref-str-tmpl"
    ],
    "customSection": "### Literal Folding Mechanics\n\nThe `FOLDLIT` QuickFix combines consecutive static literals into a single folded literal:\n\n- Text field literals (`'...'`) under 250 characters are combined into a single-quoted literal.\n- Text string literals (``` `...` ```) or strings exceeding 250 characters are combined into a backtick text string literal.\n- String templates without embedded expressions (`|...|`) are recognized as static literals.\n\nSuppress findings with `\"#EC NO_USELESS_CONCAT`."
  },
  {
    "ruleId": "pref-full-typed",
    "title": "Declare Constants with an Explicit TYPE and LENGTH",
    "rationale": "A CONSTANTS statement without TYPE derives its type from the literal, so 'CARD' silently becomes a four-character c field and 42 becomes an integer whose range nobody declared. A later change to the literal then alters the constant's type, its comparisons, and every interface that consumes it. Adding TYPE (and LENGTH where relevant) documents the contract, lets the compiler check it, and makes the ADD_TYPE QuickFix deterministic because the type is inferred from the literal.",
    "className": "/SKYL/CL_PREF_FULL_TYPED",
    "pseudoComment": "PREF_FULL_TYPED",
    "category": "clean-abap",
    "example": {
      "bad": "CONSTANTS c_payment_method VALUE 'CARD'.",
      "good": "CONSTANTS c_payment_method TYPE string VALUE 'CARD'.\nCONSTANTS c_max_retry_count  TYPE i      VALUE 3."
    },
    "seo": {
      "description": "Require explicit TYPE and LENGTH on CONSTANTS declarations so literal-inferred types cannot silently truncate values in ABAP Cloud.",
      "keywords": [
        "pref-full-typed",
        "fully typed constants",
        "CONSTANTS TYPE",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-unused-vars",
      "no-hungarian",
      "pref-naming-vars"
    ],
    "customSection": "### Scope and inferred types\n\n- Only `CONSTANTS` statements that use `VALUE` are inspected; constants already declared with `TYPE`/`LIKE` or as `BEGIN OF ... END OF` structures are ignored.\n- The `ADD_TYPE` QuickFix infers `string` for quoted literals, `i` for integer literals and `abap_bool` for `ABAP_TRUE` / `ABAP_FALSE`. Other literal forms still get the `PREF_TYPED` finding, just without a QuickFix.\n- Local `DATA` declarations are intentionally out of scope here: this check guards the published constant contract, not local variable typing."
  },
  {
    "ruleId": "pref-corresp",
    "title": "Replace MOVE-CORRESPONDING with CORRESPONDING #( )",
    "rationale": "MOVE-CORRESPONDING is a statement, so it cannot be used inside an expression and it hides which fields are actually copied. The CORRESPONDING #( ) constructor expression is expression-capable and accepts MAPPING, EXCEPT and DISCARDING to make the field mapping explicit and reviewable. It also combines with inline declarations and BASE ( ... ), which keeps source and target structure visible in one line instead of a hidden implicit copy.",
    "className": "/SKYL/CL_PREF_CORRESP",
    "pseudoComment": "PREF_CORRESP",
    "category": "clean-abap",
    "example": {
      "bad": "MOVE-CORRESPONDING ls_business_partner_api TO ls_business_partner_db.",
      "good": "ls_business_partner_db = CORRESPONDING #( ls_business_partner_api )."
    },
    "seo": {
      "description": "Replace MOVE-CORRESPONDING with the CORRESPONDING #( ) constructor expression and control field mapping with MAPPING, EXCEPT or DISCARDING.",
      "keywords": [
        "pref-corresp",
        "MOVE-CORRESPONDING",
        "CORRESPONDING operator",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-declarations",
      "pref-inline",
      "pref-final-data"
    ],
    "customSection": "### Controlled mappings\n\n`CORRESPONDING #( )` covers everything the statement does, plus explicit control over the copy:\n\n```abap\nls_business_partner_db = CORRESPONDING #( ls_business_partner_api\n                                          MAPPING street_name = street\n                                          EXCEPT last_changed_at ).\n```\n\nThe check skips `MOVE-CORRESPONDING ... EXPANDING` and `... KEEPING`, because those additions change the target structure and have no one-to-one expression equivalent. The `CORRESP` QuickFix is produced only for the plain `MOVE-CORRESPONDING source TO target.` form; suppress other findings with `\"#EC PREF_CORRESP`."
  },
  {
    "ruleId": "max-method-len",
    "title": "Limit Method and Constructor Statement Length",
    "rationale": "Procedures containing excessive statements violate the Single Responsibility Principle (SRP) by mixing multiple levels of abstraction—such as database reads, domain validations, currency calculations, and log persistence—into an unmaintainable monolithic unit. In ABAP Cloud, long methods degrade testability by requiring elaborate test setups with high mock surface areas. Constructors are particularly critical: placing complex business logic or loops in constructors prevents effective dependency injection and automated unit isolation. Restricting method lengths forces decomposition into focused, single-purpose helper methods and domain services.",
    "className": "/SKYL/CL_MAX_METHOD_LEN",
    "pseudoComment": "MAX_METHOD_LEN",
    "category": "metrics",
    "example": {
      "bad": "METHOD process_sales_order.\n  DATA lv_tax_amount TYPE p LENGTH 8 DECIMALS 2.\n  DATA lv_net_amount TYPE p LENGTH 8 DECIMALS 2.\n  DATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.\n  DATA lv_item_count TYPE i.\n  DATA lv_is_valid TYPE abap_bool.\n\n  lv_is_valid = validate_header( is_order_header ).\n  IF lv_is_valid = abap_false.\n    RAISE EXCEPTION NEW cx_bad_argument( ).\n  ENDIF.\n\n  lv_net_amount = calculate_net_total( it_order_items ).\n  lv_tax_amount = calculate_vat( lv_net_amount ).\n  lv_gross_amount = lv_net_amount + lv_tax_amount.\n  lv_item_count = lines( it_order_items ).\n\n  persist_sales_order( is_header = is_order_header\n                       iv_gross  = lv_gross_amount ).\n  update_inventory_allocation( it_order_items ).\n  enqueue_billing_job( is_order_header-order_id ).\n  dispatch_order_confirmation( is_order_header-order_id ).\n  log_order_success( is_order_header-order_id ).\nENDMETHOD.",
      "good": "METHOD process_sales_order.\n  validate_header( is_order_header ).\n  DATA(ls_pricing) = mo_pricing_engine->calculate_totals( it_order_items ).\n  mo_order_repository->save_order( is_header  = is_order_header\n                                   is_pricing = ls_pricing ).\n  mo_order_notifier->dispatch_confirmation( is_order_header-order_id ).\nENDMETHOD."
    },
    "parameters": {
      "MAX_STATEMENTS": "Maximum number of executable ABAP statements allowed in regular method bodies (default: 5).",
      "MAX_CTOR_STATEMENTS": "Maximum number of executable ABAP statements allowed in instance CONSTRUCTOR methods to discourage complex initialization (default: 10)."
    },
    "seo": {
      "description": "Limit method and constructor statement counts in ABAP Cloud to enforce single responsibility and simplify unit testing.",
      "keywords": [
        "max-method-len",
        "Clean ABAP",
        "method length",
        "Single Responsibility",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-line-len",
      "max-params",
      "max-returns"
    ],
    "customSection": "## Detection Details\n\nThe check evaluates the count of statements within procedure bodies (excluding the opening `METHOD` and closing `ENDMETHOD` statements).\n\n| Finding Code | Target | Default Threshold | Suppression |\n|---|---|---|---|\n| `MAX_METH_L` | Regular methods | `MAX_STATEMENTS` (5 statements) | `##MAX_METHOD_LEN` or `\"#EC MAX_METHOD_LEN` |\n| `MAX_CTOR` | `CONSTRUCTOR` methods | `MAX_CTOR_STATEMENTS` (10 statements) | `##MAX_CTOR_LOGIC` or `\"#EC MAX_CTOR_LOGIC` |\n\n### Recommendation\nKeep methods between 3 and 20 statements. Constructors should strictly assign injected dependencies and initialize private attributes; heavy orchestration, database queries, and iterative loops must be moved to factory methods or dedicated initialization routines."
  },
  {
    "ruleId": "max-nesting",
    "title": "Limit Control Flow Block Nesting Depth",
    "rationale": "Deeply nested control structures (such as `IF`, `CASE`, `LOOP`, `DO`, `WHILE`, and `TRY`) cause the 'Arrow Antipattern', where code drifts heavily toward the right margin of the editor. Each level of nesting multiplies the developer's cognitive load, obscures error handling branches, and drastically increases the number of execution permutations that must be exercised during automated unit testing. Clean ABAP mandates flat control flow: inverting conditions and adopting guard clauses with early `RETURN`, `EXIT`, or `CONTINUE` statements keeps the happy path unindented and transparent.",
    "className": "/SKYL/CL_MAX_NESTING",
    "pseudoComment": "MAX_NESTING",
    "category": "metrics",
    "example": {
      "bad": "METHOD process_customer_order.\n  IF is_order-is_active = abap_true.\n    LOOP AT is_order-items INTO DATA(ls_item).\n      IF ls_item-quantity > 0.\n        IF ls_item-is_blocked = abap_false.\n          reserve_inventory_stock( ls_item ).\n        ENDIF.\n      ENDIF.\n    ENDLOOP.\n  ENDIF.\nENDMETHOD.",
      "good": "METHOD process_customer_order.\n  IF is_order-is_active = abap_false.\n    RETURN.\n  ENDIF.\n\n  LOOP AT is_order-items INTO DATA(ls_item).\n    IF ls_item-quantity <= 0 OR ls_item-is_blocked = abap_true.\n      CONTINUE.\n    ENDIF.\n\n    reserve_inventory_stock( ls_item ).\n  ENDLOOP.\nENDMETHOD."
    },
    "parameters": {
      "MAX_DEPTH": "Maximum allowable nesting depth for control blocks (IF, CASE, LOOP, DO, WHILE, TRY) before reporting (default: 3)."
    },
    "seo": {
      "description": "Enforce control flow nesting depth limits in ABAP methods to eliminate arrow antipatterns and promote clean guard clauses.",
      "keywords": [
        "max-nesting",
        "Clean ABAP",
        "guard clauses",
        "control flow nesting",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-inherit",
      "max-bool-expr",
      "max-cyclo-comp"
    ],
    "customSection": "## Monitored Block Keywords\n\nThe check tracks nesting depth dynamically across all procedure statements:\n\n- **Increments Depth:** `IF`, `CASE`, `LOOP`, `DO`, `WHILE`, and `TRY`.\n- **Decrements Depth:** `ENDIF`, `ENDCASE`, `ENDLOOP`, `ENDDO`, `ENDWHILE`, and `ENDTRY`.\n\n| Finding Code | Severity | Trigger | Suppression |\n|---|---|---|---|\n| `MAX_NEST` | Warning | Block statement nested beyond `MAX_DEPTH` (default 3 levels) | `##MAX_NESTING` or `\"#EC MAX_NESTING` |\n\n### Guard Clause Refactoring\nInstead of nesting positive checks deeply, invert preconditions at the start of the procedure and exit immediately via `RETURN` or `CONTINUE`."
  },
  {
    "ruleId": "no-sy-modify",
    "title": "Avoid Direct Modification of System Fields (sy-*)",
    "rationale": "System variables in the sy and syst structures (such as sy-subrc, sy-tabix, and sy-index) are maintained exclusively by the ABAP runtime kernel to reflect the execution state of system statements. Overwriting or clearing system fields manually in application code creates deceptive status values, masks technical failures from previous statements, corrupts debugger visibility, and induces unpredictable control flow across procedure boundaries. Code should communicate status through dedicated local variables, return parameters, or class-based exceptions.",
    "className": "/SKYL/CL_NO_SY_MODIFY",
    "pseudoComment": "NO_SY_MODIFY",
    "category": "security",
    "example": {
      "bad": "SELECT SINGLE partner\n  FROM but000\n  WHERE partner = @lv_partner_id\n  INTO @DATA(lv_found_partner).\nIF sy-subrc <> 0.\n  \" Anti-pattern: Overwrites kernel system field to mask missing partner\n  sy-subrc = 0.\nENDIF.",
      "good": "SELECT SINGLE partner\n  FROM but000\n  WHERE partner = @lv_partner_id\n  INTO @DATA(lv_found_partner).\nDATA(lv_partner_exists) = xsdbool( sy-subrc = 0 ).\nIF lv_partner_exists = abap_false.\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Preserve kernel state and execution integrity in SAP ABAP by eliminating direct assignments to system fields like sy-subrc and sy-tabix.",
      "keywords": [
        "no-sy-modify",
        "sy-subrc",
        "sy-tabix",
        "Clean ABAP",
        "ABAP system fields"
      ]
    },
    "relatedRules": [
      "pref-sy",
      "no-obs-arith",
      "no-obs-control"
    ],
    "customSection": "### Detection Details\n\nThe rule scans compiler reference symbols for write access (`is_write_usage = abap_true`) to symbols in the `\\DA:SY\\*` or `\\DA:SYST\\*` namespace. Any assignment, `CLEAR`, `MOVE`, or calculation operation targeting a system field triggers finding code `NO_SY_MOD`.\n\nSuppress false positives or intentional framework hooks using the pseudo-comment `\"#EC NO_SY_MODIFY`."
  },
  {
    "ruleId": "pref-returning",
    "title": "Use RETURNING Instead of a Single EXPORTING Parameter",
    "rationale": "A method with exactly one EXPORTING parameter forces every caller to declare a target variable and invoke the method as a standalone statement. A RETURNING parameter makes the method a value expression that can be inlined into assignments, constructor expressions, method arguments and test assertions. That shortens call sites, removes unused output variables, and keeps the data flow visible when the method is read on its own.",
    "className": "/SKYL/CL_PREF_RETURNING",
    "pseudoComment": "PREF_RETURNING",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_invoice_calculator DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_total\n      IMPORTING iv_order_id TYPE i\n      EXPORTING ev_total    TYPE i.\nENDCLASS.",
      "good": "CLASS zcl_invoice_calculator DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_total\n      IMPORTING iv_order_id TYPE i\n      RETURNING VALUE(rv_total) TYPE i.\nENDCLASS."
    },
    "seo": {
      "description": "Turn single-EXPORTING methods into functional RETURNING methods so callers can use them inside expressions and inline declarations.",
      "keywords": [
        "pref-returning",
        "RETURNING parameter",
        "functional methods",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-mix-returning",
      "no-ignored-return",
      "pref-param-name"
    ],
    "customSection": "### When the check stays silent\n\nThe check runs on the class definition part and raises `PREF_RETNG` only when a `METHODS` / `CLASS-METHODS` statement has an `EXPORTING` section with exactly one typed parameter. It deliberately ignores:\n\n- constructors and `FOR TESTING` methods,\n- methods that already declare `RETURNING` or `CHANGING`,\n- `REDEFINITION` statements, because the signature is fixed by the superclass or interface.\n\nUse `\"#EC PREF_RETURNING` when an external interface or framework forces a single `EXPORTING` parameter."
  },
  {
    "ruleId": "pref-class-exc",
    "title": "Prefer Class-Based Exceptions over Classic EXCEPTIONS",
    "rationale": "Classic exceptions report a failure only through sy-subrc and cannot carry a message object, context data or a stack trace. They are easy to ignore, they clutter every caller with CLEAR sy-subrc and MESSAGE ... RAISING idioms, and they do not propagate reliably through nested call stacks. Replacing EXCEPTIONS with RAISING forces callers into TRY ... CATCH with a typed CX_ROOT subclass, which is what ABAP Cloud and the RAP error handling model expect.",
    "className": "/SKYL/CL_PREF_CLASS_EXC",
    "pseudoComment": "PREF_CLASS_EXC",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_vendor_reader DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS read_vendor\n      IMPORTING iv_vendor_id TYPE i\n      EXCEPTIONS vendor_not_found.\nENDCLASS.",
      "good": "CLASS zcl_vendor_reader DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS read_vendor\n      IMPORTING iv_vendor_id TYPE i\n      RAISING   zcx_vendor_not_found.\nENDCLASS."
    },
    "seo": {
      "description": "Replace legacy EXCEPTIONS lists with RAISING of CX_ROOT subclasses so ABAP methods propagate typed, catchable class-based exceptions.",
      "keywords": [
        "pref-class-exc",
        "class-based exceptions",
        "RAISING",
        "Clean ABAP",
        "SAP S/4HANA"
      ]
    },
    "relatedRules": [
      "no-exc-overlap",
      "no-catch-root",
      "no-raise-cx-sy"
    ],
    "customSection": "### Scope\n\n`PREF_CLEXC` is raised from the class definition part whenever a `METHODS` or `CLASS-METHODS` statement still contains an `EXCEPTIONS` addition. Replacing it with `RAISING` moves the handling to the caller:\n\n```abap\nMETHODS read_vendor\n  IMPORTING iv_vendor_id TYPE i\n  RAISING   zcx_vendor_not_found.\n```\n\nCallers use `TRY ... CATCH zcx_vendor_not_found INTO DATA(lo_error)` instead of testing `sy-subrc`, so the message, previous exception and stack stay available. `RAISE EXCEPTION NEW` and `CATCH` are the modern counterparts; suppress a single declaration with `\"#EC PREF_CLASS_EXC`."
  },
  {
    "ruleId": "no-prod-assert",
    "title": "Avoid Native ASSERT Statements in Production Logic",
    "rationale": "The native ASSERT statement triggers an immediate and uncatchable runtime crash (ASSERTION_FAILED short dump) when the condition evaluates to false. In production business processing, triggering an uncatchable short dump abruptly aborts the user session, discards uncommitted transactional work, and fails to provide diagnostic error details to the caller. Native ASSERT statements belong exclusively in automated test classes (LCL_TEST) or checkpoint groups (ASSERT ID ... CONDITION ...), whereas production business code should evaluate conditions and raise structured, catchable class-based exceptions.",
    "className": "/SKYL/CL_NO_PROD_ASSERT",
    "pseudoComment": "NO_PROD_ASSERT",
    "category": "security",
    "example": {
      "bad": "ASSERT lv_invoice_amount > 0.",
      "good": "IF lv_invoice_amount <= 0.\n  RAISE EXCEPTION NEW cx_static_check( ).\nENDIF."
    },
    "seo": {
      "description": "Prevent catastrophic ASSERTION_FAILED short dumps in production SAP systems by replacing native ASSERT statements with class-based exceptions.",
      "keywords": [
        "no-prod-assert",
        "ASSERTION_FAILED",
        "ABAP short dump",
        "Clean ABAP",
        "exception handling"
      ]
    },
    "relatedRules": [
      "no-kernel-call",
      "pref-auth-check",
      "pref-auth-subrc"
    ],
    "customSection": "### Scope and Behavior\n\nThe rule flags all native `ASSERT` statements found in non-test procedure implementations with finding code `NO_PRD_AST`. Checkpoint assertions with explicit activation groups (e.g., `ASSERT ID group CONDITION ...`) or unit test assertion methods (`cl_abap_unit_assert=>assert_true`) are recommended alternatives when assertions are required during development or automated testing.\n\nFindings can be suppressed using the pseudo-comment `\"#EC NO_PROD_ASSERT`."
  },
  {
    "ruleId": "no-raise-shortdump",
    "title": "Avoid Explicit RAISE SHORTDUMP in Application Logic",
    "rationale": "The RAISE SHORTDUMP statement deliberately terminates execution by creating an ST22 runtime dump with an uncatchable exception. Manually aborting application processing circumvents structured exception handling hierarchies, prevents cleanup handlers and transaction rollback routines from executing gracefully, and leaves external systems without informative error responses. Applications should raise catchable class-based exceptions (inheriting from CX_STATIC_CHECK or CX_NO_CHECK) containing contextual error parameters that permit calling layers to recover or log the failure cleanly.",
    "className": "/SKYL/CL_NO_RAISE_SHORTDUMP",
    "pseudoComment": "NO_RAISE_SHORTDUMP",
    "category": "security",
    "example": {
      "bad": "IF ls_sales_order_header-customer_id IS INITIAL.\n  RAISE SHORTDUMP TYPE cx_no_check.\nENDIF.",
      "good": "IF ls_sales_order_header-customer_id IS INITIAL.\n  RAISE EXCEPTION NEW cx_no_check( ).\nENDIF."
    },
    "seo": {
      "description": "Eliminate deliberate ST22 runtime crashes in SAP applications by replacing RAISE SHORTDUMP with structured, catchable class-based exceptions.",
      "keywords": [
        "no-raise-shortdump",
        "RAISE SHORTDUMP",
        "ST22 dump",
        "ABAP Cloud",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-raise-cx-sy",
      "pref-auth-check",
      "pref-auth-subrc"
    ],
    "customSection": "### Impact and Mitigation\n\nThe rule checks for statements starting with `RAISE` that contain the `SHORTDUMP` token, reporting finding code `NO_DUMP`.\n\nRather than executing `RAISE SHORTDUMP TYPE <class>`, application components should instantiate and raise a domain-specific exception using `RAISE EXCEPTION NEW <class>( ... )`. This allows top-level exception boundaries, background job frameworks, or OData gateway runtimes to handle the incident predictably.\n\nFindings can be suppressed using the pseudo-comment `\"#EC NO_RAISE_SHORTDUMP`."
  },
  {
    "ruleId": "no-metaprogramming",
    "title": "Avoid Dynamic Metaprogramming and Runtime Code Generation",
    "rationale": "Dynamic code generation statements including GENERATE SUBROUTINE POOL, INSERT REPORT, SYNTAX-CHECK, and EDITOR-CALL FOR REPORT assemble and execute uncompiled ABAP code at runtime. Metaprogramming introduces critical Remote Code Execution (RCE) and code injection vulnerabilities (CWE-94), circumvents static code analysis and ATC security inspection, and is completely blocked in ABAP Cloud (Contract C1). Modern enterprise architectures should instead employ object-oriented design patterns, strategy factories, interfaces, or standard Business Add-Ins (BAdIs) to achieve runtime extensibility safely.",
    "className": "/SKYL/CL_NO_METAPROGRAMMING",
    "pseudoComment": "NO_METAPROGRAMMING",
    "category": "security",
    "example": {
      "bad": "GENERATE SUBROUTINE POOL lt_source_lines NAME DATA(lv_program_name).",
      "good": "DATA(lo_tax_calculator) = zcl_tax_factory=>get_strategy( 'DE' ).\nDATA(lv_calculated_tax) = lo_tax_calculator->compute( '100.00' )."
    },
    "seo": {
      "description": "Prevent CWE-94 code injection vulnerabilities in SAP systems by replacing GENERATE SUBROUTINE POOL and dynamic metaprogramming with OOP strategies.",
      "keywords": [
        "no-metaprogramming",
        "GENERATE SUBROUTINE POOL",
        "CWE-94",
        "ABAP code injection",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-rfc-err",
      "no-unhandled-eml",
      "no-dynamic-stmt"
    ],
    "customSection": "### Detected Metaprogramming Statements\n\nThe check scans procedure bodies for obsolete and high-risk dynamic code manipulation keywords:\n\n| Keyword / Statement | Scope |\n|---|---|\n| `SYNTAX-CHECK` | Dynamic syntax checking of arbitrary source code buffers. |\n| `GENERATE SUBROUTINE POOL` / `REPORT` / `DYNPRO` | Runtime compilation of temporary or permanent ABAP programs. |\n| `INSERT REPORT` / `TEXTPOOL` | Direct database insertion of ABAP source code or text symbols. |\n| `DELETE REPORT` / `TEXTPOOL` / `DYNPRO` | Deletion of repository program and screen artifacts at runtime. |\n| `EXPORT DYNPRO` | Binary export or manipulation of classic screen definitions. |\n| `EDITOR-CALL FOR REPORT` | Interactive editor invocation for source code modification. |\n\nAll occurrences report finding code `NO_METAPRG`. Suppress individual statements if required using pseudo-comment `\"#EC NO_METAPROGRAMMING`."
  },
  {
    "ruleId": "no-kernel-call",
    "title": "Avoid Internal C-Kernel Calls and Native Database SQL",
    "rationale": "Invoking internal SAP C-kernel routines via SYSTEM-CALL or CALL 'routine', as well as embedding native database code with EXEC SQL, bypasses the OpenSQL syntax abstraction layer, authorization buffers, and tenant isolation safeguards. Undocumented kernel calls depend on internal C-routines that are unstable across kernel patch levels, and EXEC SQL statements create vendor-specific database coupling that breaks ABAP Cloud compatibility (Cloud Contract C1). Applications should interact with the platform exclusively through released ABAP Cloud APIs, Core Data Services (CDS) view entities, and typed ABAP SQL.",
    "className": "/SKYL/CL_NO_KERNEL_CALL",
    "pseudoComment": "NO_KERNEL_CALL",
    "category": "security",
    "example": {
      "bad": "SYSTEM-CALL rfc_clone_connection.",
      "good": "DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination( 'ERP_DEST' )."
    },
    "seo": {
      "description": "Ensure ABAP Cloud and S/4HANA readiness by replacing internal SYSTEM-CALL and native EXEC SQL statements with released SAP Cloud APIs.",
      "keywords": [
        "no-kernel-call",
        "SYSTEM-CALL",
        "EXEC SQL",
        "ABAP Cloud",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-rfc-err",
      "no-unhandled-eml",
      "no-raise-cx-sy"
    ],
    "customSection": "### Reported Instructions\n\nThe check identifies three categories of low-level platform invocations:\n\n| Construct | Description |\n|---|---|\n| `SYSTEM-CALL` | Undocumented low-level kernel routines invoked directly in ABAP. |\n| `CALL 'c_routine'` | C-kernel procedures called with literal routine names. |\n| `EXEC SQL ... ENDEXEC` | Embedded native SQL bypassing SAP Open SQL and SAP HANA CDS engines. |\n\nAll matches produce finding code `NO_KERNEL`. Suppress findings when working with approved low-level system drivers using pseudo-comment `\"#EC NO_KERNEL_CALL`."
  },
  {
    "ruleId": "pref-auth-check",
    "title": "Protect CALL TRANSACTION Statements with AUTHORITY-CHECK",
    "rationale": "Invoking SAP transactions using CALL TRANSACTION without the WITH AUTHORITY-CHECK addition bypasses transaction code authorization verification (authorization object S_TCODE). Without explicit authorization checking, any user who can reach the calling program can execute restricted transactions, leading to unauthorized privilege escalation. In on-premise ABAP systems, CALL TRANSACTION statements must include WITH AUTHORITY-CHECK, while in ABAP Cloud (where CALL TRANSACTION is not permitted), access must be guarded using explicit business object authorization checks or RAP authorization handlers.",
    "className": "/SKYL/CL_PREF_AUTH_CHECK",
    "pseudoComment": "PREF_AUTH_CHECK",
    "category": "security",
    "example": {
      "bad": "CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.",
      "good": "AUTHORITY-CHECK OBJECT 'S_TCODE'\n  ID 'TCD' FIELD 'VA03'.\nIF sy-subrc <> 0.\n  RETURN.\nENDIF."
    },
    "seo": {
      "description": "Enforce secure transaction execution in SAP ABAP by requiring WITH AUTHORITY-CHECK on CALL TRANSACTION statements to prevent authorization bypass.",
      "keywords": [
        "pref-auth-check",
        "CALL TRANSACTION",
        "WITH AUTHORITY-CHECK",
        "S_TCODE",
        "SAP authorization"
      ]
    },
    "relatedRules": [
      "pref-auth-subrc",
      "pref-check-subrc",
      "no-unhandled-eml"
    ],
    "customSection": "### Detection and QuickFix\n\nThe rule identifies `CALL TRANSACTION` statements that lack the `WITH AUTHORITY-CHECK` addition:\n\n- **Finding Code:** `PREF_AUTH`\n- **QuickFix Code:** `ADDAUTH` automatically inserts `WITH AUTHORITY-CHECK` after the transaction code identifier.\n- **Suppression:** Suppress false positives with pseudo-comment `\"#EC PREF_AUTH_CHECK`.\n\nIn modern ABAP Cloud environments, `CALL TRANSACTION` is obsolete and forbidden; secure business object access must be implemented using Core Data Services access controls or explicit `AUTHORITY-CHECK` statements against business authorization objects."
  },
  {
    "ruleId": "pref-order-by",
    "title": "Require Explicit ORDER BY with UP TO N ROWS Clauses",
    "rationale": "Relational database engines, especially distributed column stores like SAP HANA, do not guarantee physical row ordering without an explicit ORDER BY clause. Executing a query with UP TO n ROWS without sorting produces non-deterministic results: identical queries with identical inputs can return completely different records across executions depending on parallel execution threads, memory cache states, or index selection. In financial calculations, status lookups, and audit trails, this causes subtle, non-reproducible defects. Clean ABAP requires an explicit ORDER BY clause whenever restricting query result sets with UP TO.",
    "className": "/SKYL/CL_PREF_ORDER_BY",
    "pseudoComment": "PREF_ORDER_BY",
    "category": "performance",
    "example": {
      "bad": "SELECT price, currency_code, valid_from\n  FROM zprice_conditions\n  WHERE product_id = @lv_product_id\n  INTO TABLE @DATA(lt_latest_prices)\n  UP TO 1 ROWS.",
      "good": "SELECT price, currency_code, valid_from\n  FROM zprice_conditions\n  WHERE product_id = @lv_product_id\n  ORDER BY valid_from DESCENDING\n  INTO TABLE @DATA(lt_latest_prices)\n  UP TO 1 ROWS."
    },
    "seo": {
      "description": "Enforce deterministic Open SQL queries in SAP ABAP by requiring an explicit ORDER BY clause whenever UP TO N ROWS is used.",
      "keywords": [
        "pref-order-by",
        "ORDER BY",
        "UP TO 1 ROWS",
        "deterministic SQL",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-select-star",
      "no-empty-fae",
      "no-endselect"
    ],
    "customSection": "### Detection Details\n\nThe check inspects `SELECT` statements that contain the token sequence `UP TO` and verifies whether an `ORDER BY` clause is present. If `ORDER BY` is missing, finding code `PREF_ORDBY` is reported.\n\n### SAP HANA Determinism\n\nUnlike traditional disk-based row engines, SAP HANA distributes queries across multiple CPU cores and memory partitions. Results are assembled dynamically in parallel, meaning row order is never guaranteed unless explicitly requested via `ORDER BY PRIMARY KEY` or specific sort attributes.\n\nSuppress queries where arbitrary record selection is truly acceptable with the pseudo comment `\"#EC PREF_ORDER_BY`."
  },
  {
    "ruleId": "max-cyclo-comp",
    "title": "Limit McCabe Cyclomatic Complexity per Procedure",
    "rationale": "Cyclomatic Complexity (McCabe metric) measures the number of linearly independent paths through a procedure's control graph. In SAP ABAP systems, high complexity strongly correlates with elevated defect rates, high regression frequency during maintenance, and inadequate unit test branch coverage. Procedures with cyclomatic complexity exceeding 10 or 15 cannot be reliably reasoned about or exhaustively tested under modern ABAP Cloud practices. Decomposing convoluted branch networks into polymorphically dispatched strategies or focused helper routines isolates edge cases and ensures robust testability.",
    "className": "/SKYL/CL_MAX_CYCLO_COMP",
    "pseudoComment": "MAX_CYCLO_COMP",
    "category": "metrics",
    "example": {
      "bad": "METHOD calculate_settlement_discount.\n  DATA lv_discount_rate TYPE i.\n\n  IF iv_customer_tier = 'PLATINUM' AND iv_order_amount > 1000.\n    lv_discount_rate = 25.\n  ELSEIF iv_customer_tier = 'GOLD' AND iv_order_amount > 500.\n    lv_discount_rate = 15.\n  ELSEIF iv_customer_tier = 'SILVER' OR iv_has_vip_pass = abap_true.\n    lv_discount_rate = 10.\n  ELSE.\n    lv_discount_rate = 0.\n  ENDIF.\n  rv_discount_rate = lv_discount_rate.\nENDMETHOD.",
      "good": "METHOD calculate_settlement_discount.\n  DATA(lo_discount_policy) = mo_discount_factory->resolve_policy( iv_customer_tier ).\n  rv_discount_rate = lo_discount_policy->compute_discount( iv_order_amount ).\nENDMETHOD."
    },
    "parameters": {
      "MAX_COMPLEXITY": "Maximum allowable cyclomatic complexity score (McCabe metric) for a procedure before reporting (default: 5)."
    },
    "seo": {
      "description": "Monitor McCabe cyclomatic complexity in ABAP procedures to prevent defect-prone branching and guarantee testable code units.",
      "keywords": [
        "max-cyclo-comp",
        "cyclomatic complexity",
        "McCabe metric",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-bool-expr",
      "max-nesting",
      "max-method-len"
    ],
    "customSection": "## Complexity Calculation Rules\n\nThe check initializes procedure complexity at `1` and evaluates statement keywords and unreferenced operator tokens:\n\n| Construct | Contribution | Notes |\n|---|---|---|\n| Base score | +1 | Every procedure starts with 1 independent path |\n| Branch keywords | +1 each | `IF`, `ELSEIF`, `LOOP`, `DO`, `WHILE`, `WHEN`, `CATCH`, `CLEANUP` |\n| Boolean conjunctions | +1 each | `AND` (except inside `BETWEEN ... AND ...`), `OR` |\n| Constructor branching | +1 each | `COND`, `SWITCH` |\n\n| Finding Code | Severity | Trigger | Suppression |\n|---|---|---|---|\n| `MAX_CYCLO` | Warning | Procedure complexity exceeds `MAX_COMPLEXITY` | `##MAX_CYCLO_COMP` or `\"#EC MAX_CYCLO_COMP` |"
  },
  {
    "ruleId": "max-npath",
    "title": "Limit NPath Execution Path Complexity per Method",
    "rationale": "NPath complexity quantifies the total number of acyclic execution paths through a procedure. While cyclomatic complexity increases additively with each decision point, NPath complexity grows multiplicatively across consecutive and nested conditional statements. A method with an NPath score in the hundreds or thousands represents an untestable combinatorial explosion where full branch path testing in ABAP Unit is practically impossible. Keeping NPath complexity low ensures that all business paths are predictable, auditable, and fully exercisable in automated test suites.",
    "className": "/SKYL/CL_MAX_NPATH",
    "pseudoComment": "MAX_NPATH",
    "category": "metrics",
    "example": {
      "bad": "METHOD evaluate_customer_profile.\n  IF is_customer_profile-is_email_verified = abap_true.\n    enable_email_notifications( ).\n  ENDIF.\n  IF is_customer_profile-is_phone_verified = abap_true.\n    enable_sms_alerts( ).\n  ENDIF.\n  IF is_customer_profile-is_corporate_account = abap_true.\n    assign_business_tier( ).\n  ENDIF.\n  IF is_customer_profile-has_tax_exemption = abap_true.\n    apply_tax_exemption_certificate( ).\n  ENDIF.\n  IF is_customer_profile-has_credit_limit = abap_true.\n    validate_revolving_credit( ).\n  ENDIF.\n  IF is_customer_profile-is_newsletter_subscriber = abap_true.\n    enroll_marketing_campaign( ).\n  ENDIF.\n  IF is_customer_profile-is_premium_member = abap_true.\n    grant_loyalty_reward_points( ).\n  ENDIF.\n  IF is_customer_profile-requires_two_factor_auth = abap_true.\n    enforce_security_challenge( ).\n  ENDIF.\nENDMETHOD.",
      "good": "METHOD evaluate_customer_profile.\n  configure_contact_channels( is_customer_profile ).\n  configure_commercial_terms( is_customer_profile ).\n  configure_security_policy( is_customer_profile ).\nENDMETHOD."
    },
    "parameters": {
      "MAX_NPATH": "Maximum allowed acyclic execution paths per procedure before reporting combinatorial explosion (default: 200)."
    },
    "seo": {
      "description": "Limit NPath path complexity in ABAP procedures to prevent combinatorial branch explosion and guarantee unit test coverage.",
      "keywords": [
        "max-npath",
        "NPath complexity",
        "acyclic paths",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-cyclo-comp",
      "max-cognitive",
      "max-nesting",
      "max-method-len"
    ],
    "customSection": "## NPath Multiplicative Formula\n\nNPath evaluates control structures by calculating branch sums and multiplying sequential blocks:\n\n- **IF / ELSEIF / ELSE:** The sum of paths in each branch. If `ELSE` is absent, an implicit empty branch (+1) is included.\n- **CASE / WHEN / ENDCASE:** The sum of paths across all `WHEN` blocks. If `WHEN OTHERS` is missing, an extra path (+1) is added.\n- **LOOP / WHILE / DO:** Path count within the body + 1 + any boolean operators.\n- **TRY / CATCH / CLEANUP:** Sum of paths across guarded and recovery blocks.\n\n| Finding Code | Severity | Trigger | Suppression |\n|---|---|---|---|\n| `MAX_NPATH` | Warning | Procedure NPath score exceeds `MAX_NPATH` (default 200) | `##MAX_NPATH` or `\"#EC MAX_NPATH` |"
  },
  {
    "ruleId": "pref-final-cls",
    "title": "Design for Inheritance or Prohibit It with FINAL",
    "rationale": "A class that was never designed for inheritance can still be subclassed, and subclasses silently depend on protected internals that later change. Marking the class FINAL prevents the fragile base class problem and documents that no extension point exists; marking individual methods FINAL protects redefinition when the class itself must stay inheritable. The check raises PREF_FCLS and PREF_FMETH separately, so a framework base class can be exempted while its methods are still locked down.",
    "className": "/SKYL/CL_PREF_FINAL_CLS",
    "pseudoComment": "PREF_FINAL_CLASS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_customer_service DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS.",
      "good": "CLASS zcl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS execute.\nENDCLASS."
    },
    "parameters": {
      "CHECK_CLASSES": "Report CLASS ... DEFINITION statements that are neither FINAL nor ABSTRACT nor TESTING. Disable when your framework requires inheritable base classes.",
      "CHECK_METHODS": "Report METHODS statements that are not FINAL so redefinition is blocked by default. Constructors, abstract, redefined and FOR TESTING methods are skipped."
    },
    "seo": {
      "description": "Mark classes and methods FINAL by default so unintended inheritance and redefinition cannot break internal behaviour in ABAP Cloud.",
      "keywords": [
        "pref-final-cls",
        "FINAL class",
        "inheritance design",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-inherit",
      "pref-factory-name",
      "pref-composition"
    ],
    "customSection": "### Finding codes and exceptions\n\n| Code | Trigger |\n| --- | --- |\n| `PREF_FCLS` | `CLASS ... DEFINITION` without `FINAL`, `ABSTRACT` or `TESTING` |\n| `PREF_FMETH` | `METHODS` inside a non-final class without `FINAL` |\n\nThe class finding is skipped for abstract classes and test classes; classes that inherit from a superclass are still reported, because `FINAL` documents that the new class is a leaf. The method finding skips constructors, abstract and redefined methods, interface implementations (`... FOR ...`) and methods with `DEFAULT` parameters. `CHECK_CLASSES` and `CHECK_METHODS` toggle the two checks independently, `ADDFINAL` inserts the addition as a QuickFix, and suppression uses `\"#EC PREF_FINAL_CLASS` / `\"#EC PREF_FINAL_METHOD`."
  },
  {
    "ruleId": "no-magic-numbers",
    "title": "Replace Unexplained Magic Numbers with Named Constants",
    "rationale": "Hardcoded numeric literals scattered across executable statements obscure the domain rationale and business rules underlying calculations or loop conditions. If the value needs to change, developers must perform error-prone global search-and-replace edits across programs. Clean ABAP mandates replacing magic numbers with typed, descriptive CONSTANTS declarations (such as c_max_retry_count or c_default_batch_size). This provides a single source of truth, documents business constraints, and ensures robust ABAP Cloud code quality.",
    "className": "/SKYL/CL_NO_MAGIC_NUMBERS",
    "pseudoComment": "NO_MAGIC_NUMBERS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_retry_counter >= 5.\n  terminate_processing( ).\nENDIF.",
      "good": "CONSTANTS c_max_retries TYPE i VALUE 5.\nIF lv_retry_counter >= c_max_retries.\n  terminate_processing( ).\nENDIF."
    },
    "seo": {
      "description": "Replace unexplained magic numbers with typed named constants in ABAP Cloud and ATC checks.",
      "keywords": [
        "no-magic-numbers",
        "magic numbers",
        "named constants",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dead-code",
      "no-unreachable",
      "max-method-len"
    ],
    "customSection": "### Evaluated Statements and Exceptions\n\nThe rule inspects all executable statements outside of `CONSTANTS`, `DATA`, `TYPES`, and `STATICS` declarations:\n\n- The numbers `0` and `1` are exempted as standard initializers and unit increments.\n- Numeric exception return codes in `CALL FUNCTION ... EXCEPTIONS` clauses are exempted.\n- Any other raw integer or decimal literal triggers finding code `NO_MAGIC_N`.\n\nSuppress intentional magic numbers with `\"#EC NO_MAGIC_NUMBERS`."
  },
  {
    "ruleId": "pref-insert",
    "title": "Prefer INSERT ... INTO TABLE over APPEND",
    "rationale": "APPEND only exists for index tables, so swapping a STANDARD TABLE for a SORTED or HASHED TABLE later breaks every APPEND in the code base. INSERT ... INTO TABLE is valid for all three table categories and states the generic intent of adding a row without implying a physical append position. The check reports PREF_INSRT on each APPEND and offers a TOINSERT QuickFix, keeping table handling independent of the concrete table kind chosen by the data model.",
    "className": "/SKYL/CL_PREF_INSERT",
    "pseudoComment": "PREF_INSERT",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lt_order_items TYPE STANDARD TABLE OF zcl_order=>ty_item.\nAPPEND ls_order_item TO lt_order_items.",
      "good": "DATA lt_order_items TYPE STANDARD TABLE OF zcl_order=>ty_item.\nINSERT ls_order_item INTO TABLE lt_order_items."
    },
    "seo": {
      "description": "Replace APPEND with INSERT INTO TABLE so internal table writes stay valid after switching to sorted or hashed table types in ABAP.",
      "keywords": [
        "pref-insert",
        "APPEND statement",
        "INSERT INTO TABLE",
        "Clean ABAP",
        "ABAP internal tables"
      ]
    },
    "relatedRules": [
      "pref-lines",
      "pref-read-table",
      "pref-transport"
    ],
    "customSection": "### Why INSERT INTO TABLE\n\n`APPEND` only works for index tables, so replacing the table type with a `SORTED TABLE` or `HASHED TABLE` breaks it at activation. `INSERT ... INTO TABLE` compiles for every table category and keeps the caller independent of the table kind.\n\nThe `TOINSERT` QuickFix rewrites `APPEND <line> TO <table>.` to `INSERT <line> INTO TABLE <table>.`. It is not offered for `APPEND ... SORTED BY`, because that addition has no `INSERT` equivalent and must be expressed with a separate `SORT`. Suppress a finding with `\"#EC PREF_INSERT`."
  },
  {
    "ruleId": "no-like-objects",
    "title": "Declare Data Objects with Explicit TYPE Instead of LIKE",
    "rationale": "Referencing other data objects via LIKE tightly couples variable declarations to local variable implementations or structure instances rather than semantic type definitions. In modern ABAP Cloud and Clean ABAP, explicit typing with TYPE ensures strong data integrity, eliminates unintended ripple effects when source variables change, and aligns with Cloud Contract C1 requirements for decoupled API contracts. The ATC finding code NO_LIKE_OB flags LIKE additions in DATA, TYPES, STATICS, and CONSTANTS statements.",
    "className": "/SKYL/CL_NO_LIKE_OBJECTS",
    "pseudoComment": "NO_LIKE_OBJECTS",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_original_price TYPE decfloat34.\nDATA lv_discounted_price LIKE lv_original_price.",
      "good": "DATA lv_discounted_price TYPE decfloat34."
    },
    "seo": {
      "description": "Enforce explicit TYPE definitions over LIKE references in ABAP Cloud declarations according to Clean ABAP and SAP ATC standards.",
      "keywords": [
        "no-like-objects",
        "Clean ABAP",
        "ABAP Cloud",
        "SAP ATC",
        "explicit TYPE",
        "data declaration"
      ]
    },
    "relatedRules": [
      "pref-name-objects",
      "no-chained-decl",
      "no-chained-assign"
    ],
    "customSection": "## Detection Details\n\nThe check scans `DATA`, `TYPES`, `STATICS`, and `CONSTANTS` statements for the token lexeme `LIKE`. In ABAP Cloud development, declarations should reference explicit data types, data elements, or dictionary types via `TYPE` rather than mirroring the memory layout of sibling variables.\n\n### Suppression\nTo suppress a finding, use the pseudo comment `\"#EC NO_LIKE_OBJECTS` on the declaration statement."
  },
  {
    "ruleId": "no-static-cls",
    "title": "Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities",
    "rationale": "Classes containing exclusively static methods violate object-oriented design and testability principles because static operations cannot be substituted via dependency injection or mocked with test doubles during unit tests. In ABAP Cloud and Clean ABAP, components must expose behaviors through interface contracts and instantiable classes to ensure high testability, isolated state, and lifecycle management under Cloud Contract C1. The ATC finding code NO_STAT_CL reports class definitions that lack instance methods.",
    "className": "/SKYL/CL_NO_STATIC_CLS",
    "pseudoComment": "NO_STATIC_CLS",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS zcl_invoice_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    CLASS-METHODS calculate_tax\n      IMPORTING iv_net_amount TYPE decfloat34\n      RETURNING VALUE(rv_tax) TYPE decfloat34.\n    CLASS-METHODS format_amount\n      IMPORTING iv_amount         TYPE decfloat34\n      RETURNING VALUE(rv_display) TYPE string.\nENDCLASS.",
      "good": "CLASS zcl_invoice_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_tax\n      IMPORTING iv_net_amount TYPE decfloat34\n      RETURNING VALUE(rv_tax) TYPE decfloat34.\n    METHODS format_amount\n      IMPORTING iv_amount         TYPE decfloat34\n      RETURNING VALUE(rv_display) TYPE string.\nENDCLASS."
    },
    "seo": {
      "description": "Prevent purely static utility classes in ABAP Cloud to enable dependency injection, interface contracts, and unit test mocking.",
      "keywords": [
        "no-static-cls",
        "Clean ABAP",
        "ABAP Cloud",
        "SAP ATC",
        "dependency injection",
        "testability"
      ]
    },
    "relatedRules": [
      "no-static-arrow",
      "pref-final-cls",
      "no-exposed-data"
    ],
    "customSection": "## Detection Details\n\nThe rule evaluates class definitions (`procedure_kinds-class_definition`) and counts static method declarations versus instance method declarations. If a class declares one or more `CLASS-METHODS` (excluding `CLASS_CONSTRUCTOR`) but zero instance `METHODS` (excluding `CONSTRUCTOR`), it is flagged with `NO_STAT_CL`.\n\n### Clean Architecture Pattern\nReplace utility classes with instantiable domain services implementing an interface. Callers then receive instances via constructor injection, enabling seamless test substitution with test doubles.\n\n### Suppression\nSuppress findings using the pseudo comment `\"#EC NO_STATIC_CLS`."
  },
  {
    "ruleId": "pref-pred-name",
    "title": "Use Predicate Naming (is_, has_, can_) for Boolean Methods",
    "rationale": "A boolean method reads best as a yes/no question, especially when it appears inside an IF condition or a COND expression. Names such as check_active or get_valid imply a status value or a side effect and force readers to look up the return type, while is_active or has_entries make the meaning obvious at the call site. The check inspects the RETURNING type, so only genuine flag methods are renamed and data-returning getters stay untouched.",
    "className": "/SKYL/CL_PREF_PRED_NAME",
    "pseudoComment": "PREF_PRED_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_access_control DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS check_authorization\n      IMPORTING iv_user_id      TYPE i\n      RETURNING VALUE(rv_is_allowed) TYPE abap_bool.\nENDCLASS.",
      "good": "CLASS zcl_access_control DEFINITION PUBLIC CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS is_authorized\n      IMPORTING iv_user_id      TYPE i\n      RETURNING VALUE(rv_is_allowed) TYPE abap_bool.\nENDCLASS."
    },
    "seo": {
      "description": "Name boolean-returning methods with is_, has_ or can_ prefixes so predicates read as questions at every ABAP call site.",
      "keywords": [
        "pref-pred-name",
        "predicate naming",
        "abap_bool method",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-name-members",
      "pref-name-objects",
      "pref-naming-vars"
    ],
    "customSection": "### Accepted predicate prefixes\n\nBoolean methods pass when the name starts with one of:\n\n`IS_`, `HAS_`, `CAN_`, `ARE_`, `WAS_`, `WERE_`, `SHOULD_`, `MUST_`, `EXISTS`, `CONTAINS`, `SUPPORTS`, `MATCHES`, `EQUALS`.\n\nOnly `RETURNING` parameters typed `abap_bool`, `abap_boolean`, `xsdbool`, `flag`, `xfeld`, `boolean` or `boole_d` are inspected. A method returning a status structure or an object reference is never reported, so `get_status` stays valid in that case. Use `\"#EC PREF_PRED_NAME` to keep a legacy flag name."
  },
  {
    "ruleId": "max-inherit",
    "title": "Limit Class Inheritance Depth and Favor Object Composition",
    "rationale": "Deep class inheritance hierarchies (exceeding 2 to 3 levels) lead to fragile base class antipatterns and tight structural coupling. In modern ABAP Cloud architectures, changes to an ancestor class can cause unforeseen side effects in distant descendant classes. Deep hierarchies also complicate constructor chaining, attribute initialization, and test isolation. Clean ABAP strongly advises favoring object composition and role-based interfaces over inheritance hierarchies, enabling modularity, independent unit testing with test doubles, and resilient software design.",
    "className": "/SKYL/CL_MAX_INHERIT",
    "pseudoComment": "MAX_INHERIT",
    "category": "metrics",
    "example": {
      "bad": "CLASS zcl_persisted_record DEFINITION PUBLIC ABSTRACT CREATE PUBLIC.\nENDCLASS.\nCLASS zcl_sales_document DEFINITION INHERITING FROM zcl_persisted_record CREATE PUBLIC.\nENDCLASS.\nCLASS zcl_sales_order DEFINITION INHERITING FROM zcl_sales_document CREATE PUBLIC.\nENDCLASS.\nCLASS zcl_rush_order DEFINITION INHERITING FROM zcl_sales_order CREATE PUBLIC.\nENDCLASS.",
      "good": "CLASS zcl_rush_order DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    INTERFACES zif_sales_order.\n    METHODS constructor\n      IMPORTING\n        io_persistence TYPE REF TO zif_order_persistence\n        io_pricing     TYPE REF TO zif_pricing_strategy.\nENDCLASS."
    },
    "parameters": {
      "MAX_DEPTH": "Maximum allowable inheritance depth levels from standard root object before reporting (default: 3)."
    },
    "seo": {
      "description": "Limit class inheritance depth in ABAP OOP to avoid fragile base classes and promote composition over inheritance.",
      "keywords": [
        "max-inherit",
        "inheritance depth",
        "object composition",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-attributes",
      "max-nesting",
      "pref-composition"
    ],
    "customSection": "## Detection & RTTI Dependency\n\nThe check evaluates class definitions that contain an `INHERITING FROM` clause and inspects inheritance depth via ABAP Run-Time Type Identification (RTTI) using `/skyl/cl_rtti_util=>get_super_classes`.\n\n| Finding Code | Severity | Remote Enabled | Suppression |\n|---|---|---|---|\n| `MAX_INHRT` | Warning | `abap_false` (local ATC only) | `##MAX_INHERIT` or `\"#EC MAX_INHERIT` |\n\n> **Notice:** Because RTTI descriptors are unavailable across RFC connections in remote ATC scenarios, this check sets `remote_enablement = abap_false` and runs strictly in local system inspections."
  },
  {
    "ruleId": "max-attributes",
    "title": "Limit Class Member Attribute Count to Prevent God Objects",
    "rationale": "Classes declaring an excessive number of instance or static attributes (`DATA` and `CLASS-DATA`) almost invariably suffer from low cohesion and violate the Single Responsibility Principle. Such classes tend to become stateful 'God Objects' that handle disparate operational domains—from persistence and UI formatting to business validation. High attribute counts introduce mutation race conditions, make state transitions hard to follow, and complicate ABAP Unit test fixture setup. Grouping cohesive attributes into structured data types or delegating responsibilities to specialized collaborator classes produces clean, maintainable object designs.",
    "className": "/SKYL/CL_MAX_ATTRIBUTES",
    "pseudoComment": "MAX_ATTRIBUTES",
    "category": "metrics",
    "example": {
      "bad": "CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PRIVATE SECTION.\n    DATA mv_customer_id TYPE string.\n    DATA mv_customer_name TYPE string.\n    DATA mv_billing_address TYPE string.\n    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2.\n    DATA mv_payment_terms TYPE string.\n    DATA mv_tax_number TYPE string.\n    DATA mv_risk_category TYPE string.\nENDCLASS.",
      "good": "CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    TYPES:\n      BEGIN OF ty_customer_profile,\n        customer_id   TYPE string,\n        customer_name TYPE string,\n        credit_limit  TYPE p LENGTH 8 DECIMALS 2,\n        tax_number    TYPE string,\n      END OF ty_customer_profile.\n  PRIVATE SECTION.\n    DATA ms_profile     TYPE ty_customer_profile.\n    DATA mo_risk_engine TYPE REF TO zif_risk_evaluator.\nENDCLASS."
    },
    "parameters": {
      "MAX_ATTRIBUTES": "Maximum allowable member attributes (DATA and CLASS-DATA) in a class definition before reporting (default: 5)."
    },
    "seo": {
      "description": "Enforce member attribute limits on ABAP classes to avoid God Objects and maintain high cohesion and testability.",
      "keywords": [
        "max-attributes",
        "God Class",
        "member attributes",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-inherit",
      "max-params",
      "max-method-len"
    ],
    "customSection": "## Scope and Attribute Counting\n\nThe check inspects class definition blocks (`procedure_kinds-class_definition`). Every `DATA` and `CLASS-DATA` statement across all visibility sections (`PUBLIC`, `PROTECTED`, `PRIVATE`) increments the attribute count. Note that chained declarations (`DATA: ...`) are unrolled into individual `DATA` statements by Skylint's AST parser.\n\n| Finding Code | Severity | Default Limit | Suppression |\n|---|---|---|---|\n| `MAX_ATTR` | Warning | `MAX_ATTRIBUTES` (5 attributes) | `##MAX_ATTRIBUTES` or `\"#EC MAX_ATTRIBUTES` |\n\n### Refactoring Strategy\nBundle related scalar fields into flat structures or extract independent subsystems into dedicated collaborator classes injected via constructor parameters."
  },
  {
    "ruleId": "no-catch-root",
    "title": "Avoid Generic CATCH cx_root and Catch Specific Exceptions",
    "rationale": "Catching the base exception class CX_ROOT indiscriminately traps all class-based exceptions, including fatal runtime anomalies such as CX_SY_RESOURCE_FAILURE, database connection loss, and critical assertion failures. Catching CX_ROOT without proper re-raising creates the Black Hole Exception anti-pattern: severe system defects are masked, and execution continues in a corrupted state. Application code should catch only specific, anticipated domain or system exception classes (such as zcx_order_not_found or cx_sy_conversion_no_number) where meaningful recovery or domain logging can take place.",
    "className": "/SKYL/CL_NO_CATCH_ROOT",
    "pseudoComment": "NO_CATCH_ROOT",
    "category": "security",
    "example": {
      "bad": "DATA lv_invoice_id TYPE string VALUE 'INV-1001'.\nTRY.\n    zcl_billing_service=>process_invoice( iv_invoice_id = lv_invoice_id ).\n  CATCH cx_root.\n    \" Anti-pattern: Silently traps all exceptions including fatal system faults\n    RETURN.\nENDTRY.",
      "good": "DATA lv_invoice_id TYPE string VALUE 'INV-1001'.\nTRY.\n    zcl_billing_service=>process_invoice( iv_invoice_id = lv_invoice_id ).\n  CATCH cx_static_check INTO DATA(lx_error).\n    \" Clean ABAP: Handle expected domain exception specifically\n    RETURN.\nENDTRY."
    },
    "seo": {
      "description": "Prevent black hole exception handling in SAP ABAP by catching specific domain exceptions instead of generic CATCH cx_root.",
      "keywords": [
        "no-catch-root",
        "CX_ROOT",
        "Clean ABAP",
        "exception handling",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-class-exc",
      "no-raise-cx-sy",
      "no-nested-try"
    ],
    "customSection": "### Exception Handling Principles\n\nThe check inspects `CATCH` statements and flags references resolved to `\\TY:CX_ROOT` with finding code `NO_CAT_ROT`.\n\nBest practices for exception handling:\n1. Catch specific domain exceptions (`zcx_order_processing_failed`, `zcx_invalid_partner`).\n2. If catching high-level exceptions at application boundaries (e.g. background job controllers or API gateways), always log the exception or wrap it into a domain-specific fault.\n3. Never leave `CATCH cx_root` empty.\n\nSuppress findings when building top-level resilience boundaries using pseudo-comment `\"#EC NO_CATCH_ROOT`."
  },
  {
    "ruleId": "no-msg-raising",
    "title": "Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING",
    "rationale": "The MESSAGE ... RAISING statement mixes presentation-tier message output with procedural exception propagation and relies on classic non-class-based exception tables and sy-subrc checks. Modern Clean ABAP and ABAP Cloud Contract C1 mandate class-based exceptions (inheriting from CX_STATIC_CHECK or CX_NO_CHECK) using RAISE EXCEPTION NEW or RAISE EXCEPTION TYPE, optionally carrying T100 message keys via IF_T100_MESSAGE or IF_T100_DYN_MSG. The ATC check reports NO_MSG_RSG for any MESSAGE statement specifying RAISING.",
    "className": "/SKYL/CL_NO_MSG_RAISING",
    "pseudoComment": "NO_MSG_RAISING",
    "category": "anti-patterns",
    "example": {
      "bad": "MESSAGE e002(zorder) WITH lv_order_id RAISING order_not_found.",
      "good": "RAISE EXCEPTION NEW cx_order_processing_failed(\n  textid = cx_order_processing_failed=>order_not_found )."
    },
    "seo": {
      "description": "Eliminate obsolete MESSAGE RAISING statements and adopt class-based exceptions in ABAP Cloud and SAP S/4HANA systems.",
      "keywords": [
        "no-msg-raising",
        "Clean ABAP",
        "ABAP Cloud",
        "class-based exceptions",
        "RAISE EXCEPTION",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-msg-cls",
      "no-obs-strings",
      "no-useless-concat"
    ],
    "customSection": "## Detection Details\n\nThe check scans statements outside class definitions for the keyword `MESSAGE` combined with the keyword token `RAISING`. In ABAP Cloud, classic exceptions are obsolete and incompatible with modern exception handling semantics.\n\n### Recommended Migration\nDefine custom exception classes implementing `IF_T100_MESSAGE` or `IF_T100_DYN_MSG` and instantiate them with `RAISE EXCEPTION NEW cx_my_error( ... )`.\n\n### Suppression\nSuppress findings with the pseudo comment `\"#EC NO_MSG_RAISING`."
  },
  {
    "ruleId": "no-nested-try",
    "title": "Extract Nested TRY Blocks into Dedicated Helper Methods",
    "rationale": "Nesting a TRY ... CATCH construct inside another TRY block obscures exception ownership, dramatically increases cognitive complexity, and often leads to duplicated error handling or swallowed exceptions. Clean ABAP recommends keeping methods focused on a single level of abstraction where one TRY block manages the errors relevant to that scope. Any inner operations requiring localized exception handling should be extracted into a well-named private method. The ATC rule flags nested TRY statements with NO_NESTTRY.",
    "className": "/SKYL/CL_NO_NESTED_TRY",
    "pseudoComment": "NO_NESTED_TRY",
    "category": "anti-patterns",
    "example": {
      "bad": "TRY.\n    validate_customer_account( iv_customer_id = lv_customer_id ).\n    TRY.\n        charge_customer_card( iv_amount = lv_invoice_amount ).\n      CATCH cx_payment_declined INTO DATA(lx_payment).\n        log_payment_failure( lx_payment ).\n    ENDTRY.\n  CATCH cx_account_locked INTO DATA(lx_account).\n    handle_account_locked( lx_account ).\nENDTRY.",
      "good": "TRY.\n    validate_customer_account( iv_customer_id = lv_customer_id ).\n    process_card_payment( iv_amount = lv_invoice_amount ).\n  CATCH cx_account_locked INTO DATA(lx_account).\n    handle_account_locked( lx_account ).\nENDTRY."
    },
    "seo": {
      "description": "Prevent nested TRY CATCH blocks in ABAP Cloud by refactoring inner error handlers into modular helper methods.",
      "keywords": [
        "no-nested-try",
        "Clean ABAP",
        "ABAP Cloud",
        "TRY CATCH",
        "refactoring",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-catch-root",
      "no-exc-overlap",
      "pref-auth-check"
    ],
    "customSection": "## Detection Details\n\nThe check tracks nesting depth of `TRY` statements within procedures. When a `TRY` statement is encountered at depth 1 or greater, finding code `NO_NESTTRY` is reported against that statement.\n\n### Clean ABAP Remedy\nExtract the inner `TRY ... CATCH` block into a dedicated private method (e.g. `process_card_payment`). This clarifies which layer owns each recovery path and reduces cognitive load.\n\n### Suppression\nSuppress individual occurrences using `\"#EC NO_NESTED_TRY`."
  },
  {
    "ruleId": "no-raise-cx-sy",
    "title": "Avoid Raising System Exceptions Directly (cx_sy_*)",
    "rationale": "Classes in the CX_SY_* namespace (such as CX_SY_ZERODIVIDE, CX_SY_ITAB_LINE_NOT_FOUND, or CX_SY_REF_IS_INITIAL) are reserved for and raised exclusively by the SAP ABAP runtime kernel. Raising system exceptions manually in business application logic confuses callers, pollutes system logs, and obscures whether an error originated from a kernel runtime defect or from a business validation check. Application programs must define dedicated custom exception classes inheriting from CX_STATIC_CHECK, CX_DYNAMIC_CHECK, or CX_NO_CHECK that clearly articulate domain failure reasons.",
    "className": "/SKYL/CL_NO_RAISE_CX_SY",
    "pseudoComment": "NO_RAISE_CX_SY",
    "category": "security",
    "example": {
      "bad": "DATA lv_discount_percentage TYPE i VALUE 150.\nIF lv_discount_percentage > 100.\n  \" Anti-pattern: Raising kernel exception for business validation failure\n  RAISE EXCEPTION TYPE cx_sy_zerodivide.\nENDIF.",
      "good": "DATA lv_discount_percentage TYPE i VALUE 150.\nIF lv_discount_percentage > 100.\n  RAISE EXCEPTION NEW cx_static_check( ).\nENDIF."
    },
    "seo": {
      "description": "Maintain clean error boundaries in SAP ABAP by creating domain-specific exceptions instead of raising internal CX_SY_* system exceptions.",
      "keywords": [
        "no-raise-cx-sy",
        "CX_SY_*",
        "custom exceptions",
        "Clean ABAP",
        "ABAP error handling"
      ]
    },
    "relatedRules": [
      "pref-class-exc",
      "no-raise-shortdump",
      "no-catch-root"
    ],
    "customSection": "### Scope and Detection\n\nThe rule monitors `RAISE EXCEPTION` statements where the target exception class type reference matches the pattern `\\TY:CX_SY_*`.\n\n- **Finding Code:** `NO_RAIS_SY`\n- **Pseudo-Comment:** `\"#EC NO_RAISE_CX_SY`\n\nAlways define a domain exception class (e.g., `ZCX_PURCHASE_ORDER_INVALID`) that encapsulates relevant business error messages, parameters, and symptom descriptions rather than re-using runtime kernel exceptions."
  },
  {
    "ruleId": "pref-check-subrc",
    "title": "Verify sy-subrc Promptly After Data Retrieval and Search",
    "rationale": "Statements such as SELECT SINGLE, READ TABLE, FIND, SEARCH, dynamic ASSIGN and table MODIFY report success only through sy-subrc. If any other statement runs first, sy-subrc is overwritten and failures are silently ignored, which produces empty structures, unassigned field symbols or missing rows at runtime. The check demands that the immediately following statement evaluates sy-subrc, and its switches avoid the finding for operation kinds where the result is genuinely irrelevant.",
    "className": "/SKYL/CL_PREF_CHECK_SUBRC",
    "pseudoComment": "PREF_CHECK_SUBRC",
    "category": "clean-abap",
    "example": {
      "bad": "SELECT SINGLE customer_name FROM /dmo/customer\n  WHERE customer_id = @lv_customer_id\n  INTO @DATA(lv_customer_name).\nprocess_customer( lv_customer_name ).",
      "good": "SELECT SINGLE customer_name FROM /dmo/customer\n  WHERE customer_id = @lv_customer_id\n  INTO @DATA(lv_customer_name).\nIF sy-subrc <> 0.\n  RAISE EXCEPTION NEW zcx_customer_not_found( ).\nENDIF."
    },
    "parameters": {
      "CHECK_SELECT_SINGLE": "Report SELECT SINGLE statements whose next statement does not evaluate sy-subrc. Keep enabled so empty results are never silently processed.",
      "CHECK_READ_TABLE": "Report READ TABLE statements that are not followed by a sy-subrc evaluation, so a missing table line cannot go unnoticed.",
      "CHECK_FIND_SEARCH": "Report FIND and SEARCH statements without an immediate sy-subrc check. Disable when the offset result is genuinely optional.",
      "CHECK_ASSIGN": "Report dynamic ASSIGN statements without a sy-subrc check, which otherwise leave a field symbol unassigned and cause short dumps.",
      "CHECK_INSERT": "Report database INSERT statements without a sy-subrc check. Disable for customizing writes that are validated elsewhere.",
      "CHECK_MODIFY": "Report MODIFY statements on internal tables without a sy-subrc check, which reveals rows that were not found."
    },
    "seo": {
      "description": "Enforce an immediate sy-subrc check after SELECT SINGLE, READ TABLE, FIND, SEARCH, ASSIGN and table MODIFY to stop silently ignored failures.",
      "keywords": [
        "pref-check-subrc",
        "sy-subrc",
        "SELECT SINGLE",
        "READ TABLE",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-auth-subrc",
      "pref-auth-check",
      "no-unhandled-eml"
    ],
    "customSection": "### Covered statements\n\n| Statement | Attribute |\n| --- | --- |\n| `SELECT SINGLE` | `CHECK_SELECT_SINGLE` |\n| `READ TABLE` | `CHECK_READ_TABLE` |\n| `FIND`, `SEARCH` | `CHECK_FIND_SEARCH` |\n| `ASSIGN` | `CHECK_ASSIGN` |\n| database `INSERT` | `CHECK_INSERT` |\n| internal-table `MODIFY` | `CHECK_MODIFY` |\n\n`OPEN DATASET`, `UPDATE ... SET` and `DELETE FROM` are always inspected and have no switch. Only the directly following statement is examined, therefore a declaration or log statement between the operation and the `sy-subrc` test still produces `PREF_CHKSC` — that is intentional, because almost any statement updates `sy-subrc`. Use `\"#EC PREF_CHECK_SUBRC` where the result is truly irrelevant."
  },
  {
    "ruleId": "pref-auth-subrc",
    "title": "Check sy-subrc Immediately After AUTHORITY-CHECK",
    "rationale": "Executing an AUTHORITY-CHECK statement without immediately inspecting sy-subrc is a critical security vulnerability classified under CWE-862 (Missing Authorization Check). The SAP kernel evaluates user authorizations and returns sy-subrc = 0 on success or a non-zero authorization return code on failure. If intermediate statements execute before evaluating sy-subrc, subsequent statements (such as SELECT, READ TABLE, or method calls) overwrite sy-subrc, inadvertently allowing unauthorized users to execute privileged operations or access confidential data.",
    "className": "/SKYL/CL_PREF_AUTH_SUBRC",
    "pseudoComment": "PREF_AUTH_SUBRC",
    "category": "security",
    "example": {
      "bad": "DATA lv_partner_id TYPE string VALUE '1000001'.\nAUTHORITY-CHECK OBJECT 'S_TABU_DIS'\n  ID 'DICBERCLS' FIELD '&NC&'\n  ID 'ACTVT'     FIELD '03'.\n\nSELECT SINGLE partner, name_first\n  FROM but000\n  WHERE partner = @lv_partner_id\n  INTO @DATA(ls_partner).\n\" Anti-pattern: sy-subrc was overwritten by SELECT without checking authorization!",
      "good": "DATA lv_partner_id TYPE string VALUE '1000001'.\nAUTHORITY-CHECK OBJECT 'S_TABU_DIS'\n  ID 'DICBERCLS' FIELD '&NC&'\n  ID 'ACTVT'     FIELD '03'.\nIF sy-subrc <> 0.\n  RETURN.\nENDIF.\n\nSELECT SINGLE partner, name_first\n  FROM but000\n  WHERE partner = @lv_partner_id\n  INTO @DATA(ls_partner)."
    },
    "seo": {
      "description": "Prevent CWE-862 authorization bypass vulnerabilities in SAP ABAP by verifying sy-subrc immediately following AUTHORITY-CHECK statements.",
      "keywords": [
        "pref-auth-subrc",
        "AUTHORITY-CHECK",
        "CWE-862",
        "sy-subrc",
        "SAP security"
      ]
    },
    "relatedRules": [
      "pref-check-subrc",
      "pref-auth-check",
      "no-unhandled-eml"
    ],
    "customSection": "### Security Vulnerability (CWE-862)\n\nOmitting the `sy-subrc` check immediately following `AUTHORITY-CHECK` leads to privilege escalation because any subsequent statement that succeeds sets `sy-subrc` to 0, completely nullifying the security check.\n\n- **Finding Code:** `PREF_AUTHS` (Severity: Error)\n- **QuickFix Code:** `CHK_AUTHS` automatically inserts the standard `IF sy-subrc <> 0. RETURN. ENDIF.` block immediately following the `AUTHORITY-CHECK` statement.\n- **Suppression:** Suppress with pseudo-comment `\"#EC PREF_AUTH_SUBRC`."
  },
  {
    "ruleId": "no-client-spec",
    "title": "Avoid CLIENT SPECIFIED and USING CLIENT in ABAP SQL",
    "rationale": "The CLIENT SPECIFIED and USING CLIENT clauses in ABAP SQL bypass automatic client handling and disable implicit tenant filtering. In multi-tenant cloud environments (such as SAP BTP ABAP Environment and SAP S/4HANA Cloud), querying or mutating data across client boundaries violates multi-tenancy isolation and data privacy compliance (GDPR). In ABAP Cloud (Contract C1), explicit client handling is strictly prohibited, and OpenSQL automatically guarantees that database operations are strictly confined to the logon tenant.",
    "className": "/SKYL/CL_NO_CLIENT_SPEC",
    "pseudoComment": "NO_CLIENT_SPEC",
    "category": "security",
    "example": {
      "bad": "DATA lv_partner_id TYPE string VALUE '1000001'.\nSELECT SINGLE partner, name_first\n  FROM but000\n  USING CLIENT '100'\n  WHERE partner = @lv_partner_id\n  INTO @DATA(ls_business_partner).",
      "good": "DATA lv_partner_id TYPE string VALUE '1000001'.\nSELECT SINGLE partner, name_first\n  FROM but000\n  WHERE partner = @lv_partner_id\n  INTO @DATA(ls_business_partner)."
    },
    "seo": {
      "description": "Preserve multi-tenant data isolation and GDPR compliance in SAP BTP and S/4HANA by avoiding USING CLIENT and CLIENT SPECIFIED in ABAP SQL.",
      "keywords": [
        "no-client-spec",
        "CLIENT SPECIFIED",
        "USING CLIENT",
        "multi-tenant isolation",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-unfilt-dml",
      "no-db-in-loop",
      "no-empty-fae"
    ],
    "customSection": "### Scope and Multi-Tenant Isolation\n\nThe rule monitors all ABAP SQL database operations (`SELECT`, `UPDATE`, `MODIFY`, `DELETE`, `INSERT`) and reports any occurrence of:\n\n- `USING CLIENT` (ABAP SQL modern client switching)\n- `CLIENT SPECIFIED` (Classic Open SQL client switching)\n\n**Finding Code:** `NO_CLNT_SP`  \n**Suppression:** Pseudo-comment `\"#EC NO_CLIENT_SPEC`.\n\nIn ABAP Cloud and SAP BTP, tenant separation is maintained automatically by the application server and the database engine. Cross-client access is disallowed to ensure compliance with multi-tenant security architecture."
  },
  {
    "ruleId": "pref-transport",
    "title": "Specify TRANSPORTING in Internal Table MODIFY Inside Loops",
    "rationale": "Using MODIFY itab FROM workarea inside a loop without a TRANSPORTING clause causes the ABAP runtime to perform a full deep copy of every component from the work area into the internal table row on every iteration. For wide table structures, nested tables, or tables with large text fields, copying untouched columns wastes significant CPU cycles, causes CPU cache misses, and triggers memory reallocations. Clean ABAP recommends adding TRANSPORTING to update only modified columns, or even better, updating fields directly in memory using field symbols (ASSIGNING FIELD-SYMBOL) for zero-copy performance.",
    "className": "/SKYL/CL_PREF_TRANSPORT",
    "pseudoComment": "PREF_TRANSPORT",
    "category": "performance",
    "example": {
      "bad": "LOOP AT lt_orders INTO DATA(ls_order).\n  ls_order-processing_status = 'COMPLETED'.\n  MODIFY lt_orders FROM ls_order INDEX sy-tabix.\nENDLOOP.",
      "good": "LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>).\n  <ls_order>-processing_status = 'COMPLETED'.\nENDLOOP."
    },
    "seo": {
      "description": "Optimize ABAP internal table mutations inside loops by specifying TRANSPORTING fields or using in-place field symbols to eliminate full-structure copying.",
      "keywords": [
        "pref-transport",
        "MODIFY itab",
        "TRANSPORTING",
        "Clean ABAP",
        "SAP ATC performance"
      ]
    },
    "relatedRules": [
      "no-mod-loop-tab",
      "no-loop-into",
      "pref-read-table"
    ],
    "customSection": "### Detection Details\n\nThe check evaluates `MODIFY` statements inside `LOOP ... ENDLOOP` blocks targeting internal tables (identified by `FROM` or `INDEX`). If the `TRANSPORTING` clause is omitted, finding code `PREF_TRNSP` is reported. Database table `MODIFY` statements are automatically excluded.\n\n### Modern Zero-Copy Alternatives\n\nWhile adding `TRANSPORTING col1 col2` eliminates unnecessary field copying, the preferred Clean ABAP approach is mutating table rows in place using field symbols: `LOOP AT lt_tab ASSIGNING FIELD-SYMBOL(<ls_row>)`. This completely avoids the overhead of `MODIFY` statements.\n\nSuppress intentional full-structure updates with the pseudo comment `\"#EC PREF_TRANSPORT`."
  },
  {
    "ruleId": "pref-str-func",
    "title": "Replace Obsolete String Statements with Built-in String Functions",
    "rationale": "CONDENSE, TRANSLATE, SHIFT, SEARCH, OVERLAY, REPLACE and DESCRIBE FIELD mutate a variable in place, cannot be used inside an expression, and are flagged by the ABAP Cloud language profile. Built-in functions such as condense( ), to_upper( ), shift_left( ), find( ), replace( ) and strlen( ) return values, compose with constructor expressions and inline declarations, and state the intended transformation without side effects. The check reports one finding code per statement family and supplies QuickFixes for the mechanically safe rewrites.",
    "className": "/SKYL/CL_PREF_STR_FUNC",
    "pseudoComment": "PREF_STR_FUNC",
    "category": "clean-abap",
    "example": {
      "bad": "CONDENSE lv_address_text.\nTRANSLATE lv_country_code TO UPPER CASE.",
      "good": "lv_address_text = condense( lv_address_text ).\nlv_country_code  = to_upper( lv_country_code )."
    },
    "parameters": {
      "CHECK_CONDENSE": "Report CONDENSE statements. The QuickFix rewrites them as condense( val = ... ) and keeps the NO-GAPS variant as from/to parameters.",
      "CHECK_TRANSLATE": "Report TRANSLATE statements. UPPER and LOWER map to to_upper( ) / to_lower( ), while USING masks map to translate( ).",
      "CHECK_SHIFT": "Report SHIFT statements. The QuickFix emits shift_left( ) or shift_right( ) with places or the DELETING mask.",
      "CHECK_SEARCH": "Report SEARCH statements. No QuickFix is offered, because the correct replacement is find( ) or contains( ) depending on the surrounding logic.",
      "CHECK_OVERLAY": "Report OVERLAY statements. No QuickFix is offered, because the replacement is a string template or an explicit replace( ).",
      "CHECK_REPLACE": "Report REPLACE ... WITH ... INTO ... statements. The QuickFix rewrites them as replace( val = ... sub = ... with = ... ).",
      "CHECK_DESCRIBE": "Report DESCRIBE FIELD ... LENGTH statements. The QuickFix writes strlen( ) or xstrlen( ) for the IN BYTE MODE variant."
    },
    "seo": {
      "description": "Replace CONDENSE, TRANSLATE, SHIFT, SEARCH, OVERLAY, REPLACE and DESCRIBE with modern built-in string functions such as to_upper( ) and shift_left( ).",
      "keywords": [
        "pref-str-func",
        "string functions",
        "CONDENSE",
        "TRANSLATE",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-str-tmpl",
      "no-useless-concat",
      "no-obs-strings"
    ],
    "customSection": "### Finding codes\n\n| Code | Obsolete statement | Replacement |\n| --- | --- | --- |\n| `PREF_CNDNS` | `CONDENSE` | `condense( )` |\n| `PREF_TRNSL` | `TRANSLATE ... TO UPPER/LOWER CASE`, `USING` | `to_upper( )`, `to_lower( )`, `translate( )` |\n| `PREF_SHIFT` | `SHIFT ... BY ... PLACES`, `DELETING LEADING/TRAILING` | `shift_left( )`, `shift_right( )` |\n| `PREF_SRCH` | `SEARCH` | `find( )`, `contains( )` |\n| `PREF_OVRLY` | `OVERLAY` | string templates, `replace( )` |\n| `PREF_RPLC` | `REPLACE ... WITH ... INTO ...` | `replace( val = ... sub = ... with = ... )` |\n| `PREF_DSCFD` | `DESCRIBE FIELD ... LENGTH` | `strlen( )`, `xstrlen( )` |\n\n`SEARCH` and `OVERLAY` intentionally have no QuickFix. `REPLACE ... WITH ... IN ...` (in-place) and `DESCRIBE FIELD ... TYPE` are not reported by this check. All findings share the pseudo-comment `\"#EC PREF_STR_FUNC`."
  },
  {
    "ruleId": "pref-calc-op",
    "title": "Prefer Calculation Assignment Operators (+=, -=, *=, /=)",
    "rationale": "Assignments such as lv_stock = lv_stock - 1 repeat the target variable and force the reader to compare both sides to see that it is a simple update. Compound operators +=, -=, *= and /= express the change once, cannot accidentally read a different variable, and are the modern replacement for the obsolete ADD, SUBTRACT, MULTIPLY and DIVIDE statements. The check reports PREF_CALOP for both forms and supplies a CALCASGN QuickFix that rewrites the statement in place.",
    "className": "/SKYL/CL_PREF_CALC_OP",
    "pseudoComment": "PREF_CALC_OP",
    "category": "clean-abap",
    "example": {
      "bad": "lv_stock_quantity = lv_stock_quantity - 1.",
      "good": "lv_stock_quantity -= 1."
    },
    "seo": {
      "description": "Use compound calculation assignment operators +=, -=, *= and /= instead of repeated self-assignments and obsolete ADD or SUBTRACT statements.",
      "keywords": [
        "pref-calc-op",
        "calculation assignment",
        "ADD SUBTRACT",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-symbol-op",
      "no-obs-arith",
      "pref-downport"
    ],
    "customSection": "### Rewrites\n\n| Obsolete or verbose statement | Replacement |\n| --- | --- |\n| `ADD 1 TO lv_count.` | `lv_count += 1.` |\n| `SUBTRACT 1 FROM lv_count.` | `lv_count -= 1.` |\n| `MULTIPLY lv_count BY 2.` | `lv_count *= 2.` |\n| `DIVIDE lv_count BY 2.` | `lv_count /= 2.` |\n| `lv_count = lv_count + 1.` | `lv_count += 1.` |\n\nThe statement forms are only reported in the simple four-token shape; `ADD ... THEN`, `ACCORDING TO` and `PERFORM` variants are skipped. Self-assignments are recognised only when the left-hand side and the first operand are textually identical, so `lv_total = lv_total + lv_tax` is flagged while `lv_total = lv_subtotal + lv_tax` is not. Suppress with `\"#EC PREF_CALC_OP`."
  },
  {
    "ruleId": "pref-early-ret",
    "title": "Prefer Early Return and CONTINUE Guard Clauses over Nesting",
    "rationale": "Wrapping the whole method body in IF is_valid( ) pushes the happy path one indentation level to the right and grows with every additional precondition. A guard clause rejects invalid input at the top, so the remaining code stays flat, has a single indentation level, and each precondition can be read and tested in isolation. The same reasoning applies inside loops, where an inverted IF with CONTINUE removes nesting, and to ELSE branches that follow a RETURN or RAISE and can never be reached in sequence.",
    "className": "/SKYL/CL_PREF_EARLY_RET",
    "pseudoComment": "PREF_GUARD_METHOD",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD post_goods_issue.\n  IF is_posting_allowed( ).\n    create_material_document( ).\n    update_stock_balance( ).\n  ENDIF.\nENDMETHOD.",
      "good": "METHOD post_goods_issue.\n  IF is_posting_allowed( ) = abap_false.\n    RETURN.\n  ENDIF.\n  create_material_document( ).\n  update_stock_balance( ).\nENDMETHOD."
    },
    "parameters": {
      "CHECK_METHOD_RETURN": "Report an IF that wraps the entire method body so it can be inverted into a RETURN guard clause. Enabled by default.",
      "CHECK_LOOP_CONTINUE": "Report an IF that wraps the complete body of LOOP, DO or WHILE so it can be inverted into a CONTINUE guard clause. Enabled by default.",
      "REPORT_ELSEIF": "Also report ELSEIF branches that directly follow a terminating statement such as RETURN or RAISE. Disabled by default because not every chain flattens safely."
    },
    "seo": {
      "description": "Flatten nested ABAP methods and loops with early RETURN and CONTINUE guard clauses, and remove ELSE branches that follow a terminating statement.",
      "keywords": [
        "pref-early-ret",
        "guard clause",
        "early return",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-return",
      "no-ignored-return",
      "no-unnec-return"
    ],
    "customSection": "### Finding codes\n\n| Code | Trigger | Suggestion |\n| --- | --- | --- |\n| `PREF_GRDMT` | first executable method statement is an `IF` wrapping the whole body | invert the condition and `RETURN` |\n| `PREF_GRDLP` | an `IF` wraps the complete body of `LOOP`, `DO` or `WHILE` | invert the condition and `CONTINUE` |\n| `NO_ELSEEXT` | `ELSE` or `ELSEIF` directly after `RETURN`, `EXIT`, `CONTINUE`, `LEAVE` or `RAISE` | drop the redundant branch |\n\n`CHECK_METHOD_RETURN` and `CHECK_LOOP_CONTINUE` toggle the two guard-clause checks; `REPORT_ELSEIF` additionally reports `ELSEIF` after a terminator and is off by default. The `REM_ELSE` QuickFix replaces `ELSE` with `ENDIF` and deletes the original `ENDIF`, so nested `IF` blocks inside the branch are preserved. Pseudo-comments: `\"#EC PREF_GUARD_METHOD`, `\"#EC PREF_GUARD_LOOP`, `\"#EC PREF_NO_ELSE_EXIT`."
  },
  {
    "ruleId": "no-unused-vars",
    "title": "Remove Unread Local Variables and Field Symbols",
    "rationale": "Unused local variables and field symbols add cognitive clutter, create false assumptions during code reviews, and often signal incomplete refactorings or forgotten business calculations. In Clean ABAP and ABAP Cloud development, every declared variable must serve an active purpose in the routine; unread declarations waste memory and distract maintainers. The ATC check inspects symbol definitions from DATA and FIELD-SYMBOLS statements (including inline definitions) and emits NO_UNUS_VR if no subsequent READ reference exists.",
    "className": "/SKYL/CL_NO_UNUSED_VARS",
    "pseudoComment": "NO_UNUSED_VARS",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_tax_rate TYPE decfloat34.\nDATA lv_net_amount TYPE decfloat34.\nlv_net_amount = calculate_net_amount( ).\nprocess_invoice( iv_amount = lv_net_amount ).",
      "good": "DATA lv_net_amount TYPE decfloat34.\nlv_net_amount = calculate_net_amount( ).\nprocess_invoice( iv_amount = lv_net_amount )."
    },
    "seo": {
      "description": "Detect and eliminate unread local variables and inline declarations in ABAP Cloud code according to Clean ABAP guidelines.",
      "keywords": [
        "no-unused-vars",
        "Clean ABAP",
        "ABAP Cloud",
        "unused variables",
        "dead code",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-naming-vars",
      "no-shadow",
      "pref-full-typed"
    ],
    "customSection": "## Detection Details\n\nThe check collects all local definitions from `DATA`, `FIELD-SYMBOLS`, and inline declarations (`DATA(...)` and `FIELD-SYMBOL(...)`). It resolves compiler symbol references to verify whether each declared symbol is ever read within the procedure. If a variable is only written or never accessed, finding code `NO_UNUS_VR` is reported.\n\n### Suppression\nIf a variable must be retained for signature or future contract compatibility, suppress the finding with `\"#EC NO_UNUSED_VARS`."
  },
  {
    "ruleId": "pref-case",
    "title": "Prefer CASE over Multiple IF / ELSEIF on the Same Variable",
    "rationale": "A chain of ELSEIF statements that compares the same variable against different constants is harder to scan than a CASE statement: the subject is repeated in every branch and a missing alternative is easy to overlook. CASE names the subject once, groups all alternatives under it, and makes a deliberate WHEN OTHERS branch visible in the code review. The check counts the branches against a configurable threshold, so simple two-way decisions stay as IF and only real multi-value dispatches are converted.",
    "className": "/SKYL/CL_PREF_CASE",
    "pseudoComment": "PREF_CASE",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_shipping_type = 'STANDARD'.\n  schedule_standard_delivery( ).\nELSEIF lv_shipping_type = 'EXPRESS'.\n  schedule_express_delivery( ).\nELSEIF lv_shipping_type = 'PICKUP'.\n  confirm_store_pickup( ).\nENDIF.",
      "good": "CASE lv_shipping_type.\n  WHEN 'STANDARD'.\n    schedule_standard_delivery( ).\n  WHEN 'EXPRESS'.\n    schedule_express_delivery( ).\n  WHEN 'PICKUP'.\n    confirm_store_pickup( ).\n  WHEN OTHERS.\n    RAISE EXCEPTION NEW zcx_invalid_shipping_type( ).\nENDCASE."
    },
    "parameters": {
      "MIN_BRANCHES": "Number of comparisons on the same variable required before CASE is suggested. Default 3 means one IF plus two ELSEIF branches; set it to 2 for a stricter dispatch style."
    },
    "seo": {
      "description": "Convert IF/ELSEIF chains that compare one variable against many values into a readable CASE statement with an explicit WHEN OTHERS branch.",
      "keywords": [
        "pref-case",
        "CASE statement",
        "ELSEIF chain",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-cond",
      "pref-switch",
      "no-single-when"
    ],
    "customSection": "### Threshold and detection\n\n`MIN_BRANCHES` counts the `IF` plus every `ELSEIF` that compares the same variable with `=` or `EQ`. With the default of `3`, two `ELSEIF` branches are required before `PREF_CASE` is raised, so a plain `IF/ELSE` is never reported. Chains that mix variables, or that use `AND`, `OR`, `BETWEEN`, `IN` or `IS` in the condition, are left alone because they are not a single-subject dispatch.\n\nThe `USE_CASE` QuickFix replaces the whole `IF/ELSEIF/ENDIF` range, converts `ELSE` to `WHEN OTHERS` and keeps the original indentation and nested statements. If the branches compare different fields, restructure the code manually instead of suppressing with `\"#EC PREF_CASE`."
  },
  {
    "ruleId": "no-inline-len",
    "title": "Declare Character Lengths with Explicit LENGTH Clause Instead of Parenthesized Syntax",
    "rationale": "Specifying variable lengths directly on identifiers using parentheses, such as DATA lv_code(10) TYPE c, is legacy ABAP syntax that easily confuses identifier names with function calls, array indices, or substring offsets. Modern ABAP Cloud and Clean ABAP standards require explicit length declarations using the TYPE ... LENGTH ... addition or domain-specific named types. The ATC check flags parenthesized lengths in DATA, CONSTANTS, and STATICS statements with NO_INL_LEN and provides the USELENGTH quickfix to rewrite the statement cleanly.",
    "className": "/SKYL/CL_NO_INLINE_LEN",
    "pseudoComment": "NO_INLINE_LEN",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_postal_code(10) TYPE c.",
      "good": "DATA lv_postal_code TYPE c LENGTH 10."
    },
    "seo": {
      "description": "Replace legacy parenthesized length specifications in ABAP declarations with modern TYPE LENGTH syntax and automated quickfixes.",
      "keywords": [
        "no-inline-len",
        "Clean ABAP",
        "ABAP Cloud",
        "LENGTH clause",
        "DATA declaration",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-inline",
      "no-chained-decl",
      "no-chained-assign"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check evaluates `DATA`, `CONSTANTS`, and `STATICS` statements whose identifier token matches the pattern `*(*)` with an embedded length specification. When flagged, the check offers the `USELENGTH` quickfix, which automatically transforms declarations into modern `TYPE c LENGTH ...` syntax.\n\n| Legacy Syntax | Modern Clean ABAP Replacement |\n|---|---|\n| `DATA lv_code(10) TYPE c.` | `DATA lv_code TYPE c LENGTH 10.` |\n| `DATA lv_flag(1).` | `DATA lv_flag TYPE c LENGTH 1.` |\n| `CONSTANTS lc_prefix(4) TYPE c VALUE 'INV-'.` | `CONSTANTS lc_prefix TYPE c LENGTH 4 VALUE 'INV-'.` |\n\n### Suppression\nSuppress findings with the pseudo comment `\"#EC NO_INLINE_LEN`."
  },
  {
    "ruleId": "max-one-stmt",
    "title": "Limit One Statement per Source Code Line",
    "rationale": "Writing multiple statements on a single source line severely compromises code readability, debugger operation, and Git history tracking. In modern development with Eclipse ADT, breakpoints and single-step debugging operate at the line level: when multiple statements share one line, stepping into individual operations becomes impossible or misleading. Furthermore, line-level diffs in version control cannot isolate which statement was altered, obscuring change intent during peer code reviews. Clean ABAP mandates exactly one statement per source line.",
    "className": "/SKYL/CL_MAX_ONE_STMT",
    "pseudoComment": "MAX_ONE_STMT",
    "category": "metrics",
    "example": {
      "bad": "lv_order_status = 'OPEN'. lv_item_count = 0. CLEAR ls_billing_header.",
      "good": "lv_order_status = 'OPEN'.\nlv_item_count = 0.\nCLEAR ls_billing_header."
    },
    "seo": {
      "description": "Enforce one ABAP statement per line to ensure clear Git diffs, accurate debugger stepping, and clean code formatting.",
      "keywords": [
        "max-one-stmt",
        "one statement per line",
        "Clean ABAP",
        "SAP ATC",
        "code formatting"
      ]
    },
    "relatedRules": [
      "max-line-len",
      "max-params",
      "max-returns"
    ],
    "customSection": "## Evaluation Details\n\nThe check iterates through all procedure statements and compares the start line of the current statement with the end line of the preceding statement. If `lv_stmt_start = lv_prev_end_line`, the subsequent statement is reported.\n\n| Finding Code | Severity | Trigger | Suppression |\n|---|---|---|---|\n| `MAX_1STMT` | Warning | Statement begins on the same line where the previous statement ended | `##MAX_ONE_STMT` or `\"#EC MAX_ONE_STMT` |\n\n### Formatting Impact\nNever use colon-chains or sequential statements on the same line (`a = 1. b = 2.`). Always format each statement onto a distinct source line with appropriate indentation."
  },
  {
    "ruleId": "no-dash-in-form",
    "title": "Use Underscores Instead of Hyphens in Subroutine FORM Names",
    "rationale": "Using a hyphen inside a FORM subroutine name is an obsolete SAP syntax quirk that clashes with the structure component selector (-) in modern ABAP. It severely impairs readability, confuses static code analyzers, and introduces syntax ambiguity in legacy subroutines. Clean ABAP requires snake_case identifiers using underscores for all procedural names. The ATC check scans FORM statements for hyphens, reports NO_DASH_FM, and provides the DASH2UND quickfix to automatically replace hyphens with underscores.",
    "className": "/SKYL/CL_NO_DASH_IN_FORM",
    "pseudoComment": "NO_DASH_IN_FORM",
    "category": "anti-patterns",
    "example": {
      "bad": "FORM calculate-tax-total.\nENDFORM.",
      "good": "FORM calculate_tax_total.\nENDFORM."
    },
    "seo": {
      "description": "Prevent hyphens in FORM routine names and convert dashes to underscores in ABAP code using automated ATC quickfixes.",
      "keywords": [
        "no-dash-in-form",
        "Clean ABAP",
        "FORM routine",
        "subroutine naming",
        "SAP ATC",
        "quickfix"
      ]
    },
    "relatedRules": [
      "no-obs-arith",
      "no-obs-control",
      "no-obs-decl"
    ],
    "customSection": "## Detection Details\n\nThe rule checks statements with keyword `FORM` whose second token (subroutine name) contains a hyphen (`-`). The automated quickfix `DASH2UND` replaces every hyphen in the subroutine header with an underscore.\n\n### Modern Alternative\nWhile this rule ensures hygiene in legacy programs that still retain subroutines, new ABAP Cloud development prohibits `FORM` entirely. Subroutines should be refactored into methods on local or global classes.\n\n### Suppression\nSuppress findings with `\"#EC NO_DASH_IN_FORM`."
  },
  {
    "ruleId": "pref-inline",
    "title": "Prefer Inline Declarations over Separate DATA and Assignment",
    "rationale": "Declaring a variable at the top of a method and assigning it several statements later separates the declaration from its first use and widens its lifetime, which makes the method harder to reason about. An inline declaration keeps the variable next to the expression that produces it, lets the compiler infer the type, and removes the risk that the declared type drifts from the assigned one. The check only reports declarations whose first use is a pure write, so variables that are read before they are filled are never touched.",
    "className": "/SKYL/CL_PREF_INLINE",
    "pseudoComment": "PREF_INLINE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.\nlv_gross_amount = lv_net_amount * lv_tax_factor.",
      "good": "DATA(lv_gross_amount) = lv_net_amount * lv_tax_factor."
    },
    "seo": {
      "description": "Merge separate DATA declarations with their first assignment into inline DATA( ) declarations to shorten ABAP methods and infer types automatically.",
      "keywords": [
        "pref-inline",
        "inline declaration",
        "DATA( )",
        "Clean ABAP",
        "ABAP 7.40"
      ]
    },
    "relatedRules": [
      "no-inline-len",
      "no-chained-decl",
      "pref-declarations"
    ],
    "customSection": "### When the check fires\n\n`PREF_INLIN` is raised only when the declaration is followed — at the same nesting depth — by a first use that is a pure write of the variable:\n\n| First use | Replacement |\n| --- | --- |\n| `lv_x = <expression>` | `DATA(lv_x) = <expression>` |\n| `READ TABLE ... INTO lv_x` | `READ TABLE ... INTO DATA(lv_x)` |\n| `LOOP AT ... INTO lv_x` | `LOOP AT ... INTO DATA(lv_x)` |\n| `CATCH ... INTO lv_x` | `CATCH ... INTO DATA(lv_x)` |\n\nThe check stays silent when the variable is read inside the first statement (`lv_total = lv_total + 1`), when it is used in a nested block before the write, when it is declared inside a structure (`BEGIN OF`), or when the assignment uses the casting operator `?=`. Suppress a single declaration with `\"#EC PREF_INLINE`."
  },
  {
    "ruleId": "pref-final-data",
    "title": "Declare Single-Assignment Local Variables with FINAL( )",
    "rationale": "Declaring inline variables with FINAL( ) ensures immutability across the remainder of the method body, preventing accidental reassignment and lowering cognitive load during maintenance. When the ABAP compiler enforces single-assignment semantics, readers immediately recognize that the variable represents a constant calculation or fixed object reference. The check inspects procedure statements, verifies via ATC compiler references that no write usage occurs after initial definition, and reports PREF_FNDAT with the TOFINAL quickfix.",
    "className": "/SKYL/CL_PREF_FINAL_DATA",
    "pseudoComment": "PREF_FINAL_DATA",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_discount_rate) = calculate_discount( iv_customer_tier = 'GOLD' ).\napply_discount( lv_discount_rate ).",
      "good": "FINAL(lv_discount_rate) = calculate_discount( iv_customer_tier = 'GOLD' ).\napply_discount( lv_discount_rate )."
    },
    "seo": {
      "description": "Enforce immutable local declarations in ABAP Cloud by replacing single-assignment DATA inline statements with FINAL to improve readability and safety.",
      "keywords": [
        "pref-final-data",
        "FINAL()",
        "inline declaration",
        "Clean ABAP",
        "immutability"
      ]
    },
    "relatedRules": [
      "pref-naming-vars",
      "no-single-letter",
      "no-chained-decl"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check scans procedure statements for inline `DATA(var)` declarations. Using compiler reference tracking (`usage_modes-write`), it verifies whether `var` is subsequently modified anywhere in the procedure. If no write references exist, ATC finding `PREF_FNDAT` is reported. The `TOFINAL` quickfix automatically substitutes `DATA(` with `FINAL(` while preserving surrounding expressions.\n\nSuppress individual findings using the pseudo comment `\"#EC PREF_FINAL_DATA`."
  },
  {
    "ruleId": "no-friends",
    "title": "Avoid Granting Friendship via FRIENDS in Class Definitions",
    "rationale": "Declaring another class as a friend breaks fundamental encapsulation by granting external entities unrestricted access to private and protected attributes and internal methods. This creates hidden, tightly coupled bidirectional dependencies that make refactoring dangerous and unit testing brittle. Clean ABAP and ABAP Cloud architecture advocate for public interface contracts and dependency injection rather than bypassing encapsulation via FRIENDS. The ATC check reports NO_FRIENDS whenever a class definition declares friendship.",
    "className": "/SKYL/CL_NO_FRIENDS",
    "pseudoComment": "NO_FRIENDS",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS zcl_invoice_service DEFINITION PUBLIC FINAL CREATE PUBLIC\n  FRIENDS zcl_invoice_test_helper.\n  PUBLIC SECTION.\n    METHODS process_invoice.\nENDCLASS.",
      "good": "CLASS zcl_invoice_service DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS process_invoice.\nENDCLASS."
    },
    "seo": {
      "description": "Eliminate FRIENDS relationships in ABAP class definitions to preserve object encapsulation and clean interface contracts.",
      "keywords": [
        "no-friends",
        "Clean ABAP",
        "ABAP Cloud",
        "encapsulation",
        "object-oriented",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-factory-name",
      "max-inherit",
      "max-attributes"
    ],
    "customSection": "## Architectural Guidance\n\nGranting friendship is often misused to allow test classes to inspect private state. In Clean ABAP, unit tests should verify behavior through public interfaces rather than inspecting internal state. For scenarios requiring test seams, use test injection or dependency injection rather than `FRIENDS`.\n\n### Detection\nThe check inspects class definitions (`procedure_kinds-class_definition`) for the keyword token `FRIENDS`.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_FRIENDS`."
  },
  {
    "ruleId": "pref-msg-cls",
    "title": "Use Centralized Message Classes Instead of Hardcoded Text Literals",
    "rationale": "Hardcoded message literals cannot be translated via transaction SE91, cannot be cataloged across business components, and violate internationalization requirements in SAP S/4HANA and ABAP Cloud. Centralizing message definitions within message classes ensures structured error codes, parameterized placeholders, and proper multilingual maintenance. Skylint inspects MESSAGE statements and reports PREF_MSGCL when inline string literals are used instead of structured message class references.",
    "className": "/SKYL/CL_PREF_MSG_CLS",
    "pseudoComment": "PREF_MSG_CLS",
    "category": "clean-abap",
    "example": {
      "bad": "MESSAGE 'Customer account is locked for posting' TYPE 'E' INTO DATA(lv_error_text).",
      "good": "MESSAGE e102(zsales_msg) INTO DATA(lv_error_text)."
    },
    "seo": {
      "description": "Replace hardcoded string literals in ABAP MESSAGE statements with SE91 message classes to ensure internationalization and SAP S/4HANA readiness.",
      "keywords": [
        "pref-msg-cls",
        "MESSAGE",
        "SE91",
        "message class",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-msg-raising",
      "pref-str-tmpl",
      "pref-str-func"
    ],
    "customSection": "## Detection Details\n\nThe check evaluates statements starting with keyword `MESSAGE`. Statements providing an explicit message class via `ID <class>` or standard short-syntax `t<nnn>(<class>)` are accepted. If the token directly following `MESSAGE` is a string literal (e.g., `MESSAGE '...' TYPE 'E'`), ATC finding `PREF_MSGCL` is raised.\n\nSuppress findings using pseudo comment `\"#EC PREF_MSG_CLS`."
  },
  {
    "ruleId": "no-exc-overlap",
    "title": "Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses",
    "rationale": "When multiple classic exceptions in a CALL FUNCTION or CALL METHOD statement map to the same numeric return code, the caller cannot distinguish between different failure reasons when evaluating sy-subrc. This masks critical system errors, impedes accurate logging and diagnostic analysis, and turns error handling into guesswork. Clean ABAP requires assigning distinct return codes to every specific exception and reserving a unique code for OTHERS. The ATC rule detects duplicate numeric error codes and reports NO_EXC_OVL.",
    "className": "/SKYL/CL_NO_EXC_OVERLAP",
    "pseudoComment": "NO_EXC_OVERLAP",
    "category": "anti-patterns",
    "example": {
      "bad": "CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'\n  EXPORTING\n    date             = sy-datum\n    foreign_amount   = lv_foreign_amount\n    foreign_currency = lv_foreign_currency\n    local_currency   = lv_local_currency\n  IMPORTING\n    local_amount     = lv_local_amount\n  EXCEPTIONS\n    no_rate_found    = 1\n    overflow         = 1\n    OTHERS           = 2.",
      "good": "CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'\n  EXPORTING\n    date             = sy-datum\n    foreign_amount   = lv_foreign_amount\n    foreign_currency = lv_foreign_currency\n    local_currency   = lv_local_currency\n  IMPORTING\n    local_amount     = lv_local_amount\n  EXCEPTIONS\n    no_rate_found    = 1\n    overflow         = 2\n    OTHERS           = 3."
    },
    "seo": {
      "description": "Prevent overlapping exception return numbers in ABAP classic CALL FUNCTION calls to ensure reliable sy-subrc error handling.",
      "keywords": [
        "no-exc-overlap",
        "Clean ABAP",
        "CALL FUNCTION",
        "EXCEPTIONS clause",
        "sy-subrc",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-class-exc",
      "no-catch-root",
      "no-raise-cx-sy"
    ],
    "customSection": "## Detection Details\n\nThe check scans `CALL FUNCTION` and `CALL METHOD` invocations that define an `EXCEPTIONS` block. It parses each literal return number assigned to an exception name. If the same numeric literal is assigned to multiple exception entries, the duplicate token is reported with finding code `NO_EXC_OVL`.\n\n### Best Practice\nAssign incrementing numbers starting from 1 to each named exception, and assign the highest distinct integer to `OTHERS`. In modern ABAP Cloud code, favor class-based exceptions over classic exceptions altogether.\n\n### Suppression\nSuppress findings with `\"#EC NO_EXC_OVERLAP`."
  },
  {
    "ruleId": "no-rfc-err",
    "title": "Handle System and Communication Failures in Remote RFC Calls",
    "rationale": "When calling remote function modules via CALL FUNCTION ... DESTINATION or asynchronous tasks with STARTING NEW TASK ... DESTINATION IN GROUP, network timeouts, gateway disconnections, target kernel crashes, or RFC resource exhaustion trigger classical exceptions COMMUNICATION_FAILURE, SYSTEM_FAILURE, or RESOURCE_FAILURE. Omitting these exception handlers causes the calling work process to crash immediately with an unhandled RFC_COMMUNICATION_ERROR or CALL_FUNCTION_NOT_FOUND runtime dump. In Clean ABAP and SAP ATC robustness guidelines, every RFC invocation must catch communication and system failures with the MESSAGE addition to capture diagnostic error text and maintain transactional resilience.",
    "className": "/SKYL/CL_NO_RFC_ERR",
    "pseudoComment": "NO_RFC_ERR",
    "category": "security",
    "example": {
      "bad": "CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'\n  DESTINATION lv_rfcdest\n  EXPORTING\n    order_header_in = ls_order_header.",
      "good": "CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'\n  DESTINATION lv_rfcdest\n  EXPORTING\n    order_header_in       = ls_order_header\n  EXCEPTIONS\n    communication_failure = 1 MESSAGE lv_comm_error\n    system_failure        = 2 MESSAGE lv_sys_error\n    others                = 3.\n\nIF sy-subrc <> 0.\n  mo_logger->error( |Remote RFC call failed: { lv_comm_error } { lv_sys_error }| ).\nENDIF."
    },
    "seo": {
      "description": "Prevent runtime short dumps during SAP RFC integration by handling COMMUNICATION_FAILURE, SYSTEM_FAILURE, and RESOURCE_FAILURE.",
      "keywords": [
        "no-rfc-err",
        "COMMUNICATION_FAILURE",
        "SYSTEM_FAILURE",
        "RESOURCE_FAILURE",
        "RFC Exception Handling",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-kernel-call",
      "no-metaprogramming",
      "no-unhandled-eml"
    ],
    "customSection": "## Required Exceptions by RFC Mode\n\nThe check inspects `CALL FUNCTION` statements containing `DESTINATION` or `STARTING NEW TASK` and verifies that the `EXCEPTIONS` clause catches all required failure modes:\n\n| RFC Invocation Syntax | Mandatory Exceptions in `EXCEPTIONS` Block |\n|---|---|\n| `CALL FUNCTION ... DESTINATION <dest>` | `COMMUNICATION_FAILURE`, `SYSTEM_FAILURE` |\n| `CALL FUNCTION ... STARTING NEW TASK ... DESTINATION IN GROUP <grp>` | `COMMUNICATION_FAILURE`, `SYSTEM_FAILURE`, `RESOURCE_FAILURE` |\n\nCapturing the error message using `MESSAGE <lv_message_var>` is recommended so diagnostic details returned by the remote gateway or kernel can be recorded in application logs. Suppress individual findings using the pseudo comment `\"#EC NO_RFC_ERR`."
  },
  {
    "ruleId": "no-many-parens",
    "title": "Remove Redundant Parentheses in Boolean and Assignment Expressions",
    "rationale": "Wrapping single comparison clauses, entire simple conditions, or elementary assignments in unnecessary parentheses clutters source code without changing operator precedence or runtime behavior. Redundant parentheses create visual noise, make expressions appear deceptively complex, and often remain as remnants from incomplete refactorings. Clean ABAP advises keeping expressions minimal and retaining parentheses only where logical precedence or grouping genuinely requires them. The ATC check reports NO_MNY_PAR and provides the NOPARENS quickfix.",
    "className": "/SKYL/CL_NO_MANY_PARENS",
    "pseudoComment": "NO_MANY_PARENS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF ( lv_order_status = 'APPROVED' ).\n  process_purchase_order( iv_order_id = lv_order_id ).\nENDIF.",
      "good": "IF lv_order_status = 'APPROVED'.\n  process_purchase_order( iv_order_id = lv_order_id ).\nENDIF."
    },
    "seo": {
      "description": "Detect and remove redundant parentheses in ABAP conditions and assignments using automated Clean ABAP ATC quickfixes.",
      "keywords": [
        "no-many-parens",
        "Clean ABAP",
        "redundant parentheses",
        "IF condition",
        "SAP ATC",
        "quickfix"
      ]
    },
    "relatedRules": [
      "no-single-when",
      "no-check-stmt",
      "no-bool-compare"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check inspects `IF`, `ELSEIF`, `WHILE`, `CHECK`, and `COMPUTE` statements. It determines whether an outer pair of parentheses encloses the complete condition or whether a single comparison clause without logical operators is redundantly bracketed. The automated `NOPARENS` quickfix flattens the statement by removing the unnecessary outer parentheses.\n\n### Excluded Scenarios\nExpressions containing constructor operators (`VALUE`, `COND`, `CONV`, `SWITCH`, `REDUCE`, `NEW`), `NOT` negation boundaries, or mixed `AND`/`OR` precedence groups are intentionally preserved.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_MANY_PARENS`."
  },
  {
    "ruleId": "pref-pass-by-ref",
    "title": "Pass Importing Parameters by Reference to Avoid Value Copies",
    "rationale": "In ABAP Object-Oriented programming, method parameters are passed by reference by default (O(1) pointer transfer). Declaring an IMPORTING parameter with VALUE(iv_param) instructs the runtime kernel to allocate a fresh heap memory buffer and deep-copy the argument value upon entering the method. When passing internal tables, complex structures, or large strings across multiple call layers, pass-by-value causes severe memory inflation, CPU memory bus saturation, and garbage collection churn. In Clean ABAP and ABAP Cloud, IMPORTING parameters should always be passed by reference unless explicit local isolation is strictly required.",
    "className": "/SKYL/CL_PREF_PASS_BY_REF",
    "pseudoComment": "PREF_PASS_BY_REF",
    "category": "performance",
    "example": {
      "bad": "CLASS lcl_sales_service DEFINITION.\n  PUBLIC SECTION.\n    METHODS process_orders\n      IMPORTING\n        VALUE(it_orders) TYPE string_table.\nENDCLASS.",
      "good": "CLASS lcl_sales_service DEFINITION.\n  PUBLIC SECTION.\n    METHODS process_orders\n      IMPORTING\n        it_orders TYPE string_table.\nENDCLASS."
    },
    "seo": {
      "description": "Improve SAP ABAP method performance by passing IMPORTING parameters by reference instead of using VALUE() deep copies.",
      "keywords": [
        "pref-pass-by-ref",
        "pass by reference",
        "VALUE importing",
        "Clean ABAP methods",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-params",
      "no-call-method",
      "no-call-exporting"
    ],
    "customSection": "### Detection Details\n\nThe check evaluates `METHODS` and `CLASS-METHODS` declarations within `CLASS ... DEFINITION` blocks. Any parameter in an `IMPORTING` section defined with `VALUE(...)` is flagged with finding code `PREF_PASRF`.\n\n### When is Pass-by-Value Appropriate?\n\n- **RETURNING Parameters:** By ABAP language specification, `RETURNING` parameters must always be passed by value.\n- **RFC / Update Modules:** Remote function modules require value serialization across network boundaries.\n\n### Quickfix\n\nThe `OMIT_VAL` quickfix automatically strips the `VALUE(...)` wrapper from the importing parameter definition, converting it to clean pass-by-reference.\n\nSuppress legitimate pass-by-value requirements with the pseudo comment `\"#EC PREF_PASS_BY_REF`."
  },
  {
    "ruleId": "no-mod-std-table",
    "title": "Restrict Database Modifications to Customer-Owned Tables",
    "rationale": "Directly executing OpenSQL INSERT, UPDATE, MODIFY, or DELETE statements against SAP standard database tables (such as BKPF, VBAK, EKKO, or BUT000) bypasses standard document numbering, SAP business locks, consistency checks, and change document auditing. Direct table mutation corrupts enterprise data integrity and breaks Cloud Contract C1 compatibility in S/4HANA and Clean Core architectures. In Clean ABAP and modern SAP extensibility, standard entities must only be modified through released transactional APIs, RAP Business Objects, or standard BAPIs, while direct OpenSQL writes are strictly restricted to customer-owned tables in custom namespaces.",
    "className": "/SKYL/CL_NO_MOD_STD_TABLE",
    "pseudoComment": "NO_MOD_STD_TABLE",
    "category": "security",
    "example": {
      "bad": "UPDATE bkpf\n  SET bstat = 'V'\n  WHERE belnr = @lv_doc_num.",
      "good": "UPDATE zfi_doc_status\n  SET processing_status = 'V'\n  WHERE document_number = @lv_doc_num.\n\nIF sy-subrc <> 0.\n  \" Record not found or status already updated\nENDIF."
    },
    "parameters": {
      "OWN_TABLES": "Regular expression matching customer-owned table names permitted for direct OpenSQL mutation (default: ^[yz/]).",
      "REPORT_DYNAMIC": "Flag dynamic database targets specified via variable names enclosed in parentheses (default: true)."
    },
    "seo": {
      "description": "Prevent direct OpenSQL modifications on SAP standard tables to preserve database integrity and ensure SAP Clean Core compliance.",
      "keywords": [
        "no-mod-std-table",
        "Clean Core SAP",
        "Direct Table Modification",
        "OpenSQL Security",
        "ABAP Cloud Contract C1",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-std-table",
      "pref-read-table",
      "no-mod-loop-tab"
    ],
    "customSection": "## Table Namespace Enforcement\n\nThe check validates the target database table of OpenSQL `INSERT`, `UPDATE`, `MODIFY`, and `DELETE` statements against the customer namespace regex configured in `OWN_TABLES`:\n\n| Statement Pattern | Condition Evaluated | Default Rule Behavior |\n|---|---|---|\n| `UPDATE <dbtab> SET ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |\n| `DELETE FROM <dbtab> ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |\n| `INSERT INTO <dbtab> ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |\n| `MODIFY <dbtab> FROM ...` | Target matches `OWN_TABLES` regex | Allowed if table starts with `z`, `y`, or `/` namespace; flagged otherwise |\n| `(lv_dynamic_table)` | Target enclosed in parentheses | Flagged when `REPORT_DYNAMIC` is set to `abap_true` |\n\nIn-memory operations on internal tables (such as `MODIFY itab FROM wa INDEX idx`) do not constitute database access and are ignored. Suppress valid exceptions with `\"#EC NO_MOD_STD_TABLE` or `##NO_MOD_STD_TABLE`."
  },
  {
    "ruleId": "no-dynamic-stmt",
    "title": "Avoid Dynamic OpenSQL and Metaprogramming Language Constructs",
    "rationale": "Dynamic language constructs in ABAP—such as dynamic OpenSQL queries (`FROM (lv_table)`, `WHERE (lv_where)`), dynamic method calls (`CALL METHOD lo->(lv_method)`), dynamic assignments (`ASSIGN (lv_var) TO <fs>`), and dynamic program execution (`SUBMIT (lv_prog)`)—bypass static type checking and compile-time syntax verification. Unvalidated dynamic SQL introduces high-severity SQL Injection vulnerabilities (OWASP A03 / CWE-89), prevents static ATC security scanning, and degrades database query plan caching. In Clean ABAP and ABAP Cloud, logic should be statically typed and bound to explicit artifacts; unavoidable dynamic SQL in RAP custom query providers must be strictly sanitized using cl_abap_dyn_prg.",
    "className": "/SKYL/CL_NO_DYNAMIC_STMT",
    "pseudoComment": "NO_DYNAMIC_STMT",
    "category": "security",
    "example": {
      "bad": "DATA(lv_table_name) = 'ZCUSTOMERS'.\nSELECT customer_id, customer_name\n  FROM (lv_table_name)\n  WHERE customer_id = @lv_customer_id\n  INTO TABLE @DATA(lt_customers).",
      "good": "SELECT customer_id, customer_name\n  FROM zcustomers\n  WHERE customer_id = @lv_customer_id\n  INTO TABLE @DATA(lt_customers)."
    },
    "parameters": {
      "CHECK_DYNAMIC_SQL": "Flag dynamic table names, column projections, and WHERE clauses enclosed in parentheses in OpenSQL (default: true).",
      "IGNORE_RAP_QUERY_PROVIDER": "Exempt dynamic OpenSQL queries located within RAP query provider methods implementing IF_RAP_QUERY_PROVIDER~SELECT (default: true)."
    },
    "seo": {
      "description": "Prevent SQL injection and runtime errors in ABAP by avoiding dynamic OpenSQL queries, dynamic method calls, and dynamic assignments.",
      "keywords": [
        "no-dynamic-stmt",
        "Dynamic SQL ABAP",
        "SQL Injection CWE-89",
        "Clean ABAP",
        "cl_abap_dyn_prg",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-unhandled-eml",
      "no-metaprogramming",
      "no-kernel-call"
    ],
    "customSection": "## Detected Dynamic Statements\n\nThe check inspects procedure statements and flags the following dynamic patterns:\n\n| Statement Type | Dynamic Pattern Detected | Risk / Vulnerability |\n|---|---|---|\n| `SELECT` / `UPDATE` / `DELETE` | `FROM (lv_table)` or `WHERE (lv_where)` | SQL Injection (CWE-89), lack of static type checking |\n| `CALL FUNCTION` | Non-literal function name `CALL FUNCTION lv_func` | Unverified remote or local function dispatch |\n| `CALL METHOD` | Dynamic method or class dispatch `lo->(lv_meth)` | Dynamic invoke failure, runtime dump `CX_SY_DYN_CALL_ILLEGAL_METHOD` |\n| `ASSIGN` | `ASSIGN (lv_var) TO <fs>` or `ASSIGN COMPONENT` | Dynamic field symbol binding without symbol validation |\n| `CREATE OBJECT` | Dynamic type instantiation `TYPE (lv_class)` | Dynamic type mismatch, unexpected class creation |\n| `SUBMIT` / `PERFORM` | Dynamic program or routine invocation `(lv_prog)` | Arbitrary code execution risk |\n| `SORT` | Dynamic sort key `SORT itab BY (lv_col)` | Runtime dump on invalid column name |\n\nDynamic SQL inside custom RAP query provider implementations (`IF_RAP_QUERY_PROVIDER~SELECT`) is exempted when `IGNORE_RAP_QUERY_PROVIDER` is enabled. Suppress false positives with `\"#EC NO_DYNAMIC_STMT` or `##NO_DYNAMIC_STMT`."
  },
  {
    "ruleId": "pref-pub-ctor",
    "title": "Declare Instance Constructor in PUBLIC SECTION Regardless of Instantiation Scope",
    "rationale": "Declaring the instance constructor in PROTECTED or PRIVATE sections hinders reflection, dependency injection frameworks, and test doubles. Even for singleton or factory patterns where class instantiation is restricted using CREATE PRIVATE or CREATE PROTECTED, the constructor itself should remain declared in the PUBLIC SECTION. The class header declaration already controls external instantiation permissions. Skylint flags any constructor declared under protected or private sections with PREF_PBCTR.",
    "className": "/SKYL/CL_PREF_PUB_CTOR",
    "pseudoComment": "PREF_PUB_CTOR",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_invoice_factory DEFINITION PUBLIC CREATE PRIVATE.\n  PRIVATE SECTION.\n    METHODS constructor.\nENDCLASS.",
      "good": "CLASS zcl_invoice_factory DEFINITION PUBLIC CREATE PRIVATE.\n  PUBLIC SECTION.\n    METHODS constructor.\nENDCLASS."
    },
    "seo": {
      "description": "Ensure instance constructors are declared in the PUBLIC SECTION for clean reflection, testing, and modern ABAP Cloud factory architectures.",
      "keywords": [
        "pref-pub-ctor",
        "constructor",
        "PUBLIC SECTION",
        "CREATE PRIVATE",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-new-op",
      "pref-factory-name",
      "pref-final-cls"
    ],
    "customSection": "## Scope and Architectural Intent\n\nClass instantiation constraints should be governed exclusively by the class header attributes (`CREATE PUBLIC`, `CREATE PROTECTED`, or `CREATE PRIVATE`). Placing the constructor method declaration in the `PUBLIC SECTION` exposes its signature transparently to RTTI and testing frameworks while preserving strict instantiation boundaries.\n\nSuppress findings using pseudo comment `\"#EC PREF_PUB_CTOR`."
  },
  {
    "ruleId": "pref-declarations",
    "title": "Enforce Routine Declaration Hierarchy and Top-of-Block Placement",
    "rationale": "Interleaving data declarations with executable statements obscures variable scope and hampers readability during routine maintenance. Furthermore, declaring variables before the custom types they reference causes cognitive friction and compilation anomalies. Maintaining strict routine declaration hygiene requires placing all local declarations at the beginning of the routine in hierarchical order: TYPES first, followed by CONSTANTS, DATA or STATICS, and finally FIELD-SYMBOLS. Skylint flags scattered declarations with PREF_TOP and out-of-order declarations with PREF_ORDER.",
    "className": "/SKYL/CL_PREF_DECLARATIONS",
    "pseudoComment": "DEF_TOP",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD run.\n  DATA lv_total_amount TYPE i.\n  lv_total_amount = 100.\n  DATA lv_tax_amount TYPE i.\n  FIELD-SYMBOLS <ls_item> TYPE any.\n  TYPES ty_status TYPE c LENGTH 1.\nENDMETHOD.",
      "good": "METHOD run.\n  TYPES ty_status TYPE c LENGTH 1.\n  CONSTANTS lc_standard_rate TYPE i VALUE 18.\n  DATA lv_total_amount TYPE i.\n  DATA lv_tax_amount TYPE i.\n  FIELD-SYMBOLS <ls_item> TYPE any.\n  lv_total_amount = 100.\nENDMETHOD."
    },
    "parameters": {
      "CHECK_DEF_TOP": "Enforce all local declarations (DATA, TYPES, CONSTANTS, FIELD-SYMBOLS) at the top of the routine body.",
      "CHECK_DECL_ORDER": "Enforce declaration order: TYPES first, then CONSTANTS, then DATA/STATICS, then FIELD-SYMBOLS."
    },
    "seo": {
      "description": "Enforce clean ABAP routine declaration hygiene by placing TYPES, CONSTANTS, DATA, and FIELD-SYMBOLS at the top in structured hierarchy.",
      "keywords": [
        "pref-declarations",
        "declaration order",
        "local variables",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-inline",
      "pref-final-data",
      "no-hungarian"
    ],
    "customSection": "## Enforced Declaration Hierarchy\n\nWhen `CHECK_DECL_ORDER` is enabled, all declarations preceding the first executable statement must respect the following rank order:\n\n1. `TYPES` (rank 1)\n2. `CONSTANTS` (rank 2)\n3. `DATA` / `STATICS` (rank 3)\n4. `FIELD-SYMBOLS` (rank 4)\n\nAny declaration occurring after an executable statement triggers `PREF_TOP` when `CHECK_DEF_TOP` is active.\n\nSuppress findings with pseudo comments `\"#EC PREF_DEFINITIONS_TOP` / `\"#EC PREF_DECLARATION_ORDER`."
  },
  {
    "ruleId": "no-unnec-return",
    "title": "Omit Redundant RETURN Statement at the End of Routines",
    "rationale": "A RETURN statement placed immediately before the closing ENDMETHOD, ENDFORM, or ENDFUNCTION statement is completely superfluous because control flow returns automatically to the caller when reaching the routine boundary. Leaving redundant trailing returns adds visual noise, misleads reviewers into suspecting early exit logic or missing downstream code, and violates Clean ABAP simplicity principles. The ATC check flags trailing RETURN statements with NO_UNN_RET and provides the REMOVE_RET quickfix to safely delete them.",
    "className": "/SKYL/CL_NO_UNNEC_RETURN",
    "pseudoComment": "NO_UNNEC_RETURN",
    "category": "anti-patterns",
    "example": {
      "bad": "METHOD calculate_tax.\n  DATA lv_tax TYPE decfloat34.\n  lv_tax = iv_net_amount * '0.19'.\n  RETURN.\nENDMETHOD.",
      "good": "METHOD calculate_tax.\n  DATA lv_tax TYPE decfloat34.\n  lv_tax = iv_net_amount * '0.19'.\nENDMETHOD."
    },
    "seo": {
      "description": "Eliminate useless RETURN statements at routine ends in ABAP code to maintain clean control flow with automated quickfixes.",
      "keywords": [
        "no-unnec-return",
        "Clean ABAP",
        "ABAP Cloud",
        "RETURN statement",
        "control flow",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-ignored-return",
      "pref-return",
      "no-call-exporting"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check evaluates executable statements in procedures. If a `RETURN` keyword is detected at the penultimate position directly preceding the closing routine delimiter (`ENDMETHOD`, `ENDFORM`, `ENDFUNCTION`), finding code `NO_UNN_RET` is reported.\n\nThe automated `REMOVE_RET` quickfix deletes the statement cleanly without affecting routine execution.\n\n### Valid Return Usage\nEarly `RETURN` statements used as guard clauses to exit a routine upon invalid preconditions or edge cases remain valid and are not flagged by this check.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_UNNEC_RETURN`."
  },
  {
    "ruleId": "no-mix-returning",
    "title": "Separate Functional RETURNING Parameters from EXPORTING and CHANGING Outputs",
    "rationale": "A method signature combining a RETURNING parameter with EXPORTING or CHANGING parameters violates the Command-Query Separation (CQS) principle. Functional methods in Clean ABAP and ABAP Cloud are intended for expression-oriented evaluation; mixing side-effect parameter exports forces callers into cumbersome syntax and obscures whether a method performs a pure query or mutates state. Methods should either return a single value/structure functionally or act as a procedural command with output parameters. The check emits NO_MIX_RET.",
    "className": "/SKYL/CL_NO_MIX_RETURNING",
    "pseudoComment": "NO_MIX_RETURNING",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS zcl_pricing_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_discount\n      IMPORTING iv_customer_id TYPE kunnr\n      EXPORTING ev_discount_rate TYPE decfloat34\n      RETURNING VALUE(rv_final_price) TYPE decfloat34.\nENDCLASS.",
      "good": "CLASS zcl_pricing_calculator DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_discount\n      IMPORTING iv_customer_id TYPE kunnr\n      RETURNING VALUE(rv_final_price) TYPE decfloat34.\nENDCLASS."
    },
    "seo": {
      "description": "Enforce Command-Query Separation in ABAP method signatures by disallowing RETURNING alongside EXPORTING or CHANGING.",
      "keywords": [
        "no-mix-returning",
        "Clean ABAP",
        "ABAP Cloud",
        "RETURNING parameter",
        "CQS",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-returning",
      "no-call-exporting",
      "no-ignored-return"
    ],
    "customSection": "## Command-Query Separation (CQS)\n\nIn Clean ABAP, methods with a `RETURNING` parameter are expected to behave as functional queries without side-effect output parameters. When multiple results must be returned functionally, package them into a structured type or class object instead of mixing parameter kinds.\n\n### Detection Details\nThe rule inspects method signatures in class definitions (`METHODS` and `CLASS-METHODS`). If a signature contains the token `RETURNING` alongside `EXPORTING` or `CHANGING`, it reports `NO_MIX_RET`.\n\n### Suppression\nSuppress findings with pseudo comment `\"#EC NO_MIX_RETURNING`."
  },
  {
    "ruleId": "no-overw-builtin",
    "title": "Prevent Declaring Methods That Shadow Built-in ABAP Functions",
    "rationale": "Giving a custom method the same name as an ABAP built-in function (such as LINES, MATCHES, STRLEN, REPEAT, or XSDBOOL) creates severe naming ambiguity for developers and tools alike. At call sites, readers cannot easily distinguish whether the standard language built-in or the class method is invoked, which increases defect rates during maintenance. Clean ABAP mandates meaningful, domain-specific verb phrases for method names that do not collide with reserved language constructs. The ATC check scans method declarations and reports NO_OVR_BLT.",
    "className": "/SKYL/CL_NO_OVERW_BUILTIN",
    "pseudoComment": "NO_OVERW_BUILTIN",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS zcl_text_processor DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS matches\n      IMPORTING iv_pattern TYPE string\n      RETURNING VALUE(rv_is_match) TYPE abap_bool.\nENDCLASS.",
      "good": "CLASS zcl_text_processor DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS matches_pattern\n      IMPORTING iv_pattern TYPE string\n      RETURNING VALUE(rv_is_match) TYPE abap_bool.\nENDCLASS."
    },
    "seo": {
      "description": "Avoid method names that shadow standard ABAP built-in functions like lines, matches, and strlen in ABAP Cloud.",
      "keywords": [
        "no-overw-builtin",
        "Clean ABAP",
        "ABAP Cloud",
        "built-in functions",
        "method naming",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dash-in-form",
      "no-obs-arith",
      "no-obs-control"
    ],
    "customSection": "## Evaluated Built-in Functions\n\nThe check maintains a catalog of 74 ABAP built-in functions, including:\n- **String functions**: `STRLEN`, `MATCHES`, `MATCH`, `FIND`, `SUBSTRING`, `REPEAT`, `REPLACE`, `TO_UPPER`, `TO_LOWER`\n- **Table functions**: `LINES`, `LINE_EXISTS`, `LINE_INDEX`\n- **Boolean and conversion functions**: `XSDBOOL`, `BOOLC`, `BOOLX`\n- **Math functions**: `ABS`, `CEIL`, `FLOOR`, `ROUND`, `TRUNC`, `SQRT`\n\nAny `METHODS` or `CLASS-METHODS` declaration matching one of these names is flagged with finding code `NO_OVR_BLT`.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_OVERW_BUILTIN`."
  },
  {
    "ruleId": "pref-is-initial",
    "title": "Prefer IS [NOT] INITIAL Over lines( ) and Empty Literal Comparisons",
    "rationale": "Comparing lines( itab ) against zero or testing variables against empty string literals ('', ``, SPACE) or numeric zero obscures developer intent and introduces counting overhead on large tables. In contrast, the predicate IS [NOT] INITIAL is type-agnostic, evaluates emptiness directly at the kernel level without table iteration, and clearly conveys intent. Skylint detects lines( ) inequalities and empty literal comparisons in IF, ELSEIF, CHECK, and WHILE statements, reporting PREF_INIT alongside the REPLINIT quickfix.",
    "className": "/SKYL/CL_PREF_IS_INITIAL",
    "pseudoComment": "PREF_IS_INITIAL",
    "category": "clean-abap",
    "example": {
      "bad": "IF lines( lt_sales_orders ) > 0.\n  process_orders( lt_sales_orders ).\nENDIF.",
      "good": "IF lt_sales_orders IS NOT INITIAL.\n  process_orders( lt_sales_orders ).\nENDIF."
    },
    "seo": {
      "description": "Replace lines() comparisons and empty literal checks with IS NOT INITIAL and IS INITIAL for cleaner, high-performance ABAP Cloud code.",
      "keywords": [
        "pref-is-initial",
        "IS INITIAL",
        "IS NOT INITIAL",
        "lines()",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-is-not",
      "pref-case",
      "pref-cond"
    ],
    "customSection": "## Supported Patterns and Quickfix\n\nThe check flags the following patterns in control flow statements (`IF`, `ELSEIF`, `CHECK`, `WHILE`):\n\n| Expression Pattern | Recommended Replacement |\n|---|---|\n| `lines( itab ) > 0`, `>= 1`, `<> 0` | `itab IS NOT INITIAL` |\n| `lines( itab ) = 0`, `<= 0`, `< 1` | `itab IS INITIAL` |\n| `var = ''`, `var = ' '`, `var = 0`, `var = SPACE` | `var IS INITIAL` |\n| `var <> ''`, `var <> 0`, `var <> SPACE` | `var IS NOT INITIAL` |\n\nThe `REPLINIT` quickfix automatically converts these conditions to standard `IS [NOT] INITIAL` expressions.\n\nSuppress findings using pseudo comment `\"#EC PREF_IS_INITIAL`."
  },
  {
    "ruleId": "no-ignored-return",
    "title": "Capture and Consume Return Values of Functional Method Calls",
    "rationale": "Invoking a functional method without capturing its RETURNING parameter indicates either a useless statement that wastes CPU cycles or a poorly designed method that hides state mutations behind a query signature. Clean ABAP requires methods with return values to be functional queries whose results are assigned, evaluated in an expression, or passed to downstream procedures. Discarding the return value leaves side effects unexpected and makes code intent unreadable. The ATC check uses RTTI to detect uncaptured functional calls and reports NO_IGN_RET.",
    "className": "/SKYL/CL_NO_IGNORED_RETURN",
    "pseudoComment": "NO_IGNORED_RETURN",
    "category": "anti-patterns",
    "example": {
      "bad": "lo_pricing_engine->calculate_total_price( iv_order_id = lv_order_id ).",
      "good": "DATA(lv_total_price) = lo_pricing_engine->calculate_total_price( iv_order_id = lv_order_id )."
    },
    "seo": {
      "description": "Ensure return values of functional method calls are consumed rather than ignored in ABAP Cloud and Clean ABAP code.",
      "keywords": [
        "no-ignored-return",
        "Clean ABAP",
        "ABAP Cloud",
        "functional method",
        "RETURNING value",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-return",
      "no-unnec-return",
      "no-mix-returning"
    ],
    "customSection": "## Detection Details\n\nThe check evaluates standalone method call statements (`+CALL_METHOD` or `CALL METHOD`). It uses runtime type inspection (`/skyl/cl_rtti_util=>get_method_descr`) to examine the method signature. If the invoked method declares a `RETURNING` parameter and the call site neither assigns the result nor uses the `RECEIVING` addition, finding code `NO_IGN_RET` is reported.\n\n### Remote Enablement Notice\nBecause this rule inspects type descriptors at runtime via RTTI, it cannot be executed in RFC remote ATC scenarios and has `remote_enablement = abap_false`.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_IGNORED_RETURN`."
  },
  {
    "ruleId": "pref-downcast",
    "title": "Modernize Downcasting with CAST #( ) Expressions and Inline Redundant Helpers",
    "rationale": "The legacy ?= and MOVE ?TO operators are obsolete procedural downcast idioms that cannot participate in functional chaining or modern expression trees. Using modern constructor expression CAST #( ) produces clean, type-safe downcasts and enables chaining directly into method calls or assignments. Furthermore, declaring temporary single-use helper variables solely to store downcast results introduces clutter and unnecessary state. Skylint identifies obsolete cast syntax (PREF_CAST) and single-use intermediate downcast variables (PREF_INLCS), providing quickfixes TOCAST and INLINECST.",
    "className": "/SKYL/CL_PREF_DOWNCAST",
    "pseudoComment": "PREF_CAST",
    "category": "clean-abap",
    "example": {
      "bad": "lo_billing_item ?= lo_source_item.\nDATA(lo_invoice_node) = CAST lcl_invoice_node( io_tree_node ).\nlv_total_amount = lo_invoice_node->get_total_amount( ).",
      "good": "lo_billing_item = CAST #( lo_source_item ).\nlv_total_amount = CAST lcl_invoice_node( io_tree_node )->get_total_amount( )."
    },
    "parameters": {
      "CHECK_CAST_SYNTAX": "Report obsolete downcast operators (?= and MOVE ?TO) in favor of the modern CAST #( ) constructor expression.",
      "CHECK_INLINE_CAST": "Report intermediate single-use variables holding downcast results that can be directly inlined into subsequent statements."
    },
    "seo": {
      "description": "Modernize ABAP downcasts using CAST #( ) constructor expressions and eliminate redundant intermediate variables in ABAP Cloud.",
      "keywords": [
        "pref-downcast",
        "CAST #()",
        "downcast",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-new-op",
      "pref-pub-ctor",
      "pref-factory-name"
    ],
    "customSection": "## Detection Capabilities and Quickfixes\n\n1. **Downcast Operator Modernization (`PREF_CAST`):** Identifies `?=` and `MOVE ... ?TO ...` assignments, offering the `TOCAST` quickfix to convert them into `target = CAST #( source )`.\n2. **Downcast Inlining (`PREF_INLCS`):** Identifies inline declarations `DATA(lo_typed) = CAST type( lo_base )` where `lo_typed` is consumed exactly once in the immediately following statement as a method call receiver or assignment source, offering the `INLINECST` quickfix to inline the expression.\n\nSuppress findings using pseudo comments `\"#EC PREF_DOWNCAST` / `\"#EC PREF_INLINE_CAST`."
  },
  {
    "ruleId": "no-mod-loop-tab",
    "title": "Do Not Mutate or Sort Tables Currently Being Looped",
    "rationale": "Mutating the internal table currently being traversed inside a LOOP AT itab block invalidates the loop iterator and destabilizes index tracking. Appending, inserting, or deleting rows alters sy-tabix and row positions, causing skipped elements, duplicate record processing, or runtime boundary violations. Sorting the driving table within the loop scrambles iteration order and corrupts internal binary search states. Furthermore, executing SORT on any internal table inside a loop introduces an O(N * M log M) algorithmic bottleneck. Clean ABAP requires modifying rows in-place using field symbols, collecting additions into a separate result table, and pre-sorting tables before entering loops.",
    "className": "/SKYL/CL_NO_MOD_LOOP_TAB",
    "pseudoComment": "NO_MOD_LOOP_TAB",
    "category": "performance",
    "example": {
      "bad": "LOOP AT lt_items INTO DATA(ls_item).\n  IF ls_item-is_cancelled = abap_true.\n    DELETE lt_items INDEX sy-tabix.\n  ENDIF.\n  SORT lt_items BY item_id.\nENDLOOP.",
      "good": "DELETE lt_items WHERE is_cancelled = abap_true.\nSORT lt_items BY item_id.\n\nLOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).\n  \" Process active item safely in memory\nENDLOOP."
    },
    "parameters": {
      "CHECK_APPEND": "Detect APPEND statements targeting the loop driving table (default true).",
      "CHECK_INSERT": "Detect INSERT statements targeting the loop driving table (default true).",
      "CHECK_MODIFY": "Detect MODIFY statements targeting the loop driving table (default true).",
      "CHECK_DELETE": "Detect DELETE statements targeting the loop driving table (default true).",
      "CHECK_CLEAR": "Detect CLEAR and FREE statements targeting the loop driving table (default true).",
      "CHECK_SORT": "Detect SORT statements targeting the loop driving table (default true).",
      "CHECK_SORT_ANY": "Detect SORT statements on any internal table inside a loop body (default true).",
      "CHECK_COLLECT": "Detect COLLECT statements targeting the loop driving table (default true)."
    },
    "seo": {
      "description": "Prevent iterator corruption and performance degradation in ABAP loops by avoiding APPEND, INSERT, DELETE, or SORT on tables being traversed.",
      "keywords": [
        "no-mod-loop-tab",
        "table mutation in loop",
        "SORT in loop",
        "Clean ABAP loop iterator",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-concat-loop",
      "no-mod-std-table",
      "pref-transport"
    ],
    "customSection": "### Detection Details\n\nThe check tracks an internal stack of active `LOOP AT <table_name>` contexts. Finding code `NO_MOD_LTB` is raised when operations mutate the driving table, while `NO_SORT_LP` is reported when any internal table is sorted within a loop body.\n\n| Configuration Parameter | Targeted Statement |\n| --- | --- |\n| `CHECK_APPEND` | `APPEND ... TO <loop_table>` |\n| `CHECK_INSERT` | `INSERT ... INTO [TABLE] <loop_table>` |\n| `CHECK_MODIFY` | `MODIFY [TABLE] <loop_table>` |\n| `CHECK_DELETE` | `DELETE [TABLE] <loop_table>` or `DELETE ADJACENT` |\n| `CHECK_CLEAR` | `CLEAR <loop_table>` or `FREE <loop_table>` |\n| `CHECK_SORT` | `SORT <loop_table>` |\n| `CHECK_SORT_ANY` | `SORT <any_table>` inside loop |\n| `CHECK_COLLECT` | `COLLECT ... INTO <loop_table>` |\n\nSuppress intentional mutations with the pseudo comment `\"#EC NO_MOD_LOOP_TAB`."
  },
  {
    "ruleId": "no-hardcoded-env",
    "title": "Avoid Reading Environment and Landscape System Fields",
    "rationale": "Conditioning application logic on hardcoded SAP environment system fields—such as system ID (sy-sysid), client (sy-mandt), host server (sy-host), database system (sy-dbsys), operating system (sy-opsys), or logon user (sy-uname)—creates brittle code that fails when promoted through landscape tiers (DEV to QA to PROD). In multi-tenant ABAP Cloud architectures (SAP BTP ABAP environment and S/4HANA Cloud), hardcoding client numbers violates multi-tenant isolation principles and triggers Cloud Contract C1 tenant isolation errors. Clean ABAP mandates abstracting environmental dependencies into injectable configuration services, feature toggles, customizing tables, or official authorization checks.",
    "className": "/SKYL/CL_NO_HARDCODED_ENV",
    "pseudoComment": "NO_HARDCODED_ENV",
    "category": "security",
    "example": {
      "bad": "IF sy-sysid = 'PRD' AND sy-mandt = '100'.\n  process_live_payment( ls_payment ).\nELSE.\n  simulate_test_payment( ls_payment ).\nENDIF.",
      "good": "IF mo_environment_provider->is_production_environment( ) = abap_true.\n  process_live_payment( ls_payment ).\nELSE.\n  simulate_test_payment( ls_payment ).\nENDIF."
    },
    "parameters": {
      "CHECK_SYSID": "Detect access to sy-sysid system field representing the SAP system ID (default: true).",
      "CHECK_MANDT": "Detect access to sy-mandt system field representing the client number (default: true).",
      "CHECK_HOST": "Detect access to sy-host system field representing the application server hostname (default: true).",
      "CHECK_DBSYS": "Detect access to sy-dbsys system field representing the underlying database system (default: true).",
      "CHECK_OPSYS": "Detect access to sy-opsys system field representing the operating system (default: true).",
      "CHECK_UNAME": "Detect access to sy-uname system field representing the current logon username (default: true).",
      "CHECK_TCODE": "Detect access to sy-tcode system field representing the current transaction code (default: true).",
      "CHECK_REPID": "Detect access to sy-repid system field representing the current ABAP program or report (default: true).",
      "CHECK_CPROG": "Detect access to sy-cprog system field representing the calling main program (default: true).",
      "ONLY_CONDITIONAL": "Restrict detection to conditional expressions such as IF, CASE, WHEN, CHECK, COND, and SWITCH (default: false)."
    },
    "seo": {
      "description": "Eliminate hardcoded sy-sysid, sy-mandt, and sy-uname checks in ABAP to ensure multi-tenant isolation and ABAP Cloud readiness.",
      "keywords": [
        "no-hardcoded-env",
        "sy-sysid ABAP",
        "sy-mandt",
        "Multi-Tenant Isolation",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-raise-cx-sy",
      "no-kernel-call",
      "no-rfc-err"
    ],
    "customSection": "## Evaluated System Fields\n\nEach system field check can be toggled individually through rule parameters:\n\n| System Field | Parameter Attribute | Architectural Concern | Recommended Clean Alternative |\n|---|---|---|---|\n| `sy-sysid` | `CHECK_SYSID` | Brittle across landscape tiers | Feature toggles, customizing tables, or BTP destination configurations |\n| `sy-mandt` | `CHECK_MANDT` | Breaks multi-tenant isolation | Tenant-aware configuration tables or standard RAP context |\n| `sy-host` | `CHECK_HOST` | Couples logic to physical hardware | Logical RFC / HTTP destinations via SM59 or BTP Destination Service |\n| `sy-dbsys` | `CHECK_DBSYS` | Platform-specific code branch | Database-independent CDS views or AMDP wrappers |\n| `sy-opsys` | `CHECK_OPSYS` | OS-dependent file handling | Cloud storage services or released file APIs |\n| `sy-uname` | `CHECK_UNAME` | Hardcoded backdoor or user bypass | `AUTHORITY-CHECK` statements against authorization objects |\n| `sy-tcode` | `CHECK_TCODE` | Dynpro-dependent classic transaction | Business service interfaces or RAP behavior actions |\n| `sy-repid` / `sy-cprog` | `CHECK_REPID` / `CHECK_CPROG` | Program name coupling | Object-oriented caller callbacks or interfaces |\n\nSet `ONLY_CONDITIONAL` to `abap_true` to restrict reports to conditional statements (`IF`, `CASE`, `WHEN`, `CHECK`, `COND`, `SWITCH`, `WHERE`). Suppress individual findings with `\"#EC NO_HARDCODED_ENV` or `##NO_HARDCODED_ENV`."
  },
  {
    "ruleId": "max-line-len",
    "title": "Limit Source Code Line Length to Avoid Horizontal Scrolling",
    "rationale": "Source lines that exceed standard display widths (typically 120 characters) force developers to scroll horizontally during code reviews and side-by-side Git diff inspections in Eclipse ADT and web repositories. Long horizontal lines obscure trailing boolean operators, closing parentheses, and inline expressions, creating blind spots where logic defects and syntax errors frequently hide. Clean ABAP formatting standards recommend wrapping statements intelligently before reaching 120 characters, aligning continuations under the parent keyword or expression for optimal scanning.",
    "className": "/SKYL/CL_MAX_LINE_LEN",
    "pseudoComment": "MAX_LINE_LEN",
    "category": "metrics",
    "example": {
      "bad": "DATA(lo_order_service) = zcl_order_service_factory=>get_instance( )->create_order_processor( is_sales_header = ls_sales_header iv_simulate = abap_true iv_auto_commit = abap_false ).",
      "good": "DATA(lo_order_service) = zcl_order_service_factory=>get_instance( )->create_order_processor(\n  is_sales_header = ls_sales_header\n  iv_simulate     = abap_true\n  iv_auto_commit  = abap_false )."
    },
    "parameters": {
      "MAX_LENGTH": "Maximum allowable character length per source code line before reporting (default: 120)."
    },
    "seo": {
      "description": "Enforce a 120-character line length limit in ABAP code to prevent horizontal scrolling and keep side-by-side Git diffs readable.",
      "keywords": [
        "max-line-len",
        "line length limit",
        "Clean ABAP",
        "SAP ATC",
        "Eclipse ADT formatting"
      ]
    },
    "relatedRules": [
      "max-method-len",
      "max-one-stmt",
      "max-params"
    ],
    "customSection": "## Column Calculation\n\nThe check iterates over tokens in each statement and computes the ending column position (`column + strlen( lexeme ) - 1`), with an extra column offset for statement-terminating periods. If any token's end column exceeds `MAX_LENGTH`, a finding is generated for the statement.\n\n| Finding Code | Severity | Default Limit | Suppression |\n|---|---|---|---|\n| `MAX_LINLEN` | Warning | `MAX_LENGTH` (120 columns) | `##MAX_LINE_LEN` or `\"#EC MAX_LINE_LEN` |\n\n### Formatting Guideline\nConfigure Eclipse ADT print margins to 120 characters and break long expressions across multiple lines, aligning arguments or conditions vertically."
  },
  {
    "ruleId": "pref-naming-vars",
    "title": "Enforce Configured Naming Conventions for Local Variables and Field-Symbols",
    "rationale": "Consistent variable prefixes (such as `lv_` for local variables, `lc_` for constants, `<ls_>` or `<lv_>` for field-symbols, and `sv_` for static variables) provide clear scope boundaries, clarify data types, and prevent accidental shadowing of member attributes or global structures. Adhering to predictable naming rules speeds up code reviews and improves maintainability across teams. Skylint validates all local declarations and inline declarations against configurable regex patterns, reporting PREF_NAMVR upon violation.",
    "className": "/SKYL/CL_PREF_NAMING_VARS",
    "pseudoComment": "PREF_NAMING_VARS",
    "category": "clean-abap",
    "example": {
      "bad": "DATA customer_account TYPE string.\nFIELD-SYMBOLS <billing_item> TYPE any.",
      "good": "DATA lv_customer_account TYPE string.\nFIELD-SYMBOLS <ls_billing_item> TYPE any."
    },
    "parameters": {
      "LOCAL_DATA": "Regex pattern for local variable declarations (DATA and inline DATA), defaulting to `^L._.+$`.",
      "LOCAL_CONST": "Regex pattern for local constant declarations, defaulting to `^LC_.+$`.",
      "LOCAL_FS": "Regex pattern for local field-symbols (FIELD-SYMBOLS and inline FIELD-SYMBOL), defaulting to `^<L._.+>$`.",
      "LOCAL_STATICS": "Regex pattern for local static variable declarations (STATICS), defaulting to `^S._.+$`."
    },
    "seo": {
      "description": "Enforce standard naming conventions for ABAP local variables, constants, and field-symbols using configurable regex checks in SAP ATC.",
      "keywords": [
        "pref-naming-vars",
        "naming conventions",
        "local variables",
        "field-symbols",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-name-members",
      "pref-name-objects",
      "no-unused-vars"
    ],
    "customSection": "## Configured Regex Patterns\n\nDeclarations in procedure bodies are validated against the following default regex rules:\n\n| Construct | Configuration Key | Default Pattern | Example Match |\n|---|---|---|---|\n| Local Variable | `LOCAL_DATA` | `^L._.+$` | `lv_amount`, `lt_items`, `ls_header` |\n| Local Constant | `LOCAL_CONST` | `^LC_.+$` | `lc_vat_rate`, `lc_max_retries` |\n| Field Symbol | `LOCAL_FS` | `^<L._.+>$` | `<ls_item>`, `<lv_value>` |\n| Local Static | `LOCAL_STATICS` | `^S._.+$` | `sv_counter`, `st_cache` |\n\nBoth explicit statements (`DATA`, `STATICS`, `CONSTANTS`, `FIELD-SYMBOLS`) and inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`) are verified.\n\nSuppress individual findings with `\"#EC PREF_NAMING_VARS` or `##PREF_NAMING_VARS`."
  },
  {
    "ruleId": "pref-name-members",
    "title": "Enforce Standard Naming Conventions for Class Members, Parameters and Screens",
    "rationale": "Member attributes and method signatures form the primary contract of object-oriented ABAP components. Enforcing conventional Hungarian prefixes (such as mv_ for instance attributes, gv_ for class data, iv_ for importing, ev_ for exporting, cv_ for changing, and rv_ for returning parameters) communicates parameter direction and attribute scope unambiguously to callers. Selection screen elements similarly require standard prefixes (p_ and s_) in classic reporting. Skylint validates class definitions and screen statements against customizable regex patterns, raising PREF_NMATR, PREF_NMPAR, or PREF_NAMSS on violations.",
    "className": "/SKYL/CL_PREF_NAME_MEMBERS",
    "pseudoComment": "PREF_NAME_MEMBERS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    DATA customer_status TYPE string.\n    METHODS update_status\n      IMPORTING new_status TYPE string\n      RETURNING VALUE(is_ok) TYPE abap_bool.\nENDCLASS.",
      "good": "CLASS zcl_customer_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.\n  PUBLIC SECTION.\n    DATA mv_customer_status TYPE string.\n    METHODS update_status\n      IMPORTING iv_new_status TYPE string\n      RETURNING VALUE(rv_is_ok) TYPE abap_bool.\nENDCLASS."
    },
    "parameters": {
      "ATTR_IGN_EXC": "Bypass attribute naming checks in exception classes (classes inheriting from CX_*).",
      "ATTR_IGN_LOCAL": "Bypass attribute naming checks in local classes, restricting checks to global definitions.",
      "ATTR_IGN_INTF": "Bypass attribute naming checks within interface definitions.",
      "ATTR_STATICS": "Regex pattern for static class attributes (CLASS-DATA), defaulting to ^G._.+$.",
      "ATTR_INSTANCE": "Regex pattern for instance class attributes (DATA), defaulting to ^M._.+$.",
      "ATTR_CONSTANTS": "Regex pattern for class constants; left empty by default to allow any naming style.",
      "PARAM_IGN_EXC": "Bypass method parameter naming checks for exception class constructors and methods.",
      "PARAM_IMPORTING": "Regex pattern for method IMPORTING parameters, defaulting to ^I._.+$.",
      "PARAM_RETURNING": "Regex pattern for method RETURNING parameters, defaulting to ^R._.+$.",
      "PARAM_CHANGING": "Regex pattern for method CHANGING parameters, defaulting to ^C._.+$.",
      "PARAM_EXPORTING": "Regex pattern for method EXPORTING parameters, defaulting to ^E._.+$.",
      "SSCR_PARAM": "Regex pattern for classic selection screen PARAMETERS, defaulting to ^P_.+$.",
      "SSCR_SELOPT": "Regex pattern for classic selection screen SELECT-OPTIONS, defaulting to ^S_.+$."
    },
    "seo": {
      "description": "Enforce naming rules for ABAP class attributes, method parameters, and selection screen parameters with configurable regex patterns in SAP ATC.",
      "keywords": [
        "pref-name-members",
        "member naming",
        "method parameters",
        "class attributes",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-name-objects",
      "pref-naming-vars",
      "pref-pred-name"
    ],
    "customSection": "## Configuration and Monitored Constructs\n\n| Element | Finding Code | Default Regex Pattern | Example |\n|---|---|---|---|\n| Instance Attribute (`DATA`) | `PREF_NMATR` | `^M._.+$` | `mv_order_id`, `mt_items` |\n| Static Attribute (`CLASS-DATA`) | `PREF_NMATR` | `^G._.+$` | `gv_instance_counter` |\n| Importing Parameter | `PREF_NMPAR` | `^I._.+$` | `iv_customer_id`, `it_orders` |\n| Exporting Parameter | `PREF_NMPAR` | `^E._.+$` | `ev_error_message` |\n| Changing Parameter | `PREF_NMPAR` | `^C._.+$` | `cv_status_flag` |\n| Returning Parameter | `PREF_NMPAR` | `^R._.+$` | `rv_is_valid` |\n| Selection Screen Parameter | `PREF_NAMSS` | `^P_.+$` | `p_bukrs` |\n| Selection Screen Select-Option | `PREF_NAMSS` | `^S_.+$` | `s_kunnr` |\n\nSuppress findings with pseudo comment `\"#EC PREF_NAME_MEMBERS`."
  },
  {
    "ruleId": "pref-name-objects",
    "title": "Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects",
    "rationale": "Consistent naming for architectural artifacts—such as classes (zcl_ / lcl_), interfaces (zif_ / lif_), type definitions (ty_), test classes (ltcl_), and event handlers (on_)—provides immediate clarity on object lifecycle, scope, and technical kind across repository trees. A unified naming scheme simplifies cross-package navigation, enhances searchability in ABAP Development Tools (ADT), and reinforces Clean ABAP structural guidelines. Skylint enforces configurable regex patterns for all core ABAP object definitions.",
    "className": "/SKYL/CL_PREF_NAME_OBJECTS",
    "pseudoComment": "PREF_NAME_OBJECTS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS order_service DEFINITION.\n  PUBLIC SECTION.\n    TYPES order_item_type TYPE string.\nENDCLASS.",
      "good": "CLASS lcl_order_service DEFINITION.\n  PUBLIC SECTION.\n    TYPES ty_order_item TYPE string.\nENDCLASS."
    },
    "parameters": {
      "CLASS_LOCAL": "Regex pattern for local class names, defaulting to ^LC(L|X)_.+$.",
      "CLASS_TEST": "Regex pattern for ABAP Unit test class names, defaulting to ^LTCL_.+$.",
      "CLASS_GLOBAL": "Regex pattern for global class names, defaulting to ^ZC(L|X)_.+$.",
      "INTF_LOCAL": "Regex pattern for local interface names, defaulting to ^LIF_.+$.",
      "INTF_GLOBAL": "Regex pattern for global interface names, defaulting to ^ZIF_.+$.",
      "TYPES_PATTERN": "Regex pattern for local and global type definitions (TYPES), defaulting to ^TY_.+$.",
      "MACRO_PATTERN": "Regex pattern for legacy DEFINE macros, defaulting to ^_.+$.",
      "FORM_PATTERN": "Regex pattern for classic subroutine FORM names, defaulting to ^F_.+$.",
      "FUNCTION_PATTERN": "Regex pattern for function module names, defaulting to ^Z.*$.",
      "EVENT_NAME": "Regex pattern for class or interface EVENTS definitions, defaulting to ^[A-Z][A-Z0-9_]+$.",
      "EVENT_HANDLER": "Regex pattern for event handler method names (FOR EVENT), defaulting to ^ON_.+$.",
      "TEST_METHOD": "Regex pattern for ABAP Unit test method names, defaulting to ^(TEST|SHOULD)_.+$.",
      "PROG_PATTERN": "Regex pattern for executable REPORT and PROGRAM statements, defaulting to ^Z.+$.",
      "FUGR_PATTERN": "Regex pattern for function pool definitions (FUNCTION-POOL), defaulting to ^Z.+$."
    },
    "seo": {
      "description": "Standardize naming conventions for ABAP classes, interfaces, types, events, and programs with configurable ATC regex rules.",
      "keywords": [
        "pref-name-objects",
        "class naming",
        "interface naming",
        "types",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-name-members",
      "pref-naming-vars",
      "pref-pred-name"
    ],
    "customSection": "## Monitored Object Types and Defaults\n\n| Object Kind | Finding Code | Default Pattern | Valid Example |\n|---|---|---|---|\n| Local Class | `PREF_LCLS` | `^LC(L\\|X)_.+$` | `lcl_order_handler` |\n| Test Class | `PREF_LCLS` | `^LTCL_.+$` | `ltcl_order_tests` |\n| Global Class | `PREF_GCLS` | `^ZC(L\\|X)_.+$` | `zcl_invoice_service` |\n| Local Interface | `PREF_LINTF` | `^LIF_.+$` | `lif_payment_gateway` |\n| Global Interface | `PREF_GINTF` | `^ZIF_.+$` | `zif_payment_gateway` |\n| Type Definition | `PREF_TYP` | `^TY_.+$` | `ty_customer_record` |\n| Event Name | `PREF_EVT` | `^[A-Z][A-Z0-9_]+$` | `ORDER_CONFIRMED` |\n| Event Handler | `PREF_EVT` | `^ON_.+$` | `on_order_confirmed` |\n| Test Method | `PREF_TMETH` | `^(TEST\\|SHOULD)_.+$` | `test_calculate_tax` |\n| Form Routine | `PREF_FORM` | `^F_.+$` | `f_process_legacy` |\n| Function Module | `PREF_FUNC` | `^Z.*$` | `z_calculate_pricing` |\n| Function Group | `PREF_FUGR` | `^Z.+$` | `z_sales_group` |\n| Program / Report | `PREF_PROG` | `^Z.+$` | `z_monthly_accruals` |\n\nSuppress findings with pseudo comment `\"#EC PREF_NAME_OBJECTS`."
  },
  {
    "ruleId": "no-bad-indent",
    "title": "Enforce Consistent Statement Indentation Based on Block Nesting Depth",
    "rationale": "Indentation provides the primary visual structure of program flow. Inconsistent or misaligned statement indentation misleads readers regarding control block hierarchy, conceals nesting bugs, and generates noisy Git diffs during formatting. Each nested control statement (such as IF, LOOP, DO, WHILE, TRY, or CASE) must be systematically indented by a uniform step from its parent block. Skylint calculates the expected column position for each statement according to its nesting level, reporting NO_BAD_IND with the FIXINDENT quickfix on misalignment.",
    "className": "/SKYL/CL_NO_BAD_INDENT",
    "pseudoComment": "NO_BAD_INDENT",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD run.\n  DATA lv_tax_amount TYPE i.\n  IF lv_is_taxable = abap_true.\nlv_tax_amount = 19.\n  ENDIF.\nENDMETHOD.",
      "good": "METHOD run.\n  DATA lv_tax_amount TYPE i.\n  IF lv_is_taxable = abap_true.\n    lv_tax_amount = 19.\n  ENDIF.\nENDMETHOD."
    },
    "parameters": {
      "INDENT_STEP": "Number of spaces required per nested block indentation level, defaulting to 2 spaces."
    },
    "seo": {
      "description": "Enforce uniform statement indentation per control block nesting depth in ABAP routines using automated ATC inspection.",
      "keywords": [
        "no-bad-indent",
        "indentation",
        "code formatting",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "max-nesting",
      "max-method-len",
      "max-line-len"
    ],
    "customSection": "## Indentation Rules and Quickfix\n\nThe check tracks nesting depth starting at the procedure header (`METHOD`, `FORM`, `FUNCTION`) and verifies every statement:\n\n- **Block openings (`IF`, `LOOP`, `TRY`, `CASE`, etc.):** Checked at current depth, then increments depth by 1.\n- **Branching statements (`ELSE`, `ELSEIF`, `WHEN`, `CATCH`):** Aligned at `(depth - 1) * INDENT_STEP`.\n- **Block closures (`ENDIF`, `ENDLOOP`, `ENDTRY`, `ENDCASE`):** Decrements depth and checks alignment with the matching opener.\n\nWhen a statement is under-indented, the `FIXINDENT` quickfix recalculates and prepends the required leading spaces.\n\nSuppress findings with pseudo comment `\"#EC NO_BAD_INDENT`."
  },
  {
    "ruleId": "no-dead-code",
    "title": "Eliminate Unreachable Dead Code Caused by Constant False Conditions",
    "rationale": "Conditions that evaluate to constant false at compile time, such as IF 1 = 2, CHECK abap_false, or impossible BETWEEN ranges, create unreachable dead code branches that clutter the codebase and confuse maintainers. Dead branches often harbor obsolete or unmaintained logic, deceive reviewers during audits, and prevent accurate test coverage calculations. Clean ABAP mandates removing dead conditional branches or replacing constant flags with valid runtime business conditions. The ATC check emits NO_DEAD_CD and provides the DELDEAD quickfix.",
    "className": "/SKYL/CL_NO_DEAD_CODE",
    "pseudoComment": "NO_DEAD_CODE",
    "category": "anti-patterns",
    "example": {
      "bad": "IF 1 = 2.\n  archive_obsolete_invoices( ).\nENDIF.",
      "good": "IF lv_is_archiving_enabled = abap_true.\n  archive_obsolete_invoices( ).\nENDIF."
    },
    "seo": {
      "description": "Detect and delete unreachable dead code branches caused by constant false conditions in ABAP using ATC quickfixes.",
      "keywords": [
        "no-dead-code",
        "Clean ABAP",
        "ABAP Cloud",
        "dead code",
        "constant conditions",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-unreachable",
      "no-magic-numbers",
      "max-method-len"
    ],
    "customSection": "## Evaluated Constant Patterns\n\nThe check statically evaluates conditional expressions in `IF`, `ELSEIF`, `WHILE`, and `CHECK` statements:\n- **Boolean constants**: `IF abap_false.` or `CHECK abap_false.`\n- **Numeric comparisons**: Comparisons between literals such as `1 = 2`, `-5 > +3`, or `10 < 2`\n- **Literal string comparisons**: Incompatible string literals such as `'A' = 'B'`\n- **Constant BETWEEN ranges**: Ranges where the operand falls outside the boundary literals (e.g. `5 BETWEEN 1 AND 3`)\n\n### Automated Quickfix\nFor `IF`, `WHILE`, and `CHECK` statements with constant false conditions, the `DELDEAD` quickfix removes the dead branch and its enclosing block entirely.\n\n### Suppression\nSuppress with pseudo comment `\"#EC NO_DEAD_CODE`."
  },
  {
    "ruleId": "no-keyword-name",
    "title": "Avoid Using ABAP Keywords as Identifier Names",
    "rationale": "Declaring variables, field symbols, or constants with names that match ABAP language keywords (such as DATA, TYPE, CLASS, or MESSAGE) shadows built-in syntax terms. This causes semantic ambiguity in code reviews, breaks automated refactoring tools, and increases maintenance risk in ABAP Cloud where new language statements are regularly introduced. Identifiers should describe their business role rather than borrow language grammar keywords.",
    "className": "/SKYL/CL_NO_KEYWORD_NAME",
    "pseudoComment": "NO_KEYWORD_NAME",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA class TYPE string.\nDATA(message) = 'Order approved'.",
      "good": "DATA lv_class_name TYPE string.\nDATA(status_message) = 'Order approved'."
    },
    "seo": {
      "description": "Detect ABAP variables, constants, and field symbols whose names shadow ABAP language keywords, preventing syntax ambiguity and refactoring bugs.",
      "keywords": [
        "ABAP keyword shadowing",
        "naming conventions",
        "Clean ABAP",
        "SAP ATC check",
        "no-keyword-name"
      ]
    },
    "relatedRules": [
      "pref-name-members",
      "pref-name-objects",
      "pref-pred-name"
    ],
    "customSection": "### What is reported\n\nThe check inspects explicit declaration statements (`DATA`, `CONSTANTS`, `STATICS`, `TYPES`, `FIELD-SYMBOLS`) as well as modern inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`). If the declared identifier matches an ABAP reserved keyword, finding `NO_KWD_NAM` is raised.\n\n| Declaration | Finding | Recommended alternative |\n| --- | --- | --- |\n| `DATA class TYPE string.` | yes (`NO_KWD_NAM`) | `DATA class_name TYPE string.` |\n| `DATA(message) = 'Success'.` | yes (`NO_KWD_NAM`) | `DATA(log_message) = 'Success'.` |\n| `FIELD-SYMBOLS <table\\> TYPE any table.` | yes (`NO_KWD_NAM`) | `FIELD-SYMBOLS <partner_table\\> TYPE any table.` |\n| `DATA lv_class_name TYPE string.` | no | - |\n\n### Suppression\n\nLegitimate mappings to legacy APIs or external data structures can be suppressed using pseudo-comment `\"#EC NO_KEYWORD_NAME` on the declaration statement."
  },
  {
    "ruleId": "pref-join-type",
    "title": "Specify Explicit Join Types in ABAP SQL SELECT Statements",
    "rationale": "In ABAP SQL, writing a bare JOIN defaults implicitly to an INNER JOIN, but the implicit behavior is invisible at the call site and frequently misread during code reviews as an outer join. Explicitly qualifying joins as INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, or CROSS JOIN documents intended data cardinality and eliminates ambiguity. Skylint flags any bare JOIN token in SELECT statements with PREF_JOINT and provides the ADD_INNER quickfix to insert the explicit INNER keyword.",
    "className": "/SKYL/CL_PREF_JOIN_TYPE",
    "pseudoComment": "PREF_JOIN_TYPE",
    "category": "clean-abap",
    "example": {
      "bad": "SELECT sales_order~sales_order, item~material\n  FROM zsales_order AS sales_order\n  JOIN zsales_item AS item ON sales_order~sales_order = item~sales_order\n  WHERE sales_order~order_type = 'SO'\n  INTO TABLE @DATA(lt_order_details).",
      "good": "SELECT sales_order~sales_order, item~material\n  FROM zsales_order AS sales_order\n  INNER JOIN zsales_item AS item ON sales_order~sales_order = item~sales_order\n  WHERE sales_order~order_type = 'SO'\n  INTO TABLE @DATA(lt_order_details)."
    },
    "seo": {
      "description": "Require explicit join types such as INNER JOIN or LEFT OUTER JOIN in ABAP SQL SELECT queries for clear cardinality and readability.",
      "keywords": [
        "pref-join-type",
        "INNER JOIN",
        "ABAP SQL",
        "Open SQL",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-order-by",
      "no-db-in-loop",
      "no-empty-fae"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check evaluates tokens in `SELECT` statements. When a `JOIN` keyword is encountered without an immediate preceding qualifier (`INNER`, `LEFT`, `RIGHT`, `OUTER`, or `CROSS`), finding `PREF_JOINT` is reported. The `ADD_INNER` quickfix replaces the bare `JOIN` token with `INNER JOIN` in-place while retaining statement formatting.\n\nSuppress findings using pseudo comment `\"#EC PREF_JOIN_TYPE`."
  },
  {
    "ruleId": "pref-std-table",
    "title": "Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF",
    "rationale": "The shorthand declaration TYPE TABLE OF implicitly defaults to a standard internal table, requiring readers to know the language default to deduce access complexity and memory characteristics. Explicitly writing TYPE STANDARD TABLE OF clarifies table categorization alongside SORTED and HASHED alternatives, making linear search costs transparent and easing future refactoring when changing table categories. Skylint scans type sequences for TYPE TABLE OF and reports PREF_STDTB with the ADD_STDTAB quickfix.",
    "className": "/SKYL/CL_PREF_STD_TABLE",
    "pseudoComment": "PREF_STD_TABLE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lt_sales_orders TYPE TABLE OF zsales_order.",
      "good": "DATA lt_sales_orders TYPE STANDARD TABLE OF zsales_order."
    },
    "seo": {
      "description": "Enforce explicit TYPE STANDARD TABLE OF declarations over ambiguous TYPE TABLE OF shorthand in modern ABAP Cloud code.",
      "keywords": [
        "pref-std-table",
        "STANDARD TABLE",
        "internal table",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-mod-std-table",
      "pref-read-table",
      "pref-lines"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check identifies occurrences of the token sequence `TYPE TABLE OF` across all declaration and typing contexts (`DATA`, `TYPES`, `METHODS` parameter signatures, and `FIELD-SYMBOLS`). The `ADD_STDTAB` quickfix automatically rewrites the sequence as `TYPE STANDARD TABLE OF`.\n\nSuppress individual findings with pseudo comment `\"#EC PREF_STD_TABLE`."
  },
  {
    "ruleId": "pref-is-supplied",
    "title": "Replace Obsolete IS REQUESTED with Modern IS SUPPLIED Predicate",
    "rationale": "The predicate IS REQUESTED is an obsolete language construct that only checks whether an output parameter was requested by a caller, whereas IS SUPPLIED is a universal predicate verifying whether any importing, exporting, changing, or returning parameter was passed at invocation. Using IS SUPPLIED ensures consistent parameter interrogation across all parameter kinds and aligns with ABAP Cloud syntax rules. Skylint detects IS REQUESTED and IS NOT REQUESTED, raising PREF_ISSUP with the USE_SUPPLD quickfix.",
    "className": "/SKYL/CL_PREF_IS_SUPPLIED",
    "pseudoComment": "PREF_IS_SUPPLIED",
    "category": "clean-abap",
    "example": {
      "bad": "IF iv_discount_percent IS REQUESTED.\n  apply_discount( iv_discount_percent ).\nENDIF.",
      "good": "IF iv_discount_percent IS SUPPLIED.\n  apply_discount( iv_discount_percent ).\nENDIF."
    },
    "seo": {
      "description": "Replace obsolete IS REQUESTED predicates with modern IS SUPPLIED across method parameter checks in ABAP Cloud.",
      "keywords": [
        "pref-is-supplied",
        "IS SUPPLIED",
        "IS REQUESTED",
        "parameter validation",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-returning",
      "pref-param-name",
      "pref-return"
    ],
    "customSection": "## Detection and Quickfix Details\n\nThe check examines control conditions for occurrences of `IS REQUESTED` and `IS NOT REQUESTED`. The `USE_SUPPLD` quickfix replaces the token `REQUESTED` with `SUPPLIED` in-place while keeping negation and condition formatting intact.\n\nSuppress findings using pseudo comment `\"#EC PREF_IS_SUPPLIED`."
  },
  {
    "ruleId": "pref-sy",
    "title": "Prefer Short System Field Structure Alias SY Over Legacy SYST",
    "rationale": "The runtime structures SY and SYST refer to the exact same underlying ABAP system fields structure (SYST). Mixing both aliases introduces unnecessary variation, impairs automated search across codebases, and departs from modern ABAP conventions where sy- is universally preferred. Standardizing on sy- keeps system variable access concise and idiomatic. Skylint checks for references to the SYST structure and reports PREF_SY alongside the USE_SY quickfix.",
    "className": "/SKYL/CL_PREF_SY",
    "pseudoComment": "PREF_SY",
    "category": "clean-abap",
    "example": {
      "bad": "lv_current_user = syst-uname.",
      "good": "lv_current_user = sy-uname."
    },
    "seo": {
      "description": "Standardize ABAP system variable access using the concise sy- prefix instead of legacy syst- in ABAP Cloud.",
      "keywords": [
        "pref-sy",
        "sy-subrc",
        "sy-uname",
        "SYST",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-sy-modify",
      "pref-calc-op",
      "pref-symbol-op"
    ],
    "customSection": "## Detection and Quickfix Details\n\nStatements containing tokens that resolve to compiler reference `\\DA:SYST\\*` (such as `syst-subrc`, `syst-uname`, `syst-datum`) are identified. The `USE_SY` quickfix substitutes `syst-` with `sy-` automatically.\n\nSuppress findings using pseudo comment `\"#EC PREF_SY`."
  },
  {
    "ruleId": "no-unfilt-dml",
    "title": "Enforce WHERE Conditions on Database UPDATE and DELETE Statements",
    "rationale": "Executing OpenSQL UPDATE ... SET or DELETE FROM statements on database tables without an explicit WHERE clause mutates or truncates every record in the entire database table. In enterprise production systems, an unfiltered DML statement leads to catastrophic data destruction or widespread corruption, bringing core business processes to an immediate halt and requiring emergency database restorations. Clean ABAP, SAP ATC robustness checks, and ABAP Cloud Contract C1 require all OpenSQL database writes to be strictly bounded by explicit top-level WHERE conditions to guarantee precise transaction boundaries.",
    "className": "/SKYL/CL_NO_UNFILT_DML",
    "pseudoComment": "NO_UNFILT_DML",
    "category": "security",
    "example": {
      "bad": "DELETE FROM zorder_items.",
      "good": "DELETE FROM zorder_items\n  WHERE order_id = @lv_order_id.\n\nIF sy-subrc <> 0.\n  \" Record not found or already deleted\nENDIF."
    },
    "seo": {
      "description": "Prevent catastrophic full-table data deletion or corruption in ABAP OpenSQL by requiring WHERE clauses on UPDATE and DELETE.",
      "keywords": [
        "no-unfilt-dml",
        "DELETE without WHERE",
        "OpenSQL DML Security",
        "UPDATE SET WHERE",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-db-in-loop",
      "no-select-star",
      "pref-check-subrc"
    ],
    "customSection": "## Scope of DML Inspection\n\nThe check inspects OpenSQL statements that modify persistent database tables:\n\n| OpenSQL Statement | Condition Checked | Action Taken |\n|---|---|---|\n| `DELETE FROM <dbtab>` | Absence of top-level `WHERE` | Flagged with finding `NO_UNF_DML` |\n| `UPDATE <dbtab> SET ...` | Absence of top-level `WHERE` | Flagged with finding `NO_UNF_DML` |\n| `DELETE FROM <dbtab> WHERE ...` | Presence of `WHERE` at parenthesis depth 0 | Passed (compliant) |\n| `UPDATE <dbtab> SET ... WHERE ...` | Presence of `WHERE` at parenthesis depth 0 | Passed (compliant) |\n| `DELETE itab` (internal table) | In-memory table operation | Ignored (non-database access) |\n\nNote that subquery `WHERE` clauses inside `SET` expressions do not count as top-level table filters. Suppress legitimate mass cleanup operations on temporary staging tables with `\"#EC NO_UNFILT_DML` or `##NO_UNFILT_DML`."
  },
  {
    "ruleId": "no-concat-loop",
    "title": "Avoid String Accumulation Inside Loops (Quadratic Memory Growth)",
    "rationale": "Repeatedly concatenating string fragments onto an accumulator variable inside a loop using &&, string templates |{ lv_result }...|, or CONCATENATE produces quadratic O(N^2) memory copying. On each iteration, the ABAP kernel allocates a brand-new dynamic string heap buffer, copies all previously accumulated bytes plus the new fragment, and marks the previous allocation for garbage collection. On loops with hundreds or thousands of iterations (such as XML, JSON, or CSV document generation), this causes severe heap fragmentation, cache misses, and CPU thrashing. In Clean ABAP, string fragments should be collected into a string_table and combined in a single linear O(N) operation using concat_lines_of( ).",
    "className": "/SKYL/CL_NO_CONCAT_LOOP",
    "pseudoComment": "NO_CONCAT_LOOP",
    "category": "performance",
    "example": {
      "bad": "DATA lv_csv_output TYPE string.\n\nLOOP AT lt_invoices INTO DATA(ls_invoice).\n  lv_csv_output = lv_csv_output && ls_invoice-invoice_id && ',' && ls_invoice-gross_amount.\nENDLOOP.",
      "good": "DATA lt_csv_lines TYPE string_table.\n\nLOOP AT lt_invoices INTO DATA(ls_invoice).\n  INSERT |{ ls_invoice-invoice_id },{ ls_invoice-gross_amount }| INTO TABLE lt_csv_lines.\nENDLOOP.\n\nDATA(lv_csv_output) = concat_lines_of( table = lt_csv_lines sep = cl_abap_char_utilities=>newline )."
    },
    "seo": {
      "description": "Prevent quadratic string buffer allocations in ABAP loops by collecting fragments in a string table and joining them with concat_lines_of.",
      "keywords": [
        "no-concat-loop",
        "string concatenation loop",
        "concat_lines_of",
        "Clean ABAP strings",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-mod-loop-tab",
      "no-late-sys-idx",
      "pref-transport"
    ],
    "customSection": "### Detection Details\n\nThe check evaluates statements inside `LOOP`, `DO`, and `WHILE` blocks. Finding code `NO_CC_LOOP` is reported whenever a variable is written to via `COMPUTE` (using `&&` or string template `|...|`) or `CONCATENATE` and the same variable is read within the expression.\n\n### Algorithmic Comparison\n\n- **In-Loop Concatenation:** $O(N^2)$ time complexity. Iteration $k$ copies $k$ elements, requiring $\\sum_{k=1}^N k = \\frac{N(N+1)}{2}$ byte copies.\n- **Table Collection with `concat_lines_of`:** $O(N)$ linear time complexity. Inserts table pointers and allocates the final buffer in a single native pass.\n\nSuppress specific short loops with the pseudo comment `\"#EC NO_CONCAT_LOOP`."
  },
  {
    "ruleId": "no-dup-literals",
    "title": "Extract Repeated String Literals into Named Constants",
    "rationale": "Repeating identical string literals across a procedure couples disparate code paths to magic values, increasing the risk of typographic errors and making requirement updates error-prone. Defining a central typed constant clarifies business semantics, enables compile-time safety, and simplifies maintenance across ABAP Cloud and SAP S/4HANA solutions.",
    "className": "/SKYL/CL_NO_DUP_LITERALS",
    "pseudoComment": "NO_DUP_LITERALS",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_order_status = 'CANCELLED'.\n  log_status( 'CANCELLED' ).\nELSEIF lv_previous_status = 'CANCELLED'.\n  clear_status( ).\nENDIF.",
      "good": "CONSTANTS c_status_cancelled TYPE string VALUE 'CANCELLED'.\n\nIF lv_order_status = c_status_cancelled.\n  log_status( c_status_cancelled ).\nELSEIF lv_previous_status = c_status_cancelled.\n  clear_status( ).\nENDIF."
    },
    "parameters": {
      "MIN_OCCURRENCES": "Minimum number of identical string literal occurrences in a procedure required to trigger a finding (default 3).",
      "MIN_LENGTH": "Minimum character length of string literals to inspect, filtering out short delimiters and trivial tokens (default 3)."
    },
    "seo": {
      "description": "Identify repeated string literals in ABAP procedures and replace magic strings with typed constants for Clean ABAP maintainability.",
      "keywords": [
        "ABAP magic strings",
        "constants refactoring",
        "Clean ABAP",
        "SAP ATC check",
        "no-dup-literals"
      ]
    },
    "relatedRules": [
      "no-useless-concat",
      "no-obs-strings",
      "pref-str-tmpl"
    ],
    "customSection": "### How repeated literals are evaluated\n\nThe check scans all executable statements within a procedure (excluding `CLASS ... DEFINITION` sections) and counts occurrences of fixed string literals. When an identical string appears at least `MIN_OCCURRENCES` times and meets the `MIN_LENGTH` requirement, finding `NO_DUP_LIT` is reported for each instance.\n\n| Attribute | Default | Description |\n| --- | --- | --- |\n| `MIN_OCCURRENCES` | 3 | Frequency threshold before a literal is flagged |\n| `MIN_LENGTH` | 3 | Length threshold to ignore single characters like `','` or `'/'` |\n\n### Suppression\n\nIf a repeated literal is intentionally inline (for example in unit test fixture data), suppress the finding using pseudo-comment `\"#EC NO_DUP_LITERALS` on the offending statement."
  },
  {
    "ruleId": "no-neg-cond",
    "title": "Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches",
    "rationale": "A negated condition accompanied by an ELSE branch forces readers to perform mental double negation before grasping the primary execution path. Formulating the positive condition first and swapping the statements between the IF and ELSE blocks makes the dominant logic immediately visible and easier to reason about. Skylint checks for standalone negated conditions in IF statements possessing a plain ELSE branch (without intermediate ELSEIF branches) and reports NO_NEG_CND.",
    "className": "/SKYL/CL_NO_NEG_COND",
    "pseudoComment": "NO_NEG_COND",
    "category": "clean-abap",
    "example": {
      "bad": "IF NOT lv_is_authorized = abap_true.\n  reject_invoice( ).\nELSE.\n  approve_invoice( ).\nENDIF.",
      "good": "IF lv_is_authorized = abap_true.\n  approve_invoice( ).\nELSE.\n  reject_invoice( ).\nENDIF."
    },
    "seo": {
      "description": "Invert negated IF conditions with ELSE branches in ABAP to prioritize positive control flow and enhance Clean ABAP readability.",
      "keywords": [
        "no-neg-cond",
        "negated condition",
        "IF ELSE",
        "boolean logic",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-cond",
      "no-yoda-cond",
      "no-dup-cond"
    ],
    "customSection": "## Scope and Exclusions\n\nThe check evaluates `IF` statements that satisfy all of the following conditions:\n\n- The condition is negated at the root level using `NOT` or relational inequality operators (`<>`, `NE`).\n- The condition does not combine terms using `AND` or `OR`.\n- The statement contains an `ELSE` block without any intervening `ELSEIF` statements.\n- Dedicated predicate negations (such as `IS NOT INITIAL`, `IS NOT BOUND`, `IS NOT ASSIGNED`, `IS NOT SUPPLIED`) are ignored as they are governed by dedicated rules.\n\nSuppress findings using pseudo comment `\"#EC NO_NEG_COND`."
  },
  {
    "ruleId": "max-bool-expr",
    "title": "Limit Boolean Expression Complexity in Conditional Statements",
    "rationale": "Compound boolean conditions combining multiple AND, OR, and EQUIV operators in IF, ELSEIF, WHILE, or CHECK statements severely degrade code readability and increase the risk of logical precedence bugs. In ABAP, AND binds stronger than OR, but complex truth tables make verification difficult and often lead to incomplete branch coverage in ABAP Unit tests. Clean ABAP mandates extracting complex boolean conditions into dedicated, well-named predicate methods (returning abap_bool) or intermediate boolean variables, ensuring robust compliance with Clean Core and ABAP Cloud Contract C1.",
    "className": "/SKYL/CL_MAX_BOOL_EXPR",
    "pseudoComment": "MAX_BOOL_EXPR",
    "category": "metrics",
    "example": {
      "bad": "IF ls_sales_order-net_amount > 1000\n   AND ls_sales_order-currency = 'EUR'\n   AND ls_sales_order-is_blocked = abap_false\n   AND ls_sales_order-is_approved = abap_true\n   AND ls_sales_order-customer_rating = 'A'.\n  process_sales_order( ls_sales_order ).\nENDIF.",
      "good": "IF is_order_eligible_for_discount( ls_sales_order ) = abap_true.\n  process_sales_order( ls_sales_order ).\nENDIF."
    },
    "parameters": {
      "MAX_BOOLEAN_EXPRESSIONS": "Maximum allowed boolean operands in a single condition statement (counts AND, OR, EQUIV operators plus one, default: 4)."
    },
    "seo": {
      "description": "Limit boolean expression complexity in ABAP conditional statements by extracting intricate multi-operator conditions into clean predicate methods.",
      "keywords": [
        "max-bool-expr",
        "boolean complexity ABAP",
        "predicate method",
        "Clean ABAP",
        "SAP ATC check"
      ]
    },
    "relatedRules": [
      "max-cyclo-comp",
      "no-bool-compare",
      "max-nesting"
    ],
    "customSection": "## Detection and Operator Evaluation\n\nThe check evaluates boolean conditional expressions in `IF`, `ELSEIF`, `WHILE`, and `CHECK` statements:\n\n- **Tracked Operators**: Counts occurrences of `AND`, `OR`, and `EQUIV` keywords at condition level.\n- **Between Addition**: The `AND` keyword within a `BETWEEN ... AND ...` expression is recognized and excluded from the operator count.\n- **Operand Calculation**: Operands are calculated as `number of operators + 1`. If the operand count exceeds `MAX_BOOLEAN_EXPRESSIONS` (default `4`), the statement is reported with finding code `MAX_BOOL`.\n\n## Suppression\n\nSuppress a finding using the pseudo-comment `\"#EC MAX_BOOL_EXPR` on the reported conditional statement."
  },
  {
    "ruleId": "no-late-sys-idx",
    "title": "Capture sy-tabix and sy-index Immediately at Loop Start",
    "rationale": "System fields sy-tabix and sy-index are globally mutable and volatile; intervening statements, method invocations, subroutines, or secondary table reads inside a loop can alter or reset them. Accessing sy-tabix or sy-index later in a loop body rather than immediately on the first statement introduces subtle runtime bugs and fragile temporal coupling. Clean ABAP requires copying index values into an explicit local variable at loop initialization.",
    "className": "/SKYL/CL_NO_LATE_SYS_IDX",
    "pseudoComment": "NO_LATE_SYS_IDX",
    "category": "anti-patterns",
    "example": {
      "bad": "LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_order_item>).\n  process_item( <ls_order_item> ).\n  DATA(lv_current_index) = sy-tabix.\nENDLOOP.",
      "good": "LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_order_item>).\n  DATA(lv_current_index) = sy-tabix.\n  process_item( <ls_order_item> ).\nENDLOOP."
    },
    "seo": {
      "description": "Prevent fragile sy-tabix and sy-index reads inside ABAP loops by copying loop indices immediately at block entry.",
      "keywords": [
        "sy-tabix",
        "sy-index",
        "ABAP loop index",
        "Clean ABAP",
        "SAP ATC check",
        "no-late-sys-idx"
      ]
    },
    "relatedRules": [
      "no-concat-loop",
      "no-default-key",
      "pref-lines"
    ],
    "customSection": "### Evaluation details\n\nThe check verifies that reads of `sy-tabix` within `LOOP` blocks and `sy-index` within `DO` or `WHILE` blocks occur immediately as the first statement of the iteration body:\n\n| Loop Structure | Immediate Read (First statement) | Late Read (Subsequent statement) |\n| --- | --- | --- |\n| `LOOP AT itab ...` | Allowed: `DATA(lv_idx) = sy-tabix.` | Flagged: `NO_LATE_SY` |\n| `DO 10 TIMES ...` | Allowed: `DATA(lv_idx) = sy-index.` | Flagged: `NO_LATE_SY` |\n| `WHILE ...` | Allowed: `DATA(lv_idx) = sy-index.` | Flagged: `NO_LATE_SY` |\n\nReads occurring outside loops are ignored by this check (governed by other system field rules).\n\n### Suppression\n\nTo keep a late system index read when side effects are demonstrably impossible, add pseudo-comment `\"#EC NO_LATE_SYS_IDX` to the statement reading the system field."
  },
  {
    "ruleId": "no-unhandled-eml",
    "title": "Provide FAILED and REPORTED in RAP EML Statements",
    "rationale": "In the ABAP RESTful Application Programming Model (RAP), Entity Manipulation Language (EML) statements interact with business objects during transactional phases. Omitting FAILED and REPORTED clauses causes validation failures, authorization denials, and lock conflicts to fail silently. When response parameters are omitted, the calling program proceeds under the mistaken assumption that changes were successfully applied, leading to transactional buffer discrepancies, partial updates, and severe data inconsistency. Clean ABAP and SAP RAP architecture require always specifying both FAILED and REPORTED clauses and validating error tables before committing transactions.",
    "className": "/SKYL/CL_NO_UNHANDLED_EML",
    "pseudoComment": "NO_UNHANDLED_EML",
    "category": "security",
    "example": {
      "bad": "MODIFY ENTITIES OF z_root_travel\n  ENTITY travel\n  UPDATE FIELDS ( description total_price )\n  WITH lt_travel_updates.",
      "good": "MODIFY ENTITIES OF z_root_travel\n  ENTITY travel\n  UPDATE FIELDS ( description total_price )\n  WITH lt_travel_updates\n  FAILED DATA(lt_failed)\n  REPORTED DATA(lt_reported).\n\nIF lt_failed IS NOT INITIAL.\n  mo_message_handler->propagate_errors( lt_reported ).\n  RETURN.\nENDIF."
    },
    "parameters": {
      "CHECK_MODIFY": "Enforce FAILED and REPORTED response structures on MODIFY ENTITY and MODIFY ENTITIES statements (default: true).",
      "CHECK_READ": "Enforce FAILED and REPORTED response structures on READ ENTITY and READ ENTITIES statements (default: true)."
    },
    "seo": {
      "description": "Enforce FAILED and REPORTED response clauses in ABAP RAP EML statements to prevent silent transactional failures and data inconsistency.",
      "keywords": [
        "no-unhandled-eml",
        "ABAP RAP EML",
        "FAILED and REPORTED",
        "Business Object Security",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-dynamic-stmt",
      "no-metaprogramming",
      "no-kernel-call"
    ],
    "customSection": "## Required EML Response Handling\n\nThe check inspects RAP EML operations and verifies that both response parameters are explicitly declared:\n\n| EML Statement | Parameter Checked | Finding Behavior | Quickfix Code |\n|---|---|---|---|\n| `MODIFY ENTITY` / `MODIFY ENTITIES` | Controlled by `CHECK_MODIFY` | Flagged if `FAILED` or `REPORTED` is omitted | `ADD_EML` |\n| `READ ENTITY` / `READ ENTITIES` | Controlled by `CHECK_READ` | Flagged if `FAILED` or `REPORTED` is omitted | `ADD_EML` |\n\nWhen either clause is missing, the `ADD_EML` quickfix automatically appends `FAILED DATA(failed)` and/or `REPORTED DATA(reported)` to the end of the EML statement. Suppress false positives using `\"#EC NO_UNHANDLED_EML` or `##NO_UNHANDLED_EML`."
  },
  {
    "ruleId": "no-empty-override",
    "title": "Omit Method Redefinitions That Only Delegate to Super",
    "rationale": "Overriding a superclass method only to invoke super->method( ) without pre-processing, post-processing, logging, or error handling creates redundant boilerplate code. It inflates the call stack, complicates inheritance maintenance, and clutters class definitions. Unless behavior is being modified or extended, omit the redefinition and allow object-oriented polymorphism to dispatch to the superclass implementation directly.",
    "className": "/SKYL/CL_NO_EMPTY_OVERRIDE",
    "pseudoComment": "NO_EMPTY_OVERRIDE",
    "category": "anti-patterns",
    "example": {
      "bad": "METHOD calculate_tax.\n  super->calculate_tax( ).\nENDMETHOD.",
      "good": "METHOD calculate_tax.\n  super->calculate_tax( ).\n  apply_regional_surcharge( ).\nENDMETHOD."
    },
    "parameters": {
      "IGNORE_CTOR": "Exclude constructor method redefinitions when they only delegate to super->constructor (default true).",
      "IGNORE_CHECK": "Ignore defensive CHECK statements when determining whether a method body only delegates to super (default true)."
    },
    "seo": {
      "description": "Detect and remove redundant ABAP method redefinitions that merely forward execution to super without adding logic.",
      "keywords": [
        "method redefinition",
        "super call ABAP",
        "Clean ABAP inheritance",
        "SAP ATC check",
        "no-empty-override"
      ]
    },
    "relatedRules": [
      "no-friends",
      "no-static-cls",
      "no-static-arrow"
    ],
    "customSection": "### Detection rules\n\nThe rule checks methods in subclasses and raises `NO_EMP_OVR` when:\n1. The method body contains exactly one effective statement (ignoring `RETURN`, `EXIT`, and optionally `CHECK`).\n2. That statement is a call to `SUPER-><method_name>( )`.\n\n| Method Content | Finding raised |\n| --- | --- |\n| `super->do_work( ).` | yes (`NO_EMP_OVR`) |\n| `super->do_work( ). RETURN.` | yes (`NO_EMP_OVR`) |\n| `CHECK is_active = abap_true. super->do_work( ).` | yes with default `IGNORE_CHECK = abap_true` |\n| `super->do_work( ). audit_log( ).` | no (contains active logic) |\n| `super->constructor( ).` | no with default `IGNORE_CTOR = abap_true` |\n\n### Suppression\n\nIf an empty override is strictly required by an external framework interface contract, suppress the finding with `\"#EC NO_EMPTY_OVERRIDE`."
  },
  {
    "ruleId": "pref-composition",
    "title": "Favor Object Composition and Delegation Over Class Inheritance",
    "rationale": "Inheritance creates tight architectural coupling between subclasses and base implementations, exposes internal state, and frequently leads to the fragile base class problem. With the sole exception of CX_* exception hierarchies, which require inheritance to integrate with the ABAP runtime error system, business objects should favor composition by injecting collaborating interfaces and delegating responsibility. Skylint inspects class definitions containing INHERITING FROM and reports PREF_COMPO on non-exception classes.",
    "className": "/SKYL/CL_PREF_COMPOSITION",
    "pseudoComment": "PREF_COMPOSITION",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_order_processor DEFINITION INHERITING FROM lcl_order_base.\n  PUBLIC SECTION.\n    METHODS process.\nENDCLASS.",
      "good": "CLASS lcl_order_processor DEFINITION FINAL.\n  PUBLIC SECTION.\n    METHODS constructor\n      IMPORTING io_order_base TYPE REF TO lif_order_base.\n    METHODS process.\nENDCLASS."
    },
    "parameters": {
      "ALLOW_TEST_CLASSES": "Allow class inheritance inside ABAP Unit test classes defined with the FOR TESTING addition."
    },
    "seo": {
      "description": "Favor composition over inheritance in Clean ABAP to decouple business objects and prevent fragile base classes in ABAP Cloud.",
      "keywords": [
        "pref-composition",
        "composition over inheritance",
        "INHERITING FROM",
        "Clean ABAP",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "max-inherit",
      "pref-final-cls",
      "pref-new-op"
    ],
    "customSection": "## Scope and Allowed Exceptions\n\nThe check evaluates `CLASS ... DEFINITION` statements featuring the `INHERITING FROM` clause:\n\n- **Exception Classes (`CX_*`):** Permitted to inherit because ABAP class-based exceptions must inherit from `cx_static_check`, `cx_root`, or intermediate exception classes.\n- **Test Classes (`FOR TESTING`):** When configuration parameter `ALLOW_TEST_CLASSES` is set to `abap_true`, local unit test classes inheriting from shared test harnesses are permitted.\n- **Business Objects:** All standard business and utility classes are flagged with finding code `PREF_COMPO` to encourage interface-based dependency injection.\n\nSuppress findings with pseudo comment `\"#EC PREF_COMPOSITION`."
  },
  {
    "ruleId": "pref-intf-segreg",
    "title": "Prefer Small, Role-Based Interfaces (Interface Segregation)",
    "rationale": "An interface with more than a handful of methods forces every implementer and every test double to depend on behaviour it never uses, so one change ripples through unrelated classes. Splitting such a contract into small, role-based interfaces keeps implementations swappable, makes mocking trivial (one or two methods instead of six) and turns each interface into a readable, testable capability. The check counts METHODS and CLASS-METHODS declarations per interface block and reports the interface once the count exceeds MAX_METHODS, which keeps the threshold tuning-free for most teams.",
    "className": "/SKYL/CL_PREF_INTF_SEGREG",
    "pseudoComment": "PREF_INTF_SEGREG",
    "category": "clean-abap",
    "example": {
      "bad": "INTERFACE lif_order_service.\n  METHODS create_order.\n  METHODS read_order.\n  METHODS update_order.\n  METHODS delete_order.\n  METHODS archive_order.\n  METHODS print_order.\nENDINTERFACE.",
      "good": "INTERFACE lif_order_maintenance.\n  METHODS create_order.\n  METHODS update_order.\n  METHODS delete_order.\nENDINTERFACE.\n\nINTERFACE lif_order_reporting.\n  METHODS read_order.\n  METHODS print_order.\nENDINTERFACE."
    },
    "parameters": {
      "MAX_METHODS": "Maximum number of METHODS/CLASS-METHODS declarations per interface before a finding is raised (default 5, so six or more methods trigger)."
    },
    "seo": {
      "description": "Interface Segregation for ABAP: keep SAP interface contracts small and role-based so mocks, dependency injection and ATC reviews stay manageable.",
      "keywords": [
        "interface segregation ABAP",
        "ABAP interface methods",
        "Clean ABAP ISP",
        "SAP ATC",
        "pref-intf-segreg"
      ]
    },
    "relatedRules": [
      "no-exposed-data",
      "pref-new-op",
      "pref-pub-ctor"
    ],
    "customSection": "### How the threshold is evaluated\n\nThe rule counts every `METHODS` and `CLASS-METHODS` declaration inside one `INTERFACE ... ENDINTERFACE` block and reports a **single** finding (`PREF_INTFS`) on the interface header when that count is greater than `MAX_METHODS` (default `5`, so six methods trigger).\n\n| Interface content | Counted |\n| --- | --- |\n| `METHODS read_order.` | yes |\n| `CLASS-METHODS create_default.` | yes |\n| `CONSTANTS c_max_items TYPE i.` | no |\n| `TYPES ty_rows TYPE STANDARD TABLE OF ...` | no |\n| `DATA mo_reader TYPE REF TO lif_reader.` | no |\n\nOnly the interface definition is analysed; implementing classes are never reported.\n\n### Tuning\n\n- Keep `MAX_METHODS` above `0`; very low values (for example `2`) effectively force one interface per capability, which is a reasonable target for new Cloud-ready code but disruptive for legacy projects.\n- Generated proxy contracts or vendor interfaces that cannot be split can be suppressed with `\"#EC PREF_INTF_SEGREG` on the `INTERFACE` statement.\n- The check is token based and needs no RTTI, so it also runs in remote ATC scenarios."
  },
  {
    "ruleId": "no-single-letter",
    "title": "Avoid Single-Letter Identifiers in Declarations",
    "rationale": "The variable name is the only documentation most call sites ever get, and a name like `i` or `lt_x` forces readers to scroll back to the declaration to learn what it holds. Searching for a single letter is hopeless because every `i` in the repository matches, which makes refactoring and code review slower. The check measures the last segment after the final underscore, so legacy names such as `lv_i` or `lt_x` are reported as well, while field symbols like `<fs>` and two-letter business words like `id` stay legal.",
    "className": "/SKYL/CL_NO_SINGLE_LETTER",
    "pseudoComment": "NO_SINGLE_LETTER",
    "category": "clean-abap",
    "example": {
      "bad": "DATA i TYPE i.\nDATA lt_x TYPE string_table.",
      "good": "LOOP AT lt_pending_orders ASSIGNING FIELD-SYMBOL(<pending_order>).\n  DATA(order_position) = sy-tabix.\nENDLOOP."
    },
    "parameters": {
      "MIN_NAME_LEN": "Minimum length of the last name segment; shorter names are reported (default 2, so only single-letter segments such as i, x or lv_i fail)."
    },
    "seo": {
      "description": "Single-letter ABAP variable names such as i, x or lv_i hurt code search and code review; enforce intention-revealing identifiers with this ATC check.",
      "keywords": [
        "ABAP variable naming",
        "single letter variable",
        "Clean ABAP naming",
        "SAP ATC",
        "no-single-letter"
      ]
    },
    "relatedRules": [
      "pref-final-data",
      "pref-naming-vars",
      "no-scope-leak"
    ],
    "customSection": "### How the name length is measured\n\nOnly the **last** segment of the name (everything after the final underscore) is measured, and the `<` / `>` of field symbols are stripped first:\n\n| Declaration | Measured segment | Length | Finding with `MIN_NAME_LEN = 2` |\n| --- | --- | --- | --- |\n| `DATA i TYPE i.` | `i` | 1 | yes (`NO_SGL_LTR`) |\n| `DATA lv_i TYPE i.` | `i` | 1 | yes (`NO_SGL_LTR`) |\n| `DATA lt_x TYPE string_table.` | `x` | 1 | yes (`NO_SGL_LTR`) |\n| `FIELD-SYMBOLS <fs> TYPE string.` | `fs` | 2 | no |\n| `DATA id TYPE sysuuid_x16.` | `id` | 2 | no |\n\nScanned statements are `DATA`, `CLASS-DATA`, `STATICS`, `FIELD-SYMBOLS` plus every inline declaration (`DATA(...)`, `FIELD-SYMBOL(...)`).\n\n### Tuning\n\n`MIN_NAME_LEN = 2` is the recommended setting: it kills the classic `i`, `j`, `x`, `y` loop indices without arguing about short but meaningful names. Raising it to `3` also rejects `id`, `no`, `ok` and is therefore a blunt instrument - prefer a review guideline over a high threshold.\n\nSingle-letter names that mirror an external API (for example a DDIC field copied verbatim) can be suppressed with `\"#EC NO_SINGLE_LETTER` on the declaration."
  },
  {
    "ruleId": "pref-factory-name",
    "title": "Name Static Factory Methods CREATE_* When They Return Their Own Class",
    "rationale": "A CLASS-METHODS declaration that returns TYPE REF TO its own class is a factory, and callers should recognise that from the call site alone. Names such as `build`, `new_instance` or `get_object` hide the instantiation intent, especially when they sit next to real business methods in the same class. The check compares the RETURNING type with the enclosing class name and requires the configured prefix, which keeps `lcl_invoice_service=>create_instance( )` idiomatic, greppable and consistent across packages.",
    "className": "/SKYL/CL_PREF_FACTORY_NAME",
    "pseudoComment": "PREF_FACTORY_NAME",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_invoice_service DEFINITION.\n  PUBLIC SECTION.\n    CLASS-METHODS build\n      RETURNING VALUE(ro_service) TYPE REF TO lcl_invoice_service.\nENDCLASS.",
      "good": "CLASS lcl_invoice_service DEFINITION.\n  PUBLIC SECTION.\n    CLASS-METHODS create_instance\n      RETURNING VALUE(ro_service) TYPE REF TO lcl_invoice_service.\nENDCLASS."
    },
    "parameters": {
      "PREFIX": "Required name prefix for static factory methods returning the class's own type (default CREATE_, applied as a case-insensitive CP pattern)."
    },
    "seo": {
      "description": "Enforce the CREATE_ prefix on ABAP static factory methods that return their own class, so object creation is recognisable at every call site.",
      "keywords": [
        "ABAP factory method",
        "CREATE_ naming convention",
        "static constructor ABAP",
        "SAP ATC",
        "pref-factory-name"
      ]
    },
    "relatedRules": [
      "pref-final-cls",
      "no-friends",
      "no-static-arrow"
    ],
    "customSection": "### What is (and is not) reported\n\nThe rule only inspects `CLASS-METHODS` declarations directly inside a `CLASS ... DEFINITION` block and raises `PREF_FCTNM` on the declaration when **both** conditions hold:\n\n1. the method has a `RETURNING` parameter typed `TYPE REF TO <enclosing class>`, and\n2. the method name does not match the configured prefix pattern (default `CREATE_*`).\n\n| Declaration | Reported |\n| --- | --- |\n| `CLASS-METHODS build RETURNING VALUE(ro) TYPE REF TO lcl_service.` | yes |\n| `CLASS-METHODS create_instance RETURNING VALUE(ro) TYPE REF TO lcl_service.` | no |\n| `METHODS build RETURNING VALUE(ro) TYPE REF TO lcl_service.` (instance method) | no |\n| `CLASS-METHODS build RETURNING VALUE(ro) TYPE REF TO lif_service.` | no |\n| `CLASS-METHODS build RETURNING VALUE(rv_count) TYPE i.` | no |\n| `CONSTRUCTOR` | no |\n\n### Tuning the prefix\n\n`PREFIX` is matched as a `CP` wildcard pattern, so the trailing underscore matters: with the default `CREATE_`, a method called `create` is still reported while `create_instance` and `create_from_order` pass. If your guideline uses `NEW_` or `FACTORY_`, change the attribute but keep the separator so that names like `CREATION_DATE` are not accidentally accepted. A deliberate exception (for example a generated factory with a fixed name) can be suppressed with `\"#EC PREF_FACTORY_NAME`."
  },
  {
    "ruleId": "no-hungarian",
    "title": "Avoid Hungarian Notation and Legacy Type Prefixes in Names",
    "rationale": "Prefixes such as `lv_`, `ls_`, `mt_` or `iv_` encode the technical type instead of the business meaning, and they go stale as soon as a variable becomes a field symbol or a structure is replaced by a class. They also bloat every call site and turn a type migration into a repository-wide rename. The check recognises the classic prefix families plus `fs_`, and it deliberately allows `is_*` names typed `abap_bool`, where the prefix reads as a predicate instead of a type hint.",
    "className": "/SKYL/CL_NO_HUNGARIAN",
    "pseudoComment": "NO_HUNGARIAN",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD post_invoice.\n  DATA lv_net_amount TYPE i.\n  DATA lt_invoice_items TYPE STANDARD TABLE OF ty_invoice_item WITH EMPTY KEY.\nENDMETHOD.",
      "good": "METHOD post_invoice.\n  DATA(net_amount) = calculate_net_amount( ).\n  DATA(invoice_items) = read_open_items( ).\nENDMETHOD."
    },
    "parameters": {
      "CHECK_ATTR": "Report legacy prefixes on attributes declared with DATA, CLASS-DATA and CONSTANTS (default enabled).",
      "CHECK_LOCAL": "Report legacy prefixes on local variables, STATICS and inline declarations (default enabled).",
      "CHECK_PARAM": "Report legacy prefixes on method parameter names in METHODS and CLASS-METHODS signatures (default enabled)."
    },
    "seo": {
      "description": "Detect Hungarian notation in ABAP code - lv_, ls_, lt_, mv_, iv_, rv_ and fs_ prefixes - and enforce intention-revealing names in SAP ATC.",
      "keywords": [
        "Hungarian notation ABAP",
        "lv_ ls_ prefix",
        "ABAP variable naming",
        "Clean ABAP",
        "no-hungarian"
      ]
    },
    "relatedRules": [
      "pref-name-objects",
      "pref-naming-vars",
      "pref-name-members"
    ],
    "customSection": "### Recognised prefix families\n\n`NO_HUNGAR` is raised when the name matches `^[LMSGICER][VSTROCF]?_.*` or `^FS_.*`:\n\n| Pattern | Typical origin | Examples |\n| --- | --- | --- |\n| `l*_...` | local | `lv_total`, `ls_header`, `lt_items`, `lo_service`, `lr_data`, `lc_limit`, `lf_callback` |\n| `m*_...` | member | `mv_counter`, `ms_config`, `mt_rows`, `mo_adapter` |\n| `g*_...` | global | `gv_instance`, `gt_buffer` |\n| `s*_...` | static | `sv_cache`, `st_entries`, `so_where` |\n| `i*_`, `e*_`, `r*_`, `c*_` | parameter kind | `iv_order_id`, `ev_result`, `rv_ok`, `cv_state` |\n| `fs_...` | field symbol | `fs_row` |\n\n### Exceptions and switches\n\n- `is_*` names **typed `abap_bool`** are legal (`is_valid`, `is_locked`) because the prefix describes a predicate rather than a type. The same name typed as a structure is still reported.\n- Inline declarations cannot see the declared type, so `DATA(is_valid) = abap_true.` is reported even though a typed `is_valid` attribute would pass. Name such booleans without the prefix or suppress the statement.\n- `CHECK_ATTR`, `CHECK_LOCAL` and `CHECK_PARAM` let you stage the migration: keep `CHECK_PARAM` disabled while a published API is frozen, then switch it on for the next release.\n- A single statement is reported at most once, and suppression works per statement with `\"#EC NO_HUNGARIAN`."
  },
  {
    "ruleId": "max-returns",
    "title": "Limit Number of Return Statements per Procedure",
    "rationale": "Scattering multiple RETURN statements across a large method implementation obscures control flow, complicates debugging, and makes verifying post-conditions or resource cleanup difficult. While Clean ABAP encourages early return guards at the beginning of a method to eliminate nested IF pyramids, having more than six exits in a single procedure indicates that the method handles too many responsibilities. Restructuring algorithms into lookup tables, conditional expressions, or specialized sub-methods keeps control flow predictable and maintainable in modern ABAP Cloud architectures.",
    "className": "/SKYL/CL_MAX_RETURNS",
    "pseudoComment": "MAX_RETURNS",
    "category": "metrics",
    "example": {
      "bad": "IF ls_shipment-is_cancelled = abap_true.\n  rv_route = 'CANCELLED'.\n  RETURN.\nENDIF.\nIF ls_shipment-destination_country = 'DE'.\n  rv_route = 'DOMESTIC_STANDARD'.\n  RETURN.\nENDIF.\nIF ls_shipment-destination_country = 'FR'.\n  rv_route = 'WEST_EUROPE'.\n  RETURN.\nENDIF.\nIF ls_shipment-is_express = abap_true.\n  rv_route = 'EXPRESS_AIR'.\n  RETURN.\nENDIF.\nIF ls_shipment-weight_kg > 1000.\n  rv_route = 'HEAVY_FREIGHT'.\n  RETURN.\nENDIF.\nIF ls_shipment-has_hazmat = abap_true.\n  rv_route = 'HAZMAT_SPECIAL'.\n  RETURN.\nENDIF.\nIF ls_shipment-is_customs_cleared = abap_false.\n  rv_route = 'CUSTOMS_HOLD'.\n  RETURN.\nENDIF.\nrv_route = 'DEFAULT_ROUTING'.",
      "good": "IF ls_shipment-is_cancelled = abap_true.\n  rv_route = 'CANCELLED'.\n  RETURN.\nENDIF.\n\nrv_route = COND string(\n  WHEN ls_shipment-is_customs_cleared = abap_false THEN 'CUSTOMS_HOLD'\n  WHEN ls_shipment-has_hazmat = abap_true          THEN 'HAZMAT_SPECIAL'\n  WHEN ls_shipment-is_express = abap_true          THEN 'EXPRESS_AIR'\n  WHEN ls_shipment-weight_kg > 1000                THEN 'HEAVY_FREIGHT'\n  WHEN ls_shipment-destination_country = 'DE'      THEN 'DOMESTIC_STANDARD'\n  WHEN ls_shipment-destination_country = 'FR'      THEN 'WEST_EUROPE'\n  ELSE                                                  'DEFAULT_ROUTING' )."
    },
    "parameters": {
      "MAX_RETURNS": "Maximum allowed RETURN statements within a single procedure body before triggering a refactoring warning (default: 6)."
    },
    "seo": {
      "description": "Limit RETURN statements in ABAP methods to maintain predictable exit points and clean procedural control flow in SAP ATC inspections.",
      "keywords": [
        "max-returns",
        "multiple return statements",
        "Clean ABAP control flow",
        "guard clauses ABAP",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "max-params",
      "max-method-len",
      "max-one-stmt"
    ],
    "customSection": "## Detection Scope\n\nThe check scans all statements in procedure implementations (methods, function modules, and form routines):\n\n- **Keyword Matching**: Only statements with keyword `RETURN` are counted. `EXIT` and `CHECK` statements are not evaluated by this rule.\n- **Reporting Target**: If the total number of `RETURN` statements exceeds `MAX_RETURNS` (default `6`), a finding with code `MAX_RET` is reported on the first statement of the procedure (e.g. `METHOD`).\n\n## Suppression\n\nSuppress the check using the pseudo-comment `\"#EC MAX_RETURNS` placed on the opening procedure statement (e.g., `METHOD`)."
  },
  {
    "ruleId": "no-instance-of",
    "title": "Replace IS INSTANCE OF and CASE TYPE OF with Polymorphism",
    "rationale": "Runtime type tests turn an open class hierarchy into a growing IF/CASE ladder: every new subtype requires editing this method, which is exactly what the Open-Closed Principle forbids. The branches also depend on concrete classes, so the code cannot be tested with a lightweight test double and the coupling is invisible in the interface. Pushing the behaviour into a method on the common interface lets the runtime dispatch select the implementation and keeps the caller independent of every subtype.",
    "className": "/SKYL/CL_NO_INSTANCE_OF",
    "pseudoComment": "NO_INSTANCE_OF",
    "category": "clean-abap",
    "example": {
      "bad": "CASE TYPE OF io_payment.\n  WHEN TYPE zcl_credit_card_payment.\n    apply_credit_card( io_payment ).\n  WHEN TYPE zcl_bank_transfer.\n    apply_bank_transfer( io_payment ).\nENDCASE.",
      "good": "\" lif_payment->apply is implemented by every payment type\nio_payment->apply( )."
    },
    "parameters": {
      "CHECK_CASE_TYPE": "Also report CASE TYPE OF constructs, not just IS INSTANCE OF (default enabled; disable to allow classic exception mappers)."
    },
    "seo": {
      "description": "Remove ABAP runtime type checks such as IS INSTANCE OF and CASE TYPE OF in favour of polymorphic interface methods and Open-Closed Principle design.",
      "keywords": [
        "IS INSTANCE OF",
        "CASE TYPE OF",
        "ABAP polymorphism",
        "SAP ATC",
        "no-instance-of"
      ]
    },
    "relatedRules": [
      "no-static-arrow",
      "no-exposed-data",
      "pref-new-op"
    ],
    "customSection": "### Both type tests are reported\n\n| Construct | Finding | Replacement |\n| --- | --- | --- |\n| `IF oref IS INSTANCE OF zcl_class.` | `NO_INST_OF` | add the behaviour to the interface and call it |\n| `CASE TYPE OF oref. WHEN TYPE zcl_class.` | `NO_INST_OF` while `CHECK_CASE_TYPE` is on | strategy / visitor dispatched through the interface |\n| `IF oref IS BOUND.` | no | - |\n| `IF oref IS INITIAL.` | no | - |\n| `CAST zcl_class( oref )` / `TRY ... CATCH CX_SY_MOVE_CAST_ERROR` | no | - |\n\nThe check matches the token sequences `INSTANCE OF` and `CASE TYPE OF` and does not need the type to be resolvable, so it also works in remote ATC runs.\n\n### When a type test is legitimate\n\nFramework code that reacts to external, non-extensible types sometimes has to inspect the type: deserialisation, RTTI helpers, mapping of arbitrary `CX_ROOT` instances, or adapters around generated proxies. Keep such a branch in one clearly documented place and suppress it with `\"#EC NO_INSTANCE_OF`. Setting `CHECK_CASE_TYPE = abap_false` allows `CASE TYPE OF` in classic exception mappers while still banning `IS INSTANCE OF` everywhere else."
  },
  {
    "ruleId": "no-self-compare",
    "title": "Avoid Comparisons and Operations with Identical Operands",
    "rationale": "Comparing a variable or expression to itself (such as lv_status = lv_status) is either a tautology or permanently false, almost always signifying a copy-paste defect or missing field qualifier. Similarly, subtracting or dividing an operand by itself yields a constant value (0 or 1) while obscuring developer intent. Compiler symbol resolution validates both sides, ensuring accurate detection without false positives on shadowed identifiers.",
    "className": "/SKYL/CL_NO_SELF_COMPARE",
    "pseudoComment": "NO_SELF_COMPARE",
    "category": "anti-patterns",
    "example": {
      "bad": "IF lv_order_status = lv_order_status.\n  process_order( ).\nENDIF.\nlv_net_amount = lv_gross_amount - lv_gross_amount.",
      "good": "IF lv_order_status = c_status_confirmed.\n  process_order( ).\nENDIF.\nlv_net_amount = lv_gross_amount - lv_discount_amount."
    },
    "seo": {
      "description": "Detect redundant comparisons and arithmetic operations with identical left and right operands in ABAP conditional statements.",
      "keywords": [
        "self comparison ABAP",
        "tautology check",
        "Clean ABAP logic",
        "SAP ATC check",
        "no-self-compare"
      ]
    },
    "relatedRules": [
      "no-dead-code",
      "no-dup-cond",
      "no-redun-assign"
    ],
    "customSection": "### Checked operators and findings\n\nThe check examines expressions in `IF`, `ELSEIF`, `WHILE`, `CHECK`, and `COMPUTE` statements:\n\n| Operator Category | Operators | Finding Code |\n| --- | --- | --- |\n| Comparison | `=`, `<>`, `<`, `>`, `<=`, `>=`, `EQ`, `NE`, `LT`, `GT`, `LE`, `GE` | `NO_SELFCMP` |\n| Arithmetic | `-`, `/`, `DIV`, `MOD` | `NO_SELFOPR` |\n\nStatements containing top-level logical chains (`AND`, `OR`, `BETWEEN`, `IS`) are bypassed to prevent duplicate findings with `no-dup-cond`.\n\n### Suppression\n\nIn rare generated or macro-expanded routines where identical operand evaluations cannot be avoided, use `\"#EC NO_SELF_COMPARE`."
  },
  {
    "ruleId": "no-catch-reraise",
    "title": "Avoid CATCH Handlers That Only Re-raise the Caught Exception",
    "rationale": "Catching an exception only to immediately re-raise the identical exception type or object without logging, cleanup, or enrichment is redundant overhead. It increases call stack depth, obscures the point of failure, and bloats TRY...CATCH control structures. Either delete the unnecessary CATCH clause so the exception propagates naturally up the call stack, or wrap it in a meaningful domain exception using PREVIOUS.",
    "className": "/SKYL/CL_NO_CATCH_RERAISE",
    "pseudoComment": "NO_CATCH_RERAISE",
    "category": "anti-patterns",
    "example": {
      "bad": "TRY.\n    io_order_gateway->execute_payment( ).\n  CATCH cx_payment_processing_error INTO DATA(lx_error).\n    RAISE EXCEPTION lx_error.\nENDTRY.",
      "good": "TRY.\n    io_order_gateway->execute_payment( ).\n  CATCH cx_payment_processing_error INTO DATA(lx_error).\n    RAISE EXCEPTION NEW zcx_order_settlement_failed( previous = lx_error ).\nENDTRY."
    },
    "seo": {
      "description": "Identify redundant ABAP CATCH blocks that simply rethrow caught exceptions without adding logging or contextual wrapping.",
      "keywords": [
        "CATCH reraise",
        "ABAP exception handling",
        "Clean ABAP TRY CATCH",
        "SAP ATC check",
        "no-catch-reraise"
      ]
    },
    "relatedRules": [
      "no-catch-root",
      "no-exc-chain",
      "no-empty-block"
    ],
    "customSection": "### Handlers inspected\n\nA finding `NO_RETHROW` is reported when a `CATCH` clause contains exactly one statement that re-raises the caught instance or type without extra parameters:\n\n| Catch Block Content | Finding | Explanation |\n| --- | --- | --- |\n| `CATCH cx_error INTO lx. RAISE EXCEPTION lx.` | yes (`NO_RETHROW`) | Redundant rethrow without enrichment |\n| `CATCH cx_error. RAISE EXCEPTION TYPE cx_error.` | yes (`NO_RETHROW`) | Bare re-instantiation of caught type |\n| `CATCH cx_error INTO lx. RAISE EXCEPTION NEW zcx_domain( previous = lx ).` | no | Enriches context via chained exception |\n| `CATCH cx_error INTO lx. log_error( lx ). RAISE EXCEPTION lx.` | no | Performs intermediate logging |\n\n### Suppression\n\nTo retain an explicit rethrow block for debugging breakpoints, annotate the `RAISE` statement with `\"#EC NO_CATCH_RERAISE`."
  },
  {
    "ruleId": "pref-when-others",
    "title": "Require WHEN OTHERS as the Last Branch of Every CASE",
    "rationale": "A CASE without WHEN OTHERS silently does nothing when a new enum value, status or exception type appears, so the defect surfaces much later as a missing update or a stale record. A terminal WHEN OTHERS with RAISE EXCEPTION or a documented safe default makes the branching total and turns an unknown state into a loud, testable failure. Keeping it last matters as well: readers scan branches top-down and expect the fallback at the bottom instead of hidden between explicit cases.",
    "className": "/SKYL/CL_PREF_WHEN_OTHERS",
    "pseudoComment": "PREF_WHEN_OTHERS",
    "category": "clean-abap",
    "example": {
      "bad": "CASE ls_order-status.\n  WHEN c_status-open.\n    release_order( ).\n  WHEN c_status-blocked.\n    reject_order( ).\nENDCASE.",
      "good": "CASE ls_order-status.\n  WHEN c_status-open.\n    release_order( ).\n  WHEN c_status-blocked.\n    reject_order( ).\n  WHEN OTHERS.\n    RAISE EXCEPTION NEW zcx_illegal_order_status( ).\nENDCASE."
    },
    "parameters": {
      "MIN_BRANCHES": "Number of explicit WHEN branches a CASE needs before WHEN OTHERS becomes mandatory (default 2).",
      "REQUIRE_LAST": "Report a WHEN OTHERS branch that is not the final WHEN branch of its CASE (default enabled)."
    },
    "seo": {
      "description": "Enforce a WHEN OTHERS fallback as the last branch of ABAP CASE statements so unexpected statuses and enum values fail loudly instead of silently.",
      "keywords": [
        "ABAP CASE WHEN OTHERS",
        "CASE statement fallback",
        "ABAP status enum",
        "SAP ATC",
        "pref-when-others"
      ]
    },
    "relatedRules": [
      "pref-case",
      "no-single-when",
      "no-empty-block"
    ],
    "customSection": "### Findings and the quickfix\n\n| Finding | Raised on | Meaning |\n| --- | --- | --- |\n| `PREF_NO_WO` | the `CASE` statement | at least `MIN_BRANCHES` explicit `WHEN` branches but no `WHEN OTHERS` |\n| `PREF_WOPOS` | the offending `WHEN OTHERS` | `WHEN OTHERS` exists but further `WHEN` branches follow it |\n\nThe `ADD_WO` quickfix inserts `WHEN OTHERS.` directly before `ENDCASE`, indented to the `CASE` column. It deliberately does not invent error handling: add the `RAISE EXCEPTION` or the default assignment yourself.\n\n### Threshold and exceptions\n\n- `MIN_BRANCHES` (default `2`) protects small, obviously total CASE statements such as a two-value mapping. Set it to `1` to demand a fallback everywhere, or raise it for legacy code bases full of short CASE blocks.\n- `REQUIRE_LAST` (default on) only controls `PREF_WOPOS`; switch it off if your guideline merely requires the branch to exist.\n- Nested CASE statements are tracked with an explicit stack, so an inner `WHEN OTHERS` never satisfies the outer `CASE`.\n- Suppress a deliberate exhaustive CASE with `\"#EC PREF_WHEN_OTHERS` on the `CASE` statement."
  },
  {
    "ruleId": "no-exc-chain",
    "title": "Preserve Root Cause Exceptions in PREVIOUS Parameter",
    "rationale": "When converting a low-level technical exception into an application or business exception inside a CATCH block, omitting the PREVIOUS parameter discards the root cause exception and its stack trace. In ABAP Cloud and SAP S/4HANA RAP architectures, missing exception chains make root cause analysis in production telemetry and application logs extremely difficult. Chaining the caught exception preserves full diagnostic context.",
    "className": "/SKYL/CL_NO_EXC_CHAIN",
    "pseudoComment": "NO_EXC_CHAIN",
    "category": "anti-patterns",
    "example": {
      "bad": "TRY.\n    mo_payment_gateway->authorize_payment( ).\n  CATCH cx_http_communication_failure INTO DATA(lx_comm_err).\n    RAISE EXCEPTION NEW zcx_checkout_exception( ).\nENDTRY.",
      "good": "TRY.\n    mo_payment_gateway->authorize_payment( ).\n  CATCH cx_http_communication_failure INTO DATA(lx_comm_err).\n    RAISE EXCEPTION NEW zcx_checkout_exception( previous = lx_comm_err ).\nENDTRY."
    },
    "parameters": {
      "REQUIRE_PREVIOUS": "Enforce passing caught exceptions via PREVIOUS when raising new exceptions in CATCH handlers (default true)."
    },
    "seo": {
      "description": "Enforce PREVIOUS parameter chaining in ABAP exception handling to retain root cause error diagnostics in SAP ATC.",
      "keywords": [
        "ABAP exception chaining",
        "PREVIOUS parameter",
        "Clean ABAP exceptions",
        "SAP ATC check",
        "no-exc-chain"
      ]
    },
    "relatedRules": [
      "no-catch-reraise",
      "no-catch-root",
      "pref-class-exc"
    ],
    "customSection": "### Exception chaining and quickfixes\n\nThe check inspects `RAISE EXCEPTION NEW` and `RAISE EXCEPTION TYPE` statements inside `CATCH ... INTO <var>` blocks:\n\n| Statement in CATCH Block | Finding | Quickfix Available |\n| --- | --- | --- |\n| `RAISE EXCEPTION NEW zcx_err( ).` | yes (`NO_EXCCHN`) | yes (`ADD_PREV` appends `previous = lx_err`) |\n| `RAISE EXCEPTION TYPE zcx_err.` | yes (`NO_EXCCHN`) | yes (`ADD_PREV` adds `EXPORTING previous = lx_err`) |\n| `RAISE EXCEPTION NEW zcx_err( previous = lx_err ).` | no | none required |\n\n### Suppression\n\nIf an exception is deliberately sanitized to prevent leaking sensitive infrastructure details to callers, suppress with `\"#EC NO_EXC_CHAIN`."
  },
  {
    "ruleId": "pref-between",
    "title": "Use BETWEEN for Inclusive Range Checks",
    "rationale": "A condition like `amount >= min AND amount <= max` repeats the operand and hides one idea - an inclusive range - behind two comparisons that must stay symmetric; editing only one operator silently changes the semantics. BETWEEN states the range once, cannot be half-edited and removes the duplicated token that reviewers have to compare by eye. The check reports only genuine `>=`/`<=` pairs by default, because `>`/`<` is not equivalent for packed or fractional values.",
    "className": "/SKYL/CL_PREF_BETWEEN",
    "pseudoComment": "PREF_BETWEEN",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_amount >= lv_min_amount AND lv_amount <= lv_max_amount.\n  approve_payment( ).\nENDIF.",
      "good": "IF lv_amount BETWEEN lv_min_amount AND lv_max_amount.\n  approve_payment( ).\nENDIF."
    },
    "parameters": {
      "STRICT_RANGE": "Also report strict > / < pairs; keep disabled because BETWEEN is inclusive and strict ranges are not equivalent for decimals (default disabled)."
    },
    "seo": {
      "description": "Simplify ABAP range checks from duplicated comparisons to the readable BETWEEN operator and avoid off-by-one mistakes in ATC-reviewed code.",
      "keywords": [
        "ABAP BETWEEN operator",
        "range check ABAP",
        "Clean ABAP condition",
        "SAP ATC",
        "pref-between"
      ]
    },
    "relatedRules": [
      "max-bool-expr",
      "no-many-parens",
      "no-dup-cond"
    ],
    "customSection": "### Recognised range shapes\n\n`PREF_BETWN` is raised when exactly one `AND` at parenthesis depth zero joins two comparisons whose operands form a range:\n\n| Shape | Example |\n| --- | --- |\n| same operand on the left | `lv_amount >= lv_min AND lv_amount <= lv_max` |\n| same operand on the right | `lv_min <= lv_amount AND lv_max >= lv_amount` |\n| chained on the left operand | `lv_min <= lv_amount AND lv_amount <= lv_max` |\n| mirrored | `lv_amount >= lv_min AND lv_max >= lv_amount` |\n\nOuter parentheses are stripped, so `IF ( lv_amount >= lv_min ) AND ( lv_amount <= lv_max ).` is recognised too. The `USE_BTWN` quickfix rewrites the complete `IF`, `ELSEIF`, `WHILE` or `CHECK` line as `<keyword> <operand> BETWEEN <low> AND <high>.`\n\n### Deliberately not reported\n\n- `OR` conditions, negations, and statements with more than one `AND` on the same level.\n- Different operands, for example `lv_amount >= lv_min AND lv_quantity <= lv_max`.\n- Statements with fewer than eight tokens, typically a single comparison.\n- Strict `>` / `<` pairs unless `STRICT_RANGE` is enabled - and even then the suggestion is only a hint, because `BETWEEN` is inclusive on both ends.\n\nOnly swap when the original condition really includes its bounds; otherwise keep the explicit comparisons and add `\"#EC PREF_BETWEEN`."
  },
  {
    "ruleId": "no-loop-into",
    "title": "Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets",
    "rationale": "The LOOP AT itab INTO wa statement copies every single row of an internal table into a local work area structure upon each iteration. For wide structures, nested components, or tables containing thousands of entries, this repetitive row-by-row memory copy generates significant CPU memory bus traffic and cache misses. In Clean ABAP and ABAP Cloud, iterating with `ASSIGNING FIELD-SYMBOL(<ls_row>)` binds a direct reference pointer to the table line in memory (O(1) zero-copy iteration). Alternatively, `REFERENCE INTO DATA(lo_row)` should be used when data references are explicitly required.",
    "className": "/SKYL/CL_NO_LOOP_INTO",
    "pseudoComment": "NO_LOOP_INTO",
    "category": "performance",
    "example": {
      "bad": "DATA lv_total_amount TYPE p DECIMALS 2.\n\nLOOP AT lt_order_items INTO DATA(ls_item).\n  lv_total_amount = lv_total_amount + ls_item-net_amount.\nENDLOOP.",
      "good": "DATA lv_total_amount TYPE p DECIMALS 2.\n\nLOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_item>).\n  lv_total_amount = lv_total_amount + <ls_item>-net_amount.\nENDLOOP."
    },
    "seo": {
      "description": "Eliminate row-by-row memory copies in ABAP loops by replacing LOOP AT INTO with ASSIGNING field symbols for zero-copy performance.",
      "keywords": [
        "no-loop-into",
        "LOOP AT ASSIGNING",
        "field symbols",
        "Clean ABAP loops",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-mod-loop-tab",
      "pref-read-table",
      "no-concat-loop"
    ],
    "customSection": "### Detection Details\n\nThe check evaluates `LOOP` statements. Finding code `NO_LOOPIN` is reported when `AT` and `INTO` are present without an `ASSIGNING` or `REFERENCE` target.\n\n### Scope and Design\n\n- Single row lookups via `READ TABLE ... INTO` are intentionally excluded from this check and handled by rule `pref-read-table` to avoid redundant findings.\n- Using `ASSIGNING FIELD-SYMBOL(<ls_row>)` allows modifying fields in place without requiring an explicit `MODIFY` statement.\n- When data references are needed for polymorphism or generic processing, use `LOOP AT itab REFERENCE INTO DATA(lr_row)`.\n\nSuppress legacy copy loops with the pseudo comment `\"#EC NO_LOOP_INTO`."
  },
  {
    "ruleId": "max-cognitive",
    "title": "Enforce Cognitive Complexity Thresholds per Procedure",
    "rationale": "Cognitive complexity measures the mental effort required for a human developer to understand and reason about control flow. Unlike classic cyclomatic complexity, which treats every decision branch identically, cognitive complexity heavily penalizes nesting: an IF or LOOP located three levels deep incurs an exponential mental penalty. High cognitive complexity in SAP S/4HANA core business methods leads directly to defect hotspots, regression risks, and unmaintainable legacy code. Refactoring deeply nested control structures into flat guard clauses and decomposed private methods preserves Clean Core agility.",
    "className": "/SKYL/CL_MAX_COGNITIVE",
    "pseudoComment": "MAX_COGNITIVE",
    "category": "metrics",
    "example": {
      "bad": "LOOP AT lt_invoices ASSIGNING FIELD-SYMBOL(<ls_invoice>).\n  IF <ls_invoice>-is_posted = abap_false.\n    IF <ls_invoice>-currency = 'EUR' AND <ls_invoice>-total_amount > 1000.\n      LOOP AT <ls_invoice>-items ASSIGNING FIELD-SYMBOL(<ls_item>).\n        IF <ls_item>-tax_rate > 0.\n          apply_tax_adjustment( <ls_item> ).\n        ENDIF.\n      ENDLOOP.\n    ENDIF.\n  ENDIF.\nENDLOOP.",
      "good": "LOOP AT lt_invoices ASSIGNING FIELD-SYMBOL(<ls_invoice>).\n  IF <ls_invoice>-is_posted = abap_true OR <ls_invoice>-currency <> 'EUR'.\n    CONTINUE.\n  ENDIF.\n\n  process_single_invoice( <ls_invoice> ).\nENDLOOP."
    },
    "parameters": {
      "MAX_COGNITIVE": "Maximum allowable cognitive complexity score per procedure based on nesting penalties and logical operators (default: 15)."
    },
    "seo": {
      "description": "Measure and constrain cognitive complexity in ABAP methods to prevent deeply nested control flow and unreadable logic in SAP ATC.",
      "keywords": [
        "max-cognitive",
        "cognitive complexity ABAP",
        "nesting penalty",
        "Sonar S3776 ABAP",
        "Clean ABAP metrics"
      ]
    },
    "relatedRules": [
      "max-cyclo-comp",
      "max-nesting",
      "max-bool-expr"
    ],
    "customSection": "## Scoring Rules\n\nThe cognitive complexity algorithm evaluates procedures using depth-weighted increments:\n\n- **Nesting Increases**: Statements `IF`, `LOOP`, `DO`, `WHILE`, and `CASE` add `1 + current_depth` to the score and increase nesting depth by 1.\n- **Branch Continuations**: Statements `ELSEIF`, `ELSE`, `WHEN`, and `CATCH` add `1 + current_depth` to the score without increasing depth.\n- **Nesting Reductions**: Closing statements `ENDIF`, `ENDLOOP`, `ENDDO`, `ENDWHILE`, and `ENDCASE` decrease the nesting depth by 1.\n- **Logical Operators**: Any statement with unparenthesized `AND` or `OR` (excluding `BETWEEN ... AND ...`) incurs an additional `+1` penalty.\n- **Threshold**: When the accumulated score exceeds `MAX_COGNITIVE` (default `15`), finding `MAX_COGNIT` is reported on the opening procedure statement.\n\n## Suppression\n\nSuppress the rule with the pseudo-comment `\"#EC MAX_COGNITIVE` placed on the `METHOD` statement."
  },
  {
    "ruleId": "max-locals",
    "title": "Limit Local Variable and Field-Symbol Declarations",
    "rationale": "A procedure declaring dozens of local variables and field symbols invariably indicates an overloaded method with multiple conflicting responsibilities. Tracking extensive mutable state inside a single method increases the cognitive load of code reviews, leads to unintended side effects from variable reuse, and complicates unit test isolation. Clean ABAP recommends keeping methods focused on a single task with minimal local state. Excess declarations should be refactored by introducing cohesive parameter structures, dedicated value objects, or by delegating distinct subtasks to helper methods.",
    "className": "/SKYL/CL_MAX_LOCALS",
    "pseudoComment": "MAX_LOCALS",
    "category": "metrics",
    "example": {
      "bad": "DATA lv_net_amount TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_tax_amount TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_discount_rate TYPE p LENGTH 4 DECIMALS 2.\nDATA lv_discount_amount TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_freight_charges TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_customs_duty TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_handling_fee TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_insurance_fee TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_surcharge_amount TYPE p LENGTH 8 DECIMALS 2.\nDATA lv_currency_code TYPE c LENGTH 3.\nDATA lv_exchange_rate TYPE p LENGTH 6 DECIMALS 4.\nDATA lv_customer_id TYPE c LENGTH 10.\nDATA lv_billing_date TYPE d.\nDATA lv_payment_terms TYPE c LENGTH 4.\nDATA lv_is_tax_exempt TYPE abap_bool.\ncalculate_totals( ).",
      "good": "DATA ls_financial_summary TYPE ty_financial_summary.\nDATA ls_customer_context  TYPE ty_customer_context.\n\nls_financial_summary = calculate_financials( ls_customer_context ).\npersist_billing_summary( ls_financial_summary )."
    },
    "parameters": {
      "MAX_LOCALS": "Maximum allowed number of local data, field-symbol, and inline declarations per procedure (default: 15)."
    },
    "seo": {
      "description": "Limit the number of local variable and inline declarations per ABAP method to reduce mutable state and enforce Clean ABAP modularity.",
      "keywords": [
        "max-locals",
        "local variable limit ABAP",
        "Clean ABAP state",
        "inline declaration count",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "no-unused-vars",
      "max-attributes",
      "max-method-len"
    ],
    "customSection": "## Evaluation Criteria\n\nThe check inspects the procedure body and counts local symbols as follows:\n\n- **Explicit Declarations**: Each statement with keyword `DATA` or `FIELD-SYMBOLS` increments the count by 1. Note that colon-chained declarations are normalized by the parser into individual statements.\n- **Inline Declarations**: Any inline declarations (`DATA(...)` and `FIELD-SYMBOL(...)`) inside other statements (such as `SELECT`, `LOOP AT`, `READ TABLE`, or method calls) are counted via AST inspection.\n- **Excluded Statements**: `CONSTANTS`, `STATICS`, and `TYPES` statements do not count towards the local declaration limit unless they contain inline declarations.\n- **Reporting**: When the total count exceeds `MAX_LOCALS` (default `15`), finding `MAX_LOCALS` is reported on the opening procedure statement.\n\n## Suppression\n\nSuppress the finding with the pseudo-comment `\"#EC MAX_LOCALS` on the opening `METHOD` statement."
  },
  {
    "ruleId": "max-fanout",
    "title": "Limit Distinct Class and Interface Coupling per Procedure",
    "rationale": "Coupling fan-out measures the number of distinct external classes and interfaces that a single procedure depends on. Referencing more than 15 distinct collaborator types signals a God method or over-centralized mediator that is tightly coupled to wide swaths of the system architecture. Such excessive coupling makes unit testing almost impossible, as setting up test doubles and mocks for 15+ collaborators is brittle and labor-intensive. In Clean ABAP and modern SAP enterprise design, procedures with high fan-out should be decomposed using design patterns like Facade, Mediator, or Domain Services.",
    "className": "/SKYL/CL_MAX_FANOUT",
    "pseudoComment": "MAX_FANOUT",
    "category": "metrics",
    "example": {
      "bad": "DATA lo_cust_svc TYPE REF TO zcl_customer_service.\nDATA lo_inv_svc  TYPE REF TO zcl_invoice_service.\nDATA lo_tax_svc  TYPE REF TO zcl_tax_calculation_svc.\nDATA lo_pay_svc  TYPE REF TO zcl_payment_gateway_svc.\nDATA lo_gl_svc   TYPE REF TO zcl_general_ledger_svc.\nDATA lo_ar_svc   TYPE REF TO zcl_accounts_receivable.\nDATA lo_fx_svc   TYPE REF TO zcl_foreign_exchange_svc.\nDATA lo_disc_svc TYPE REF TO zcl_discount_engine.\nDATA lo_notif    TYPE REF TO zcl_notification_service.\nDATA lo_audit    TYPE REF TO zcl_compliance_audit_svc.\nDATA lo_archive  TYPE REF TO zcl_document_archive_svc.\nDATA lo_workflow TYPE REF TO zcl_approval_workflow.\nDATA lo_credit   TYPE REF TO zcl_credit_check_engine.\nDATA lo_shipment TYPE REF TO zcl_shipment_tracking_svc.\nDATA lo_pricing  TYPE REF TO zcl_pricing_condition_svc.\nDATA lo_partner  TYPE REF TO zcl_business_partner_mgr.\nexecute_settlement( ).",
      "good": "DATA lo_settlement_facade TYPE REF TO zif_settlement_facade.\n\nlo_settlement_facade = mo_facade_factory->get_settlement_facade( ).\nlo_settlement_facade->execute_full_settlement( is_settlement_context )."
    },
    "parameters": {
      "MAX_FANOUT": "Maximum allowed number of distinct collaborator classes or interfaces referenced by a single procedure (default: 15)."
    },
    "seo": {
      "description": "Limit architectural class and interface fan-out coupling per ABAP procedure to keep unit tests maintainable and services decoupled.",
      "keywords": [
        "max-fanout",
        "coupling fan-out ABAP",
        "class dependencies metric",
        "Clean ABAP architecture",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "max-inherit",
      "max-attributes",
      "max-method-len"
    ],
    "customSection": "## Analysis and RTTI Mechanics\n\nThe check analyzes compiler references attached to each statement in the procedure body:\n\n- **Type Resolution**: Inspects compiler references of kind `type` and `method` and resolves them via ABAP RTTI (`cl_abap_objectdescr`).\n- **Unique Counting**: Deduplicates referenced classes and interfaces by their relative object name into a hashed set.\n- **Local Execution Only**: Because this rule utilizes ABAP Run-Time Type Identification (RTTI) to resolve class descriptors, `remote_enablement = abap_false` is enforced. This check runs locally on the SAP ATC system.\n- **Reporting**: If the number of distinct object types exceeds `MAX_FANOUT` (default `15`), finding `MAX_FANOUT` is reported on the first procedure statement.\n\n## Suppression\n\nSuppress the check with the pseudo-comment `\"#EC MAX_FANOUT` on the opening `METHOD` statement."
  },
  {
    "ruleId": "no-bool-blindness",
    "title": "Replace Boolean Importing Parameters with Explicit APIs",
    "rationale": "An abap_bool IMPORTING parameter turns a call into a positional switch: `save_order( abap_true )` tells the reader nothing and reviewers must open the signature to learn what `true` does. It also grows into a parameter zoo - send_mail, skip_validation, commit - where every new variation edits the same method and every caller re-tests all combinations. Separate, well-named methods or a small typed mode keep each behaviour testable in isolation and make the call site self-documenting.",
    "className": "/SKYL/CL_NO_BOOL_BLINDNESS",
    "pseudoComment": "NO_BOOL_BLINDNESS",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_order_service DEFINITION.\n  PUBLIC SECTION.\n    METHODS save_order\n      IMPORTING send_confirmation TYPE abap_bool.\nENDCLASS.",
      "good": "CLASS lcl_order_service DEFINITION.\n  PUBLIC SECTION.\n    METHODS save_order.\n    METHODS save_and_confirm_order.\nENDCLASS."
    },
    "seo": {
      "description": "Detect boolean flag IMPORTING parameters in ABAP method signatures and replace boolean blindness with dedicated, self-explanatory APIs.",
      "keywords": [
        "ABAP boolean parameter",
        "boolean blindness",
        "Clean ABAP method signature",
        "SAP ATC",
        "no-bool-blindness"
      ]
    },
    "relatedRules": [
      "pref-pred-name",
      "no-bool-compare",
      "max-params"
    ],
    "customSection": "### What the check inspects\n\nOnly `METHODS` / `CLASS-METHODS` declarations inside class and interface definitions are inspected. `NO_BOOL_BL` is raised once per declaration when at least one `IMPORTING` parameter is typed `abap_bool`:\n\n| Signature element | Reported |\n| --- | --- |\n| `IMPORTING iv_flag TYPE abap_bool` | yes |\n| `IMPORTING iv_flag TYPE abap_bool DEFAULT abap_true` | yes |\n| `EXPORTING ev_active TYPE abap_bool` | no |\n| `RETURNING VALUE(rv_ok) TYPE abap_bool` | no |\n| `CHANGING cv_flag TYPE abap_bool` | no |\n| `IMPORTING iv_mode TYPE ty_dispatch_mode` (enum) | no |\n\n### Acceptable alternatives\n\n- **Two methods**: `save_order( )` and `save_and_confirm_order( )` - the usual Clean ABAP answer.\n- **Typed flag**: a DDIC domain, enum or constants interface with meaningful values, so the call reads `process( mode = dispatch_immediately )` instead of `process( abap_true )`.\n- **Collaborator**: move the optional behaviour into an injected service, which also keeps the method unit-testable.\n\nBoolean `EXPORTING` and `RETURNING` values are fine because they are results, not switches. A wrapper around a legacy API that cannot change its signature can be suppressed with `\"#EC NO_BOOL_BLINDNESS` on the `METHODS` statement."
  },
  {
    "ruleId": "no-static-state",
    "title": "Avoid Mutable Static State via CLASS-DATA and STATICS",
    "rationale": "Static state defined with CLASS-DATA or STATICS persists across procedure executions for the entire user session, coupling unrelated processes and introducing non-deterministic failures in unit tests. Hidden global state breaks idempotence and concurrency guarantees in ABAP Cloud stateless runtime containers. State should reside within instance attributes or be transferred explicitly via method parameters.",
    "className": "/SKYL/CL_NO_STATIC_STATE",
    "pseudoComment": "NO_STATIC_STATE",
    "category": "anti-patterns",
    "example": {
      "bad": "STATICS sv_invoice_counter TYPE i.\nsv_invoice_counter = sv_invoice_counter + 1.",
      "good": "DATA lv_invoice_counter TYPE i.\nlv_invoice_counter = lv_invoice_counter + 1."
    },
    "parameters": {
      "CHECK_CLASS_DATA": "Flag CLASS-DATA declarations in class definitions to prevent static class-level memory state (default true).",
      "CHECK_STATICS": "Flag STATICS variable declarations inside methods, forms, and function modules (default true)."
    },
    "seo": {
      "description": "Detect mutable CLASS-DATA and STATICS in ABAP to prevent hidden session state and unit test interference.",
      "keywords": [
        "ABAP STATICS",
        "CLASS-DATA",
        "global state anti-pattern",
        "Clean ABAP",
        "SAP ATC check",
        "no-static-state"
      ]
    },
    "relatedRules": [
      "no-static-arrow",
      "pref-name-members",
      "max-attributes"
    ],
    "customSection": "### Scanned declarations\n\nThe check monitors static memory declarations across compilation units:\n\n| Statement | Scope | Governed By Parameter |\n| --- | --- | --- |\n| `CLASS-DATA` | Class definitions | `CHECK_CLASS_DATA` (default: `abap_true`) |\n| `STATICS` | Methods, function modules, and form routines | `CHECK_STATICS` (default: `abap_true`) |\n\n### Testability & Session Safety\n\nIn modern ABAP Cloud systems, internal sessions can be reused across service calls or test executions. Retaining mutable variables in static memory leads to cross-test contamination and race conditions in multi-threaded ABAP environments. Use dependency injection and instance member attributes instead.\n\n### Suppression\n\nLegitimate performance caches or singleton registries can be suppressed with `\"#EC NO_STATIC_STATE`."
  },
  {
    "ruleId": "no-dummy-auth",
    "title": "Avoid DUMMY Addition in AUTHORITY-CHECK Statements",
    "rationale": "The DUMMY addition in an AUTHORITY-CHECK statement bypasses authorization verification for the designated authorization field, causing the SAP kernel to accept the check without verifying the user's role assignment against that field. Developers sometimes insert DUMMY as a temporary workaround during local development or to satisfy rudimentary static security scans without implementing real access control, leaving sensitive business operations exposed to unauthorized users (OWASP Top 10 A01: Broken Access Control). Clean ABAP and SAP ATC security guidelines require supplying valid authorization field values using the FIELD addition and verifying sy-subrc immediately.",
    "className": "/SKYL/CL_NO_DUMMY_AUTH",
    "pseudoComment": "NO_DUMMY_AUTH",
    "category": "security",
    "example": {
      "bad": "AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'\n  ID 'BUKRS' DUMMY\n  ID 'ACTVT' FIELD '03'.",
      "good": "AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'\n  ID 'BUKRS' FIELD lv_company_code\n  ID 'ACTVT' FIELD '03'.\n\nIF sy-subrc <> 0.\n  RAISE EXCEPTION NEW zcx_auth_failure( ).\nENDIF."
    },
    "seo": {
      "description": "Detect AUTHORITY-CHECK statements using the DUMMY addition in ABAP to prevent authorization check bypasses and access control vulnerabilities.",
      "keywords": [
        "no-dummy-auth",
        "AUTHORITY-CHECK DUMMY",
        "ABAP Authorization Security",
        "Broken Access Control",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "pref-auth-subrc",
      "pref-auth-check",
      "no-dynamic-stmt"
    ],
    "customSection": "## Security Risk of DUMMY Field Checks\n\nIn ABAP authorization checks, `ID <field> DUMMY` informs the kernel that the authorization field should be ignored during evaluation:\n\n| AUTHORITY-CHECK Construct | Kernel Evaluation Behavior | Security Status |\n|---|---|---|\n| `ID <field> DUMMY` | Authorization field is completely ignored; any user passes | Insecure (Broken Access Control) |\n| `ID <field> FIELD lv_val` | Verified against user profile / authorization role | Secure (Enforced access control) |\n| `OBJECT 'DUMMY'` | Evaluates authorization object named `DUMMY` | Permitted (string literal name) |\n\nThe check scans `AUTHORITY-CHECK OBJECT` statements and flags any occurrence of the `DUMMY` keyword. Literal strings (such as authorization object names) are not flagged. Suppress approved exceptions with `\"#EC NO_DUMMY_AUTH` or `##NO_DUMMY_AUTH`."
  },
  {
    "ruleId": "no-dead-store",
    "title": "Avoid Overwriting Variable Values Before They Are Read",
    "rationale": "Assigning a value to a variable and then immediately overwriting it without an intervening read operation constitutes a dead store. Dead stores waste computation and memory bandwidth, but more critically, they often conceal logic flaws where an intermediate calculation or validation check was accidentally bypassed during code refactoring. Remove the redundant assignment or read the variable.",
    "className": "/SKYL/CL_NO_DEAD_STORE",
    "pseudoComment": "NO_DEAD_STORE",
    "category": "anti-patterns",
    "example": {
      "bad": "DATA lv_order_status TYPE string.\nlv_order_status = 'PENDING'.\nlv_order_status = 'CONFIRMED'.\nlog_order_status( lv_order_status ).",
      "good": "DATA lv_order_status TYPE string.\nlv_order_status = 'CONFIRMED'.\nlog_order_status( lv_order_status )."
    },
    "seo": {
      "description": "Identify ABAP dead stores where variables are overwritten before being read, revealing dead code and refactoring bugs.",
      "keywords": [
        "ABAP dead store",
        "overwritten assignment",
        "unused assignment",
        "Clean ABAP",
        "SAP ATC check",
        "no-dead-store"
      ]
    },
    "relatedRules": [
      "no-unused-vars",
      "no-dead-code",
      "pref-final-data"
    ],
    "customSection": "### Detection logic\n\nThe check inspects assignment statements (`COMPUTE` and legacy `MOVE`) for local variables:\n1. An assignment sets a pending store state on a variable.\n2. A subsequent write before any read marks the first assignment as a dead store (`NO_DEAD_ST`).\n3. Intervening block boundaries (`IF`, `CASE`, `LOOP`, `TRY`) and conditional writes (`SELECT`, `READ TABLE`) reset pending stores to prevent false positives across branches.\n4. If a variable is never read anywhere in the procedure, this check leaves it to `no-unused-vars`.\n\n| Sequence | Result |\n| --- | --- |\n| `val = 1. val = 2. log( val ).` | First assignment flagged (`NO_DEAD_ST`) |\n| `val = 1. log( val ). val = 2. log( val ).` | Compliant (read between assignments) |\n| `val = 1. IF flag = abap_true. val = 2. ENDIF.` | Compliant (branch boundary resets pending store) |\n\n### Suppression\n\nIf an initial assignment is required by an external macro or interface, annotate with `\"#EC NO_DEAD_STORE`."
  },
  {
    "ruleId": "no-wrong-wildcard",
    "title": "Use Appropriate Wildcards for LIKE and CP/NP Comparisons",
    "rationale": "SQL pattern matching with LIKE uses standard SQL wildcards (% for multi-character sequences, _ for single characters), whereas ABAP logical comparisons with CP (Contains Pattern) and NP use ABAP wildcards (* and +). Interchanging them causes patterns to treat wildcards as literal characters, leading to silent query failures, unexpected empty result sets, or incorrect filtering logic in business workflows.",
    "className": "/SKYL/CL_NO_WRONG_WILDCARD",
    "pseudoComment": "NO_WRONG_WILDCARD",
    "category": "anti-patterns",
    "example": {
      "bad": "SELECT SINGLE customer_id FROM zcustomers\n  WHERE customer_id LIKE '*DE*'\n  INTO @DATA(lv_customer).\nIF lv_company_code CP 'US%'.\n  apply_domestic_rules( ).\nENDIF.",
      "good": "SELECT SINGLE customer_id FROM zcustomers\n  WHERE customer_id LIKE '%DE%'\n  INTO @DATA(lv_customer).\nIF lv_company_code CP 'US*'.\n  apply_domestic_rules( ).\nENDIF."
    },
    "parameters": {
      "CHECK_LIKE": "Detect invalid wildcard usage such as asterisk (*) in SQL LIKE string comparisons (default true).",
      "CHECK_CP": "Detect invalid wildcard usage such as percent (%) in ABAP CP and NP pattern comparisons (default true)."
    },
    "seo": {
      "description": "Ensure correct wildcards in ABAP: enforce % and _ in SQL LIKE, and * and + in ABAP CP and NP comparisons.",
      "keywords": [
        "ABAP LIKE wildcard",
        "CP operator ABAP",
        "SQL wildcards",
        "Clean ABAP",
        "SAP ATC check",
        "no-wrong-wildcard"
      ]
    },
    "relatedRules": [
      "pref-between",
      "no-dup-literals"
    ],
    "customSection": "### Wildcard conventions reference\n\nABAP distinguishes between Open SQL / ABAP SQL pattern syntax and internal ABAP character comparisons:\n\n| Comparison Operator | Wildcard (Multi-char) | Wildcard (Single-char) | Finding on Misuse |\n| --- | --- | --- | --- |\n| `LIKE` (SQL / string) | `%` | `_` | `NO_LIKE_WL` when `*` is used |\n| `CP` (Contains Pattern) | `*` | `+` | `NO_CP_WILD` when `%` is used |\n| `NP` (No Pattern) | `*` | `+` | `NO_CP_WILD` when `%` is used |\n\n### Suppression\n\nWhen querying literal percent signs in CP (escaped via `#%`) or literal asterisks in LIKE, suppress with `\"#EC NO_WRONG_WILDCARD`."
  },
  {
    "ruleId": "pref-sort-order",
    "title": "Specify ASCENDING or DESCENDING on Every Sort Key",
    "rationale": "`SORT lt_orders BY customer_id order_date.` silently falls back to the implicit ascending order, and a later edit that adds a descending key mixes explicit and implicit directions in one statement - the classic source of a mysteriously ordered list. Writing the direction for every key, or one direction before BY, makes the intent explicit, stable and reviewable. The check can additionally demand an explicit order for plain table sorts that omit BY entirely.",
    "className": "/SKYL/CL_PREF_SORT_ORDER",
    "pseudoComment": "PREF_SORT_ORDER",
    "category": "clean-abap",
    "example": {
      "bad": "SORT lt_orders BY customer_id order_date.",
      "good": "SORT lt_orders BY customer_id ASCENDING order_date DESCENDING."
    },
    "parameters": {
      "CHECK_BY_ONLY": "Only require an explicit direction when the BY addition is used; set to false to also report plain SORT lt_orders. (default enabled)."
    },
    "seo": {
      "description": "Require explicit ASCENDING or DESCENDING on ABAP SORT keys to remove implicit ordering and stabilise multi-key internal table sorts in ATC.",
      "keywords": [
        "ABAP SORT ASCENDING DESCENDING",
        "SORT BY internal table",
        "implicit sort order ABAP",
        "SAP ATC",
        "pref-sort-order"
      ]
    },
    "relatedRules": [
      "no-mod-loop-tab",
      "no-obs-control"
    ],
    "customSection": "### What counts as explicit\n\n| Statement | Result |\n| --- | --- |\n| `SORT lt_orders BY customer_id order_date.` | `PREF_SORT` - the second key falls back to the implicit order |\n| `SORT lt_orders BY customer_id ASCENDING order_date DESCENDING.` | ok - every key has a direction |\n| `SORT lt_orders DESCENDING BY customer_id order_date.` | ok - the direction before `BY` applies to all keys |\n| `SORT lt_orders BY field1 AS TEXT ASCENDING field2 DESCENDING.` | ok - `AS TEXT` is a modifier, not a key |\n| `SORT lt_orders BY (lv_dynamic_field).` | ok - dynamic keys are not evaluated |\n| `SORT lt_orders.` | reported only when `CHECK_BY_ONLY` is off |\n\nThe check reports the whole `SORT` statement once, on the first key it finds without a direction, so a statement with several unspecified keys produces a single finding.\n\n### Tuning\n\nOnly ascending order is implicit in ABAP, so the default configuration (`CHECK_BY_ONLY = abap_true`) targets the real risk: mixed or missing directions after `BY`. Setting `CHECK_BY_ONLY = abap_false` additionally reports `SORT lt_orders.`; that is stricter than the Clean ABAP baseline and usually only worth enabling for new code. Suppress an intentionally stable sort (an itab that is already sorted and may be re-sorted cheaply) with `\"#EC PREF_SORT_ORDER`."
  },
  {
    "ruleId": "pref-icon-const",
    "title": "Use ICON Constants Instead of Hardcoded @xx@ Icon Codes",
    "rationale": "A literal such as `'@01@'` is an undocumented magic value: nobody can tell whether it means a green light, a printer or a warning, and the code silently shows the wrong glyph once the icon set or the UI technology changes. The icon type pool exposes readable constants - `icon_led_green`, `icon_cancel`, `icon_okay` - that name the glyph, can be searched and are documented in the system. The check flags every literal token of the icon-code shape inside a procedure, including literals used in `VALUE` additions and in `CONSTANTS`.",
    "className": "/SKYL/CL_PREF_ICON_CONST",
    "pseudoComment": "PREF_ICON_CONST",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_status_icon TYPE c LENGTH 4.\nlv_status_icon = '@01@'.",
      "good": "DATA lv_status_icon TYPE c LENGTH 4.\nlv_status_icon = icon_led_green."
    },
    "seo": {
      "description": "Replace hardcoded @xx@ ABAP icon literals with readable icon_* constants from the ICON type pool and remove magic strings from ALV and UI code.",
      "keywords": [
        "ABAP icon constants",
        "ICON type pool",
        "@01@ icon code",
        "SAP ATC",
        "pref-icon-const"
      ]
    },
    "relatedRules": [
      "no-magic-numbers",
      "no-dup-literals"
    ],
    "customSection": "### Detection logic\n\n`PREF_ICON` is raised per token when the token is a literal of exactly six characters (quotes included) whose content matches `@++@`, that is a four-character icon code wrapped in `@`: `'@01@'`, `'@BZ@'`, `'@5B@'` or the backtick equivalents.\n\n| Token | Reported |\n| --- | --- |\n| `'@01@'` | yes |\n| `` `@5B@` `` | yes |\n| `'OKAY'` | no - content does not match `@++@` |\n| `'email@test.com'` | no - wrong length |\n| longer ALV icon names that embed text (for example `'@01\\QSystem\\Q@'`) | no - the token is longer than six characters |\n| `icon_led_green` | no - not a literal |\n\nBoth declaration positions (`DATA ... VALUE '@01@'`) and usage positions (`lv_icon = '@01@'`) are inspected, and a constant that stores the raw code is reported as well - point the constant at the icon constant instead.\n\n### Which constant to use\n\nPick the constant that documents the glyph, not the one with the same number as in a screenshot: the mapping between `@nn@` codes and `icon_*` names differs between releases. The icon type pool (`SE11` type pool `ICON`, or report `RSCPICON`) lists the valid names for your system.\n\nOn ABAP Cloud, `TYPE-POOLS` is not available, so centralise the icons you need in a constants interface (for example `zif_ui_icons=>status_okay`) and reference that. The rule accepts any non-literal token, so such a constant is compliant. Suppress unavoidable raw codes from an external interface with `\"#EC PREF_ICON_CONST`."
  },
  {
    "ruleId": "no-ambiguous-stmt",
    "title": "Make MODIFY, DELETE, INSERT and UPDATE Unambiguous for Itab and Database",
    "rationale": "A statement like `MODIFY lt_order_items FROM ls_order_item.` can update an internal table or an ABAP SQL table, and the compiler decides from the target's type - information that is invisible at the call site and easy to break when a variable shadows a DDIC table. The explicit forms (`MODIFY TABLE ...` or `MODIFY zorder FROM @ls_order`) state the intent for the reader and keep the statement stable when tables are renamed. The rule also reports the shorthand forms without a visible target, which are ambiguous by construction.",
    "className": "/SKYL/CL_NO_AMBIGUOUS_STMT",
    "pseudoComment": "NO_AMBIGUOUS_STMT",
    "category": "clean-abap",
    "example": {
      "bad": "MODIFY lt_order_items FROM ls_order_item.",
      "good": "MODIFY TABLE lt_order_items FROM ls_order_item."
    },
    "seo": {
      "description": "Disambiguate ABAP MODIFY, DELETE, INSERT and UPDATE between internal tables and ABAP SQL by requiring the TABLE keyword or @ host escapes in ATC.",
      "keywords": [
        "ABAP MODIFY TABLE",
        "ambiguous ABAP statement",
        "ABAP SQL @ escape",
        "SAP ATC",
        "no-ambiguous-stmt"
      ]
    },
    "relatedRules": [
      "pref-strict-sql",
      "no-db-in-loop"
    ],
    "customSection": "### Ambiguous versus explicit forms\n\n| Ambiguous | Why it is ambiguous | Explicit form |\n| --- | --- | --- |\n| `MODIFY lt_items FROM ls_item.` | itab line update or SQL update? | `MODIFY TABLE lt_items FROM ls_item.` |\n| `DELETE lt_items FROM ls_item.` | itab delete or SQL delete? | `DELETE TABLE lt_items FROM ls_item.` or `DELETE lt_items INDEX 1.` |\n| `DELETE lt_items.` | clears an itab but looks like SQL | `DELETE TABLE lt_items.` |\n| `MODIFY zorder FROM ls_order.` | SQL without an escaped host variable | `MODIFY zorder FROM @ls_order.` |\n\nThe following are accepted without a finding:\n\n- any statement that already contains `TABLE`;\n- `DELETE ... INDEX`, `DELETE ... ADJACENT` and `MODIFY ... INDEX`;\n- SQL `DELETE FROM zorder WHERE ...`;\n- SQL statements whose source work area is escaped with `@`, e.g. `INSERT zorder FROM @ls_order` or `UPDATE zorder FROM @ls_order`.\n\n`INSERT` and `UPDATE` are also reported when the statement consists of nothing but the keyword and a target, because no `TABLE` keyword and no escaped host variable identify the table kind.\n\n### Remote readiness\n\nThe check is purely token based and uses no RTTI, so it also runs in remote ATC scenarios."
  },
  {
    "ruleId": "no-empty-proc",
    "title": "Remove Empty Methods, Forms and Function Modules",
    "rationale": "An empty method or FORM is dead API surface: callers cannot tell whether it is a forgotten implementation, an intentional hook or a leftover from a refactor, and reviewers and coverage reports waste time on it. Empty procedures also let an interface contract be fulfilled without any behaviour, which hides a missing feature behind a green build. The check reports procedures whose body holds nothing but the header and footer, so the fix is either to implement the logic or to delete the declaration and its callers.",
    "className": "/SKYL/CL_NO_EMPTY_PROC",
    "pseudoComment": "NO_EMPTY_PROC",
    "category": "clean-abap",
    "example": {
      "bad": "METHOD refresh_pricing_cache.\nENDMETHOD.",
      "good": "METHOD refresh_pricing_cache.\n  DATA(pricing_entries) = read_pricing_from_database( ).\n  cache_pricing_entries( pricing_entries ).\nENDMETHOD."
    },
    "parameters": {
      "CHECK_METHODS": "Report METHOD ... ENDMETHOD blocks with an empty body (default enabled).",
      "CHECK_FORMS": "Report FORM ... ENDFORM routines with an empty body (default enabled; switch off while legacy forms are being retired).",
      "CHECK_FUNCS": "Report FUNCTION ... ENDFUNCTION modules with an empty body (default enabled; function modules are not available in ABAP Cloud)."
    },
    "seo": {
      "description": "Detect empty ABAP methods, FORM routines and function modules so dead API surface is deleted or implemented instead of silently passing ATC review.",
      "keywords": [
        "empty ABAP method",
        "FORM routine",
        "function module cleanup",
        "SAP ATC",
        "no-empty-proc"
      ]
    },
    "relatedRules": [
      "no-empty-block",
      "no-dead-code"
    ],
    "customSection": "### Which procedures are checked\n\n| Procedure kind | Attribute | Default |\n| --- | --- | --- |\n| `METHOD ... ENDMETHOD` | `CHECK_METHODS` | on |\n| `FORM ... ENDFORM` | `CHECK_FORMS` | on |\n| `FUNCTION ... ENDFUNCTION` | `CHECK_FUNCS` | on |\n\nA procedure counts as empty when its inspected statement block contains at most two statements - the opening and the closing keyword. Comments are not statements, so a body that only holds a placeholder such as `\"TODO: implement` is reported as well; that is exactly the case the rule wants to surface.\n\nNot reported: interface method declarations (they have no body) and any procedure kind outside the table above, for example a class constructor pool entry that is generated.\n\n### Choosing the fix\n\n- **Delete** the procedure and its callers when it is dead - that also removes the false impression of an extension point.\n- **Implement** the behaviour when the declaration is part of an interface contract.\n- **Make the hook explicit**: add a documented `RETURN.` to a deliberate no-op hook so the intent is visible and the body is no longer empty.\n\nSuppressions use `\"#EC NO_EMPTY_PROC` on the procedure header statement."
  },
  {
    "ruleId": "no-intf-class-ref",
    "title": "Keep Concrete Class References Out of Interface Components",
    "rationale": "An interface that declares `TYPE REF TO zcl_concrete` creates a compile-time dependency on one implementation, so every consumer of the interface is coupled to that class and can no longer be tested with a lighter test double. Interface-typed components keep the Dependency Inversion Principle intact and let the runtime, a factory or dependency injection choose the implementation. The check resolves the referenced type through RTTI and reports only names that really denote a class, so interfaces and unresolved names stay clean.",
    "className": "/SKYL/CL_NO_INTF_CLASS_REF",
    "pseudoComment": "NO_INTF_CLASS_REF",
    "category": "clean-abap",
    "example": {
      "bad": "INTERFACE lif_document_printer.\n  DATA mo_document TYPE REF TO cl_abap_typedescr.\nENDINTERFACE.",
      "good": "INTERFACE lif_document_printer.\n  DATA mo_renderer TYPE REF TO lif_document_renderer.\nENDINTERFACE."
    },
    "seo": {
      "description": "Stop ABAP interfaces from exposing concrete class references such as TYPE REF TO zcl_... and keep Dependency Inversion intact, verified through RTTI.",
      "keywords": [
        "ABAP interface design",
        "Dependency Inversion ABAP",
        "TYPE REF TO class",
        "SAP ATC",
        "no-intf-class-ref"
      ]
    },
    "relatedRules": [
      "pref-intf-segreg",
      "no-exposed-data"
    ],
    "customSection": "### How the check decides\n\nFor every `TYPE REF TO <name>` inside an `INTERFACE ... ENDINTERFACE` block the rule resolves `<name>` via RTTI:\n\n| Type behind `<name>` | Result |\n| --- | --- |\n| class (`CL_*`, `ZCL_*`, exception class) | `NO_CLS_REF` |\n| interface (`IF_*`, `LIF_*`) | ok |\n| the interface being declared (self reference) | ok - skipped explicitly |\n| `TYPE REF TO object` | ok - skipped explicitly |\n| unresolvable or not installed in the system | ok - nothing can be proven |\n\nOnly the first `TYPE REF TO` per statement is inspected, so declare one component per statement when you refactor an interface.\n\n### Remote enablement\n\nBecause the decision needs runtime type information, the check declares `remote_enablement = abap_false`. In an ATC run against a remote system the local RTTI cannot see the remote classes and would produce wrong results, so the check is skipped there. Run it in the local system, or in a central check system that holds the same software component versions."
  },
  {
    "ruleId": "no-aliases",
    "title": "Avoid ALIASES and Reference Interface Components Explicitly",
    "rationale": "An alias creates a second, unqualified name for the same component, so a search for the method finds the alias while the interface, the implementation and the caller use three different spellings. Aliases also hide which interface a method belongs to - exactly the information needed when two interfaces define a method with the same name. Writing `lif_printable~print( )` at the call site and `METHOD lif_printable~print.` in the implementation keeps one canonical name per capability and makes interface replacement a compile-time error instead of a silent rebinding.",
    "className": "/SKYL/CL_NO_ALIASES",
    "pseudoComment": "NO_ALIASES",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_invoice_service DEFINITION.\n  PUBLIC SECTION.\n    INTERFACES lif_printable.\n    ALIASES print FOR lif_printable~print.\nENDCLASS.",
      "good": "CLASS lcl_invoice_service DEFINITION.\n  PUBLIC SECTION.\n    INTERFACES lif_printable.\nENDCLASS.\n\nCLASS lcl_invoice_service IMPLEMENTATION.\n  METHOD lif_printable~print.\n    render_invoice_pdf( ).\n  ENDMETHOD.\nENDCLASS."
    },
    "parameters": {
      "IGNORE_PRIVATE": "Skip ALIASES statements declared in a PRIVATE SECTION (default disabled, so every alias is reported)."
    },
    "seo": {
      "description": "Remove ABAP ALIASES and require explicit lif_interface~component qualification at call sites and implementations for searchable, unambiguous code.",
      "keywords": [
        "ABAP ALIASES",
        "interface component alias",
        "lif~method qualification",
        "SAP ATC",
        "no-aliases"
      ]
    },
    "relatedRules": [
      "pref-intf-segreg",
      "no-intf-class-ref"
    ],
    "customSection": "### Ignoring private aliases\n\n`IGNORE_PRIVATE` (default off) skips `ALIASES` statements that appear after `PRIVATE SECTION` and before the next `PUBLIC SECTION` or `PROTECTED SECTION`. The section is tracked statement by statement, so the setting only helps when the alias really sits in the private section; a misplaced section header silently re-enables the finding.\n\n### Why explicit qualification wins\n\n| With alias | Without alias |\n| --- | --- |\n| `ALIASES print FOR lif_printable~print.` plus `print( ).` | `lif_printable~print( ).` |\n| `ALIASES status FOR lif_state~status.` | `lif_state~status` |\n| two interfaces both exposing `print` - alias collision | each call names its interface |\n\nExplicit `interface~component` also survives interface replacement: when a component moves to another interface, the compiler points at every affected call site instead of quietly re-binding through an alias.\n\nThe check runs on class and interface definitions only, reports each `ALIASES` statement separately, and is token based (no RTTI), so it also works in remote ATC scenarios."
  },
  {
    "ruleId": "no-abstract-final",
    "title": "Avoid Conflicting ABSTRACT and FINAL Class Modifiers",
    "rationale": "Declaring a class as both ABSTRACT and FINAL is an inherent contradiction in object-oriented architecture. An ABSTRACT class is incomplete by definition and cannot be directly instantiated, requiring subclasses to implement its contracts. Conversely, a FINAL class explicitly prohibits subclassing. A class marked with both modifiers cannot be instantiated or inherited from, rendering it unusable dead code.",
    "className": "/SKYL/CL_NO_ABSTRACT_FINAL",
    "pseudoComment": "NO_ABSTRACT_FINAL",
    "category": "anti-patterns",
    "example": {
      "bad": "CLASS lcl_pricing_strategy DEFINITION ABSTRACT FINAL.\n  PUBLIC SECTION.\n    METHODS calculate_discount ABSTRACT.\nENDCLASS.",
      "good": "CLASS lcl_pricing_strategy DEFINITION ABSTRACT.\n  PUBLIC SECTION.\n    METHODS calculate_discount ABSTRACT.\nENDCLASS."
    },
    "seo": {
      "description": "Prevent invalid ABSTRACT FINAL class definitions in ABAP OO, enforcing valid inheritance and instantiation contracts.",
      "keywords": [
        "ABSTRACT FINAL ABAP",
        "class definition modifiers",
        "ABAP OO architecture",
        "Clean ABAP",
        "SAP ATC check",
        "no-abstract-final"
      ]
    },
    "relatedRules": [
      "no-empty-proc",
      "no-dead-code"
    ],
    "customSection": "### Why ABSTRACT FINAL is invalid\n\nIn ABAP OO design, modifiers serve complementary but mutually exclusive purposes on class headers:\n\n| Modifier | Intended Purpose | Direct Instantiation | Subclassing Allowed |\n| --- | --- | --- | --- |\n| `ABSTRACT` | Defines extensible base contract | No | Yes |\n| `FINAL` | Locks class hierarchy against extension | Yes | No |\n| `ABSTRACT FINAL` | Inherent contradiction | No | No (Unusable) |\n\nFor utility classes containing only static methods (`CLASS-METHODS`), use `CREATE PRIVATE` or `FINAL` without `ABSTRACT`, or prefer modern ABAP interfaces with stateless implementations.\n\n### Suppression\n\nIf required by legacy code generation templates, suppress using `\"#EC NO_ABSTRACT_FINAL`."
  },
  {
    "ruleId": "no-double-space",
    "title": "Use Exactly One Space Between Tokens on the Same Line",
    "rationale": "Column-aligned declarations and stray double spaces make diffs noisy: renaming one identifier forces realignment of a whole block, and reviewers cannot separate the semantic change from the whitespace noise. A single space between tokens keeps lines stable under renames, keeps the 120-character limit usable and works with any formatter or editor setting. The check compares each token's column with the end of the previous token and reports the first padded gap per statement.",
    "className": "/SKYL/CL_NO_DOUBLE_SPACE",
    "pseudoComment": "NO_DOUBLE_SPACE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_order_count      TYPE i.\nDATA lv_customer_name    TYPE string.",
      "good": "DATA lv_order_count TYPE i.\nDATA lv_customer_name TYPE string."
    },
    "seo": {
      "description": "Flag redundant double spaces and column alignment padding between ABAP tokens so diffs stay minimal and formatting matches any code formatter.",
      "keywords": [
        "ABAP double space",
        "code formatting ABAP",
        "alignment whitespace",
        "SAP ATC",
        "no-double-space"
      ]
    },
    "relatedRules": [
      "pref-param-1line",
      "no-chained-decl"
    ],
    "customSection": "### What is reported\n\n`NO_DBL_SPC` is raised on the token whose column is greater than `previous token column + previous token length + 1` on the same source line, that is whenever more than one space separates two tokens. Only the first padded gap per statement is reported.\n\n| Snippet | Result |\n| --- | --- |\n| `DATA  lv_order_count TYPE i.` | reported - two spaces after `DATA` |\n| `DATA lv_order_count      TYPE i.` | reported - declaration alignment padding |\n| `DATA lv_order_count TYPE i.` | ok |\n| `account = VALUE #( street = 'Main Street' city = 'Walldorf' ).` | reported - padding between the parameter assignments |\n\n### Alignment across lines\n\nAlignment is only a problem **within** one line. A declaration that continues on the next line (the usual `TYPES ... BEGIN OF ... END OF` layout) and a parameter that is wrapped onto its own line are both fine, because no two tokens share a padded line. Splitting a long statement over several lines is therefore the recommended fix for both this rule and `pref-param-1line`.\n\nAn intentionally aligned one-liner can be suppressed with `\"#EC NO_DOUBLE_SPACE` on the statement."
  },
  {
    "ruleId": "pref-param-1line",
    "title": "One Parameter or Structure Component per Line",
    "rationale": "A call like `VALUE #( street = 'Main Street' city = 'Walldorf' )` packs several named parameters into one line, which makes a dropped entry invisible and turns the addition of one parameter into a reformat of the whole expression. One assignment per line gives every parameter its own diff line, keeps the call readable when a value is itself a constructor expression or a nested call, and stays within the 120-character limit. The check counts `=` signs inside parentheses per line, so it covers method calls, `VALUE`/`CORRESPONDING`/`NEW` expressions and nested calls alike.",
    "className": "/SKYL/CL_PREF_PARAM_1LINE",
    "pseudoComment": "PREF_PARAM_1LINE",
    "category": "clean-abap",
    "example": {
      "bad": "ls_address = VALUE #( street = 'Main Street' city = 'Walldorf' ).",
      "good": "ls_address = VALUE #(\n    street = 'Main Street'\n    city = 'Walldorf' )."
    },
    "seo": {
      "description": "Enforce one parameter or structure component assignment per line in ABAP method calls, VALUE and CORRESPONDING expressions for reviewable diffs.",
      "keywords": [
        "ABAP one parameter per line",
        "VALUE constructor expression",
        "method call formatting ABAP",
        "SAP ATC",
        "pref-param-1line"
      ]
    },
    "relatedRules": [
      "no-double-space",
      "max-method-len"
    ],
    "customSection": "### What triggers the finding\n\n`PREF_1LINE` is raised on a statement when two `=` signs appear inside parentheses on the same source line, no matter whether they belong to a method call, a constructor expression or a nested call.\n\n| Snippet | Result |\n| --- | --- |\n| `ls_address = VALUE #( street = 'Main Street' city = 'Walldorf' ).` | reported |\n| `ls_address = VALUE #( street = 'Main Street'` + newline + `city = 'Walldorf' ).` | ok - different lines |\n| `post_invoice( invoice = lo_invoice mode = 'I' ).` | reported |\n| `post_invoice( invoice = lo_invoice` + newline + `mode = 'I' ).` | ok |\n| `post_invoice( lo_invoice )` | ok - positional, no `=` |\n| `IF lv_amount = lv_limit.` | ok - no parentheses |\n\nOne finding per statement is enough: fix the statement and re-run the check.\n\n### Known edge case: parenthesised SQL\n\nBecause the heuristic only looks at `=` inside parentheses, a condition written on a single line inside a parenthesised ABAP SQL clause can be reported:\n\n```abap\nSELECT SINGLE * FROM zorder\n  WHERE ( status = @lv_status AND created_by = @lv_user )\n  INTO @DATA(ls_order).\n```\n\nSplit the condition over several lines (as above) or suppress the statement with `\"#EC PREF_PARAM_1LINE`. Positional arguments, `WHERE` clauses outside parentheses and comparisons in `IF` statements are never reported."
  },
  {
    "ruleId": "no-into-fs",
    "title": "Use ASSIGNING Instead of INTO with Field Symbols",
    "rationale": "Using INTO `<fs>` in READ TABLE or LOOP AT statements performs value assignment into the memory currently dereferenced by the field symbol instead of binding the field symbol to the table row. If the field symbol is unassigned, it triggers a runtime crash (GETWA_NOT_ASSIGNED). If already assigned, it silently overwrites previously referenced memory while failing to provide reference semantics. Use ASSIGNING for pointer reference binding.",
    "className": "/SKYL/CL_NO_INTO_FS",
    "pseudoComment": "NO_INTO_FS",
    "category": "anti-patterns",
    "example": {
      "bad": "READ TABLE lt_invoice_items INTO <ls_item> INDEX 1.\nLOOP AT lt_invoice_items INTO <ls_item>.\n  <ls_item>-tax_rate = '0.19'.\nENDLOOP.",
      "good": "READ TABLE lt_invoice_items ASSIGNING <ls_item> INDEX 1.\nLOOP AT lt_invoice_items ASSIGNING <ls_item>.\n  <ls_item>-tax_rate = '0.19'.\nENDLOOP."
    },
    "seo": {
      "description": "Prevent dangerous INTO <fs> usage in ABAP READ TABLE and LOOP AT statements by enforcing ASSIGNING for field symbols.",
      "keywords": [
        "INTO field symbol",
        "ASSIGNING <fs>",
        "ABAP READ TABLE",
        "Clean ABAP itab",
        "SAP ATC check",
        "no-into-fs"
      ]
    },
    "relatedRules": [
      "pref-strict-sql",
      "no-ambiguous-stmt"
    ],
    "customSection": "### Semantics comparison\n\nThe difference between `INTO` and `ASSIGNING` with field symbols is fundamental:\n\n| Syntax | Memory Semantics | Risk If Unassigned |\n| --- | --- | --- |\n| `READ TABLE itab INTO <fs>.` | Copy data into whatever `<fs>` currently points to | Runtime dump `GETWA_NOT_ASSIGNED` |\n| `READ TABLE itab ASSIGNING <fs>.` | Bind `<fs>` to table row memory address | Safely handles `sy-subrc <> 0` |\n| `LOOP AT itab INTO <fs>.` | Copy each row into target memory of `<fs>` | Runtime dump or stale target mutation |\n| `LOOP AT itab ASSIGNING <fs>.` | Bind `<fs>` to each row in-place | Clean, zero-copy table iteration |\n\n### Suppression\n\nIn the rare event that copying into a dynamically assigned buffer is deliberate, suppress with `\"#EC NO_INTO_FS`."
  },
  {
    "ruleId": "pref-strict-sql",
    "title": "Escape ABAP SQL Host Variables and Table Targets with @",
    "rationale": "ABAP SQL strict mode, which is mandatory in ABAP Cloud and for new S/4HANA development, requires every host variable, host expression and internal table target to be marked with the escape character @ so the compiler can separate ABAP operands from database columns. Without the escape a statement either fails in strict mode or silently falls back to the classic variant, where a same-named DDIC column shadows the local variable and the result is hard to predict. The check inspects the operand after INTO, APPENDING TABLE, OF TABLE and FIELDS OF TABLE, including the comma-separated INTO ( ... ) list form, and reports PREF_SQL so strict mode compliance grows statement by statement. The escape also documents intent for reviewers: @lt_orders is unambiguously an ABAP table, not a database object.",
    "className": "/SKYL/CL_PREF_STRICT_SQL",
    "pseudoComment": "PREF_STRICT_SQL",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lt_open_orders TYPE STANDARD TABLE OF zsales_order.\nSELECT sales_order_id, customer_id FROM zsales_order\n  INTO TABLE lt_open_orders\n  WHERE status = 'OPEN'.",
      "good": "DATA lt_open_orders TYPE STANDARD TABLE OF zsales_order.\nSELECT sales_order_id, customer_id FROM zsales_order\n  INTO TABLE @lt_open_orders\n  WHERE status = 'OPEN'."
    },
    "seo": {
      "description": "Detect ABAP SQL statements whose INTO, APPENDING or OF TABLE targets are not escaped with @ - strict SQL mode readiness for ABAP Cloud and S/4HANA.",
      "keywords": [
        "ABAP strict SQL mode",
        "@ escaping host variables",
        "SELECT INTO TABLE",
        "pref-strict-sql",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-into-fs",
      "no-ambiguous-stmt"
    ],
    "customSection": "## Inspected target positions\n\n| Statement form | Operand that must start with `@` |\n| --- | --- |\n| `INTO TABLE target` | `target` |\n| `APPENDING TABLE target` | `target` |\n| `... OF TABLE target` | `target` |\n| `FIELDS OF target` | `target` |\n| `INTO target` | `target` |\n| `INTO ( operand_a, operand_b )` | every operand inside the parentheses |\n\n## Notes\n\n- Only statements classified as database access are inspected, so `READ TABLE`, `APPEND` and other internal table operations are never reported.\n- The escape character must be the first character of the operand: `@DATA(lt_orders)` and `@ls_order` pass, while `DATA(lt_orders)` and `ls_order` are reported.\n- Suppress a single statement with `\"#EC PREF_STRICT_SQL` when classic SQL is unavoidable, for example a client-dependent `SELECT` that needs an explicit `ORDER BY`.\n- The rule only checks the target side. Unescaped comparison operands in the `WHERE` clause are a separate migration step and are not part of this finding."
  },
  {
    "ruleId": "pref-enum",
    "title": "Use Enumerated Types Instead of Structured Constants",
    "rationale": "A structured CONSTANTS block describes a value set but keeps the type system out of the decision: every component is an independent constant, any value of the base type can be assigned to the variable, and nothing prevents mixing members of two unrelated groups. An enumerated type declared with TYPES BEGIN OF ENUM creates one dedicated type whose only valid values are the enumerated constants, so the compiler rejects cross-family assignments and every consumer sees the closed value set in the signature. The check reports PREF_ENUM for every CONSTANTS statement that contains both BEGIN and OF, pointing maintainers to the ABAP 7.51 enum syntax that is also fully supported in ABAP Cloud. Single scalar constants stay untouched because they are a legitimate, non-structured declaration.",
    "className": "/SKYL/CL_PREF_ENUM",
    "pseudoComment": "PREF_ENUM",
    "category": "clean-abap",
    "example": {
      "bad": "CONSTANTS:\n  BEGIN OF c_order_status,\n    created  TYPE string VALUE 'CREATED',\n    released TYPE string VALUE 'RELEASED',\n    closed   TYPE string VALUE 'CLOSED',\n  END OF c_order_status.",
      "good": "TYPES:\n  BEGIN OF ENUM ty_order_status,\n    created,\n    released,\n    closed,\n  END OF ENUM ty_order_status.\n\nDATA lv_order_status TYPE ty_order_status.\nlv_order_status = released."
    },
    "seo": {
      "description": "Replace structured CONSTANTS value sets with typed ABAP ENUM definitions - compiler-checked status values for Clean ABAP and ABAP Cloud development.",
      "keywords": [
        "ABAP ENUM",
        "BEGIN OF ENUM",
        "structured constants",
        "pref-enum",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-magic-numbers",
      "no-hardcoded-env"
    ],
    "customSection": "## What is reported\n\nThe check fires on any `CONSTANTS` declaration that contains both `BEGIN` and `OF`, i.e. every structure-shaped constant definition:\n\n```abap\nCONSTANTS: BEGIN OF c_order_status, created TYPE string VALUE 'CREATED', END OF c_order_status.\n```\n\nSingle, non-structured declarations such as `CONSTANTS c_max_retries TYPE i VALUE 3.` are never reported.\n\n## Preferred alternative\n\n```abap\nTYPES:\n  BEGIN OF ENUM ty_order_status,\n    created,\n    released,\n    closed,\n  END OF ENUM ty_order_status.\n```\n\n| Advantage | Effect |\n| --- | --- |\n| Dedicated type | `ty_order_status` appears in the signature instead of `string`/`i` |\n| Compiler check | assigning `released` to a `ty_payment_status` variable fails at compile time |\n| Closed set | SE11/ADT display all legal values in one place |\n\nValues that come from Customizing should stay a domain with fixed values or a CDS domain; an enum is the right tool only for a set that is fixed in the code."
  },
  {
    "ruleId": "no-protected-data",
    "title": "Keep Class Attributes Private Instead of Protected",
    "rationale": "Protected attributes are the weakest form of encapsulation: invisible to clients but fully readable and writable by every subclass, so an inherited class can bypass the validation, invariants and change notifications the superclass implements. Clean ABAP therefore asks for private attributes plus protected or public accessor methods that the owner still controls. The check walks the CLASS DEFINITION statement stream, tracks the active visibility section and reports NO_PROTDAT for every DATA or CLASS-DATA declared while PROTECTED SECTION is open. Protected methods, types and constants stay allowed because they are the intended extension contract for subclasses.",
    "className": "/SKYL/CL_NO_PROTECTED_DATA",
    "pseudoComment": "NO_PROTECTED_DATA",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_pricing_engine DEFINITION\n  PUBLIC\n  CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_price.\n  PROTECTED SECTION.\n    DATA mv_discount_rate TYPE decfloat34.\nENDCLASS.",
      "good": "CLASS zcl_pricing_engine DEFINITION\n  PUBLIC\n  CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS calculate_price.\n  PROTECTED SECTION.\n    METHODS get_discount_rate\n      RETURNING VALUE(rv_rate) TYPE decfloat34.\n  PRIVATE SECTION.\n    DATA mv_discount_rate TYPE decfloat34.\nENDCLASS."
    },
    "seo": {
      "description": "Report DATA and CLASS-DATA declared in the PROTECTED SECTION of ABAP classes - enforce private attributes and accessor methods for real encapsulation.",
      "keywords": [
        "ABAP protected attributes",
        "class encapsulation",
        "no-protected-data",
        "Clean ABAP classes",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-exposed-data",
      "max-attributes"
    ],
    "customSection": "## Detected declarations\n\n| Declaration in `PROTECTED SECTION` | Reported |\n| --- | --- |\n| `DATA` | yes |\n| `CLASS-DATA` | yes |\n| `TYPES`, `CONSTANTS`, `METHODS` | no |\n\n`DATA` in `PUBLIC SECTION` or `PRIVATE SECTION` is not part of this rule.\n\n## Notes\n\n- The check follows the section statements in document order, so a class that re-opens `PROTECTED SECTION` further down is still analyzed correctly.\n- A `FINAL` class cannot be inherited, so `PROTECTED SECTION` should not exist there at all - remove the section instead of suppressing the finding.\n- Sharing state with subclasses is better expressed through a protected getter (`RETURNING` a read-only copy) and a protected hook method the superclass calls itself.\n- Suppress legacy code with `\"#EC NO_PROTECTED_DATA` on the offending `DATA` statement."
  },
  {
    "ruleId": "no-method-chain",
    "title": "Avoid Method Call Chains Longer Than the Configured Limit",
    "rationale": "A chain such as lo_invoice->get_header( )->get_total_amount( ) hides two intermediate objects and one implicit dependency in a single line, so a dump in the second call cannot be reproduced without first inspecting what the first call returned, and the debugger cannot stop between the calls. Extracting each step into a well-named variable makes the data flow explicit for reviewers and lets you reuse or null-check the intermediate reference. The check counts the -> tokens of every method-call statement (string literals are excluded) and reports NO_CHAIN when the count exceeds MAX_CHAIN. A plain lo_service->run( ) counts as one link and therefore passes with the default value 1.",
    "className": "/SKYL/CL_NO_METHOD_CHAIN",
    "pseudoComment": "NO_METHOD_CHAIN",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lo_invoice) = NEW zcl_invoice( iv_order_id = lv_order_id ).\nDATA(lv_total) = lo_invoice->get_header( )->get_total_amount( ).",
      "good": "DATA(lo_invoice) = NEW zcl_invoice( iv_order_id = lv_order_id ).\nDATA(lo_header) = lo_invoice->get_header( ).\nDATA(lv_total) = lo_header->get_total_amount( )."
    },
    "parameters": {
      "MAX_CHAIN": "Maximum number of -> links allowed in one method-call statement. Default 1 permits a single object->method( ) call; raise it to 2-3 only for intentional fluent APIs."
    },
    "seo": {
      "description": "Limit chained ABAP method calls with the configurable MAX_CHAIN threshold - readable, debuggable object navigation instead of fluent one-liners.",
      "keywords": [
        "ABAP method chaining",
        "no-method-chain",
        "MAX_CHAIN",
        "Clean ABAP readability",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-call-method",
      "max-method-len"
    ],
    "customSection": "## How MAX_CHAIN is counted\n\nEach `->` token of a method-call statement counts as one link. Static access with `=>` and text inside literals are ignored.\n\n| Statement | Links |\n| --- | --- |\n| `lo_service->run( ).` | 1 |\n| `lo_service->get_reader( )->read( ).` | 2 |\n| `lo_service->get_reader( )->get_buffer( )->read( ).` | 3 |\n| `cl_service=>create( )->run( ).` | 1 |\n\n- `MAX_CHAIN` is an integer with default `1`: a single `object->method( )` call is fine, the first real chaining is reported.\n- Raising `MAX_CHAIN` to `2` tolerates short fluent chains while still catching long builder sequences.\n- Only statements recognised as method calls are inspected, so declarations and assignments without a call are never counted.\n\n## Refactoring recipe\n\n1. Name the intermediate object after its role (`lo_header`, `lo_position`), not after its type.\n2. Keep the fluent builder chain at the place where the object is created (`NEW zcl_document( )->add_line( ... )->build( )`) only if it is a single expression assigned to one variable.\n3. If the chain exists only to reach a nested attribute, ask the owning class for a dedicated getter instead of navigating the object graph."
  },
  {
    "ruleId": "no-implicit-any",
    "title": "Declare Concrete Types Instead of Generic ANY",
    "rationale": "Untyped FIELD-SYMBOLS and generic parameter types such as ANY, DATA, OBJECT, CLIKE, CSEQUENCE, NUMERIC or TABLE postpone every type check to runtime, so misuse is only detected when the assignment dumps with a MOVE-CAST or internal table error in production. Declaring the concrete type, a DDIC structure, a table type or an interface, lets the compiler validate component access, parameter passing and RETURNING types at build time and keeps the code compatible with the stricter ABAP Cloud type checks. The check reports NO_ANY_TYP for FIELD-SYMBOLS without TYPE/LIKE, for FIELD-SYMBOLS with a generic built-in type and for METHODS/CLASS-METHODS parameters whose type is missing or generic. Fully typed declarations make the signature self-documenting and remove the need for runtime DESCRIBE or ASSIGN COMPONENT introspection.",
    "className": "/SKYL/CL_NO_IMPLICIT_ANY",
    "pseudoComment": "NO_IMPLICIT_ANY",
    "category": "clean-abap",
    "example": {
      "bad": "FIELD-SYMBOLS <ls_order_item>.\nASSIGN lt_order_items[ 1 ] TO <ls_order_item>.",
      "good": "FIELD-SYMBOLS <ls_order_item> TYPE zsales_order_item.\nASSIGN lt_order_items[ 1 ] TO <ls_order_item>."
    },
    "seo": {
      "description": "Flag untyped FIELD-SYMBOLS and generic ANY, DATA, CLIKE or TABLE method parameters in ABAP - enforce concrete types for compile-time safety.",
      "keywords": [
        "ABAP generic types",
        "TYPE any",
        "FIELD-SYMBOLS typing",
        "no-implicit-any",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "pref-full-typed",
      "pref-final-data"
    ],
    "customSection": "## Reported forms\n\n| Form | Example |\n| --- | --- |\n| `FIELD-SYMBOLS` without `TYPE` / `LIKE` | `FIELD-SYMBOLS <ls_order_item>.` |\n| Generic `FIELD-SYMBOLS` type | `<ls_order_item> TYPE any`, `TYPE data`, `TYPE clike` |\n| Parameter without a type | `IMPORTING iv_count` |\n| Generic parameter type | `IMPORTING iv_count TYPE numeric` |\n\nGeneric names recognised by the check: `ANY`, `DATA`, `OBJECT`, `CLIKE`, `CSEQUENCE`, `XSEQUENCE`, `NUMERIC`, `DECFLOAT`, `SIMPLE`, `TABLE`, `ANY TABLE`, `INDEX TABLE`.\n\n## Not reported\n\n- `FIELD-SYMBOLS <lo_service> TYPE REF TO zif_service.` - a reference type is concrete.\n- `LIKE` declarations that copy the type of a typed data object.\n- Inline declarations such as `ASSIGN lt_items[ 1 ] TO FIELD-SYMBOL(<ls_item>)`, which derive the type from the memory area.\n- `EXPORTING`, `CHANGING` and `RETURNING` parameters of a type that is not in the generic list.\n\n## Migration tip\n\nReplace `TYPE any` with the structure that is actually moved, and `TYPE standard table` with the concrete table type (`TYPE zsales_order_items`). Where a truly generic container is required, prefer `TYPE REF TO zif_...` or `TYPE REF TO data` behind a dedicated accessor class instead of spreading `ASSIGN COMPONENT` logic."
  },
  {
    "ruleId": "pref-union",
    "title": "Prefer Distinct UNION over UNION ALL in SQL Queries",
    "rationale": "Combining query result sets with `UNION ALL` retains duplicate records from all participating branches, which can lead to accidental double-counting in business reports, inaccurate metric aggregations, and excessive network transport from the database. In contrast, standard `UNION` performs set deduplication directly within the database engine before rows are sent to the application server. The check detects `UNION ALL` sequences in ABAP SQL and reports `PREF_UNION`. Unless duplicate records are explicitly expected and handled, use standard `UNION` to ensure deterministic, distinct dataset retrieval and lower application memory consumption.",
    "className": "/SKYL/CL_PREF_UNION",
    "pseudoComment": "PREF_UNION",
    "category": "performance",
    "example": {
      "bad": "SELECT company_code, customer_number\n  FROM zsales_order_hist\n  UNION ALL\n  SELECT company_code, customer_number\n  FROM zsales_order_curr\n  INTO TABLE @DATA(lt_active_customers).",
      "good": "SELECT company_code, customer_number\n  FROM zsales_order_hist\n  UNION\n  SELECT company_code, customer_number\n  FROM zsales_order_curr\n  INTO TABLE @DATA(lt_active_customers)."
    },
    "seo": {
      "description": "Ensure distinct SQL query results and prevent duplicate data processing by using UNION instead of UNION ALL in SAP ABAP Cloud applications.",
      "keywords": [
        "pref-union",
        "UNION ALL",
        "ABAP SQL",
        "Clean ABAP",
        "database performance"
      ]
    },
    "relatedRules": [
      "pref-join-type",
      "pref-strict-sql"
    ],
    "customSection": "## Detection and Intent\n\nThe check inspects `SELECT` statements for the token sequence `UNION ALL`. If duplicate records across queries are genuinely intended (e.g. for complete audit event logs or union of pre-partitioned disjoint datasets where duplicates are mathematically impossible), suppress the finding with the pseudo-comment.\n\n| Aspect | Details |\n|---|---|\n| Finding Code | `PREF_UNION` |\n| Default Severity | Warning |\n| Pseudo Comment | `\"#EC PREF_UNION` |\n| Detected Pattern | Consecutive keywords `UNION ALL` within an ABAP SQL `SELECT` statement |"
  },
  {
    "ruleId": "no-hardcoded-url",
    "title": "Avoid Hardcoded HTTP and FTP URLs in Source Code",
    "rationale": "Hardcoding absolute HTTP, HTTPS, or FTP URLs directly in ABAP source code creates tight coupling to external network infrastructure, breaks environment portability across landscape tiers (development, testing, quality assurance, and production), and prevents infrastructure teams from modifying hostnames, proxy routes, or TLS configurations without source code deployments. In SAP BTP and S/4HANA Cloud (Cloud Contract C1), outbound network communication must be decoupled via SAP Destination Service, SM59 HTTP destinations, or Communication Arrangements (cl_http_destination_provider). Clean ABAP requires isolating network endpoints in centrally managed destinations.",
    "className": "/SKYL/CL_NO_HARDCODED_URL",
    "pseudoComment": "NO_HARDCODED_URL",
    "category": "security",
    "example": {
      "bad": "DATA(lo_destination) = cl_http_destination_provider=>create_by_url(\n  i_url = 'https://api.partner.example.com/v1/orders' ).",
      "good": "DATA(lo_destination) = cl_http_destination_provider=>create_by_destination(\n  i_destination = 'OUTBOUND_ORDER_API' )."
    },
    "parameters": {
      "CHECK_HTTP": "Detect hardcoded HTTP and HTTPS URLs in string literals and text symbols (default: true).",
      "CHECK_FTP": "Detect hardcoded FTP and SFTP URLs in string literals and text symbols (default: true)."
    },
    "seo": {
      "description": "Detect hardcoded HTTP, HTTPS, and FTP URLs in ABAP source code to enforce SAP Destination Service and Communication Arrangements.",
      "keywords": [
        "no-hardcoded-url",
        "Hardcoded URL ABAP",
        "SAP Destination Service",
        "Communication Arrangement",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-hardcoded-env",
      "no-rfc-err"
    ],
    "customSection": "## URL Protocol Detection\n\nThe check inspects string literals and templates for embedded URL schemes:\n\n| Protocol Checked | Parameter Attribute | Example Flagged Literal | Clean Replacement |\n|---|---|---|---|\n| `HTTP://` / `HTTPS://` | `CHECK_HTTP` | `'https://api.example.com/orders'` | `cl_http_destination_provider=>create_by_destination` |\n| `FTP://` / `SFTP://` | `CHECK_FTP` | `'ftp://files.example.com/exports'` | Logical file destinations or managed communication arrangements |\n\nShort literals under 10 characters (such as prefix constants `'https://'`) and relative URL paths (such as `'/api/v1/orders'`) are not flagged. Suppress valid static URL declarations using `\"#EC NO_HARDCODED_URL` or `##NO_HARDCODED_URL`."
  },
  {
    "ruleId": "no-hardcoded-ip",
    "title": "Avoid Hardcoded IPv4 and IPv6 Addresses in Source Code",
    "rationale": "Embedding raw IPv4 or IPv6 network addresses directly into ABAP business logic tightly couples application components to physical or virtual host hardware, bypassing DNS hostname resolution, TLS certificate validation, load balancers, and reverse proxies. In containerized, virtualized, and hybrid cloud environments (such as SAP BTP and SAP S/4HANA Cloud), network topologies and IP address assignments change dynamically without warning. Clean ABAP, SAP security baselines, and ABAP Cloud Contract C1 mandate routing outbound network connections through logical destinations (such as SM59 or SAP Destination Service) or fully qualified domain names.",
    "className": "/SKYL/CL_NO_HARDCODED_IP",
    "pseudoComment": "NO_HARDCODED_IP",
    "category": "security",
    "example": {
      "bad": "DATA(lo_destination) = cl_http_destination_provider=>create_by_url(\n  i_url = 'http://192.168.10.50:8080/api/v1/telemetry' ).",
      "good": "DATA(lo_destination) = cl_http_destination_provider=>create_by_destination(\n  i_destination = 'TELEMETRY_GATEWAY' )."
    },
    "parameters": {
      "CHECK_IPV4": "Detect hardcoded IPv4 dot-decimal addresses in string literals and templates (default: true).",
      "CHECK_IPV6": "Detect hardcoded IPv6 hexadecimal colon-separated addresses in string literals (default: true)."
    },
    "seo": {
      "description": "Detect and eliminate hardcoded IPv4 and IPv6 addresses in ABAP source code to enforce DNS resolution and destination-based routing.",
      "keywords": [
        "no-hardcoded-ip",
        "Hardcoded IP ABAP",
        "IPv4 Address Linting",
        "IPv6 Security",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-hardcoded-url",
      "no-hardcoded-env"
    ],
    "customSection": "## Supported IP Address Formats\n\nThe check inspects string literals and templates using regular expression pattern matching:\n\n| IP Version | Parameter Attribute | Pattern Detected | Excluded Patterns |\n|---|---|---|---|\n| `IPv4` | `CHECK_IPV4` | Dot-decimal notation (`192.168.1.100`, `10.20.30.40:8080`) | Semantic version strings (`1.2.3`), single numbers |\n| `IPv6` | `CHECK_IPV6` | Hexadecimal colon-separated notation (`2001:0db8:...`, `::1`) | Standard timestamps, port numbers |\n\nOutbound network calls should reference destination configurations managed in SM59 or SAP BTP Destination Service. Suppress intentional IP declarations using `\"#EC NO_HARDCODED_IP` or `##NO_HARDCODED_IP`."
  },
  {
    "ruleId": "no-raw-html",
    "title": "Avoid Hardcoded Raw HTML Markup and Cross-Site Scripting",
    "rationale": "Embedding raw HTML markup strings (`<script>`, `<div>`, `<span>`, `<table>`) directly inside ABAP business logic violates separation of concerns by coupling backend data processing to client-side presentation rendering. Furthermore, interpolating dynamic user values into raw HTML strings without strict context-aware encoding introduces severe Cross-Site Scripting (XSS / OWASP Top 10 A03 / CWE-79) vulnerabilities. In modern SAP architectures and ABAP Cloud, user interfaces should be developed with SAP Fiori / SAPUI5 consuming OData/RAP services. Where HTML generation is strictly necessary (such as email bodies), all dynamic variables must be sanitized using escape( val = ... format = cl_abap_format=>e_html_text ).",
    "className": "/SKYL/CL_NO_RAW_HTML",
    "pseudoComment": "NO_RAW_HTML",
    "category": "security",
    "example": {
      "bad": "DATA(lv_html_content) = |<div class=\"user-profile\"><span>{ lv_customer_name }</span></div>|.",
      "good": "DATA(lv_safe_name) = escape( val = lv_customer_name format = cl_abap_format=>e_html_text ).\nDATA(lv_html_content) = |<div class=\"user-profile\"><span>{ lv_safe_name }</span></div>|. \"#EC NO_RAW_HTML"
    },
    "parameters": {
      "CHECK_SCRIPTS": "Detect script and iframe HTML tags presenting critical Cross-Site Scripting (XSS) risks (default: true).",
      "CHECK_TAGS": "Detect structural HTML tags such as div, span, table, form, and input in string literals (default: true)."
    },
    "seo": {
      "description": "Prevent Cross-Site Scripting (XSS) in ABAP by detecting hardcoded raw HTML tags in strings and enforcing cl_abap_format escaping.",
      "keywords": [
        "no-raw-html",
        "XSS ABAP Security",
        "Raw HTML Detection",
        "cl_abap_format",
        "Clean ABAP",
        "SAP ATC"
      ]
    },
    "relatedRules": [
      "no-hardcoded-url",
      "no-hardcoded-ip"
    ],
    "customSection": "## Detected HTML Elements\n\nThe check inspects string literals and templates for embedded HTML tags:\n\n| Tag Category | Parameter Attribute | Tags Detected | Security Assessment |\n|---|---|---|---|\n| High-Risk Executable Tags | `CHECK_SCRIPTS` | `<script>`, `<iframe>` | Critical XSS risk; client-side code execution |\n| Structural Markup Tags | `CHECK_TAGS` | `<html>`, `<body>`, `<div>`, `<span>`, `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<td>`, `<th>`, `<form>`, `<input>`, `<img>`, `<a>`, `<p>` | UI coupling, formatting inconsistencies, XSS injection surface |\n\nNon-HTML XML tags (such as `<OrderHeader id=\"123\"/>`) and relational comparison operators (`<`, `>`) without HTML tag names are ignored. When generating HTML email notifications, encode dynamic values with `escape( val = ... format = cl_abap_format=>e_html_text )` and suppress the literal markup statement with `\"#EC NO_RAW_HTML` or `##NO_RAW_HTML`."
  },
  {
    "ruleId": "pref-test-attributes",
    "title": "Declare DURATION and RISK LEVEL on ABAP Unit Test Classes",
    "rationale": "DURATION and RISK LEVEL tell the ABAP Unit runner how a test class behaves: SHORT tests are pure in-memory checks, MEDIUM tests may touch the database, LONG tests may run for minutes, while RISK LEVEL HARMLESS promises no changes to persistent data. Without explicit attributes the runner must assume the worst case, so a hermetic unit test can be skipped in restricted systems, blocked by the commit/rollback guard or moved to a slow nightly job instead of running in CI on every transport. The check validates every CLASS ... DEFINITION FOR TESTING statement and reports PREF_TSTAT when DURATION or RISK LEVEL is missing, while CHECK_DURATION and CHECK_RISK_LEVEL let teams adopt the two attributes gradually. Explicit attributes also document intent to reviewers and keep test execution time predictable.",
    "className": "/SKYL/CL_PREF_TEST_ATTR",
    "pseudoComment": "PREF_TEST_ATTR",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS lcl_order_service_test DEFINITION FOR TESTING.\n  PUBLIC SECTION.\n    METHODS test_total_is_rounded.\nENDCLASS.",
      "good": "CLASS lcl_order_service_test DEFINITION FOR TESTING\n  DURATION SHORT\n  RISK LEVEL HARMLESS.\n  PUBLIC SECTION.\n    METHODS test_total_is_rounded.\nENDCLASS."
    },
    "parameters": {
      "CHECK_DURATION": "Report test classes that do not declare DURATION (SHORT, MEDIUM or LONG). Keep true to require runtime classification; set false only while migrating legacy test includes.",
      "CHECK_RISK_LEVEL": "Report test classes that do not declare RISK LEVEL (HARMLESS, DANGEROUS or CRITICAL). Keep true so tests with database commits are clearly marked; set false for teams that only track runtime."
    },
    "seo": {
      "description": "Require DURATION SHORT and RISK LEVEL HARMLESS on ABAP Unit FOR TESTING classes - stable test runner behaviour and CI-ready unit tests.",
      "keywords": [
        "ABAP Unit DURATION",
        "RISK LEVEL HARMLESS",
        "FOR TESTING class",
        "pref-test-attributes",
        "ABAP Cloud"
      ]
    },
    "relatedRules": [
      "no-prod-assert",
      "pref-final-cls"
    ],
    "customSection": "## Attributes\n\n| Attribute | Allowed values | Meaning |\n| --- | --- | --- |\n| `DURATION` | `SHORT`, `MEDIUM`, `LONG` | expected runtime class of the test |\n| `RISK LEVEL` | `HARMLESS`, `DANGEROUS`, `CRITICAL` | side effects on persistent data |\n\nRecommended default for hermetic unit tests: `DURATION SHORT RISK LEVEL HARMLESS`.\n\n## Parameters\n\n| Parameter | Default | Effect |\n| --- | --- | --- |\n| `CHECK_DURATION` | `true` | report a missing `DURATION` |\n| `CHECK_RISK_LEVEL` | `true` | report a missing `RISK LEVEL` |\n\n## Notes\n\n- Only classes with `FOR TESTING` are inspected; production classes and plain helper classes are ignored.\n- A test class with only `DURATION` is still reported (once) because `RISK LEVEL` is missing, and vice versa.\n- Suppress per class with `\"#EC PREF_TEST_ATTR` on the `CLASS ... DEFINITION` line.\n- `RISK LEVEL` is written as two tokens (`RISK` `LEVEL`); both must appear on the `CLASS` statement, not on a separate line of the definition."
  },
  {
    "ruleId": "no-raw-str-tmpl",
    "title": "Avoid String Templates Without Embedded Expressions",
    "rationale": "A string template such as |Hello World| is compiled as a string template with a format-driven evaluation path, yet it contains no embedded expression, so the runtime pays for template handling that a plain character or string literal does not need. It also misleads readers, who expect { ... } placeholders and start looking for dynamic content that does not exist. The check scans the token stream of every statement for a | token and reports NO_RAWTMPL when the closing | is reached without a { expression, so empty templates || and static templates |text| are detected with one finding code but controlled by two independent switches. Only templates that really interpolate or format an expression should use the string template syntax.",
    "className": "/SKYL/CL_NO_RAW_STR_TMPL",
    "pseudoComment": "NO_RAW_STR_TMPL",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_greeting) = |Hello World|.\nDATA(lv_blank) = ||.",
      "good": "DATA(lv_greeting) = 'Hello World'.\nDATA(lv_message) = |Order { lv_order_id } created|."
    },
    "parameters": {
      "CHECK_EMPTY_TEMPLATE": "Report empty string templates written as || - replace them with an empty character literal or an empty string. Default true.",
      "CHECK_STATIC_TEMPLATE": "Report string templates without any { } expression, e.g. |Fixed text|. Default true; set false if your team uses templates purely as a visual marker."
    },
    "seo": {
      "description": "Detect ABAP string templates such as |Fixed text| and || that contain no embedded expression and should be plain literals instead.",
      "keywords": [
        "ABAP string template",
        "empty template",
        "no-raw-str-tmpl",
        "string literal",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-str-tmpl",
      "no-useless-concat"
    ],
    "customSection": "## Parameters\n\n| Parameter | Default | Effect |\n| --- | --- | --- |\n| `CHECK_EMPTY_TEMPLATE` | `true` | report an empty template `||` |\n| `CHECK_STATIC_TEMPLATE` | `true` | report `|text|` without `{ }` |\n\n## Notes\n\n- The criterion is the presence of a `{` token between the opening and the closing `|`; a template that only contains escaped braces but no expression is still reported.\n- Templates with formatting options (`|{ lv_amount NUMBER = USER }|`) are not reported.\n- A backtick literal (`` `text` ``) is a string literal and is never reported, even when it contains a `{`.\n- The finding is reported on the opening `|` token, so the marker points exactly at the template that must change.\n\n## Replacement table\n\n| Reported | Replacement |\n| --- | --- |\n| `||` | `''` (empty character literal) or `` `` `` (empty string) |\n| `|Fixed text|` | `'Fixed text'` for a text literal, `` `Fixed text` `` when trailing blanks matter |\n| `|Status: OK|` | `'Status: OK'` |\n| `|Total: { lv_total }|` | keep it - it embeds an expression |"
  },
  {
    "ruleId": "max-sql-joins",
    "title": "Limit Database Table JOINs in ABAP SQL Queries",
    "rationale": "Executing ABAP SQL queries with excessive table JOINs (more than 4 by default) complicates query execution plans, creates expensive intermediate spool results, and saturates SAP HANA memory buffers. Large join graphs make statements brittle to schema evolutions and significantly hinder maintainability. Under the ABAP RESTful Application Programming Model (RAP) and Clean ABAP principles, complex data models should be modeled as reusable Core Data Services (CDS) analytical or transactional views with associations, or broken down into focused, staged queries. The check inspects `SELECT` statements and reports `MAX_SQLJN` whenever the join count exceeds the configured `MAX_JOINS` threshold.",
    "className": "/SKYL/CL_MAX_SQL_JOINS",
    "pseudoComment": "MAX_SQL_JOINS",
    "category": "performance",
    "example": {
      "bad": "SELECT header~sales_order,\n       item~order_item,\n       customer~customer_name,\n       material~material_desc,\n       status~status_text,\n       currency~currency_code\n  FROM zso_header AS header\n  INNER JOIN zso_item AS item ON header~sales_order = item~sales_order\n  LEFT OUTER JOIN zcustomer AS customer ON header~customer_id = customer~customer_id\n  LEFT OUTER JOIN zmaterial AS material ON item~material_id = material~material_id\n  LEFT OUTER JOIN zso_status AS status ON header~status_code = status~status_code\n  LEFT OUTER JOIN zcurrency AS currency ON header~currency_code = currency~currency_code\n  INTO TABLE @DATA(lt_order_details).",
      "good": "SELECT sales_order,\n       order_item,\n       customer_name,\n       material_desc,\n       status_text,\n       currency_code\n  FROM zi_sales_order_analytics\n  INTO TABLE @DATA(lt_order_details)."
    },
    "parameters": {
      "MAX_JOINS": "Maximum number of table JOIN occurrences allowed in a single ABAP SQL statement before reporting a finding (default: 4)."
    },
    "seo": {
      "description": "Limit the number of database table JOINs in ABAP SQL to prevent SAP HANA optimizer bottlenecks and encourage CDS view modeling.",
      "keywords": [
        "max-sql-joins",
        "SQL JOIN",
        "CDS view",
        "SAP HANA",
        "ABAP SQL performance"
      ]
    },
    "relatedRules": [
      "pref-join-type",
      "no-select-star"
    ],
    "customSection": "## Configuration and Best Practices\n\n| Setting | Default | Description |\n|---|---|---|\n| `MAX_JOINS` | `4` | Maximum permissible `JOIN` keywords per `SELECT` statement |\n\n### Architectural Recommendations\n- **Encapsulate in CDS Views:** Model complex multi-table graphs in Core Data Services (CDS) entity views with lazy associations (`_Association`) instead of writing long Open SQL JOIN chains in procedural code.\n- **Query Decomposition:** If data comes from disparate business domains, split queries into targeted fetches using `FOR ALL ENTRIES` or separate service calls.\n- **Suppression:** Suppress false positives on necessary reporting queries using `\"#EC MAX_SQL_JOINS` or `##MAX_SQL_JOINS`."
  },
  {
    "ruleId": "pref-loop-where",
    "title": "Filter Internal Tables with LOOP AT WHERE Instead of a CONTINUE Guard",
    "rationale": "Filtering with an initial IF ... CONTINUE guard forces the loop to visit every row of the table: the runtime assigns the row to the work area, the body starts, the condition is evaluated and the iteration is abandoned. With LOOP AT ... WHERE the table is filtered during traversal, so non-matching rows never reach the loop body, which is faster on large tables and much easier to read because the filter appears in the LOOP header instead of the first three lines of the body. The check reports PREF_LOOPW when the statements immediately after LOOP are exactly IF, CONTINUE, ENDIF. Moving the condition to WHERE also removes one nesting level and makes the loop body contain only the real business logic.",
    "className": "/SKYL/CL_PREF_LOOP_WHERE",
    "pseudoComment": "PREF_LOOP_WHERE",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_open_count) = 0.\nLOOP AT lt_sales_orders INTO DATA(ls_order).\n  IF ls_order-status <> 'OPEN'.\n    CONTINUE.\n  ENDIF.\n  lv_open_count += 1.\nENDLOOP.",
      "good": "DATA(lv_open_count) = 0.\nLOOP AT lt_sales_orders INTO DATA(ls_order) WHERE status = 'OPEN'.\n  lv_open_count += 1.\nENDLOOP."
    },
    "seo": {
      "description": "Replace leading IF CONTINUE guards with LOOP AT WHERE in ABAP internal table loops - fewer visited rows, less nesting and clearer table filtering.",
      "keywords": [
        "LOOP AT WHERE",
        "ABAP CONTINUE guard",
        "pref-loop-where",
        "internal table filter",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-merge-ifs",
      "no-useless-cont",
      "pref-read-table"
    ],
    "customSection": "## Detected pattern\n\nThe finding is raised when the three statements directly after `LOOP` are exactly:\n\n```abap\nLOOP AT lt_sales_orders INTO DATA(ls_order).\n  IF ls_order-status <> 'OPEN'.\n    CONTINUE.\n  ENDIF.\n  ...\nENDLOOP.\n```\n\n## Why the pattern is strict\n\n- Any statement between `LOOP` and the `IF` (even an initialisation) prevents detection, because the guard is no longer a pure loop filter.\n- A guard whose body contains more than one `CONTINUE` is not reported - that logic is not a filter.\n- Nested loops are analyzed independently, so a guard inside the inner loop is reported on the inner `LOOP`.\n\n## Better alternatives\n\n| Goal | Idiomatic ABAP |\n| --- | --- |\n| Filter by one component | `LOOP AT lt_sales_orders INTO DATA(ls_order) WHERE status = 'OPEN'.` |\n| Filter by a complex condition | `LOOP AT lt_sales_orders INTO DATA(ls_order) WHERE total > 100 AND currency = 'EUR'.` |\n| Filter once, reuse the result | `DATA(lt_open) = FILTER #( lt_sales_orders WHERE status = 'OPEN' ).` |\n| Direct component access without a work area | `LOOP AT lt_sales_orders ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = 'OPEN'.` |\n\nPseudo-comment: `\"#EC PREF_LOOP_WHERE` on the `LOOP` statement."
  },
  {
    "ruleId": "pref-sort-key",
    "title": "Specify Explicit Sort Fields with SORT BY",
    "rationale": "Using `SORT itab` without an explicit `BY` clause sorts an internal table using its implicit standard key. In ABAP, the standard key of standard tables consists of all non-numeric and character-like fields, which can change silently whenever table components are added, reordered, or modified. Furthermore, tables declared with `WITH EMPTY KEY` cannot be safely sorted without an explicit key. Specifying explicit sort criteria via `SORT itab BY field1 ASCENDING field2 DESCENDING` makes sorting deterministic, prevents subtle ordering bugs, and documents developer intent clearly. The check reports `PREF_SORTK` when a `SORT` statement omits the `BY` keyword.",
    "className": "/SKYL/CL_PREF_SORT_KEY",
    "pseudoComment": "PREF_SORT_KEY",
    "category": "performance",
    "example": {
      "bad": "SORT lt_sales_orders.",
      "good": "SORT lt_sales_orders BY creation_date DESCENDING sales_order ASCENDING."
    },
    "seo": {
      "description": "Enforce explicit sort keys using SORT BY on ABAP internal tables to guarantee deterministic order and prevent implicit standard key defects.",
      "keywords": [
        "pref-sort-key",
        "SORT BY",
        "internal table",
        "Clean ABAP",
        "deterministic sorting"
      ]
    },
    "relatedRules": [
      "pref-sort-order",
      "pref-std-table"
    ],
    "customSection": "## Why Implicit Standard Key Sorting Is Fragile\n\n| Declaration Type | Behavior with `SORT itab.` |\n|---|---|\n| `STANDARD TABLE WITH DEFAULT KEY` | Sorts by all character-like and byte-like components, ignoring integers, packed decimals, and timestamps. Changing structure layout alters sort behavior. |\n| `STANDARD TABLE WITH EMPTY KEY` | Runtime behavior is non-deterministic or sorts across all components depending on kernel version. |\n| `SORT itab BY comp1 comp2` | Explicit, robust, and independent of dictionary type alterations. |\n\nSuppress single occurrences where table definition keys are strictly intended using `\"#EC PREF_SORT_KEY` or `##PREF_SORT_KEY`."
  },
  {
    "ruleId": "pref-plain-regex",
    "title": "Use Simple String Functions Instead of Metacharacter-Free Regex",
    "rationale": "When a regex pattern contains no metacharacter, the regex engine still compiles the pattern, builds its internal automaton and runs the backtracking machinery for a task that a plain substring comparison answers directly. The simple parameters sub, case, start and occurrence are cheaper, immune to escaping mistakes and obvious to reviewers, which matters in hot paths such as log parsing or mass data cleansing. The check reports PREF_PREGX only for literal, non-template patterns that contain none of the metacharacters . [ { ( ) * + ? ^ $ | \\, so genuine regular expressions and dynamically built patterns stay untouched. Textual FIND/REPLACE with REGEX is a separate concern handled by no-obs-strings.",
    "className": "/SKYL/CL_PREF_PLAIN_REGEX",
    "pseudoComment": "PREF_PLAIN_REGEX",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_clean) = replace( val = lv_comment regex = 'TODO' with = 'DONE' ).",
      "good": "DATA(lv_clean) = replace( val = lv_comment sub = 'TODO' with = 'DONE' )."
    },
    "seo": {
      "description": "Replace metacharacter-free regex patterns in ABAP find, replace and count with the sub parameter - avoid regex engine overhead for literal searches.",
      "keywords": [
        "ABAP regex",
        "find sub parameter",
        "pref-plain-regex",
        "string function performance",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "no-obs-strings",
      "pref-str-func",
      "pref-str-tmpl"
    ],
    "customSection": "## Metacharacters that disable the finding\n\n`. [ { ( ) * + ? ^ $ | \\`\n\nAny pattern containing one of these characters is treated as a real regular expression and is not reported.\n\n## Not reported\n\n| Case | Reason |\n| --- | --- |\n| `regex = lv_pattern` | pattern is only known at runtime |\n| `regex = |HELLO|` | string template may embed an expression |\n| `regex = ''` | empty pattern, rejected by the length guard |\n| `find( val = lv_text sub = 'HELLO' )` | no `REGEX` token |\n\n## Replacements\n\n| Reported | Replacement |\n| --- | --- |\n| `find( val = lv_text regex = 'TODO' )` | `find( val = lv_text sub = 'TODO' )` |\n| `replace( val = lv_text regex = 'TODO' with = 'DONE' )` | `replace( val = lv_text sub = 'TODO' with = 'DONE' )` |\n| `count( val = lv_text regex = 'TODO' )` | `count( val = lv_text sub = 'TODO' )` |\n| `contains( val = lv_text regex = 'TODO' )` | `contains( val = lv_text sub = 'TODO' )` |\n\nAdd `case = abap_true` or `case = abap_false` explicitly when the replacement must keep the exact case sensitivity of the original pattern.\n\nPseudo-comment: `\"#EC PREF_PLAIN_REGEX`."
  },
  {
    "ruleId": "max-blank-lines",
    "title": "Limit Consecutive Blank Lines Between Statements",
    "rationale": "Long runs of empty lines break the visual grouping of a method: readers cannot tell whether a block was deleted, a merge conflict happened or the author simply pressed Enter twice, and the code appears to have gaps where logic is missing. Oversized gaps also push related statements apart on screen, so reviews and diffs become harder to follow, especially when comments are separated from the code they describe. The check measures the distance between the end line of the previous statement (including continuation lines) and the start line of the next statement inside a procedure and reports MAX_BLANKL when more than MAX_BLANKS lines are empty. Comment-only lines are invisible to the parser and therefore count as empty space, which keeps the measurement deterministic.",
    "className": "/SKYL/CL_MAX_BLANK_LINES",
    "pseudoComment": "MAX_BLANK_LINES",
    "category": "clean-abap",
    "example": {
      "bad": "DATA(lv_total) = 0.\n\n\nlv_total = lv_total + 10.",
      "good": "DATA(lv_total) = 0.\n\nlv_total = lv_total + 10."
    },
    "parameters": {
      "MAX_BLANKS": "Maximum number of consecutive empty lines allowed between two statements. Default 1 keeps logical groups separated; 0 enforces compact code, 2 tolerates wider visual separation."
    },
    "seo": {
      "description": "Report excessive consecutive blank lines between ABAP statements with a configurable MAX_BLANKS threshold - compact, reviewable method bodies.",
      "keywords": [
        "ABAP blank lines",
        "max-blank-lines",
        "source formatting",
        "code readability",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "max-line-len",
      "max-method-len",
      "max-one-stmt"
    ],
    "customSection": "## How the distance is measured\n\nThe check compares the first line of the current statement with the last line occupied by the previous statement, including continuation lines and a trailing comment on the same line:\n\n```text\ndistance = current_start_line - previous_end_line - 1\n```\n\nA finding is raised when `distance > MAX_BLANKS`.\n\n| `MAX_BLANKS` | Effect |\n| --- | --- |\n| `0` | no empty line allowed between two statements |\n| `1` (default) | one empty line may separate logical groups |\n| `2` | two empty lines are tolerated |\n\n## Notes\n\n- Comment-only lines are not statements and count as empty space, so a comment block surrounded by blank lines can trigger the finding.\n- Multi-line statements are measured with their last token, so a long `SELECT` or constructor expression is never mistaken for a gap.\n- Only procedures are inspected; blank lines in the class definition part are ignored.\n- Suppress the position with `\"#EC MAX_BLANK_LINES` on the statement that follows the gap."
  },
  {
    "ruleId": "pref-read-key",
    "title": "Use WITH KEY Instead of WHERE in READ TABLE Statements",
    "rationale": "Using `READ TABLE ... WHERE` with conjunctions of equality expressions forces a linear row-by-row table scan because the `WHERE` condition does not engage internal table key optimization or binary search. The `WITH KEY` clause (or modern table expression `itab[ ... ]`) enables the ABAP kernel to exploit primary and secondary sorted or hashed keys for logarithmic O(log N) or constant O(1) single-line lookups. The rule specifically detects `WHERE` clauses consisting solely of `=` or `EQ` comparisons connected by `AND`, which are fully convertible to `WITH KEY`, reporting `PREF_READK` to eliminate unnecessary full table scans.",
    "className": "/SKYL/CL_PREF_READ_KEY",
    "pseudoComment": "PREF_READ_KEY",
    "category": "performance",
    "example": {
      "bad": "READ TABLE lt_deliveries INTO ls_delivery\n  WHERE delivery_number = lv_delivery_number\n    AND item_number = lv_item_number.",
      "good": "READ TABLE lt_deliveries INTO ls_delivery\n  WITH KEY delivery_number = lv_delivery_number\n           item_number = lv_item_number."
    },
    "seo": {
      "description": "Improve internal table read performance in ABAP by replacing linear READ TABLE WHERE scans with optimized WITH KEY access or table expressions.",
      "keywords": [
        "pref-read-key",
        "READ TABLE WITH KEY",
        "internal table performance",
        "secondary keys",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-read-table",
      "pref-loop-where"
    ],
    "customSection": "## Scope and Key Optimization\n\nThe check inspects `READ TABLE` statements and flags only those `WHERE` clauses that can be directly mapped to `WITH KEY`:\n- Conditions containing only equality operators (`=` or `EQ`) joined by `AND` are flagged.\n- Conditions containing disjunctions (`OR`), negations (`NOT`), pattern comparisons (`CS`, `CP`, `LIKE`), range expressions (`IN`, `BETWEEN`), or relational inequalities (`>`, `<`, `>=`, `<=`) are not flagged because `WITH KEY` syntax cannot express them.\n\nModern ABAP Cloud code can also replace `READ TABLE ... WITH KEY` with table expressions (e.g. `ls_delivery = VALUE #( lt_deliveries[ delivery_number = lv_delivery_number item_number = lv_item_number ] OPTIONAL ).`)."
  },
  {
    "ruleId": "no-multi-exc",
    "title": "Raise Only One Exception Type per Method",
    "rationale": "Every distinct exception class raised by a method becomes part of its public contract, so callers have to write one CATCH block per type, keep the handler order correct and duplicate cleanup logic in each branch. A single exception type per method, with the error detail carried in attributes or a reason code, keeps the signature stable when a new failure mode appears and lets callers handle everything in one place. The check collects the class name of every RAISE EXCEPTION TYPE/NEW statement per procedure and reports NO_MULTEXC on the first statement that introduces a type different from the one raised first. Both the TYPE and the NEW operand forms are analysed, so modern and legacy raising styles are covered.",
    "className": "/SKYL/CL_NO_MULTI_EXC",
    "pseudoComment": "NO_MULTI_EXC",
    "category": "clean-abap",
    "example": {
      "bad": "IF lv_order_total <= 0.\n  RAISE EXCEPTION NEW zcx_order_invalid_total( ).\nENDIF.\nIF lv_customer_id IS INITIAL.\n  RAISE EXCEPTION NEW zcx_order_missing_customer( ).\nENDIF.",
      "good": "IF lv_order_total <= 0.\n  RAISE EXCEPTION NEW zcx_order_invalid( iv_reason = 'TOTAL' ).\nENDIF.\nIF lv_customer_id IS INITIAL.\n  RAISE EXCEPTION NEW zcx_order_invalid( iv_reason = 'CUSTOMER' ).\nENDIF."
    },
    "seo": {
      "description": "Report methods that raise more than one distinct exception class - enforce a single exception type per ABAP method for simpler TRY CATCH handling.",
      "keywords": [
        "ABAP exception design",
        "RAISE EXCEPTION TYPE",
        "no-multi-exc",
        "single exception class",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-class-exc",
      "no-exc-overlap",
      "no-msg-raising"
    ],
    "customSection": "## How the finding is computed\n\n1. The first `RAISE EXCEPTION TYPE` / `RAISE EXCEPTION NEW` statement of the procedure defines the accepted exception class.\n2. Every later `RAISE` that names a different class is reported as `NO_MULTEXC`.\n\n| Sequence of raised classes | Findings |\n| --- | --- |\n| `zcx_order_invalid`, `zcx_order_invalid` | none |\n| `zcx_order_invalid`, `zcx_missing_customer` | 1 (on `zcx_missing_customer`) |\n| `zcx_a`, `zcx_b`, `zcx_c` | 2 (on `zcx_b` and `zcx_c`) |\n\n## Recommended design\n\n- Raise one dedicated exception class per method and transport the cause in an attribute (`iv_reason`, `iv_failed_field`, `iv_order_id`).\n- If callers really must distinguish cases, define a small exception hierarchy (`zcx_order_error` as superclass, `zcx_order_total` and `zcx_order_customer` as subclasses) and raise the superclass type - one RAISE statement, the caller catches the superclass.\n- `RAISE EXCEPTION TYPE` and `RAISE EXCEPTION NEW` are both analysed; `RAISE` with a resumable or `MESSAGE ... RAISING` pattern is out of scope.\n- Suppress legacy code with `\"#EC NO_MULTI_EXC` on the second `RAISE` statement."
  },
  {
    "ruleId": "no-dyn-message",
    "title": "Avoid Dynamic MESSAGE Statements",
    "rationale": "MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno re-raises whatever the previous failed statement produced: the origin is invisible in the source, SE91 where-used cannot find the message, and the text, severity and even the meaning change with runtime values. Static message identifiers keep the message in the repository, keep ID, TYPE and NUMBER translatable and let static checks such as missing-message or unused-message analysis work. The check reports NO_DYN_MSG when the operands after ID, TYPE and NUMBER are not all literals, so a constant message class and number pass while sy-msg* pass-through or a variable severity is flagged. Inline-text MESSAGE forms and `MESSAGE e001(zmsg)` are handled by pref-msg-cls, not by this rule.",
    "className": "/SKYL/CL_NO_DYN_MESSAGE",
    "pseudoComment": "NO_DYN_MESSAGE",
    "category": "clean-abap",
    "example": {
      "bad": "MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO DATA(lv_message).",
      "good": "MESSAGE e001(zorder_msg) WITH lv_order_id INTO DATA(lv_message)."
    },
    "seo": {
      "description": "Detect dynamic MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno statements in ABAP - keep message class, type and number static for SE91 where-used.",
      "keywords": [
        "ABAP MESSAGE statement",
        "dynamic message ID",
        "SE91 where-used",
        "no-dyn-message",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-msg-cls",
      "no-msg-raising",
      "no-dynamic-stmt"
    ],
    "customSection": "## Analysed statement form\n\nOnly `MESSAGE` with the explicit `ID ... TYPE ... NUMBER ...` operand list is inspected. The finding is raised when at least one of the three operands is not a literal.\n\n| Statement | Finding |\n| --- | --- |\n| `MESSAGE ID 'ZORDER' TYPE 'E' NUMBER '001' INTO DATA(lv_text).` | none |\n| `MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO DATA(lv_text).` | `NO_DYN_MSG` |\n| `MESSAGE ID 'ZORDER' TYPE lv_msgty NUMBER '001' INTO DATA(lv_text).` | `NO_DYN_MSG` |\n| `MESSAGE e001(zorder_msg) INTO DATA(lv_text).` | none |\n\n## Replacing the sy-msg pass-through\n\n| Legacy pattern | Modern pattern |\n| --- | --- |\n| `MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno ...` | raise a typed exception: `RAISE EXCEPTION NEW zcx_order_error( iv_text = lv_text ).` |\n| Re-raise the caught message in `CATCH` | `RAISE EXCEPTION NEW zcx_order_error( previous = lo_error ).` |\n| Dynamic severity from `sy-msgty` | one static `MESSAGE w002(zorder_msg) INTO DATA(lv_text).` per case |\n\nA message that must remain a message should always be written with a static class and number so that SE91 where-used, translation and the message checks keep working. Suppress a single statement with `\"#EC NO_DYN_MESSAGE`."
  },
  {
    "ruleId": "max-when-count",
    "title": "Limit Number of WHEN Branches in CASE Blocks",
    "rationale": "A CASE statement containing more than ten WHEN branches is a classic code smell indicating missing polymorphism, lack of strategy patterns, or hardcoded business rules that belong in customizing or database configuration tables. Long CASE blocks inflate cyclomatic complexity, make unit tests tedious and difficult to achieve comprehensive branch coverage on, and violate the Open-Closed Principle (OCP) because adding a new business variant requires modifying existing procedural control flow. In Clean ABAP and ABAP Cloud, replace oversized CASE blocks with object-oriented polymorphism or factory lookup tables.",
    "className": "/SKYL/CL_MAX_WHEN_COUNT",
    "pseudoComment": "MAX_WHEN_COUNT",
    "category": "metrics",
    "example": {
      "bad": "CASE ls_order_status-status_code.\n  WHEN 'DRAFT'.\n    handle_draft_order( ).\n  WHEN 'SUBMITTED'.\n    handle_submitted_order( ).\n  WHEN 'APPROVED'.\n    handle_approved_order( ).\n  WHEN 'REJECTED'.\n    handle_rejected_order( ).\n  WHEN 'PROCESSING'.\n    handle_processing_order( ).\n  WHEN 'SHIPPED'.\n    handle_shipped_order( ).\n  WHEN 'DELIVERED'.\n    handle_delivered_order( ).\n  WHEN 'INVOICED'.\n    handle_invoiced_order( ).\n  WHEN 'PAID'.\n    handle_paid_order( ).\n  WHEN 'CANCELLED'.\n    handle_cancelled_order( ).\n  WHEN OTHERS.\n    handle_unknown_status( ).\nENDCASE.",
      "good": "DATA lo_order_handler TYPE REF TO zif_order_status_handler.\n\nlo_order_handler = mo_status_factory->get_handler( ls_order_status-status_code ).\nlo_order_handler->process_status( ls_order_status )."
    },
    "parameters": {
      "MAX_WHEN_COUNT": "Maximum number of WHEN clauses (including WHEN OTHERS) allowed in a single CASE statement block (default: 10)."
    },
    "seo": {
      "description": "Limit the number of WHEN branches in ABAP CASE statements to maintain clean polymorphism and low cyclomatic complexity in SAP ATC.",
      "keywords": [
        "max-when-count",
        "CASE WHEN limit ABAP",
        "Clean ABAP CASE",
        "polymorphism refactoring",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "max-cyclo-comp",
      "max-elseif-count",
      "pref-case"
    ],
    "customSection": "## Branch Counting and Stack Behavior\n\n- **Clause Counting**: Every statement with keyword `WHEN` is counted, including `WHEN OTHERS`.\n- **Nesting Support**: An internal stack tracks nested `CASE ... ENDCASE` structures independently. Branches inside an inner `CASE` block do not increment the counter of the enclosing outer block.\n- **Reporting**: When `ENDCASE` is reached and the recorded branch count exceeds `MAX_WHEN_COUNT` (default `10`), finding code `MAX_WHEN` is reported on the opening `CASE` statement.\n\n## Suppression\n\nSuppress a finding with the pseudo-comment `\"#EC MAX_WHEN_COUNT` placed on the opening `CASE` statement."
  },
  {
    "ruleId": "max-elseif-count",
    "title": "Limit Number of ELSEIF Branches in IF Statements",
    "rationale": "Long chains of ELSEIF statements create convoluted decision cascades where earlier conditions implicitly constrain later ones, forcing readers to reconstruct complex truth tables in their heads. When multiple conditions check the same variable for distinct values, Clean ABAP strongly recommends using CASE ... WHEN or SWITCH #( ) instead, which expresses discrete matching clearly and allows the ABAP compiler to optimize branch dispatch. When checking distinct business predicates, polymorphism, dispatch tables, or separating into guard clauses should be preferred to preserve ABAP Cloud testability.",
    "className": "/SKYL/CL_MAX_ELSEIF_COUNT",
    "pseudoComment": "MAX_ELSEIF_COUNT",
    "category": "metrics",
    "example": {
      "bad": "IF lv_region_code = 'NORTH'.\n  apply_regional_rate( '1.05' ).\nELSEIF lv_region_code = 'SOUTH'.\n  apply_regional_rate( '1.08' ).\nELSEIF lv_region_code = 'EAST'.\n  apply_regional_rate( '1.06' ).\nELSEIF lv_region_code = 'WEST'.\n  apply_regional_rate( '1.07' ).\nELSEIF lv_region_code = 'CENTRAL'.\n  apply_regional_rate( '1.04' ).\nELSEIF lv_region_code = 'EXPORT'.\n  apply_regional_rate( '1.00' ).\nELSE.\n  apply_regional_rate( '1.02' ).\nENDIF.",
      "good": "DATA lv_rate_multiplier TYPE string.\n\nlv_rate_multiplier = SWITCH #( lv_region_code\n  WHEN 'NORTH'   THEN '1.05'\n  WHEN 'SOUTH'   THEN '1.08'\n  WHEN 'EAST'    THEN '1.06'\n  WHEN 'WEST'    THEN '1.07'\n  WHEN 'CENTRAL' THEN '1.04'\n  WHEN 'EXPORT'  THEN '1.00'\n  ELSE                '1.02' ).\napply_regional_rate( lv_rate_multiplier )."
    },
    "parameters": {
      "MAX_ELSEIF_COUNT": "Maximum number of ELSEIF clauses allowed per IF control block before recommending CASE or SWITCH (default: 5)."
    },
    "seo": {
      "description": "Limit ELSEIF clauses in ABAP IF statements to avoid tangled decision cascades and encourage modern SWITCH or CASE structures.",
      "keywords": [
        "max-elseif-count",
        "ELSEIF limit ABAP",
        "Clean ABAP IF",
        "SWITCH constructor ABAP",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "max-cyclo-comp",
      "max-when-count",
      "pref-case"
    ],
    "customSection": "## Detection Rules\n\n- **Clause Counting**: Counts each `ELSEIF` statement within an `IF ... ENDIF` block. The final `ELSE` branch is not counted as an `ELSEIF`.\n- **Nesting Support**: Evaluated per block level via an internal statement stack; inner `IF` blocks have their own independent counters and do not affect outer blocks.\n- **Reporting**: When `ENDIF` is reached and the count of `ELSEIF` statements exceeds `MAX_ELSEIF_COUNT` (default `5`), finding code `MAX_ELSEIF` is reported on the opening `IF` statement.\n\n## Suppression\n\nSuppress the check using the pseudo-comment `\"#EC MAX_ELSEIF_COUNT` placed on the opening `IF` statement."
  },
  {
    "ruleId": "max-loop-jumps",
    "title": "Limit Jump Statements (CONTINUE and EXIT) per Loop",
    "rationale": "Loops with multiple scattered CONTINUE and EXIT statements introduce unstructured control jumps that make it difficult to reason about loop invariants, post-conditions, and iteration state. Clean ABAP recommends keeping loop bodies small, predictable, and focused on processing elements. When a loop requires three or more jumps, filtering criteria should be pushed into a WHERE condition on the LOOP AT statement, iterations should use table expressions or FILTER #( ), or inner processing logic should be encapsulated inside a dedicated helper method to maintain Clean Core maintainability.",
    "className": "/SKYL/CL_MAX_LOOP_JUMPS",
    "pseudoComment": "MAX_LOOP_JUMPS",
    "category": "metrics",
    "example": {
      "bad": "LOOP AT lt_billing_items ASSIGNING FIELD-SYMBOL(<ls_item>).\n  IF <ls_item>-is_deleted = abap_true.\n    CONTINUE.\n  ENDIF.\n  IF <ls_item>-quantity <= 0.\n    CONTINUE.\n  ENDIF.\n  IF <ls_item>-is_fatal_error = abap_true.\n    EXIT.\n  ENDIF.\n  process_billing_item( <ls_item> ).\nENDLOOP.",
      "good": "LOOP AT lt_billing_items ASSIGNING FIELD-SYMBOL(<ls_item>)\n     WHERE is_deleted = abap_false AND quantity > 0.\n  IF process_item_safely( <ls_item> ) = abap_false.\n    EXIT.\n  ENDIF.\nENDLOOP."
    },
    "parameters": {
      "MAX_LOOP_JUMPS": "Maximum allowed jump statements (CONTINUE or EXIT) within a single LOOP, DO, or WHILE iteration block (default: 2)."
    },
    "seo": {
      "description": "Limit CONTINUE and EXIT statements per ABAP loop to prevent tangled loop control flow and improve iteration readability in SAP ATC.",
      "keywords": [
        "max-loop-jumps",
        "CONTINUE EXIT limit",
        "Clean ABAP loop",
        "loop control flow",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "no-check-stmt",
      "no-nested-loop",
      "max-cyclo-comp"
    ],
    "customSection": "## Detection Scope\n\nThe check inspects all loop constructs (`LOOP AT ...`, `DO ... TIMES`, and `WHILE ...`):\n\n- **Jump Statements**: Counts each statement with keyword `CONTINUE` or `EXIT`.\n- **Nesting Isolation**: An internal loop stack tracks jumps per loop level. Jumps within an inner loop do not affect the jump counter of the outer enclosing loop.\n- **Reporting**: When `ENDLOOP`, `ENDDO`, or `ENDWHILE` is reached and the count of jump statements exceeds `MAX_LOOP_JUMPS` (default `2`), finding `MAX_JUMPS` is reported on the opening loop statement (`LOOP`, `DO`, or `WHILE`).\n\n## Suppression\n\nSuppress a finding using the pseudo-comment `\"#EC MAX_LOOP_JUMPS` placed on the opening loop statement (`LOOP`, `DO`, `WHILE`)."
  },
  {
    "ruleId": "max-catch-clauses",
    "title": "Limit Number of CATCH Clauses per TRY Block",
    "rationale": "A TRY block that catches four or more distinct exception classes is a clear symptom of high error-handling coupling and indicates that the enclosed code performs too many heterogeneous operations. In clean object-oriented architecture, exceptions should be organized into meaningful package or component hierarchies sharing common abstract superclasses (e.g., cx_static_check or custom zcx_application_error). Catching too many individual leaf exceptions clutters the procedure with redundant error-handling blocks. Catching at the appropriate level of abstraction produces cleaner, more resilient error handling in ABAP Cloud.",
    "className": "/SKYL/CL_MAX_CATCH_CLAUSES",
    "pseudoComment": "MAX_CATCH_CLAUSES",
    "category": "metrics",
    "example": {
      "bad": "TRY.\n    execute_financial_posting( ls_posting_payload ).\n  CATCH zcx_currency_conversion_error.\n    handle_currency_error( ).\n  CATCH zcx_account_determination_err.\n    handle_account_error( ).\n  CATCH zcx_posting_period_closed.\n    handle_period_error( ).\n  CATCH zcx_fiscal_year_variant_err.\n    handle_fiscal_error( ).\nENDTRY.",
      "good": "TRY.\n    execute_financial_posting( ls_posting_payload ).\n  CATCH zcx_financial_posting_error INTO DATA(lx_posting_error).\n    log_posting_failure( lx_posting_error ).\nENDTRY."
    },
    "parameters": {
      "MAX_CATCH_CLAUSES": "Maximum number of CATCH clauses allowed for a single TRY block before recommending exception hierarchy consolidation (default: 3)."
    },
    "seo": {
      "description": "Limit CATCH clauses per ABAP TRY block to prevent bloated error handling and enforce clean exception hierarchy design in SAP ATC.",
      "keywords": [
        "max-catch-clauses",
        "TRY CATCH limit ABAP",
        "Clean ABAP exceptions",
        "error handling coupling",
        "SAP ATC metrics"
      ]
    },
    "relatedRules": [
      "no-catch-root",
      "pref-class-exc"
    ],
    "customSection": "## Analysis Mechanics\n\n- **Clause Counting**: Counts each statement with keyword `CATCH`. Note that multiple exception types grouped in a single statement (e.g., `CATCH cx_one cx_two INTO lx_ex.`) count as one `CATCH` clause.\n- **Nesting Support**: An internal stack tracks nested `TRY ... ENDTRY` blocks independently.\n- **Reporting**: When `ENDTRY` is encountered and the number of `CATCH` statements exceeds `MAX_CATCH_CLAUSES` (default `3`), finding code `MAX_CATCH` is reported on the opening `TRY` statement.\n\n## Suppression\n\nSuppress the check with the pseudo-comment `\"#EC MAX_CATCH_CLAUSES` placed on the opening `TRY` statement."
  },
  {
    "ruleId": "pref-clamp",
    "title": "Replace Manual IF Range Clamping with nmin( ) and nmax( )",
    "rationale": "Clamping a value by hand costs five statements, introduces two branches that must be reviewed and tested separately, and can silently drift when one bound changes but the other does not. The built-in functions nmin( ) and nmax( ) express the same range containment as a single expression without control flow, so it can be inlined into a constructor expression, debugged in one step and unit tested as pure arithmetic. The check reports PREF_CLAMP only for the exact five-statement pattern IF / assignment / ELSEIF / assignment / ENDIF where both conditions compare the same variable with the assigned bound in opposite directions. The TO_NMINMAX quickfix rewrites the whole block, keeping the original indentation, so the migration is a single click.",
    "className": "/SKYL/CL_PREF_CLAMP",
    "pseudoComment": "PREF_CLAMP",
    "category": "clean-abap",
    "example": {
      "bad": "DATA lv_discount_pct TYPE i VALUE 130.\nIF lv_discount_pct < 0.\n  lv_discount_pct = 0.\nELSEIF lv_discount_pct > 100.\n  lv_discount_pct = 100.\nENDIF.",
      "good": "DATA lv_discount_pct TYPE i VALUE 130.\nlv_discount_pct = nmin( val1 = 100\n                        val2 = nmax( val1 = 0\n                                     val2 = lv_discount_pct ) )."
    },
    "seo": {
      "description": "Detect manual IF ELSEIF range clamping in ABAP and rewrite it with nmin and nmax - branch-free, testable value clamping with an automatic quickfix.",
      "keywords": [
        "ABAP clamp",
        "nmin nmax",
        "manual range check",
        "pref-clamp",
        "Clean ABAP expressions"
      ]
    },
    "relatedRules": [
      "pref-between",
      "pref-cond",
      "pref-switch"
    ],
    "customSection": "## Exact pattern\n\nAll five statements must be adjacent and match this shape:\n\n```abap\nIF lv_discount_pct < 0.\n  lv_discount_pct = 0.\nELSEIF lv_discount_pct > 100.\n  lv_discount_pct = 100.\nENDIF.\n```\n\n- The comparison operator may be `<`, `LT`, `<=`, `LE`, `>`, `GT`, `>=` or `GE`, and the variable may stand on either side of the operator - the direction is normalised.\n- Both conditions must compare the *same* variable, and each branch must assign the *other* bound to it.\n- Parentheses around the conditions (`IF ( lv < lo ).`) are stripped before analysis.\n\n## Not reported\n\n| Shape | Why |\n| --- | --- |\n| Two separate `IF ... ENDIF` blocks | there is no `ELSEIF` chain |\n| `IF ... ELSEIF ... ELSE ... ENDIF` | the chain has a third branch |\n| Branch assigns a literal instead of the compared bound | not a clamp |\n| Condition and assignment use different variables | no clamp pattern |\n\n## QuickFix\n\n`TO_NMINMAX` replaces the five statements with one expression, preserving indentation:\n\n```abap\nlv_discount_pct = nmin( val1 = 100 val2 = nmax( val1 = 0 val2 = lv_discount_pct ) ).\n```"
  },
  {
    "ruleId": "no-nested-loop",
    "title": "Avoid Unindexed Nested LOOP AT Statements",
    "rationale": "Nesting unindexed `LOOP AT` statements against standard internal tables creates quadratic O(N*M) algorithmic complexity. As datasets grow in production, nested linear iterations consume excessive CPU time, exhaust work process runtimes, and cause severe performance degradation. Application logic requiring line matching between collections should utilize sorted/hashed secondary keys with targeted reads, modern `LOOP AT ... GROUP BY` constructs, or a parallel cursor approach using `LOOP AT ... FROM index WHERE ...`. The check reports `NO_NEST_LP` on nested table loops that omit grouping or index constraints.",
    "className": "/SKYL/CL_NO_NESTED_LOOP",
    "pseudoComment": "NO_NESTED_LOOP",
    "category": "performance",
    "example": {
      "bad": "LOOP AT lt_sales_orders INTO ls_sales_order.\n  LOOP AT lt_order_items INTO ls_order_item\n    WHERE sales_order = ls_sales_order-sales_order.\n    CLEAR ls_order_item.\n  ENDLOOP.\nENDLOOP.",
      "good": "LOOP AT lt_sales_orders INTO ls_sales_order.\n  LOOP AT lt_order_items INTO ls_order_item\n    FROM lv_start_index\n    WHERE sales_order = ls_sales_order-sales_order.\n    CLEAR ls_order_item.\n  ENDLOOP.\nENDLOOP."
    },
    "seo": {
      "description": "Detect nested LOOP AT statements in ABAP to prevent O(N*M) performance bottlenecks and enforce parallel cursor or GROUP BY patterns.",
      "keywords": [
        "no-nested-loop",
        "nested LOOP AT",
        "parallel cursor",
        "internal table performance",
        "GROUP BY loop"
      ]
    },
    "relatedRules": [
      "pref-loop-where",
      "pref-read-table",
      "max-loop-jumps"
    ],
    "customSection": "## Exemptions and Performance Alternatives\n\nThe check ignores nested loops when either loop employs performance-optimized access patterns:\n\n| Pattern | Detection | Rationale |\n|---|---|---|\n| Parallel Cursor | `LOOP AT itab FROM index ...` | Restricts inner loop scan start using a binary-search index (`sy-tabix`), avoiding full scans. |\n| Grouping Loops | `LOOP AT itab ... GROUP BY ...` and `LOOP AT GROUP` | Native kernel grouping avoids quadratic traversal. |\n| Non-table Loops | `DO ... ENDDO` or `WHILE ... ENDWHILE` | Only `LOOP AT <itab>` is evaluated. |\n| Screen Loops | `LOOP AT SCREEN` | UI screen loops are explicitly exempted. |\n\nTo suppress intentional small-table nested loops, use `\"#EC NO_NESTED_LOOP` or `##NO_NESTED_LOOP`."
  },
  {
    "ruleId": "no-full-scan-sel",
    "title": "Avoid Unfiltered SELECT Statements on Database Tables",
    "rationale": "Executing a `SELECT` statement on a database table without a `WHERE` clause triggers a full table scan, bypassing primary and secondary database indexes. In production environments with millions of records in transactional or master data tables, full table scans saturate SAP HANA memory, exhaust network bandwidth between the database and application server, and cause severe response time degradation. Every database read must be restricted with an index-supported `WHERE` filter or explicitly bound using `UP TO n ROWS` when pagination or sampling is intended. The check reports `NO_FULL_SC` on unfiltered table reads.",
    "className": "/SKYL/CL_NO_FULL_SCAN_SEL",
    "pseudoComment": "NO_FULL_SCAN_SELECT",
    "category": "performance",
    "example": {
      "bad": "SELECT sales_order, customer_id, net_amount\n  FROM zso_header\n  INTO TABLE @DATA(lt_orders).",
      "good": "SELECT sales_order, customer_id, net_amount\n  FROM zso_header\n  WHERE customer_id = @lv_customer_id\n    AND order_status = 'OPEN'\n  INTO TABLE @DATA(lt_orders)."
    },
    "parameters": {
      "ALLOW_UP_TO_N": "Allow SELECT statements without an explicit WHERE clause when restricted by an UP TO n ROWS addition (default: false)."
    },
    "seo": {
      "description": "Prevent full database table scans in ABAP SQL by enforcing WHERE conditions on SELECT queries across SAP S/4HANA and ABAP Cloud.",
      "keywords": [
        "no-full-scan-sel",
        "full table scan",
        "SELECT WHERE",
        "ABAP SQL performance",
        "SAP HANA index"
      ]
    },
    "relatedRules": [
      "no-unfilt-dml",
      "no-bypass-buf",
      "no-select-star"
    ],
    "customSection": "## Configuration and Filtering Guidelines\n\n| Parameter | Type | Default | Description |\n|---|---|---|---|\n| `ALLOW_UP_TO_N` | Boolean | `false` | When enabled (`true`), queries containing `UP TO n ROWS` are exempted from the `WHERE` requirement. |\n\n### Exceptions and Behavior\n- **Internal Table Queries:** Queries selecting from host internal tables (e.g. `SELECT ... FROM @lt_itab AS itab`) are automatically exempted because they do not query the database.\n- **Table Buffering:** Even for buffered customizing tables, omitting `WHERE` can trigger full table buffer loads. Always provide key filters when reading specific records.\n- **Suppression:** Legitimate administrative full-table extractors (e.g. archiving jobs or migration tools) can be suppressed using `\"#EC NO_FULL_SCAN_SELECT` or `##NO_FULL_SCAN_SELECT`."
  },
  {
    "ruleId": "no-bypass-buf",
    "title": "Avoid BYPASSING BUFFER in ABAP SQL Queries",
    "rationale": "Specifying `BYPASSING BUFFER` in ABAP SQL forces an immediate direct roundtrip to the underlying database, explicitly circumventing the high-speed SAP table buffer on the application server. For customizing, configuration, and master data tables configured with single-record or generic buffering, bypassing the buffer creates redundant database network traffic, CPU overhead, and table locks. Relying on application server buffer synchronization preserves database capacity and yields sub-millisecond response times. The check reports `NO_BYP_BUF` to protect application server caching benefits.",
    "className": "/SKYL/CL_NO_BYPASS_BUF",
    "pseudoComment": "NO_BYPASS_BUFFER",
    "category": "performance",
    "example": {
      "bad": "SELECT country_code, country_name\n  FROM zcountry_config\n  BYPASSING BUFFER\n  WHERE country_code = @lv_country_code\n  INTO @DATA(ls_country).",
      "good": "SELECT SINGLE country_code, country_name\n  FROM zcountry_config\n  WHERE country_code = @lv_country_code\n  INTO @DATA(ls_country)."
    },
    "seo": {
      "description": "Prevent unnecessary database roundtrips by avoiding BYPASSING BUFFER on SAP table buffered entities in ABAP Cloud.",
      "keywords": [
        "no-bypass-buf",
        "BYPASSING BUFFER",
        "SAP table buffer",
        "ABAP SQL performance",
        "database caching"
      ]
    },
    "relatedRules": [
      "no-full-scan-sel",
      "no-select-star",
      "pref-read-table"
    ],
    "customSection": "## Application Server Buffering Impact\n\n| Buffer State | Execution Path | Latency Impact |\n|---|---|---|\n| Buffered (`SELECT`) | Read directly from Application Server shared memory | Microseconds (< 0.1 ms), zero DB CPU load |\n| `BYPASSING BUFFER` | Network hop + Database optimizer planning + physical read | Milliseconds (1 - 10 ms), DB connection consumption |\n\n### Valid Exceptions\n- When reading immediately after an update in the same logical unit of work (LUW) before the database commit or buffer invalidation telegrams have propagated.\n- Administrative buffer diagnosis utilities.\n- Suppress necessary occurrences using `\"#EC NO_BYPASS_BUFFER` or `##NO_BYPASS_BUFFER`."
  },
  {
    "ruleId": "no-cross-join",
    "title": "Avoid Unconstrained CROSS JOIN in ABAP SQL Queries",
    "rationale": "A `CROSS JOIN` computes the full Cartesian product (M * N rows) between two database tables without an `ON` join condition. When executed on non-trivial business tables, Cartesian products produce exponential row proliferation, exhausting SAP HANA memory limits and triggering database out-of-memory (OOM) aborts or critical query timeouts. In modern Clean ABAP and relational modeling, table relationships must always be explicitly defined using `INNER JOIN` or `LEFT OUTER JOIN` with strict `ON` predicate conditions, or generated through structured domain views. The check reports `NO_CROSS_J`.",
    "className": "/SKYL/CL_NO_CROSS_JOIN",
    "pseudoComment": "NO_CROSS_JOIN",
    "category": "performance",
    "example": {
      "bad": "SELECT FROM zplant CROSS JOIN zstorage_loc\n  FIELDS zplant~plant_id, zstorage_loc~storage_loc_id\n  INTO TABLE @DATA(lt_locations).",
      "good": "SELECT FROM zplant\n  INNER JOIN zstorage_loc ON zplant~plant_id = zstorage_loc~plant_id\n  FIELDS zplant~plant_id, zstorage_loc~storage_loc_id\n  INTO TABLE @DATA(lt_locations)."
    },
    "seo": {
      "description": "Avoid Cartesian products in ABAP SQL by prohibiting unconstrained CROSS JOIN queries to protect SAP HANA memory and query runtimes.",
      "keywords": [
        "no-cross-join",
        "CROSS JOIN",
        "Cartesian product",
        "ABAP SQL performance",
        "SAP HANA"
      ]
    },
    "relatedRules": [
      "no-full-scan-sel",
      "pref-join-type",
      "pref-strict-sql"
    ],
    "customSection": "## Cartesian Product Risks\n\n| Join Type | Relationship | Complexity | HANA Memory Impact |\n|---|---|---|---|\n| `CROSS JOIN` | Unbounded Cartesian product | $O(M \\times N)$ | Exponential row growth, risk of out-of-memory abort |\n| `INNER JOIN ... ON` | Key-constrained intersection | $O(M)$ with index | Controlled, index-accelerated join |\n| `LEFT OUTER JOIN ... ON` | Key-constrained outer join | $O(M)$ with index | Controlled, null-padded match |\n\n### Mitigations\n- Connect all joined sources with explicit `ON` conditions matching foreign key relationships.\n- In rare scenarios where a Cartesian combination of small fixed lookup tables (e.g. matrix of calendar months and currencies) is mathematically required, suppress the finding with `\"#EC NO_CROSS_JOIN` or `##NO_CROSS_JOIN`."
  },
  {
    "ruleId": "no-sql-hints",
    "title": "Avoid Database Hints (%_HINTS) in ABAP SQL Queries",
    "rationale": "Hardcoding database hints via `%_HINTS` overrides the database cost-based optimizer and couples application code to specific database platforms (such as SAP HANA, Oracle, or IBM DB6). Proprietary hints break database portability, fail syntax validation in modern ABAP Cloud (Contract C1), and prevent the database engine from adapting query plans when data volume or distribution evolves. Query performance must instead be tuned through proper index design, index-aligned `WHERE` filtering, CDS view pushdown, and query restructuring. The check flags `%_HINTS` tokens with `NO_SQL_HNT`.",
    "className": "/SKYL/CL_NO_SQL_HINTS",
    "pseudoComment": "NO_SQL_HINTS",
    "category": "performance",
    "example": {
      "bad": "SELECT sales_order, order_type, net_amount\n  FROM zso_header\n  INTO TABLE @DATA(lt_orders)\n  %_HINTS HDB 'INDEX_SEARCH'.",
      "good": "SELECT sales_order, order_type, net_amount\n  FROM zso_header\n  WHERE customer_id = @lv_customer_id\n  INTO TABLE @DATA(lt_orders)."
    },
    "seo": {
      "description": "Eliminate database hints (%_HINTS) in ABAP SQL to ensure database portability, ABAP Cloud compliance, and cost-based optimizer adaptability.",
      "keywords": [
        "no-sql-hints",
        "%_HINTS",
        "database hints",
        "ABAP SQL performance",
        "ABAP Cloud Contract C1"
      ]
    },
    "relatedRules": [
      "no-full-scan-sel",
      "pref-strict-sql"
    ],
    "customSection": "## Portability and ABAP Cloud Contract C1\n\n| Aspect | Detail |\n|---|---|\n| Finding Code | `NO_SQL_HNT` |\n| Default Severity | Warning |\n| Pseudo Comment | `\"#EC NO_SQL_HINTS` |\n| Cloud Readiness | `%_HINTS` is strictly prohibited in ABAP Cloud / Steampunk development contracts |\n\n### Tuning Strategies without Hints\n- **Secondary Indexes:** Ensure the database table has secondary indexes covering the leading fields of your `WHERE` condition.\n- **Selective Projections:** Select only required columns rather than `*` to enable index-only or column-store scan optimizations.\n- **CDS Data Modeling:** Push complex calculations, joins, and aggregations into CDS views where SAP HANA can leverage optimized calculation engines automatically."
  },
  {
    "ruleId": "no-lead-wildcard",
    "title": "Avoid Leading Wildcards in SQL LIKE Predicates",
    "rationale": "Using a leading wildcard (`%` or `_`) in an SQL `LIKE` condition (such as `LIKE '%text'` or `LIKE '_text'`) forces a full column or table scan because B-tree and database inverted indexes cannot be searched from the root without a fixed prefix. On high-volume database tables, unindexed substring searches cause severe CPU spikes and excessive disk I/O. Where prefix matching satisfies requirements, anchor searches with a leading character prefix (e.g. `LIKE 'prefix%'`), or leverage SAP HANA full-text search indexes with fuzzy matching for arbitrary substring queries. The check reports `NO_LD_WILD`.",
    "className": "/SKYL/CL_NO_LEAD_WILDCARD",
    "pseudoComment": "NO_LEAD_WILDCARD",
    "category": "performance",
    "example": {
      "bad": "SELECT customer_id, customer_name, country_code\n  FROM zcustomer\n  WHERE customer_name LIKE '%CORP'\n  INTO TABLE @DATA(lt_customers).",
      "good": "SELECT customer_id, customer_name, country_code\n  FROM zcustomer\n  WHERE customer_name LIKE 'CORP%'\n  INTO TABLE @DATA(lt_customers)."
    },
    "seo": {
      "description": "Prevent full table scans in ABAP Open SQL by avoiding leading wildcards in LIKE predicates and utilizing prefix index scans.",
      "keywords": [
        "no-lead-wildcard",
        "LIKE wildcard",
        "full table scan",
        "ABAP SQL performance",
        "database index"
      ]
    },
    "relatedRules": [
      "no-full-scan-sel",
      "pref-between"
    ],
    "customSection": "## Index Utilization and Search Alternatives\n\n| Search Pattern | Index Usage | Performance Characteristic |\n|---|---|---|\n| `LIKE 'prefix%'` | **Index Range Scan** | Fast; binary search locates the start position in the index tree. |\n| `LIKE '%suffix'` | **Full Table / Index Scan** | Slow; every entry must be inspected to check the suffix. |\n| `LIKE '%contains%'` | **Full Table / Index Scan** | Slow; cannot traverse index trees without prefix anchoring. |\n| `LIKE '_single'` | **Full Table / Index Scan** | Slow; single-character wildcard at position 1 prevents index lookup. |\n\n### Architectural Recommendations\n- **Prefix Anchoring:** Whenever business requirements allow, anchor searches at the beginning of the field.\n- **HANA Search:** For flexible substring searches on large master data tables, declare full-text indexes or use the SAP HANA fuzzy search operator `CONTAINS( ... FUZZY( ... ) )`.\n- **Suppression:** Suppress unavoidable leading wildcard scans using `\"#EC NO_LEAD_WILDCARD` or `##NO_LEAD_WILDCARD`."
  },
  {
    "ruleId": "no-dedup-no-sort",
    "title": "Sort Internal Tables Before DELETE ADJACENT DUPLICATES",
    "rationale": "In ABAP, DELETE ADJACENT DUPLICATES only checks immediately adjacent rows in internal table sequence. If the table is not sorted beforehand, identical entries separated by other rows are retained, leading to incomplete deduplication and corrupt business data. Unless the table is defined as SORTED TABLE, always precede DELETE ADJACENT DUPLICATES with a SORT statement referencing matching sort keys.",
    "className": "/SKYL/CL_NO_DEDUP_NO_SORT",
    "pseudoComment": "NO_DEDUP_NO_SORT",
    "category": "anti-patterns",
    "example": {
      "bad": "DELETE ADJACENT DUPLICATES FROM lt_business_partners COMPARING partner_id.",
      "good": "SORT lt_business_partners BY partner_id ASCENDING.\nDELETE ADJACENT DUPLICATES FROM lt_business_partners COMPARING partner_id."
    },
    "seo": {
      "description": "Require explicit SORT before DELETE ADJACENT DUPLICATES on ABAP internal tables to prevent incomplete deduplication bugs.",
      "keywords": [
        "DELETE ADJACENT DUPLICATES",
        "SORT internal table",
        "ABAP deduplication",
        "Clean ABAP",
        "SAP ATC check",
        "no-dedup-no-sort"
      ]
    },
    "relatedRules": [
      "pref-sort-key",
      "pref-sort-order"
    ],
    "customSection": "### Verification mechanism\n\nThe rule verifies that every `DELETE ADJACENT DUPLICATES FROM <itab>` statement is preceded by an explicit `SORT <itab>` statement in the same procedure, matching the target internal table symbol.\n\n| Statement Sequence | Finding Raised |\n| --- | --- |\n| `DELETE ADJACENT DUPLICATES FROM lt_data.` | yes (`NO_DEDUP_S`) |\n| `SORT lt_other. DELETE ADJACENT DUPLICATES FROM lt_data.` | yes (`NO_DEDUP_S`, sorted wrong table) |\n| `SORT lt_data. DELETE ADJACENT DUPLICATES FROM lt_data.` | no |\n\n### Key Consistency\n\nEnsure that the fields specified in `SORT itab BY ...` match the fields in `COMPARING ...`. If `COMPARING` is omitted, the default table key is used for both operations.\n\n### Suppression\n\nFor tables inherently sorted by construction or database query order, suppress with `\"#EC NO_DEDUP_NO_SORT`."
  },
  {
    "ruleId": "no-dup-subexpr",
    "title": "Avoid Duplicate Subexpressions in a Single Statement",
    "rationale": "Repeating identical subexpressions - such as table expressions (lt_items[ 1 ]-amount) or functional method calls (lo_calc->get_rate( )) - within a single statement causes redundant table lookups, secondary hash computations, or repeated method invocations. In performance-critical logic, this wastes CPU cycles and increases runtime overhead. Evaluate common subexpressions once into a local helper variable or field symbol.",
    "className": "/SKYL/CL_NO_DUP_SUBEXP",
    "pseudoComment": "NO_DUP_SUBEXPR",
    "category": "anti-patterns",
    "example": {
      "bad": "lv_total_amount = lt_order_items[ 1 ]-net_amount + lt_order_items[ 1 ]-tax_amount.",
      "good": "DATA(ls_order_item) = lt_order_items[ 1 ].\nlv_total_amount = ls_order_item-net_amount + ls_order_item-tax_amount."
    },
    "seo": {
      "description": "Detect duplicate table expressions and method calls in ABAP statements to apply Common Subexpression Elimination.",
      "keywords": [
        "duplicate table expression",
        "common subexpression ABAP",
        "ABAP performance",
        "Clean ABAP",
        "SAP ATC check",
        "no-dup-subexpr"
      ]
    },
    "relatedRules": [
      "pref-read-table",
      "no-dedup-no-sort",
      "pref-sort-key"
    ],
    "customSection": "### Subexpressions detected\n\nThe check scans statements for duplicate subexpressions, focusing on:\n- Table expressions with square brackets: `itab[ ... ]`\n- Functional method invocations: `oref->method( ... )` or `class=>method( ... )`\n\n| Statement Pattern | Finding Raised |\n| --- | --- |\n| `lv_tot = lt_orders[ 1 ]-net + lt_orders[ 1 ]-tax.` | yes (`NO_DUPSBX`) |\n| `lv_val = lo_calc->eval( 10 ) + lo_calc->eval( 10 ).` | yes (`NO_DUPSBX`) |\n| `DATA(ls) = lt_orders[ 1 ]. lv_tot = ls-net + ls-tax.` | no (Common Subexpression Eliminated) |\n| `lv_tot = lt_orders[ 1 ]-net + lt_orders[ 2 ]-tax.` | no (Different subexpression indices) |\n\n### Suppression\n\nWhen duplicate subexpressions have side effects or intentional non-deterministic results, suppress with `\"#EC NO_DUP_SUBEXPR`."
  },
  {
    "ruleId": "no-badi-commit",
    "title": "Avoid COMMIT and ROLLBACK WORK Inside BAdI Implementations",
    "rationale": "Business Add-Ins (BAdIs) execute within the caller's Logical Unit of Work (LUW). Triggering COMMIT WORK or ROLLBACK WORK inside a BAdI implementation prematurely terminates the caller's transaction boundary, triggers background update tasks unexpectedly, and invalidates SAP database locks. This leads to critical database inconsistencies and runtime short dumps (e.g. COMMIT_IN_POSTING). Transaction boundaries must remain under the orchestrating caller's control.",
    "className": "/SKYL/CL_NO_BADI_COMMIT",
    "pseudoComment": "NO_BADI_COMMIT",
    "category": "anti-patterns",
    "example": {
      "bad": "METHOD if_badi_interface~execute.\n  save_custom_audit_log( ).\n  COMMIT WORK.\nENDMETHOD.",
      "good": "METHOD if_badi_interface~execute.\n  save_custom_audit_log( ).\n  \" Transaction boundaries are controlled by the calling orchestrator\nENDMETHOD."
    },
    "seo": {
      "description": "Prohibit COMMIT WORK and ROLLBACK WORK in ABAP BAdI implementations to safeguard SAP LUW transactional integrity.",
      "keywords": [
        "BAdI COMMIT WORK",
        "SAP LUW integrity",
        "IF_BADI_INTERFACE",
        "Clean ABAP transactions",
        "SAP ATC check",
        "no-badi-commit"
      ]
    },
    "relatedRules": [
      "no-unclosed-res",
      "no-scope-leak"
    ],
    "customSection": "### LUW integrity and BAdIs\n\nClasses implementing `IF_BADI_INTERFACE` participate in SAP transactional units managed by standard or orchestrating applications:\n\n| Command in BAdI Method | Risk | Finding |\n| --- | --- | --- |\n| `COMMIT WORK.` | Triggers premature commit, flushes update tasks, releases enqueue locks | `NO_BADI_CM` |\n| `ROLLBACK WORK.` | Destroys caller's uncommitted transaction state | `NO_BADI_CM` |\n| Asynchronous update via `CALL FUNCTION ... IN UPDATE TASK` | Registered for caller's eventual commit | Compliant |\n\n### Remote Enablement Note\n\nThis check utilizes ABAP Run-Time Type Identification (RTTI) to inspect whether the enclosing class implements `IF_BADI_INTERFACE`. As a result, `remote_enablement` is set to `abap_false` by design to prevent RFC failures in remote ATC scenarios.\n\n### Suppression\n\nIn exceptional standalone test runners, suppress with `\"#EC NO_BADI_COMMIT`."
  },
  {
    "ruleId": "pref-opt-last",
    "title": "Declare OPTIONAL and DEFAULT Parameters Last",
    "rationale": "When an OPTIONAL or DEFAULT parameter precedes a mandatory one, callers must either use named parameter notation or fill the optional slot just to reach the required argument, which produces confusing positional calls and hides which values are really supplied. Keeping mandatory parameters first and optional ones last makes positional and named calls predictable and keeps the signature stable when a new optional parameter is appended. The check parses the IMPORTING and CHANGING sections of every METHODS and CLASS-METHODS statement and reports PREF_OPT_L on the first mandatory parameter that follows an optional or defaulted one. EXPORTING and RETURNING are ignored because they are always optional for the caller.",
    "className": "/SKYL/CL_PREF_OPT_LAST",
    "pseudoComment": "PREF_OPTIONAL_LAST",
    "category": "clean-abap",
    "example": {
      "bad": "CLASS zcl_order_service DEFINITION\n  PUBLIC\n  CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS create_order\n      IMPORTING\n        iv_priority TYPE i OPTIONAL\n        iv_customer TYPE kunnr.\nENDCLASS.",
      "good": "CLASS zcl_order_service DEFINITION\n  PUBLIC\n  CREATE PUBLIC.\n  PUBLIC SECTION.\n    METHODS create_order\n      IMPORTING\n        iv_customer TYPE kunnr\n        iv_priority TYPE i OPTIONAL.\nENDCLASS."
    },
    "seo": {
      "description": "Enforce parameter order in ABAP method signatures: mandatory IMPORTING and CHANGING parameters before OPTIONAL and DEFAULT ones for predictable calls.",
      "keywords": [
        "ABAP OPTIONAL parameter",
        "DEFAULT parameter order",
        "method signature",
        "pref-opt-last",
        "Clean ABAP"
      ]
    },
    "relatedRules": [
      "pref-param-name",
      "pref-param-1line",
      "max-params"
    ],
    "customSection": "## Scope\n\n| Section | Inspected |\n| --- | --- |\n| `IMPORTING` | yes |\n| `CHANGING` | yes |\n| `EXPORTING` | no - always optional for the caller |\n| `RETURNING` | no - single mandatory value |\n\n- `OPTIONAL` and `DEFAULT` both count as optional; `DEFAULT` often hides the problem because callers can omit the value silently.\n- The state resets per section, so an optional `EXPORTING` parameter never influences the `IMPORTING` order.\n- Each mandatory parameter that follows an optional one is reported, so a signature with two violations produces two findings.\n- Only class definition procedures are inspected; `FORM`/`FUNCTION` interfaces are not part of this rule.\n\n## Notes\n\n- `METHODS` and `CLASS-METHODS` are both analysed, and the finding points at the offending parameter token, not at the whole statement.\n- Suppress a released API with `\"#EC PREF_OPTIONAL_LAST` on the `METHODS` / `CLASS-METHODS` statement when its historical parameter order cannot change.\n- Appending a new `OPTIONAL` parameter at the end is source-compatible for existing callers; inserting it in the middle is not."
  },
  {
    "ruleId": "pref-cloud-ready",
    "title": "Use Only Statements Available in ABAP Cloud",
    "rationale": "ABAP Cloud restricts development to a strictly released subset of language elements and APIs. Classic statements such as SUBMIT, CALL TRANSACTION, EXEC SQL, or legacy list processing are fundamentally unsupported in modern cloud environments (SAP BTP ABAP Environment and S/4HANA Cloud). Code containing these constructs cannot be compiled or transported to cloud systems. Replace non-cloud statements with released successor APIs, RAP business objects, or modern ABAP OO design patterns.",
    "className": "/SKYL/CL_PREF_CLOUD_READY",
    "pseudoComment": "PREF_CLOUD_READY",
    "category": "clean-abap",
    "example": {
      "bad": "\" Classic report execution is not supported in ABAP Cloud\nSUBMIT z_billing_report\n  WITH p_vbeln = lv_billing_doc\n  AND RETURN.",
      "good": "\" Encapsulate logic into modern class methods or background jobs\nzcl_billing_service=>process(\n  iv_billing_doc = lv_billing_doc )."
    },
    "seo": {
      "description": "Detect ABAP statements that are not available in ABAP Cloud, including SUBMIT, CALL TRANSACTION, EXEC SQL and other legacy language elements.",
      "keywords": [
        "pref-cloud-ready",
        "ABAP Cloud syntax",
        "forbidden ABAP statements",
        "Steampunk language subset",
        "ABAP Cloud readiness",
        "SAP ATC check"
      ]
    },
    "relatedRules": [
      "no-obs-control",
      "no-list-proc",
      "pref-func-module"
    ],
    "customSection": "### Statement Scope and Handling\n\nThe check scans statement prefixes against the ABAP Cloud forbidden catalog:\n\n| Statement Construct | Status | Note |\n|---|---|---|\n| `SUBMIT ...` | Forbidden | Classic report execution |\n| `CALL TRANSACTION ...` | Forbidden | Dynpro transaction call |\n| `EXEC SQL ...` | Forbidden | Native SQL |\n| `CALL FUNCTION ...` | Allowed | Released function modules |\n| `CREATE OBJECT ... TYPE ...` | Allowed | Standard ABAP OO instantiation |\n| `SORT itab BY ...` | Allowed | Internal table sorting |\n\n### Prefix Disambiguation\n\nWhen a keyword prefix is shared between classic and cloud syntax, the longest match applies:\n- `CALL` is forbidden, but `CALL FUNCTION` and `CALL METHOD` are allowed.\n- `SORT` without an internal table is forbidden (dataset sort); `SORT itab` is allowed.\n- `CREATE OBJECT` with `TYPE` is allowed; OLE automation (`CREATE OBJECT ref 'PROGID'`) is forbidden.\n- Loop events (`AT NEW`, `AT LAST`) are allowed; dynpro events (`AT PF01`, `AT LINE-SELECTION`) are forbidden.\n\n### Suppression\n\nSuppress intentional legacy usages with `\"#EC PREF_CLOUD_READY`."
  }
];



export const RULE_BY_RULE_ID = new Map(RULES.map(r => [r.ruleId, r]));
export const RULE_BY_CLASS = new Map(RULES.map(r => [r.className.toUpperCase(), r]));
export const RULE_BY_CLASS_LOWER = new Map(RULES.map(r => [r.className.toLowerCase(), r]));
export const RULE_BY_SHORT_CLASS = new Map(RULES.map(r => [r.className.toLowerCase().replace(/^\/skyl\/cl_/, ''), r]));

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
  const shortName = lower.replace(/^\/skyl\/cl_/, '');
  if (RULE_BY_SHORT_CLASS.has(shortName)) return RULE_BY_SHORT_CLASS.get(shortName);
  return null;
}
