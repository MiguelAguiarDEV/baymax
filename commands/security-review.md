---
description: Run security gate review with severity findings and PASS/FAIL verdict
agent: security-reviewer
subtask: true
---
Run a focused security review for this scope:
$ARGUMENTS

Cover auth/authz, input validation, secrets, APIs, payments, and PII when relevant.
Return output using the security-reviewer contract.
