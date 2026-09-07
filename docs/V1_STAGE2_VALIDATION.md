# V1 Stage 2 Validation

Run `python3 scripts/run_tests.py` for the local non-MATLAB suite and `python3 scripts/integration_check.py` for the contract, registry, family, migration, review/evidence, domain composition, and export checks. Both commands are deterministic and use only synthetic/external data bindings. MATLAB is probed with `MATLAB_BIN`, `matlab`, or `matlab.exe`; a binary that cannot start is reported as `MATLAB_AVAILABLE=NO` and its smoke tests are `SKIPPED_UNAVAILABLE`.

This document records implementation checks only. Stage 3 qualification, certification, promotion, and release qualification are separate activities and are intentionally not performed here.
