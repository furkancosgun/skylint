// ---------------------------------------------------------------------------
// Skylint Runner - Public API
// Single entry point for both test harness and frontend playground.
// ---------------------------------------------------------------------------

export {
  scanAbap,
  scanProcedures,
  ensureRuntimeReady,
  discoverChecks,
} from './scan.mjs';

export {
  checkSyntaxErrors,
  applySingleFix,
  applyAllFixes,
} from './fix.mjs';

export { initRuntime, createLoader } from '../bridge/abap-runtime.mjs';
export {
  buildProcedureValue,
  buildProceduresTable,
  buildObjectValue,
  createFakes,
  newCompUnit,
  newLocation,
} from '../bridge/abap-fakes.mjs';
export { getCheckInstance, clearCheckCache } from '../bridge/abap-loader.mjs';
