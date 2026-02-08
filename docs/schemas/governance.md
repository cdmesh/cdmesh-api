# Governance Schemas

**Module**: `governance/`
**Schemas**: `Policy`, `Constraint`, `PIIMixin`, `GDPRMixin`, `PCIDSSMixin`, `SOC2Mixin`
**Files**: `governance/policy.k`, `governance/mixins.k`

## Overview

The `governance` module implements the governance layer of the Composable Mesh Architecture (CMA), enabling **compile-time policy verification** and **cascading governance** across the hierarchy. This implements the **Contract Driven Lifecycle (CDL)** pillar of CMA.

The governance schemas provide:
- **Shift-left validation**: Policy violations caught during `kcl run`, not in production
- **Federated governance**: O(D) policy propagation vs O(T) tuple-based systems
- **Constraint propagation**: Taint analysis via tag inheritance
- **Regulatory compliance**: GDPR, CCPA, PCI-DSS, HIPAA, SOC 2
- **Reusable mixins**: Tag-triggered compliance patterns

## Core Concepts

### Contract Driven Lifecycle (CDL)

CDL is one of the three foundational pillars of CMA:

1. **Compile-time verification**: Policies are validated during `kcl run`, not at runtime
2. **Shift-left governance**: Catch violations before deployment
3. **Type-safe constraints**: KCL's type system ensures constraint correctness
4. **Zero runtime overhead**: No policy evaluation cost in production

### Policy Cascading Model

Policies cascade from parent to child nodes through inheritance:

```
C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Product ⊕ C_Local

Where:
- C_final is the effective constraint set for a node
- ⊕ represents policy composition (union with child precedence)
- Policies cascade from parent to child nodes automatically
```

**Complexity Analysis**:
- **Federated Inheritance (CMA)**: O(D) where D ≈ 4 (hierarchy depth)
- **Tuple-Based Governance (Traditional)**: O(T) where T ≈ 10,000 (table count)
- **Benefit**: 2,500x reduction in governance overhead

### Constraint Propagation (Taint Analysis)

**Theorem 1 (Constraint Propagation)**:
If Node A has property P (ContainsPII) and Node C consumes Node A, then Node C must satisfy constraint Requires(P) (HasEncryption).

**Implementation**: Via tag inheritance and check blocks that validate dependent node properties.

**Example**:
```
Product A: tags = ["PII"]  → requires encryption
Product C: dependsOn = ["product-a"]  → inherits PII tag → must encrypt
```

## Policy Schema

### Design Philosophy

**Policy** represents a governance rule that can be applied at any level of the CMA hierarchy. Policies are **Specification Objects** in DDD terms:
- No independent identity
- Embedded in MeshNode aggregates
- Define "what" should be true, not "how" to achieve it
- Composed of metadata + constraints

### Key Attributes

#### id (required)

Globally unique policy identifier.

**Format**: kebab-case with version suffix
**Examples**: `"pii-encryption-v1"`, `"gdpr-retention-v2"`, `"cost-limit-v1"`

**Purpose**:
- Policy versioning (track changes over time)
- Policy references (apply specific policy version)
- Audit trail (which policies were active when)

#### name (required)

Human-readable policy name.

**Examples**: `"PII Encryption Required"`, `"GDPR Data Retention Limit"`, `"Production Cost Threshold"`

**Purpose**:
- User interfaces (display in catalog)
- Documentation (explain what policy does)
- Reports (policy compliance dashboards)

#### scope (required)

Hierarchical level at which this policy applies.

**Valid values**:
- `"organization"`: Global policies (apply to all child nodes)
- `"mesh"`: Mesh-level policies (apply to domains and products within mesh)
- `"domain"`: Domain-level policies (apply to products within domain)
- `"product"`: Product-level policies (apply to this product only)
- `"port"`: Port-level policies (validate interface contracts)

**Purpose**:
- Scope enforcement (where policy is active)
- Policy inheritance (which nodes inherit this policy)
- Governance boundaries (separation of concerns)

#### policyType (required)

Classification of the policy's domain.

**Valid values**:
- `"security"`: Security requirements (encryption, access control)
- `"privacy"`: Privacy regulations (GDPR, CCPA, HIPAA)
- `"quality"`: Data quality requirements (completeness, accuracy)
- `"compliance"`: Regulatory compliance (PCI-DSS, SOC 2, ISO 27001)
- `"cost"`: Cost management (budget limits, resource quotas)

