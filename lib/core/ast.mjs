// ---------------------------------------------------------------------------
// Skylint AST Core - Orchestrator
// Re-exports all core modules for backward compatibility.
// Individual modules:
//   lib/core/lexer.mjs      - Lexer class + parenDelta
//   lib/core/parser.mjs     - buildStements + statement classification
//   lib/core/procedures.mjs - extractAllProcedures + resolveProcedureForTarget
//   lib/core/semantic.mjs   - enrichStatements + semantic analysis
// ---------------------------------------------------------------------------

export { Lexer, parenDelta } from './lexer.mjs';
export {
  buildStatements,
  ASSIGN_OPS,
  METHOD_CALL_BLACKLIST,
  DECL_KEYWORDS,
  DB_KEYWORDS_READ,
  DB_KEYWORDS_WRITE,
  isCommentToken,
  isPragmaToken,
  copyToken,
  pseudoWords,
  collectPseudo,
  isAssignment,
  isMethodCall,
  classifyStatement,
  pushRef,
  hasRefKind,
  isStringToken,
  dataScopePrefix,
  cutAtParen,
  emitStatement,
} from './parser.mjs';
export {
  extractAllProcedures,
  resolveProcedureForTarget,
} from './procedures.mjs';
export { enrichStatements, attachAbaplintReferences } from './semantic.mjs';
export {
  collectAbaplintReferences,
  clearReferenceCache,
  detectObjectKind,
  fileNameFor,
} from './references-abaplint.mjs';
