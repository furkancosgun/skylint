# Core - Skylint Infrastructure

- `base/`: Minimalist ATC check base class (`zcl_skylint_check_base`) & metadata handler (`zcl_skylint_check_meta_data`)
- `reporter/`: Finding reporter interface (`zif_skylint_reporter`) & location/checksum/pseudo-comment processor (`zcl_skylint_reporter`)
- `quickfix/`: QuickFix builder interface (`zif_skylint_quickfix`) & code replacement engine (`zcl_skylint_quickfix`)
- `analyzer/`: Token/statement analysis & AST helpers (`zif_skylint_analyzer`, `zcl_skylint_analyzer`)