**Purpose**:
- Policy categorization (filter by type)
- Responsibility assignment (security team vs compliance team)
- Reporting (compliance status by category)

#### enforcement (required)

How violations are handled.

**Valid values**:
- `"blocking"`: Compilation fails on violation (hard enforcement)
- `"warning"`: Compilation succeeds with warning (soft enforcement)
- `"audit"`: No compilation impact, logged for post-deployment audit

**Purpose**:
- Enforcement strategy (fail fast vs warn and proceed)
- Risk management (critical vs recommended policies)
- Gradual adoption (start with warnings, move to blocking)

**Best practices**:
- Use `"blocking"` for: Security requirements, regulatory compliance, SLAs
- Use `"warning"` for: Best practices, recommendations, deprecations
- Use `"audit"` for: Experimental policies, monitoring, metrics

#### constraints (required)

List of compile-time checkable constraints that implement this policy.

**Type**: `[Constraint]`

**Purpose**:
- Executable validation logic
- Multiple constraints per policy (AND semantics)
- Type-safe constraint evaluation

**Validation**: Must have at least one constraint (`len(constraints) > 0`)

### Use Cases

#### Use Case 1: Encryption Policy

**Scenario**: All production products must enable encryption at rest.

**Solution**:
```kcl
encryptionPolicy = Policy {
    id = "encryption-policy-v1"
    name = "Encryption at Rest Required"
    scope = "organization"  # Global policy
    policyType = "security"
    enforcement = "blocking"  # Hard enforcement
    constraints = [
        Constraint {
            expression = "deployment.environment == 'production' implies deployment.encryption.atRest == true"
            message = "Production deployments must enable encryption at rest"
            severity = "error"
        }
    ]
}
```

**Benefits**:
- Global enforcement (all products must comply)
- Compile-time validation (no runtime cost)
- Clear error message (developer knows what to fix)

#### Use Case 2: GDPR Retention Policy

**Scenario**: GDPR requires data retention period less than 7 years.

**Solution**:
```kcl
gdprRetentionPolicy = Policy {
    id = "gdpr-retention-v1"
    name = "GDPR Data Retention Limit"
    scope = "organization"
    policyType = "compliance"
    enforcement = "blocking"
    constraints = [
        Constraint {
            expression = "'GDPR' in tags implies retentionPolicy.maxDays <= 2555"
            message = "GDPR requires data retention period ≤ 7 years (2555 days)"
            severity = "error"
        },
        Constraint {
            expression = "'GDPR' in tags implies retentionPolicy.erasureCapability == true"
            message = "GDPR Article 17: Right to erasure must be supported"
            severity = "error"
        }
    ]
}
```

**Benefits**:
- Tag-triggered enforcement (only applies to GDPR-tagged products)
- Multiple constraints (retention + erasure)
- Compliance reporting (prove GDPR compliance)

#### Use Case 3: Cost Limit Policy

**Scenario**: Development environments have a $1000/month cost limit.

**Solution**:
```kcl
devCostPolicy = Policy {
    id = "dev-cost-limit-v1"
    name = "Development Cost Limit"
    scope = "mesh"
    policyType = "cost"
    enforcement = "warning"  # Soft enforcement
    constraints = [
        Constraint {
            expression = "deployment.environment == 'development' implies costBudget.monthlyLimit <= 1000"
            message = "Development environments should not exceed $1000/month"
            severity = "warning"
        }
    ]
}
```

**Benefits**:
- Budget enforcement (prevent overspending)
- Soft enforcement (warning, not blocking)
- Environment-specific (only dev, not prod)

## Constraint Schema

### Design Philosophy

**Constraint** is a compile-time checkable expression that enforces a policy requirement. Constraints are evaluated during KCL compilation, implementing **shift-left governance**.

Constraints use:
- KCL's native expression syntax
- Type-safe validation (compile-time type checking)
- Boolean expressions (must evaluate to true/false)
- Field references (node attributes like `deployment.encryption.atRest`)

### Key Attributes

#### expression (required)

KCL expression that evaluates to a boolean.

**Syntax**: KCL boolean expressions with field references

