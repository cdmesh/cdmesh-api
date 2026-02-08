# Core Schemas

**Module**: `core/`
**Primary Schema**: `MeshNode`
**File**: `core/node.k`

## Overview

The `core` module defines the foundational schema for all catalog-managed entities in the Composable Mesh Architecture (CMA). At its heart is **MeshNode**, the universal base schema that provides a semantically precise and governance-aware foundation for the entire mesh topology.

MeshNode is not merely a data structure—it is an **architectural pattern** that embodies the principles of Domain-Driven Design, Data Mesh, and Contract-Driven Infrastructure. Every catalog-discoverable entity in CDMesh API extends MeshNode, inheriting its identity, governance, semantic, and lifecycle capabilities.

## MeshNode: Universal Abstraction

### Design Philosophy

MeshNode represents a **universal abstraction** for autonomous units in the mesh topology. It provides:

1. **Independent Identity**: Globally unique `id` for catalog lookup and graph relations
2. **Independent Lifecycle**: Version, status, and ownership tracking
3. **Governance Integration**: Cascading policies and compile-time constraints
4. **Semantic Awareness**: RDF/OWL metadata for knowledge graph construction
5. **Deployment Specification**: GitOps-ready infrastructure definition

### Domain-Driven Design Pattern: Aggregate Root

In DDD terminology, MeshNode is an **Aggregate Root**:

- **Aggregate**: A cluster of domain objects that can be treated as a single unit
- **Root**: The entry point for accessing the aggregate
- **Identity**: MeshNode has a globally unique identifier (`id` field)
- **Lifecycle**: MeshNode manages its own lifecycle (version, status)
- **Boundary**: MeshNode defines a consistency boundary for its aggregate

**Implications**:
- All catalog entities (Organization, Mesh, Domain, Product, Component) extend MeshNode
- Each MeshNode instance is independently managed in the platform catalog
- MeshNodes are mapped as vertices in the CDMesh Knowledge Graph
- External references to MeshNodes use the `id` field (foreign key pattern)

### Architecture: 6-Level Hierarchy Root

MeshNode forms the root of the 6-level hierarchy:

```
MeshNode (base schema)
├── Organization (Level 0) - Global governance boundary
├── Mesh (Level 1) - Organizational/tenant boundary
├── Domain (Level 2) - Business capability grouping
├── Product (Level 3) - Autonomous deployable unit
└── Component (Level 4) - Atomic building block
```

**Non-MeshNodes** (not catalog entities):
- **Port** (Level 5): Value Object embedded in Product/Component
- **DeploymentSpec**: Specification Object owned by MeshNode
- **Policy**: Governance metadata applied to MeshNode
- **Constraint**: Validation rule within Policy
- **SemanticMetadata**: Ontological metadata attached to MeshNode

### Key Attributes

#### Identity Attributes

- **`id`** (required): Globally unique identifier for catalog lookup and graph relations
  - Format: kebab-case or UUID
  - Examples: `"customer-profile"`, `"recommendation-engine"`, `"7f3e9a2b-4c1d-4e8f-9b6c-2d1e4f7a8c3b"`
  - Used for: Catalog indexing, graph vertex IDs, foreign key references

- **`name`** (required): Human-readable name for the node
  - Examples: `"Customer Profile"`, `"Recommendation Engine"`
  - Used for: User interfaces, documentation, reports

- **`description`** (optional): Detailed description of the node's purpose and scope
  - Used for: Documentation, catalog discovery, semantic search

#### Semantic Attributes

- **`semantics`** (optional): SemanticMetadata for knowledge graph construction
  - Enables: RDF export, business glossary integration, data lineage
  - Contains: RDF types, namespace URIs, business terms, data classification
  - Purpose: Ontological reasoning, semantic search, compliance classification

#### Governance Attributes

- **`policies`** (default `[]`): Governance policies applicable to this node
  - Cascades from parent nodes via inheritance
  - Local policies can extend or override parent policies
  - Examples: Encryption requirements, retention policies, access controls
  - Evaluation: Compile-time validation via `check` blocks

