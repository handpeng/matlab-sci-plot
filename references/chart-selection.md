# Chart Selection

Select from family manifests using the communication task, declared roles, sample policy, and backend capabilities. Prediction validation starts with `prediction.parity`; relationships use `relationship.scatter`; model comparisons use aligned metric panels; distributions use histogram/KDE or box+points; ordered process data uses `trend.line`. Candidate alternatives are bounded to three and each plan records its compatibility reason.

When a contract declares `required_relationship`, selection additionally
requires the family manifest to support that relationship identity, every
required relationship role, the declared pairing requirement, and the declared
representation. For V1 `distance -> error`, `relationship.scatter` supports
paired observations and explicitly authorized aggregates; `trend.line` supports
paired observations when the communication task is an ordered trend. A family
that matches only generic numeric roles is excluded rather than upgraded to
relationship authority.
