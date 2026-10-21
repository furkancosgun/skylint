// ---------------------------------------------------------------------------
// Skylint Runner - Browser-safe Public API
// Exports only functions that work without Node.js filesystem access.
// scanAbap is excluded because it requires loading compiled ABAP classes
// from the filesystem (Node.js only).
// ---------------------------------------------------------------------------

export {
  checkSyntaxErrors,
  applySingleFix,
  applyAllFixes,
  discoverChecks,
} from './fix.mjs';