**Examples**:
```kcl
# Simple equality
"deployment.encryption.atRest == true"

# Implication (if-then)
"deployment.environment == 'production' implies deployment.encryption.atRest == true"

# Tag membership
"'PII' in tags"

# Complex logic
"'PII' in tags implies (deployment.encryption.atRest == true and deployment.accessLogging.enabled == true)"

# Numeric comparison
"retentionPolicy.maxDays <= 2555"

# String matching
"deployment.region.startsWith('eu-')"
```

**Purpose**:
- Executable validation logic
- Type-safe constraint checking
- Boolean evaluation (pass/fail)

**Validation**: Must be a valid KCL boolean expression that references available fields.

#### message (required)

Human-readable error message displayed when constraint fails.

**Best practices**:
- Start with what's wrong: "Products handling PII must..."
- Include context: Reference regulatory requirements (GDPR Article 32)
- Actionable: Tell developer what to fix

**Examples**:
```kcl
"Products handling PII must enable encryption at rest (GDPR Article 32)"
"GDPR requires data retention period ≤ 7 years (2555 days)"
"Production deployments must specify at least 2 availability zones for high availability"
```

#### severity (required)

Constraint severity level.

**Valid values**:
- `"error"`: Blocking violation (compilation fails)
- `"warning"`: Non-blocking violation (compilation succeeds with warning)
- `"info"`: Informational (no compilation impact)

**Purpose**:
- Prioritization (critical vs recommended)
- Enforcement strategy (fail fast vs progressive)
- Risk management (high-risk vs low-risk)

### Constraint Patterns

#### Pattern 1: Implication (If-Then)

Use implication for conditional constraints:
```kcl
expression = "condition implies requirement"
```

**Examples**:
```kcl
# If production, then require encryption
"deployment.environment == 'production' implies deployment.encryption.atRest == true"

# If PII tag, then require access logging
"'PII' in tags implies deployment.accessLogging.enabled == true"

# If EU region, then require GDPR compliance
"deployment.region.startsWith('eu-') implies 'GDPR' in tags"
```

#### Pattern 2: Tag-Based Constraints

Use tag membership for policy activation:
```kcl
expression = "'TAG' in tags implies requirement"
```

**Examples**:
```kcl
# PII handling
"'PII' in tags implies deployment.encryption.atRest == true"

# GDPR compliance
"'GDPR' in tags implies retentionPolicy.maxDays <= 2555"

# PCI-DSS compliance
"'PCI-DSS' in tags implies networkSegmentation == true"
```

#### Pattern 3: Threshold Constraints

Use comparison operators for limits:
```kcl
expression = "metric <= threshold"
```

**Examples**:
```kcl
# Retention limit
"retentionPolicy.maxDays <= 2555"

# Cost limit
"costBudget.monthlyLimit <= 1000"

# Latency SLA
"sla.latency_p95 <= '100ms'"
```

## Policy Mixins

Policy mixins are **reusable policy patterns** that automatically apply governance constraints based on node properties (primarily tags). They implement:
- Tag-triggered activation
- Constraint propagation (taint analysis)
- Regulatory compliance patterns
- Reusable governance logic

### PIIMixin: Personally Identifiable Information

**Triggered by**: `["PII"]` tag

**Regulatory alignment**:
- GDPR Article 32: Security of processing
- CCPA Section 1798.150: Data security requirements
- HIPAA Security Rule: Administrative, physical, technical safeguards

**Enforced constraints**:

| Constraint | Expression | Severity |
|------------|------------|----------|
| Encryption at rest | `deployment.encryption.atRest == true` | error |
| Encryption in transit | `deployment.encryption.inTransit == true` | error |
| Access logging | `deployment.accessLogging.enabled == true` | error |
| Data masking (non-prod) | `deployment.environment != 'production' implies masking.enabled == true` | warning |

**Use cases**:
- Customer personal data (names, emails, addresses)
- Employee records (SSN, salary, performance reviews)
- Healthcare data (patient records, medical history)
- Financial data (account numbers, credit cards)

**Example**:
```kcl
customerProduct = Product {
    id = "customer-profile"
    name = "Customer Profile"
    tags = ["PII"]  # Triggers PIIMixin
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            atRest = true  # Required by PIIMixin
            inTransit = true  # Required by PIIMixin
        }
        accessLogging = AccessLoggingConfig {
            enabled = true  # Required by PIIMixin
        }
    }
}
```