- **`constraints`** (default `[]`): Direct compile-time constraints
  - Alternative to policy-based constraints
  - Useful for node-specific validations not part of reusable policies
  - Evaluation: Compile-time validation via KCL `check` blocks

#### Deployment Attributes

- **`deployment`** (required): DeploymentSpec for infrastructure
  - Part of the MeshNode aggregate (Specification Object pattern)
  - Contains: Environment (production/staging/development), source repository, encryption config
  - Purpose: GitOps-managed infrastructure provisioning

#### Lifecycle Attributes

- **`version`** (default `"0.1.0"`): Semantic version of this node (X.Y.Z format)
  - Follows semver conventions for compatibility tracking
  - Major version: Breaking changes
  - Minor version: Backward-compatible features
  - Patch version: Backward-compatible bug fixes

- **`status`** (default `"proposed"`): Lifecycle status of this node
  - **proposed**: Design phase, not yet implemented
  - **experimental**: Early implementation, unstable API
  - **live**: Production-ready, stable API
  - **deprecated**: Scheduled for removal, use alternatives
  - **retired**: No longer available

- **`owner`** (optional): Owner or team responsible for this node
  - Examples: `"data-platform-team"`, `"finance-domain"`, `"alice@company.com"`
  - Purpose: Accountability, contact information, RACI matrix

- **`tags`** (default `[]`): Freeform tags for categorization and policy triggering
  - Special tags trigger policy mixins:
    - `"PII"`: Triggers PIIMixin (encryption, masking)
    - `"GDPR"`: Triggers GDPRMixin (retention, consent)
    - `"PCI-DSS"`: Triggers PCI compliance policies
    - `"SOC2"`: Triggers SOC 2 compliance policies
  - Purpose: Policy activation, catalog filtering, semantic tagging

## Governance Model

### Policy Cascading: O(D) Complexity

MeshNodes inherit policies from parent nodes via schema inheritance:

```
C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Product ⊕ C_Local

Where ⊕ represents policy composition (union with child precedence)
```

**Hierarchy Depth (D)**:
- Organization → Mesh → Domain → Product ≈ **4 levels**

**Complexity Analysis**:
- **Federated Inheritance (CDMesh)**: O(D) where D ≈ 4
- **Tuple-Based Governance (Traditional)**: O(T) where T ≈ 10,000
- **Benefit**: **2,500x reduction** in governance overhead

**Example**:
```
Organization.policies = [GlobalEncryptionPolicy, GlobalRetentionPolicy]
Mesh.policies = Organization.policies + [MeshSpecificPolicy]
Domain.policies = Mesh.policies + [DomainCompliancePolicy]
Product.policies = Domain.policies + [ProductSLAPolicy]
```

When Organization updates `GlobalEncryptionPolicy`, the change propagates to all child nodes with O(D) recompilation cost, not O(T) tuple updates.

### Compile-Time Validation

MeshNode enforces compile-time validation via KCL `check` blocks:

```kcl
check:
    len(id) > 0, "id must not be empty"
    len(name) > 0, "name must not be empty"
    regex.match(version, r"^\d+\.\d+\.\d+$"), "version must follow semantic versioning (X.Y.Z)"
```

**Benefits**:
- Policy violations caught during `kcl run`, not in production
- Shift-left governance verification (Contract Driven Lifecycle)
- No runtime governance overhead

### Tag-Triggered Policy Mixins

Tags on MeshNodes trigger reusable policy mixins:

| Tag | Mixin | Triggered Constraints |
|-----|-------|----------------------|
| `PII` | PIIMixin | Encryption at rest, access logging, data masking in non-production |
| `GDPR` | GDPRMixin | Retention limits, erasure capability, data portability |
| `PCI-DSS` | PCIDSSMixin | Cardholder data encryption, network segmentation, vulnerability scans |
| `SOC2` | SOC2Mixin | System monitoring, change management, incident response |

