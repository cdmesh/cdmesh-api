"""
Policy and Constraint schemas for Contract-Driven Lifecycle (CDL).

This module implements the governance layer of the Composable Mesh Architecture (CMA),
enabling compile-time policy verification and cascading governance across the hierarchy.

Core Concepts:
--------------
- Policy: A governance rule that applies to one or more MeshNodes
- Constraint: A compile-time checkable expression that enforces policy requirements
- Scope: The hierarchical level at which a policy is defined (organization, mesh, domain, product, port)
- Enforcement: How violations are handled (blocking, warning, audit)

Mathematical Model:
------------------
C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Local

Where:
- C_final is the effective constraint set
- ⊕ represents constraint composition (union with precedence)
- Policies cascade from parent to child nodes

Examples:
--------
# PII Encryption Policy
piiPolicy = Policy {
    id = "pii-encryption-v1"
    name = "PII Data Encryption Required"
    scope = "product"
    policyType = "privacy"
    enforcement = "blocking"
    constraints = [
        Constraint {
            expression = "deployment.encryption.atRest == true"
            message = "Products with PII tags must enable encryption at rest"
            severity = "error"
        }
    ]
}

# GDPR Retention Policy
gdprPolicy = Policy {
    id = "gdpr-retention-v1"
    name = "GDPR Data Retention Limit"
    scope = "organization"
    policyType = "compliance"
    enforcement = "blocking"
    constraints = [
        Constraint {
            expression = "retentionPolicy.maxDays <= 2555"
            message = "GDPR requires data retention period less than 7 years (2555 days)"
            severity = "error"
        }
    ]
}

Academic References:
-------------------
- Dolhopolov et al. (2024): Implementing Federated Governance in Data Mesh Architecture
- van der Werf et al. (2025): Towards a Data Mesh Reference Architecture
"""

schema Policy:
    """
    A governance rule that can be applied at any level of the CMA hierarchy.

    Policies consist of:
    1. Metadata (id, name, scope, type)
    2. Enforcement strategy (blocking, warning, audit)
    3. Constraints (compile-time checkable expressions)

    Policies cascade from parent to child nodes through mixin inheritance,
    implementing the federated governance pattern with O(D) complexity.

    Attributes
    ----------
    id: str, required.
        Globally unique policy identifier (e.g., "pii-encryption-v1").
    name: str, required.
        Human-readable policy name.
    scope: str, required.
        Hierarchical level at which this policy applies.
        Valid values: "organization", "mesh", "domain", "product", "port".
    policyType: str, required.
        Classification of the policy's domain.
        Valid values: "security", "privacy", "quality", "compliance", "cost".
    enforcement: str, required.
        How violations are handled.
        Valid values:
        - "blocking": Compilation fails on violation
        - "warning": Compilation succeeds with warning
        - "audit": No compilation impact, logged for post-deployment audit
    constraints: [Constraint], required.
        List of compile-time checkable constraints that implement this policy.

    Examples
    --------
    encryptionPolicy = Policy {
        id = "encryption-policy-v1"
        name = "Encryption at Rest Required"
        scope = "product"
        policyType = "security"
        enforcement = "blocking"
        constraints = [
            Constraint {
                expression = "deployment.encryption.atRest == true"
                message = "All products must enable encryption at rest"
                severity = "error"
            }
        ]
    }
    """
    id: str
    name: str
    scope: "organization" | "mesh" | "domain" | "product" | "port"
    policyType: "security" | "privacy" | "quality" | "compliance" | "cost"
    enforcement: "blocking" | "warning" | "audit"
    constraints: [Constraint]

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
        len(constraints) > 0, "policy must have at least one constraint"

schema Constraint:
    """
    A compile-time checkable expression that enforces a policy requirement.

    Constraints are evaluated during KCL compilation (shift-left governance).
    They use KCL's native expression syntax for type-safe validation.

    Constraint Propagation:
    ----------------------
    When a node depends on another node with constraints, those constraints
    can propagate based on semantic tags (taint analysis):

    Example:
    - Node A has tag "PII" → requires encryption
    - Node C consumes Node A → inherits PII requirement
    - Constraint validates: C.deployment.encryption.atRest == true

    Attributes
    ----------
    expression: str, required.
        KCL expression that evaluates to a boolean.
        Must reference fields available in the node's schema.
        Examples:
        - "deployment.encryption.atRest == true"
        - "retentionPolicy.maxDays <= 2555"
        - "'PII' in tags implies deployment.encryption.atRest == true"
    message: str, required.
        User-facing error/warning message when constraint fails.
    severity: str, required.
        Impact level of constraint violation.
        Valid values:
        - "error": Blocks compilation (for blocking policies)
        - "warning": Warns but allows compilation (for warning policies)

    Examples
    --------
    piiConstraint = Constraint {
        expression = "'PII' in tags implies deployment.encryption.atRest == true"
        message = "Products handling PII must enable encryption at rest"
        severity = "error"
    }

    retentionConstraint = Constraint {
        expression = "retentionPolicy.maxDays <= 2555"
        message = "GDPR compliance requires retention period <= 7 years"
        severity = "error"
    }
    """
    expression: str
    message: str
    severity: "error" | "warning"

    check:
        len(expression) > 0, "expression must not be empty"
        len(message) > 0, "message must not be empty"
