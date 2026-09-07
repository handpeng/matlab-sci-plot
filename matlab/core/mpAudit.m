function findings = mpAudit(contract)
% Scientific audit entry point; hard failures remain visible to callers.
findings = struct('code', {}, 'severity', {}, 'message', {});
if isfield(contract, 'uncertainty_requested') && contract.uncertainty_requested && ~isfield(contract, 'uncertainty')
    findings(end+1) = struct('code','UNCERTAINTY_UNDECLARED','severity','error','message','Uncertainty semantics are required.');
end
if isfield(contract, 'dual_y_axis') && contract.dual_y_axis && ~isfield(contract, 'dual_y_axis_justification')
    findings(end+1) = struct('code','DUAL_AXIS_UNJUSTIFIED','severity','warning','message','Dual y-axis requires justification.');
end
end