**Constraint propagation**:
If Product B depends on Product A (PII-tagged), then Product B must either:
1. Apply PIIMixin (handle PII directly)
2. Apply MaskingMixin (de-identify PII)
3. Prove data is aggregated/anonymized

### GDPRMixin: General Data Protection Regulation

**Triggered by**: `["GDPR"]` tag

**Regulatory alignment**:
- GDPR Article 5: Principles relating to processing
- GDPR Article 17: Right to erasure ("right to be forgotten")
- GDPR Article 20: Right to data portability

**Enforced constraints**:

| Constraint | Expression | Severity |
|------------|------------|----------|
| Retention limit | `retentionPolicy.maxDays <= 2555` | error |
| Erasure capability | `retentionPolicy.erasureCapability == true` | error |
| Data portability | `portability.exportFormats includes 'json'` | error |
| Consent tracking | `consent.trackingEnabled == true` | error |

**Use cases**:
- EU customer data
- EU employee records
- EU healthcare data
- Any data subject to GDPR

**Example**:
```kcl
euCustomerProduct = Product {
    id = "eu-customer-data"
    name = "EU Customer Data"
    tags = ["GDPR", "PII"]  # Triggers both GDPRMixin and PIIMixin
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            atRest = true  # PIIMixin
        }
    }
    retentionPolicy = RetentionPolicy {
        maxDays = 2555  # 7 years (GDPRMixin)
        erasureCapability = true  # GDPRMixin
    }
    portability = DataPortability {
        exportFormats = ["json", "csv"]  # GDPRMixin
    }
}
```

### PCIDSSMixin: Payment Card Industry Data Security Standard

**Triggered by**: `["PCI-DSS"]` tag

**Regulatory alignment**:
- PCI-DSS Requirement 3: Protect stored cardholder data
- PCI-DSS Requirement 4: Encrypt transmission of cardholder data
- PCI-DSS Requirement 7: Restrict access to cardholder data
- PCI-DSS Requirement 11: Test security systems regularly

**Enforced constraints**:

| Constraint | Expression | Severity |
|------------|------------|----------|
| Cardholder data encryption | `encryption.cardholder == true` | error |
| Network segmentation | `networkSegmentation == true` | error |
| Access restrictions | `accessControl.rbac == true` | error |
| Vulnerability scans | `securityScanning.frequency == 'quarterly'` | error |

**Use cases**:
- Payment processing systems
- E-commerce platforms
- Point-of-sale systems
- Cardholder data environments

**Example**:
```kcl
paymentProduct = Product {
    id = "payment-gateway"
    name = "Payment Gateway"
    tags = ["PCI-DSS"]  # Triggers PCIDSSMixin
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            cardholder = true  # PCIDSSMixin
        }
        networkSegmentation = true  # PCIDSSMixin
        accessControl = AccessControl {
            rbac = true  # PCIDSSMixin
        }
        securityScanning = SecurityScanning {
            frequency = "quarterly"  # PCIDSSMixin
        }
    }
}
```

### SOC2Mixin: Service Organization Control 2

**Triggered by**: `["SOC2"]` tag

**Regulatory alignment**:
- SOC 2 Trust Service Criteria: Security, Availability, Processing Integrity, Confidentiality, Privacy

**Enforced constraints**:

| Constraint | Expression | Severity |
|------------|------------|----------|
| System monitoring | `monitoring.enabled == true` | error |
| Change management | `changeManagement.enabled == true` | error |
| Incident response | `incidentResponse.plan == 'documented'` | error |
| Backup procedures | `backup.frequency == 'daily'` | error |

**Use cases**:
- SaaS platforms
- Cloud service providers
- Managed security services
- Business-critical systems

**Example**:
```kcl
saasProduct = Product {
    id = "crm-platform"
    name = "CRM Platform"
    tags = ["SOC2"]  # Triggers SOC2Mixin
    deployment = DeploymentSpec {
        environment = "production"
        monitoring = MonitoringConfig {
            enabled = true  # SOC2Mixin
            metrics = ["availability", "latency", "errors"]
        }
        changeManagement = ChangeManagement {
            enabled = true  # SOC2Mixin
            approvalRequired = true
        }
        incidentResponse = IncidentResponse {
            plan = "documented"  # SOC2Mixin
            oncallRotation = true
        }
        backup = BackupConfig {
            frequency = "daily"  # SOC2Mixin
            retention = "30d"
        }
    }
}
```