**Example**:
```kcl
product = Product {
    id = "customer-transactions"
    name = "Customer Transactions"
    tags = ["PII", "GDPR", "PCI-DSS"]  # Triggers 3 mixins
    deployment = DeploymentSpec { ... }
    # PIIMixin enforces encryption.atRest = true
    # GDPRMixin enforces retentionDays <= 365
    # PCIDSSMixin enforces networkSegmentation = true
}
```

## Semantic Metadata Integration

### Semantic Driven Design (SDD)

MeshNode supports **Semantic Driven Design**, one of the three CMA pillars. The `semantics` attribute enables:

1. **RDF/OWL Integration**: Map MeshNodes to RDF classes for ontological reasoning
2. **Business Glossary**: Link technical entities to business concepts
3. **Data Classification**: Automated access control based on sensitivity levels
4. **Data Lineage**: Track upstream dependencies and downstream consumers

### RDF Type Mapping

MeshNodes can be mapped to RDF ontologies:

| MeshNode Type | RDF Class (rdfType) | Ontology |
|---------------|---------------------|----------|
| Product (dataset) | `http://schema.org/Dataset` | Schema.org |
| Product (api) | `http://schema.org/WebAPI` | Schema.org |
| Product (stream) | `http://www.w3.org/ns/dcat#DataService` | DCAT 2.0 |
| Domain | `http://www.w3.org/ns/org#OrganizationalUnit` | W3C Organization |
| Organization | `http://www.w3.org/ns/org#Organization` | W3C Organization |

### Knowledge Graph Construction

SemanticMetadata enables CDMesh entities to be exported as RDF triples:

```turtle
# RDF Turtle representation
<https://mesh.company.com/products/customer-profile>
    a schema:Dataset ;
    rdfs:label "Customer Profile" ;
    dct:description "Customer master data and profile information" ;
    dcat:keyword "PII", "GDPR" ;
    prov:wasGeneratedBy <https://mesh.company.com/domains/customer> .
```

## Use Cases

### Use Case 1: Multi-Tenant Platform

**Scenario**: A SaaS platform needs to isolate customer data and enforce tenant-specific policies.

**Solution**: Use Organization as the global governance boundary:
```kcl
acmeCorp = Organization {
    id = "org-acme-corp"
    name = "Acme Corporation"
    legalName = "Acme Corp Inc."
    jurisdiction = "US"
    regulatoryFramework = ["SOC2", "HIPAA"]
    deployment = DeploymentSpec {
        environment = "production"
    }
    tags = ["enterprise-tier"]
}

globexCorp = Organization {
    id = "org-globex"
    name = "Globex Corporation"
    jurisdiction = "EU"
    regulatoryFramework = ["GDPR", "SOC2"]
    deployment = DeploymentSpec {
        environment = "production"
    }
}
```

**Benefits**:
- Tenant isolation at the Organization level
- Jurisdiction-specific policies (US vs EU)
- Regulatory compliance enforcement (HIPAA vs GDPR)

### Use Case 2: Federated Governance

**Scenario**: A large enterprise wants to enforce global policies while allowing domain teams autonomy.

**Solution**: Use policy cascading with domain-level overrides:
```kcl
# Organization-level global policy
globalOrg = Organization {
    id = "enterprise"
    policies = [
        Policy {
            id = "global-encryption"
            name = "Global Encryption Policy"
            scope = "organization"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.encryption.atRest == true"
                    message = "All data must be encrypted at rest"
                    severity = "error"
                }
            ]
        }
    ]
    deployment = DeploymentSpec { ... }
}

# Domain-level specific policy
financeDomain = Domain {
    id = "finance-domain"
    meshId = "finance-mesh"
    # Inherits globalOrg.policies + adds domain-specific
    policies = [
        Policy {
            id = "finance-audit-logging"
            name = "Finance Audit Logging"
            scope = "domain"
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
    deployment = DeploymentSpec { ... }
}
```

**Benefits**:
- Global policies cascade automatically (O(D) complexity)
- Domain teams can add specific policies
- Compile-time validation prevents violations

### Use Case 3: Data Lineage Tracking

