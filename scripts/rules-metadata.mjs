/**
 * Global Rationale and Clean ABAP Style Guide references for all Skylint rules.
 */

export const RULES_METADATA = {
  'prefer-lines': {
    title: 'Prefer lines( ) over DESCRIBE TABLE',
    rationale: 'The built-in `lines( )` function is modern, functional, and can be embedded directly into expressions and conditionals without requiring a temporary variable or the cumbersome procedural `DESCRIBE TABLE ... LINES` statement.',
  },
  'prefer-is-initial': {
    title: 'Prefer IS [NOT] INITIAL over lines( ) or Literal Comparisons',
    rationale: 'Checking whether an internal table, string, or variable is empty should be done with `IS [NOT] INITIAL` rather than counting `lines( ) > 0` or comparing to empty literals (`""`, `space`, `0`). `IS INITIAL` is idiomatic Clean ABAP, expressive, and optimized.',
  },
  'no-ignored-return-value': {
    title: 'Do Not Ignore Return Value of Functional Methods',
    rationale: 'Functional methods that declare a `RETURNING` parameter are designed to compute and return a value. Calling such methods without assigning or consuming their result indicates a bug, dead code, or an improper command-query violation where side effects were bundled into a query.',
  },
  'prefer-cast': {
    title: 'Prefer CAST #( ) over ?=',
    rationale: '`?=` is legacy downcast syntax from early ABAP Objects. Modern ABAP exclusively uses `CAST #( )` constructor expressions, which can be inlined directly into method call chains and expressions.',
  },
  'no-redundant-clear': {
    title: 'Do Not CLEAR Variables Directly After Declaration',
    rationale: 'Variables in ABAP are automatically initialized to their type-specific default initial value upon declaration. Explicitly executing `CLEAR` immediately after declaration adds visual noise and redundant statements without any functional effect.',
  },
  'no-call-method': {
    title: 'Avoid Obsolete CALL METHOD',
    rationale: 'Procedural `CALL METHOD` is legacy syntax from early ABAP Objects. Modern ABAP exclusively uses functional call syntax (`ref->method( )` or `class=>method( )`), which reduces visual clutter and enables functional expression chaining.',
  },
  'no-default-key': {
    title: 'Avoid WITH DEFAULT KEY',
    rationale: '`WITH DEFAULT KEY` is dangerous and unpredictable because it includes all non-numeric fields as table keys, causing unexpected sorting and duplicate record bugs. Always prefer `WITH EMPTY KEY` or explicitly specified table keys.',
  },
  'prefer-is-not': {
    title: 'Prefer IS NOT over NOT ... IS',
    rationale: 'Writing `IF lo_ref IS NOT BOUND` or `IF lt_tab IS NOT INITIAL` mirrors natural language reading order and avoids misreading inverted expressions that start with `NOT`.',
  },
  'no-me-reference': {
    title: 'Avoid Redundant ME-> Self Reference',
    rationale: 'In ABAP, member variables and methods are automatically accessible within the instance context. Prefixing every member access with `me->` creates visual noise, except when disambiguating parameter shadowing in constructors.',
  },
  'no-redundant-method-call': {
    title: 'Omit Redundant Call Syntax (EXPORTING / RECEIVING / Single Param)',
    rationale: 'Modern ABAP allows omitting the `EXPORTING` and `RECEIVING` keywords in functional method calls. Furthermore, when calling a method with a single importing parameter, the parameter name can be omitted entirely to make code clean and concise.',
  },
  'no-chained-statements': {
    title: 'Avoid Chained Declarations & Assignments',
    rationale: 'Chained statements (`DATA: ... , ... .`) create formatting headaches, merge conflicts in Git diffs, and frequently confuse developers regarding where a type or modifier applies. Each statement should stand independently on its own line.',
  },
  'prefer-string-template': {
    title: 'Prefer String Templates over CONCATENATE',
    rationale: 'String templates (`|Hello { lv_name }|`) provide type-safe, readable string interpolation with built-in formatting options. They eliminate procedural `CONCATENATE` and `SEPARATED BY` statements.',
  },
  'no-boolean-comparison': {
    title: 'Avoid Comparing to abap_true / abap_false',
    rationale: 'Predicate methods and boolean expressions evaluate directly to true or false. Comparing them explicitly (`IF is_valid( ) = abap_true`) is redundant, noisy, and unidiomatic.',
  },
  'prefer-line-exists': {
    title: 'Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS',
    rationale: '`line_exists( )` clearly communicates the intent of checking table membership in a single functional expression, eliminating the boilerplate of `READ TABLE ... TRANSPORTING NO FIELDS` followed by `sy-subrc = 0`.',
  },
  'prefer-return': {
    title: 'Prefer RETURN over EXIT in Methods',
    rationale: 'In method contexts, `EXIT` can be ambiguous when placed near loops. `RETURN` explicitly indicates an immediate exit from the current processing block or method.',
  },
  'no-check-statement': {
    title: 'Avoid CHECK Statements',
    rationale: '`CHECK` has context-dependent dual semantics: inside loops it behaves like `CONTINUE`, but outside loops it behaves like `RETURN`. This makes code fragile and refactoring hazardous. Use explicit `IF ... CONTINUE` or `IF ... RETURN` instead.',
  },
  'no-empty-block': {
    title: 'Avoid Empty Control Blocks',
    rationale: 'Empty blocks (such as `IF ... ELSEIF ... ENDIF` with no executable statements) confuse readers and usually represent unfinished business logic or forgotten debug code.',
  },
  'no-duplicate-conditions': {
    title: 'Avoid Duplicate Branch Conditions',
    rationale: 'Repeating the exact same condition across `IF / ELSEIF` or `WHEN` branches means subsequent duplicate branches can never be reached, indicating a copy-paste error or broken logic.',
  },
  'prefer-merged-ifs': {
    title: 'Merge Nested IF Statements',
    rationale: 'Consecutive nested `IF` statements without intermediate statements can be combined with `AND`. This reduces nesting depth, flattens control flow, and simplifies cyclomatic complexity.',
  },
  'no-unreachable-code': {
    title: 'Avoid Dead / Unreachable Code',
    rationale: 'Statements appearing immediately after an unconditional `RETURN`, `RAISE EXCEPTION`, `EXIT`, or `LEAVE PROGRAM` can never execute, cluttering the codebase and misleading maintainers.',
  },
  'no-single-when': {
    title: 'Avoid CASE with a Single WHEN Branch',
    rationale: 'A `CASE` statement containing only one `WHEN` branch is unnecessarily verbose. An `IF ... ENDIF` is more concise and idiomatic.',
  },
  'no-yoda-conditions': {
    title: 'Avoid Yoda Conditions',
    rationale: 'Placing constants or literals on the left side of comparisons (`IF 42 = lv_value`) impairs readability. ABAP natural reading flow expects the variable or subject on the left (`IF lv_value = 42`).',
  },
  'prefer-symbol-operators': {
    title: 'Prefer Symbol Comparison Operators (=, <>, <, >)',
    rationale: 'Text comparison operators (`EQ`, `NE`, `LT`, `GT`, `LE`, `GE`) are legacy syntax. Modern programming and Clean ABAP universally standardize on mathematical symbols (`=`, `<>`, `<`, `>`, `<=`, `>=`).',
  },
  'prefer-new-operator': {
    title: 'Prefer NEW #( ) over CREATE OBJECT',
    rationale: 'The constructor expression `NEW #( )` is type-inferred, expression-capable, and avoids the archaic procedural `CREATE OBJECT` statement.',
  },
  'prefer-xsdbool': {
    title: 'Prefer xsdbool( ) for Boolean Assignments',
    rationale: 'Writing `IF cond. lv_flag = abap_true. ELSE. lv_flag = abap_false. ENDIF.` is 5 lines of boilerplate. `lv_flag = xsdbool( cond )` expresses the same logic cleanly in one readable line.',
  },
  'no-static-via-instance': {
    title: 'Avoid Calling Static Methods via Instance References (->)',
    rationale: 'Calling a static method via an object reference arrow `lo_instance->static_method( )` gives the false impression that polymorphic instance dispatch is occurring. Use `cl_class=>static_method( )`.',
  },
  'no-public-attributes': {
    title: 'Avoid Public Attributes in Classes',
    rationale: 'Public attributes violate encapsulation because external consumers can mutate internal state arbitrarily. Encapsulate state using private/protected attributes exposed via methods or `READ-ONLY`.',
  },
  'no-obsolete-statements': {
    title: 'Avoid Obsolete & Forbidden Statements',
    rationale: 'Legacy statements such as `MOVE`, `COMPUTE`, `REFRESH`, `TABLES`, `STATICS`, `FORM`, and `LEAVE` are prohibited in ABAP Cloud and discouraged in Clean ABAP. Replace them with modern value assignments and object-oriented constructs.',
  },
  'max-params': {
    title: 'Limit Method Parameter Count',
    rationale: 'Methods with excessive parameters are difficult to comprehend, call, and test. When a method needs more than 5-8 parameters, bundle related fields into a structured type or parameter object.',
  },
  'no-db-in-loop': {
    title: 'Avoid Database Access Inside Loops',
    rationale: 'Executing SQL queries (`SELECT`, `UPDATE`, `DELETE`) inside a `LOOP` generates an N+1 query performance anti-pattern. Fetch data in bulk using `FOR ALL ENTRIES` or SQL Joins outside the loop.',
  },
  'no-empty-fae': {
    title: 'Prevent Empty FOR ALL ENTRIES Inquiries',
    rationale: 'In ABAP SQL, executing `FOR ALL ENTRIES IN @lt_table` when `lt_table` is empty drops the `WHERE` clause entirely and performs a full table scan, causing severe system performance degradation and data leaks.',
  },
  'no-select-star': {
    title: 'Avoid SELECT * Queries',
    rationale: 'Selecting all database columns transfers unnecessary data across the network, bypasses secondary indexes, and breaks table buffering. Always specify the explicit columns required.',
  },
  'no-scope-leak': {
    title: 'Avoid Variable Scope Leaking from Inner Blocks',
    rationale: 'In ABAP, variable declarations inside control blocks (`IF`, `LOOP`) have procedure-wide scope. Using an inner-declared variable outside its originating block creates confusing temporal dependencies.',
  },
  'no-self-assignment': {
    title: 'Avoid Redundant Self-Assignments',
    rationale: 'Assigning a variable or structure field to itself (`lv_x = lv_x`) is a redundant no-op and frequently hides a typo where another source field was intended.',
  },
  'prefer-fully-typed': {
    title: 'Require Fully Typed Variables and Parameters',
    rationale: 'Generic types (`ANY`, `DATA`, `TABLE`) bypass compiler type checking and hide runtime type mismatches. Always declare concrete, specific types unless writing truly generic frameworks.',
  },
  'prefer-corresponding': {
    title: 'Prefer CORRESPONDING #( ) Operator',
    rationale: 'The constructor expression `CORRESPONDING #( )` is type-safe, expression-capable, and supports modern features like `EXCEPT` and `MAPPING`. It replaces the archaic `MOVE-CORRESPONDING` statement.',
  },
  'max-method-length': {
    title: 'Limit Method Length (Statements)',
    rationale: 'Long methods violate the Single Responsibility Principle, accumulate side effects, and are notoriously difficult to unit test. Split large methods into small, focused sub-methods.',
  },
  'max-nesting-depth': {
    title: 'Limit Control Flow Nesting Depth',
    rationale: 'Deeply nested blocks (`IF`, `LOOP`, `TRY`, `CASE`) cause cognitive overload ("arrow antipattern"). Flatten nested code using early exits (`RETURN`), guard clauses, and extracted methods.',
  },
  'no-sy-modify': {
    title: 'Avoid Modifying System Fields (sy-*)',
    rationale: 'System fields like `sy-subrc`, `sy-tabix`, and `sy-index` are managed exclusively by the ABAP runtime. Writing to them manually undermines system integrity and masks actual execution results.',
  },
  'prefer-returning': {
    title: 'Prefer Functional RETURNING Parameters',
    rationale: 'Methods with a `RETURNING` parameter can be used directly within expressions, assignments, and assertions. Prefer `RETURNING` over a single `EXPORTING` parameter.',
  },
  'prefer-class-exceptions': {
    title: 'Prefer Class-Based Exceptions over Classic EXCEPTIONS',
    rationale: 'Classic non-class exceptions (set via `sy-subrc`) lack stack traces, cannot carry context data, and cannot be propagated up call stacks cleanly. Use class-based exceptions (`CX_ROOT` subclasses).',
  },
  'no-dangerous-statements': {
    title: 'Avoid Dangerous & Dynamic Native Statements',
    rationale: 'Dynamic code generation (`GENERATE SUBROUTINE POOL`, `INSERT REPORT`), kernel calls (`SYSTEM-CALL`), and production `ASSERT` or `RAISE SHORTDUMP` jeopardize cloud compliance, security, and stability.',
  },
  'prefer-auth-check': {
    title: 'Ensure AUTHORITY-CHECK Before Sensitive Operations',
    rationale: 'Omitting authorization checks leaves critical business data and actions exposed to unauthorized users. Always verify permissions before selecting or modifying protected resources.',
  },
  'prefer-order-by': {
    title: 'Require ORDER BY for Deterministic SELECT Results',
    rationale: 'Selecting rows from a relational database without an explicit `ORDER BY` clause yields non-deterministic ordering that can change unpredictably between DB executions and updates.',
  },
  'max-cyclomatic-complexity': {
    title: 'Limit Cyclomatic Complexity',
    rationale: 'High cyclomatic complexity means a method contains too many decision points (branches, loops, catches), making comprehensive unit test branch coverage nearly impossible.',
  },
  'prefer-final-class': {
    title: 'Design for Inheritance or Prohibit It (FINAL)',
    rationale: 'Classes not explicitly designed and documented for inheritance should be declared `FINAL`. This prevents subclassing that relies on fragile base-class implementation details.',
  },
  'no-magic-numbers': {
    title: 'Avoid Magic Numbers; Use Named Constants',
    rationale: 'Hardcoded numeric literals scattered in logic obscure business rules and make updates error-prone. Give numbers meaningful names by declaring structured constants.',
  },
  'prefer-insert-into': {
    title: 'Prefer INSERT ... INTO TABLE over APPEND',
    rationale: '`APPEND` implies indexed, sequential appending and fails on hashed or sorted tables. `INSERT ... INTO TABLE` works polymorphically across all internal table categories.',
  },
  'no-like-objects': {
    title: 'Avoid LIKE Typing on Global Dictionary Objects',
    rationale: 'Typing dictionary objects with `LIKE` is obsolete. Use `TYPE` to refer to data types and reserve `LIKE` solely for referencing local data objects in the same procedure.',
  },
  'max-constructor-statements': {
    title: 'Keep Constructors Clean & Lightweight',
    rationale: 'Constructors should only initialize state and inject dependencies. Heavy business logic, database queries, or network I/O in constructors make test mocking and instantiation brittle.',
  },
  'no-static-classes': {
    title: 'Avoid Purely Static Utility Classes',
    rationale: 'Classes consisting entirely of static methods cannot be mocked via interfaces or subclassing during unit tests, creating rigid coupling throughout the application.',
  },
  'prefer-predicate-names': {
    title: 'Use Predicate Naming for Boolean Methods (is_, has_, can_)',
    rationale: 'Methods returning boolean status should read like questions (`is_valid`, `has_children`, `can_execute`) so conditionals read naturally like plain English.',
  },
  'max-inheritance-depth': {
    title: 'Limit Inheritance Depth',
    rationale: 'Deep class inheritance hierarchies create the fragile base class problem and tight coupling. Favor composition over inheritance (`HAS-A` instead of `IS-A`).',
  },
  'max-attributes': {
    title: 'Limit Member Attributes per Class',
    rationale: 'Classes with dozens of member variables are almost always God Objects that handle multiple unrelated responsibilities. Split them into smaller, focused domain classes.',
  },
  'no-interface-data': {
    title: 'Avoid DATA Attributes in Interfaces',
    rationale: 'Interfaces should declare behavior (methods) and immutable contracts (constants). Mutable data in interfaces creates hidden global state across all implementers.',
  },
  'no-catch-cx-root': {
    title: 'Avoid Catching Generic CX_ROOT',
    rationale: 'Catching `cx_root` indiscriminately swallows system runtime errors, resource exhaustion errors, and programming bugs, masking critical defects from developers.',
  },
  'no-message-raising': {
    title: 'Avoid Obsolete MESSAGE ... RAISING in Methods',
    rationale: '`MESSAGE ... RAISING` combines procedural exception handling with UI messaging, preventing proper separation of concerns. Raise modern class-based exceptions instead.',
  },
  'no-nested-try': {
    title: 'Avoid Deeply Nested TRY ... CATCH Blocks',
    rationale: 'Nesting `TRY` blocks inside other `TRY` blocks obfuscates error handling flow. Extract inner protected operations into distinct methods.',
  },
  'no-raise-cx-sy': {
    title: 'Avoid Explicitly Raising System Exceptions (CX_SY_*)',
    rationale: '`cx_sy_*` exceptions are reserved exclusively for the ABAP runtime engine (e.g., divide by zero, null reference). Applications must define and raise their own custom exception hierarchies.',
  },
  'prefer-subrc-check': {
    title: 'Verify sy-subrc Promptly After System Calls',
    rationale: 'Statements that set `sy-subrc` (such as `SELECT SINGLE`, `READ TABLE`, `AUTHORITY-CHECK`, `ASSIGN`) must have their return code verified immediately before invoking unrelated statements.',
  },
  'no-client-specified': {
    title: 'Avoid CLIENT SPECIFIED / USING CLIENT in Cloud',
    rationale: 'Explicit client switching bypasses automatic multi-tenant client isolation and is strictly prohibited in ABAP Cloud environment standards.',
  },
  'no-commit-work': {
    title: 'Avoid Explicit COMMIT WORK in Business Logic',
    rationale: 'Transactional business logic should rely on the persistence framework or framework save sequence (e.g. RAP) rather than triggering premature or uncoordinated database commits.',
  },
  'prefer-transporting': {
    title: 'Specify TRANSPORTING in MODIFY / READ TABLE',
    rationale: 'Modifying internal tables without specifying `TRANSPORTING` copies all table fields across the buffer. Specify only the modified fields to optimize execution speed.',
  },
  'prefer-test-naming': {
    title: 'Follow Clean Naming for Unit Test Methods',
    rationale: 'Test method names should clearly state the condition and expected outcome (e.g., `calculate_discount_when_gold`). Meaningful test names act as living documentation.',
  },
  'prefer-string-functions': {
    title: 'Prefer Built-in String Functions over SEARCH/SHIFT',
    rationale: 'Procedural string statements (`SEARCH`, `SHIFT`, `TRANSLATE`) are legacy ABAP. Replace them with functional built-in string functions (`find`, `to_upper`, `substring`, `shift_left`).',
  },
  'prefer-calc-assign-op': {
    title: 'Prefer Calculation Assignment Operators (+=, -=, *=)',
    rationale: 'Modern ABAP supports arithmetic assignment operators (`lv_count += 1.`), which are cleaner and more expressive than verbose legacy assignments (`lv_count = lv_count + 1.`).',
  },
  'prefer-early-return': {
    title: 'Prefer Early Return to Reduce Nesting (Guard Clauses)',
    rationale: 'Check preconditions and invalid states at the start of the method and return immediately. This eliminates deeply nested `IF ... ELSE` ladders.',
  },
  'no-unused-variables': {
    title: 'Eliminate Unused Local Variables and Symbols',
    rationale: 'Unused variables clutter code, confuse developers reviewing changes, and increase compilation and execution memory overhead without providing any benefit.',
  },
  'prefer-decl-order': {
    title: 'Order Declarations (TYPES, CONSTANTS, DATA)',
    rationale: 'Declaring types first, then constants, then data variables creates a logical reading flow where subsequent definitions can safely depend on preceding ones.',
  },
  'no-param-escape': {
    title: 'Avoid Reassigning Importing Parameters',
    rationale: 'Importing parameters should be treated as immutable inputs. Modifying them inside the method leads to unexpected side effects and debugging difficulties.',
  },
  'prefer-case': {
    title: 'Prefer CASE over Multiple IF / ELSEIF on the Same Variable',
    rationale: 'When branching on multiple values of a single variable, `CASE ... WHEN` is more readable, structured, and performant than a chain of `ELSEIF` statements.',
  },
  'no-inline-length': {
    title: 'Avoid Obsolete Inline Length Specifications (var(len))',
    rationale: 'Specifying length in parentheses directly after a variable name (`lv_str(10) TYPE c`) is legacy syntax. Use modern explicit typing: `TYPE c LENGTH 10`.',
  },
  'max-one-statement': {
    title: 'Limit One Statement per Source Code Line',
    rationale: 'Placing multiple statements on a single line hinders debugger stepping, breaks Git line diffs, and hurts overall code scannability.',
  },
  'no-dash-in-names': {
    title: 'Avoid Obsolete Dash (-) in Program Identifiers',
    rationale: 'Using a hyphen/dash in structure component references is archaic. Modern ABAP standardizes on the arrow notation `->` or hyphen only where mandatory.',
  },
  'prefer-inline': {
    title: 'Prefer Modern Inline Declarations in ABAP 7.40+',
    rationale: 'In versions supporting inline declarations, declaring variables at the point of first use reduces variable lifetime scope and removes top-of-method variable clutter.',
  },
  'prefer-pass-by-reference': {
    title: 'Avoid Unnecessary Pass-by-Value for Large Tables',
    rationale: 'Passing large internal tables by value creates an in-memory deep copy on every method invocation. Use pass-by-reference (`REFERENCE(it_data)`) or read-only references.',
  },
  'no-modify-standard-tables': {
    title: 'Only Modify Tables Defined in Your Own Package/Component',
    rationale: 'Directly inserting, updating, or deleting tables belonging to another application component bypasses business validation logic and violates modular architecture.',
  },
  'no-dynamic-stuff': {
    title: 'Avoid Unnecessary Dynamic Programming Constructs',
    rationale: 'Dynamic programming (`ASSIGN (lv_var)`, `CALL METHOD (lv_method)`) disables compile-time type checking, hampers automated refactoring, and opens security vulnerabilities.',
  },
  'prefer-public-constructor': {
    title: 'Declare Constructor in PUBLIC SECTION',
    rationale: 'Instance constructors must always be declared in the PUBLIC SECTION, even for classes with CREATE PRIVATE or CREATE PROTECTED, ensuring standard reflection, factory instantiation, and Clean ABAP compliance.',
  },
  'prefer-definitions-top': {
    title: 'Place Definitions at Top of Routine',
    rationale: 'Explicit local definitions (DATA, TYPES, CONSTANTS, FIELD-SYMBOLS) should be placed at the very beginning of the routine rather than scattered in the middle of executable code.',
  },
  'no-unnecessary-return': {
    title: 'Omit Unnecessary RETURN Statement',
    rationale: 'Routines automatically return upon reaching ENDMETHOD, ENDFORM, or ENDFUNCTION. An explicit RETURN statement at the very end of the routine body is redundant and clutters the code.',
  },
  'mix-returning': {
    title: 'Do Not Mix RETURNING with EXPORTING or CHANGING',
    rationale: 'Clean ABAP methods should either be pure functional (RETURNING a single result) or procedures (using EXPORTING/CHANGING). Mixing both in the same signature creates confusing APIs.',
  },
  'method-overwrites-builtin': {
    title: 'Avoid Method Names That Overwrite Built-in Functions',
    rationale: 'Naming a method after a built-in ABAP function (e.g., LINES, STRLEN, MATCHES, XSDBOOL) obscures the standard SAP built-in and makes expressions ambiguous and difficult to read.',
  },
  'max-one-method-parameter-per-line': {
    title: 'Max One Method Parameter Definition Per Line',
    rationale: 'Defining multiple parameters on the same line hampers readability and produces noisy version control diffs. Each parameter in a signature should be declared on its own dedicated line.',
  },
  'no-modify-loop-table': {
    title: 'Do Not Mutate the Internal Table Currently Being Looped',
    rationale: 'Adding rows (APPEND/INSERT), modifying, deleting, or clearing rows from the table while actively looping over it can cause infinite loops, skipped rows, or cursor invalidation. Parametric toggles are available for append, insert, modify, delete, and clear operations.',
  },
  'no-hardcoded-env-checks': {
    title: 'Avoid Hardcoding System & Tenant Environment Checks',
    rationale: 'Hardcoding system identifiers (sy-sysid), client numbers (sy-mandt), host names (sy-host), or database systems (sy-dbsys) against literal values violates cloud multi-tenancy and breaks during staging, system copy, or migration. Use feature toggles, switch frameworks, or customizing instead.',
  },
};