## Policy Application Patterns

### Pattern 1: Global Policies (Organization Level)

Apply policies at Organization level to cascade to all child nodes:

```kcl
organization = Organization {
    id = "acme-corp"
    policies = [
        Policy {
            id = "global-encryption-v1"
            scope = "organization"
            policyType = "security"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.environment == 'production' implies deployment.encryption.atRest == true"
                    message = "All production deployments must enable encryption"
                    severity = "error"
                }
            ]
        }
    ]
}

# All meshes, domains, and products within this organization inherit the policy
```

### Pattern 2: Domain-Specific Policies

Add domain-specific policies on top of inherited global policies:

```kcl
financeDomain = Domain {
    id = "finance"
    meshId = "enterprise-mesh"
    # Inherits organization policies + adds domain-specific
    policies = [
        Policy {
            id = "finance-audit-logging-v1"
            scope = "domain"
            policyType = "compliance"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.accessLogging.enabled == true"
                    message = "Finance domain requires audit logging"
                    severity = "error"
                }
            ]
        }
    ]
}
```

### Pattern 3: Product-Specific Policies

Add product-specific policies for fine-grained control:

```kcl
customerProduct = Product {
    id = "customer-analytics"
    domainId = "customer"
    # Inherits organization + mesh + domain policies + adds product-specific
    policies = [
        Policy {
            id = "analytics-retention-v1"
            scope = "product"
            policyType = "quality"
            enforcement = "warning"
            constraints = [
                Constraint {
                    expression = "sla.freshness <= '1h'"
                    message = "Analytics data should be fresh within 1 hour"
                    severity = "warning"
                }
            ]
        }
    ]
}
```

## Validation Examples

### Example 1: Valid Product (Passes Validation)

```kcl
validProduct = Product {
    id = "secure-customer-data"
    name = "Secure Customer Data"
    tags = ["PII", "GDPR"]
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            atRest = true  # ✓ PIIMixin satisfied
            inTransit = true  # ✓ PIIMixin satisfied
        }
        accessLogging = AccessLoggingConfig {
            enabled = true  # ✓ PIIMixin satisfied
        }
    }
    retentionPolicy = RetentionPolicy {
        maxDays = 2000  # ✓ GDPRMixin satisfied (< 2555)
        erasureCapability = true  # ✓ GDPRMixin satisfied
    }
}

# kcl run → SUCCESS
```

### Example 2: Invalid Product (Fails Validation)

```kcl
invalidProduct = Product {
    id = "insecure-customer-data"
    name = "Insecure Customer Data"
    tags = ["PII"]
    deployment = DeploymentSpec {
        environment = "production"
        # ✗ Missing encryption (PIIMixin violation)
    }
}

# kcl run → ERROR: Products handling PII must enable encryption at rest (GDPR Article 32)
```

### Example 3: Warning (Non-Blocking)

```kcl
warningProduct = Product {
    id = "dev-prototype"
    deployment = DeploymentSpec {
        environment = "development"
        costBudget = CostBudget {
            monthlyLimit = 1500  # ⚠ Exceeds $1000 limit
        }
    }
}

# kcl run → WARNING: Development environments should not exceed $1000/month
# Compilation succeeds, warning logged
```

## Best Practices

### 1. Use Descriptive Policy IDs

Include version suffix for policy evolution:
```kcl
✅ Good: id = "pii-encryption-v1"
❌ Bad:  id = "policy-1"
```

### 2. Write Clear Constraint Messages

Reference regulatory requirements:
```kcl
✅ Good: message = "Products handling PII must enable encryption at rest (GDPR Article 32)"
❌ Bad:  message = "Encryption required"
```

### 3. Choose Appropriate Enforcement Levels

- `blocking`: Security, compliance, SLAs
- `warning`: Best practices, recommendations
- `audit`: Experimental, monitoring

### 4. Use Tag-Triggered Mixins