**Scenario**: A data platform needs to track data lineage for compliance and debugging.

**Solution**: Use SemanticMetadata for upstream/downstream tracking:
```kcl
rawProduct = Product {
    id = "raw-events"
    semantics = SemanticMetadata {
        rdfType = "http://schema.org/Dataset"
        dataClassification = "internal"
        downstreamConsumers = ["cleaned-events", "aggregated-metrics"]
    }
    deployment = DeploymentSpec { ... }
}

cleanedProduct = Product {
    id = "cleaned-events"
    semantics = SemanticMetadata {
        rdfType = "http://schema.org/Dataset"
        dataClassification = "internal"
        upstreamDependencies = ["raw-events"]
        downstreamConsumers = ["customer-360"]
    }
    deployment = DeploymentSpec { ... }
}
```

**Benefits**:
- Explicit lineage tracking in semantics
- Knowledge graph construction for impact analysis
- Automated compliance reporting (data provenance)

### Use Case 4: Lifecycle Management

**Scenario**: A platform needs to manage the lifecycle of data products from proposal to retirement.

**Solution**: Use `status` field for lifecycle tracking:
```kcl
# New product in design phase
proposedProduct = Product {
    id = "new-recommendation-engine"
    name = "Recommendation Engine v2"
    status = "proposed"  # Not yet implemented
    version = "0.1.0"
    owner = "data-science-team"
    deployment = DeploymentSpec { ... }
}

# Product in production
liveProduct = Product {
    id = "customer-profile"
    status = "live"  # Production-ready
    version = "1.2.3"
    deployment = DeploymentSpec { ... }
}

# Old product being phased out
deprecatedProduct = Product {
    id = "legacy-customer-db"
    status = "deprecated"  # Use customer-profile instead
    version = "0.8.5"
    description = "Deprecated: Use customer-profile instead"
    deployment = DeploymentSpec { ... }
}
```

**Benefits**:
- Clear lifecycle stages for catalog discovery
- Deprecation warnings for consumers
- Version tracking for compatibility

### Use Case 5: Constraint Propagation (Taint Analysis)

**Scenario**: A platform needs to ensure PII data is handled correctly across dependent products.

**Solution**: Use tag inheritance for constraint propagation:
```kcl
# Product A contains PII
productA = Product {
    id = "customer-personal-data"
    tags = ["PII", "GDPR"]  # Triggers PIIMixin and GDPRMixin
    deployment = DeploymentSpec {
        encryption = EncryptionConfig { atRest = true }  # Required by PIIMixin
    }
}

# Product C depends on Product A
productC = Product {
    id = "customer-analytics"
    dependsOn = ["customer-personal-data"]
    # Must inherit "PII" tag due to dependency
    tags = ["PII"]  # Taint analysis propagates PII tag
    deployment = DeploymentSpec {
        encryption = EncryptionConfig { atRest = true }  # Required by PIIMixin
    }
}
```

**Benefits**:
- Automatic constraint propagation via tag inheritance
- Compile-time validation of PII handling
- Theorem 1: If Node A has ContainsPII and Node C consumes Node A, then Node C must satisfy HasEncryption

## Integration with Other Schemas

MeshNode is designed to compose with other schemas in the CDMesh API:

### Deployment Integration

Every MeshNode has a `deployment` attribute of type `DeploymentSpec`:
- Defines operational context (production/staging/development)
- References source repository for GitOps
- Configures encryption, logging, and regional deployment
- See [Deployment Schemas](deploy.md) for details

### Governance Integration

MeshNode includes `policies` and `constraints` attributes:
- Policies cascade from parent nodes via inheritance
- Constraints enable compile-time validation
- Policy mixins triggered by tags (PII, GDPR, PCI-DSS, SOC2)
- See [Governance Schemas](governance.md) for details

### Semantic Integration

MeshNode includes `semantics` attribute of type `SemanticMetadata`:
- Maps to RDF/OWL ontologies for knowledge graphs
- Links to business glossary terms
- Tracks data lineage (upstream/downstream)
- Classifies data sensitivity (public/internal/confidential/restricted)
- See [Semantic Schemas](semantics.md) for details

