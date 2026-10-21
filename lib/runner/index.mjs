// ---------------------------------------------------------------------------
// Skylint Runner - Public API
// Single entry point for both test harness and frontend playground.
// ---------------------------------------------------------------------------

export {
  scanAbap,
  scanProcedures,
  ensureRuntimeReady,
} from './scan.mjs';

export {
  checkSyntaxErrors,
  applySingleFix,
  applyAllFixes,
  discoverChecks,
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