Leverage reusable patterns:
```kcl
✅ Good: tags = ["PII", "GDPR"]  # Triggers PIIMixin + GDPRMixin
❌ Bad:  Manually define encryption policies for every product
```

### 5. Test Policies with Examples

Create test products that should pass and fail:
```kcl
# Test: valid product
validTest = Product {
    tags = ["PII"]
    deployment = DeploymentSpec {
        encryption = EncryptionConfig { atRest = true }
    }
}

# Test: invalid product (should fail compilation)
invalidTest = Product {
    tags = ["PII"]
    deployment = DeploymentSpec { }  # Missing encryption
}
```

## Integration with Other Schemas

### MeshNode Integration

All MeshNodes include `policies` and `constraints` attributes:
- Policies cascade from parent to child
- Constraints evaluated during `kcl run`
- Tag-triggered mixins apply automatically
- See [Core Schemas](core.md) for details

### Discovery Integration

Policies apply to all catalog entities:
- Organization, Mesh, Domain, Product, Component all inherit policies
- Policy scope determines which entities are affected
- See [Discovery Schemas](discovery.md) for hierarchy details

## Academic Foundation

### Federated Governance (Dolhopolov et al., 2024)

- **Hierarchical Policy Propagation**: O(D) vs O(T) complexity reduction
- **Compile-Time Validation**: Shift-left governance verification
- **Tag-Triggered Constraints**: Automated policy application

**Reference**: Dolhopolov, A., et al. (2024). "Implementing Federated Governance in Data Mesh Architecture." *MDPI Future Internet*, Vol. 16, Issue 4.

### Data Mesh Reference Architecture (van der Werf et al., 2025)

- **Federated Computational Governance**: Domain autonomy with global compliance
- **Policy as Code**: Declarative, version-controlled governance
- **Constraint Propagation**: Taint analysis for data sensitivity

**Reference**: van der Werf, J. M., et al. (2025). "Towards a Data Mesh Reference Architecture." *Springer LNBIP - Enterprise Design, Operations, and Computing*.

### Scalable Policy-as-Code (Brambilla & Plebani, 2025)

- **Policy Decision Points (PDPs)**: Distributed policy evaluation architecture
- **Policy Enforcement Points (PEPs)**: Scalable enforcement with minimal central coordination
- **Hybrid Approach**: Balances policy consistency with system scalability
- **Dependency Management**: Graph-based policy dependencies for optimal distribution

**Reference**: Brambilla, M., & Plebani, P. (2025). "Scalable Policy-as-Code Decision Points for Data Products." *IEEE International Conference on Web Services (ICWS)*.

**CDMesh Implementation**: While Brambilla & Plebani focus on runtime PDPs, CDMesh extends this to **compile-time policy validation**, achieving zero runtime overhead through KCL's shift-left validation.

### AI-Assisted Governance (Wider et al., 2025)

- **LLM-Based Policy Evaluation**: Using GPT-4 for automated compliance checking
- **Access Request Validation**: AI-assisted evaluation of data access requests against policies
- **Policy Violation Detection**: Automated identification of constraint violations
- **Governance Automation**: Reducing manual workload in policy verification

**Reference**: Wider, A., Harrer, S., & Dietz, L. W. (2025). "AI-Assisted Data Governance with Data Mesh Manager." *IEEE International Conference on Web Services (ICWS)*.

**CDMesh Opportunity**: Future integration could leverage LLMs for policy authoring assistance and natural language policy queries.

### Contract-Driven Lifecycle (CMA Pillar)

- **Shift-Left Validation**: Catch violations before deployment
- **Zero Runtime Overhead**: No policy evaluation cost in production
- **Type-Safe Constraints**: KCL's type system ensures correctness

## Related Documentation

- **[Architecture Overview](../architecture.md)** - CMA pillars and governance model
- **[Core Schemas](core.md)** - MeshNode with policies and constraints
- **[Discovery Schemas](discovery.md)** - Policy cascading in hierarchy
- **[Deployment Schemas](deploy.md)** - Deployment configuration validated by policies

---

**Schema Locations**: `governance/policy.k`, `governance/mixins.k`
**DDD Pattern**: Specification Object (Policy), Specification Object (Constraint)
**CMA Pillar**: Contract Driven Lifecycle (CDL)
**Complexity**: O(D) policy propagation (D ≈ 4)