### Discovery Integration

All catalog-discoverable entities extend MeshNode:
- Organization, Mesh, Domain, Product, Component are MeshNodes
- Each inherits identity, governance, semantic, and lifecycle attributes
- Relationships between MeshNodes form the mesh topology graph
- See [Discovery Schemas](discovery.md) for details

## Academic Foundation

MeshNode design is grounded in academic research:

### Domain-Driven Design (Evans, 2003)

- **Aggregate Root**: MeshNode serves as the root of the entity aggregate
- **Bounded Context**: Each MeshNode defines a consistency boundary
- **Ubiquitous Language**: MeshNode attributes map to domain concepts (owner, version, status)

### Data Mesh Principles (Dehghani, 2022; van der Werf et al., 2025)

- **Domain Ownership**: `owner` attribute establishes accountability
- **Data as a Product**: MeshNode treats all resources as first-class products
- **Self-Serve Platform**: `deployment` attribute enables self-service provisioning
- **Federated Governance**: Policy cascading achieves O(D) complexity

### Federated Governance (Dolhopolov et al., 2024)

- **Hierarchical Policy Propagation**: O(D) vs O(T) complexity reduction
- **Compile-Time Validation**: Shift-left governance verification
- **Tag-Triggered Constraints**: Automated policy application

### Liskov Substitution Principle (Liskov, 1987)

- **Substitutability**: All MeshNodes can be treated uniformly by catalog systems
- **Behavioral Subtyping**: Derived entities (Product, Domain) preserve MeshNode contracts
- **Abstraction**: MeshNode provides a stable abstraction for heterogeneous entities

## Best Practices

### 1. Always Provide Meaningful IDs

Use kebab-case for human-readable IDs:
```kcl
✅ Good: id = "customer-profile-api"
❌ Bad:  id = "cp-001"
```

### 2. Use Semantic Versioning

Follow semver for version tracking:
```kcl
✅ Good: version = "1.2.3"
❌ Bad:  version = "v1"
```

### 3. Set Appropriate Status

Match status to actual lifecycle stage:
```kcl
✅ Good: status = "experimental"  # For beta products
❌ Bad:  status = "live"  # For untested products
```

### 4. Tag for Policy Activation

Use tags to trigger compliance policies:
```kcl
✅ Good: tags = ["PII", "GDPR"]  # Triggers PIIMixin and GDPRMixin
❌ Bad:  tags = []  # No policy enforcement
```

### 5. Provide Semantic Metadata

Enhance discoverability with semantic annotations:
```kcl
✅ Good: semantics = SemanticMetadata {
    rdfType = "http://schema.org/Dataset"
    businessGlossaryTerms = ["CustomerData", "CRM"]
    dataClassification = "confidential"
}
❌ Bad:  semantics = None  # No semantic integration
```

## Validation Rules

MeshNode enforces compile-time validation:

1. **Non-Empty ID**: `len(id) > 0`
2. **Non-Empty Name**: `len(name) > 0`
3. **Semantic Versioning**: `regex.match(version, r"^\d+\.\d+\.\d+$")`
4. **Valid Status**: One of `["proposed", "experimental", "live", "deprecated", "retired"]`
5. **Required Deployment**: `deployment` attribute must be present

Additional validation may be enforced by policy constraints and mixins.

## Related Documentation

- **[Architecture Overview](../architecture.md)** - Comprehensive architecture documentation
- **[Discovery Schemas](discovery.md)** - Organization, Mesh, Domain, Product, Component
- **[Governance Schemas](governance.md)** - Policy, Constraint, Mixins
- **[Deployment Schemas](deploy.md)** - DeploymentSpec, SourceRepository
- **[Semantic Schemas](semantics.md)** - SemanticMetadata

---

**Schema Location**: `core/node.k`
**Extends**: None (base schema)
**Extended By**: Organization, Mesh, Domain, Product, Component
