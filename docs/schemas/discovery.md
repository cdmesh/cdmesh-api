# Discovery Schemas

**Module**: `discovery/`
**Schemas**: `Organization`, `Mesh`, `Domain`, `Product`, `Component`, `Port`, `ComponentEdge`
**Files**: `discovery/*.k`

## Overview

The `discovery` module defines the **6-level hierarchical topology** that forms the backbone of the Composable Mesh Architecture (CMA). These schemas represent catalog-discoverable entities that can be queried, indexed, and navigated through the CDMesh platform.

The discovery schemas implement a sophisticated architectural pattern that combines:
- **Data Mesh principles**: Domain Ownership, Data as a Product, Self-Serve Platform, Federated Governance
- **Domain-Driven Design patterns**: Aggregate Roots, Value Objects, Bounded Contexts
- **Composable architecture**: Unified abstraction for data products, microservices, event streams, and ML pipelines

### Hierarchical Structure

```
Level 0: Organization (Global governance boundary)
    ↓ CONTAINS
Level 1: Mesh (Organizational/tenant boundary)
    ↓ CONTAINS
Level 2: Domain (Business capability grouping)
    ↓ OWNS
Level 3: Product (Autonomous deployable unit)
    ↓ COMPOSES
Level 4: Component (Atomic building block)
    ↓ EXPOSES
Level 5: Port (Interface boundary - Value Object)

Wiring: ComponentEdge (Data flow between components)
```

### MeshNode vs Non-MeshNode

**MeshNodes** (Aggregate Roots extending MeshNode):
- Organization, Mesh, Domain, Product, Component
- Independently managed in the platform catalog
- Mapped as nodes in the CDMesh Knowledge Graph
- Have independent lifecycle and identity

**Non-MeshNodes** (Value Objects and Specification Objects):
- Port: Interface boundary (embedded in Product/Component)
- ComponentEdge: Data flow descriptor (part of Product.componentGraph)

---

## Organization: Global Governance Boundary (Level 0)

### Design Philosophy

**Organization** represents the highest level of the mesh topology, establishing the **root governance boundary** for the entire hierarchy. It enables multi-tenant scenarios where different customers, business units, or regulatory jurisdictions require complete isolation and independent policy frameworks.

In regulatory and enterprise contexts, Organizations represent:
- **Legal entities**: Corporations, subsidiaries, holding companies
- **Tenant boundaries**: Customer organizations in SaaS platforms
- **Jurisdictional boundaries**: US, EU, APAC regions with different regulations
- **Compliance boundaries**: GDPR, HIPAA, PCI-DSS regulatory frameworks

### Architecture and Hierarchy Position

**Level**: 0 (Root of hierarchy)
**DDD Pattern**: Aggregate Root (outermost Bounded Context)
**Extends**: MeshNode
**Graph Relationships**:
- CONTAINS → Mesh (one-to-many)

Organization is the **entry point** for policy cascading. All policies defined at this level automatically propagate to all child entities (Meshes, Domains, Products, Components), enabling **O(D) governance complexity** where D = hierarchy depth ≈ 4.

### Key Attributes

#### Inherited from MeshNode

- **id**: Organization identifier (e.g., "acme-corp", "eu-tenant-1")
- **name**: Human-readable organization name
- **description**: Organization purpose and scope
- **deployment**: Organization-level infrastructure configuration
- **policies**: Global policies (cascade to all children)
- **semantics**: Ontological metadata (industry classification)
- **version**, **status**, **owner**, **tags**: Lifecycle management

#### Organization-Specific Attributes

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `legalName` | str | Optional | Legal registered name for contracts and compliance reporting |
| `jurisdiction` | str | Optional | Primary legal jurisdiction (ISO 3166-1 alpha-2: "US", "EU", "GB") |
| `regulatoryFramework` | [str] | Optional | Applicable compliance frameworks (["GDPR", "HIPAA", "PCI-DSS"]) |
| `billingAccountId` | str | Optional | Cloud provider billing account (AWS Organizations, Azure MGs) |
| `costCenter` | str | Optional | Internal cost allocation identifier for chargeback/showback |

### Data Mesh Principle: Federated Governance

Organization implements **federated governance** through policy cascading:

```
Mathematical Model:
C_Product = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Product_Local

Where ⊕ represents policy composition (union with child precedence)
```

**Benefits**:
- Single policy update at Organization level propagates to all descendants
- O(D) complexity vs O(T) for tuple-based governance (2,500x reduction)
- Automated compliance enforcement across entire organization

### Use Cases

#### Use Case 1: Multi-Tenant SaaS Platform

**Scenario**: A SaaS platform hosts multiple customer organizations, each requiring data isolation and independent governance.

**Solution**:
```kcl
# Customer A (US-based, HIPAA-compliant)
customerA = Organization {
    id = "customer-a"
    name = "Healthcare Provider A"
    legalName = "Healthcare Provider A Inc."
    jurisdiction = "US"
    regulatoryFramework = ["HIPAA", "HITECH"]
    deployment = DeploymentSpec {
        environment = "production"
        region = "us-east-1"
    }
    policies = [
        Policy {
            id = "hipaa-baseline"
            name = "HIPAA Security Rule"
            scope = "organization"
            policyType = "compliance"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.encryption.atRest == true"
                    message = "HIPAA requires encryption at rest"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["healthcare", "HIPAA"]
}

# Customer B (EU-based, GDPR-compliant)
customerB = Organization {
    id = "customer-b"
    name = "European Enterprise B"
    jurisdiction = "EU"
    regulatoryFramework = ["GDPR", "ePrivacy"]
    deployment = DeploymentSpec {
        environment = "production"
        region = "eu-central-1"
    }
    policies = [
        Policy {
            id = "gdpr-baseline"
            name = "GDPR Baseline"
            scope = "organization"
            policyType = "compliance"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.region.startswith('eu-')"
                    message = "EU data must remain in EU regions (GDPR Article 44)"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["enterprise", "GDPR"]
}
```

**Benefits**:
- Complete tenant isolation at the Organization level
- Jurisdiction-specific policies (US HIPAA vs EU GDPR)
- Regional data residency enforcement
- Independent cost tracking per customer

#### Use Case 2: Enterprise Holding Company

**Scenario**: A holding company with multiple subsidiaries, each requiring independent governance but shared global policies.

**Solution**:
```kcl
# Global corporate organization
globalCorp = Organization {
    id = "global-corp"
    name = "Global Corporation"
    policies = [
        Policy {
            id = "global-encryption"
            name = "Global Encryption Policy"
            scope = "organization"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.encryption.atRest == true"
                    message = "All data must be encrypted at rest (corporate policy)"
                    severity = "error"
                }
            ]
        }
    ]
    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Global policies cascade to all subsidiaries (via Mesh entities)
- Subsidiaries can add domain-specific policies
- Centralized compliance management

### Best Practices

1. **Use ISO 3166-1 Alpha-2 for Jurisdictions**: `jurisdiction = "US"` (not "United States")
2. **Match Regulatory Framework to Jurisdiction**: EU → GDPR, US → CCPA/HIPAA
3. **Align Tags with Compliance Frameworks**: Tags trigger policy mixins automatically
4. **Set Legal Name for Contracts**: Required for billing and legal agreements
5. **Use Cloud Provider Billing IDs**: Link to AWS Organizations, Azure Management Groups

### Validation Rules

- `jurisdiction` must be 2-character ISO code if specified
- `regulatoryFramework` must contain at least one framework if specified
- All MeshNode validation rules apply (id, name, version format)

---

## Mesh: Organizational Boundary (Level 1)

### Design Philosophy

**Mesh** defines an organizational or tenant boundary within a parent Organization. In Data Mesh terms, a Mesh represents the entire data ecosystem within a business unit, encompassing all domains and their data products.

A Mesh establishes:
- **Tenant isolation**: Separate mesh per customer or business unit
- **Organizational scope**: Boundary for domain organization
- **Policy inheritance**: Cascades from Organization + local policies
- **Discovery context**: Scope for catalog queries and navigation

### Architecture and Hierarchy Position

**Level**: 1
**DDD Pattern**: Aggregate Root (Bounded Context)
**Extends**: MeshNode
**Graph Relationships**:
- CONTAINED_BY → Organization (many-to-one)
- CONTAINS → Domain (one-to-many)

Mesh serves as the **organizational partition** for multi-tenant deployments. All domains within a mesh share the same organizational context and governance framework.

### Key Attributes

#### Inherited from MeshNode

All MeshNode attributes (id, name, description, deployment, policies, semantics, version, status, owner, tags)

#### Mesh-Specific Attributes

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `organizationId` | str | Optional | Reference to parent Organization (required for multi-tenant) |

**Policy Cascading**:
```
Mesh.policies = Organization.policies ⊕ Mesh.localPolicies
```

If `organizationId` is specified, the Mesh inherits all policies from the parent Organization.

### Data Mesh Principle: Mesh Ecosystem

Mesh embodies the **data ecosystem** concept from Data Mesh:
- All domains within a mesh form a cohesive ecosystem
- Cross-domain data sharing within mesh boundaries
- Unified governance framework across all domains
- Shared infrastructure and platform capabilities

### Use Cases

#### Use Case 1: Multi-Tenant Platform with Business Units

**Scenario**: A SaaS platform where each customer has multiple business units (Finance, Marketing, Operations).

**Solution**:
```kcl
# Customer organization
acmeCorp = Organization {
    id = "acme-corp"
    name = "Acme Corporation"
    jurisdiction = "US"
    deployment = DeploymentSpec { environment = "production" }
}

# Finance mesh (tenant-specific)
financeMesh = Mesh {
    id = "acme-finance-mesh"
    name = "Acme Finance Mesh"
    organizationId = "acme-corp"  # Inherits Acme policies
    deployment = DeploymentSpec { environment = "production" }
    tags = ["finance", "compliance"]
}

# Marketing mesh (tenant-specific)
marketingMesh = Mesh {
    id = "acme-marketing-mesh"
    name = "Acme Marketing Mesh"
    organizationId = "acme-corp"  # Inherits Acme policies
    deployment = DeploymentSpec { environment = "production" }
    tags = ["marketing", "analytics"]
}
```

**Benefits**:
- Tenant isolation at the Organization level
- Business unit separation at the Mesh level
- Shared global policies from Organization
- Independent domain organization per mesh

#### Use Case 2: Geographical Mesh Partitions

**Scenario**: A global enterprise with regional meshes (US, EU, APAC) for data residency.

**Solution**:
```kcl
globalOrg = Organization {
    id = "global-enterprise"
    name = "Global Enterprise"
    deployment = DeploymentSpec { environment = "production" }
}

usMesh = Mesh {
    id = "us-mesh"
    name = "US Mesh"
    organizationId = "global-enterprise"
    deployment = DeploymentSpec {
        environment = "production"
        region = "us-east-1"
    }
    tags = ["us-region"]
}

euMesh = Mesh {
    id = "eu-mesh"
    name = "EU Mesh"
    organizationId = "global-enterprise"
    deployment = DeploymentSpec {
        environment = "production"
        region = "eu-central-1"
    }
    policies = [
        Policy {
            id = "eu-data-residency"
            constraints = [
                Constraint {
                    expression = "deployment.region.startswith('eu-')"
                    message = "EU mesh data must stay in EU regions"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["eu-region", "GDPR"]
}
```

**Benefits**:
- Geographic data residency enforcement
- Regional compliance (GDPR in EU)
- Performance optimization (local data access)
- Disaster recovery (regional failover)

### Best Practices

1. **Always Set organizationId for Multi-Tenant**: Required for policy inheritance
2. **Use Descriptive Mesh Names**: Include tenant/business unit context
3. **Align Mesh with Organizational Structure**: Mirror real-world org chart
4. **Tag for Discovery**: Use tags for catalog filtering and navigation
5. **Set Deployment Region**: Match mesh to geographic location

---

## Domain: Business Capability Boundary (Level 2)

### Design Philosophy

**Domain** defines a business capability boundary that owns and manages a collection of related data products. In Data Mesh terms, a Domain embodies the principle of **Domain Ownership**—each domain represents a cohesive business capability (Finance, Customer, Supply Chain) with dedicated teams responsible for their data products.

In Domain-Driven Design terms, a Domain is a **Bounded Context** with its own:
- **Ubiquitous language**: Domain-specific terminology
- **Business logic**: Domain-specific rules and transformations
- **Team ownership**: Dedicated domain teams
- **Lifecycle independence**: Autonomous product development

### Architecture and Hierarchy Position

**Level**: 2
**DDD Pattern**: Aggregate Root (Bounded Context)
**Data Mesh Principle**: Domain Ownership
**Extends**: MeshNode
**Graph Relationships**:
- CONTAINED_BY → Mesh (many-to-one)
- OWNS → Product (one-to-many)

Domains represent **business capabilities** rather than technical boundaries. They align with Conway's Law: organizational structure drives system architecture.

### Key Attributes

#### Inherited from MeshNode

All MeshNode attributes (id, name, description, deployment, policies, semantics, version, status, owner, tags)

#### Domain-Specific Attributes

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `meshId` | str | Optional | Reference to parent Mesh (required for hierarchical governance) |

**Policy Cascading**:
```
Domain.policies = Mesh.policies ⊕ Domain.localPolicies
Domain.policies = Organization.policies ⊕ Mesh.policies ⊕ Domain.localPolicies
```

### Data Mesh Principle: Domain Ownership

Domain implements **domain ownership** through:
- **Accountability**: `owner` attribute specifies responsible team
- **Autonomy**: Domains manage their own products and deployments
- **Clear boundaries**: Domains encapsulate related business capabilities
- **Independent lifecycle**: Domains evolve independently

**Benefits**:
- Teams own end-to-end data product lifecycle
- Reduced coordination overhead (no central data team bottleneck)
- Domain-specific quality standards and SLAs
- Scalable organizational model (add domains independently)

### Use Cases

#### Use Case 1: Enterprise Domain Organization

**Scenario**: A large enterprise organizes data products by business capability.

**Solution**:
```kcl
# Finance domain (owns financial data products)
financeDomain = Domain {
    id = "finance-domain"
    name = "Finance Domain"
    description = "Financial reporting, accounting, and analytics"
    meshId = "enterprise-mesh"
    owner = "finance-data-team"
    deployment = DeploymentSpec { environment = "production" }
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
    tags = ["finance", "compliance", "SOC2"]
}

# Customer domain (owns customer data products)
customerDomain = Domain {
    id = "customer-domain"
    name = "Customer Domain"
    description = "Customer profiles, preferences, and behavior"
    meshId = "enterprise-mesh"
    owner = "customer-data-team"
    deployment = DeploymentSpec { environment = "production" }
    tags = ["customer", "PII", "GDPR"]
}

# Supply chain domain (owns logistics data products)
supplyChainDomain = Domain {
    id = "supply-chain-domain"
    name = "Supply Chain Domain"
    description = "Inventory, logistics, and supplier management"
    meshId = "enterprise-mesh"
    owner = "supply-chain-team"
    deployment = DeploymentSpec { environment = "production" }
    tags = ["supply-chain", "operations"]
}
```

**Benefits**:
- Clear ownership (finance-data-team owns finance domain)
- Domain-specific policies (audit logging for finance)
- Business-aligned organization (mirrors org chart)
- Independent evolution (customer team doesn't block finance team)

#### Use Case 2: Cross-Domain Data Sharing

**Scenario**: Marketing domain needs customer data from Customer domain.

**Solution**:
```kcl
customerDomain = Domain {
    id = "customer-domain"
    name = "Customer Domain"
    meshId = "enterprise-mesh"
    owner = "customer-data-team"
    deployment = DeploymentSpec { environment = "production" }
    tags = ["PII", "GDPR"]
}

# Customer domain exposes products
customerProfile = Product {
    id = "customer-profile"
    name = "Customer Profile"
    domainId = "customer-domain"
    kind = "dataset"
    ports = [
        Port {
            name = "profile-data"
            direction = "output"
            portType = "data"
            format = "parquet"
            classification = "confidential"
        }
    ]
    deployment = DeploymentSpec { environment = "production" }
}

# Marketing domain depends on customer data
marketingDomain = Domain {
    id = "marketing-domain"
    name = "Marketing Domain"
    meshId = "enterprise-mesh"
    owner = "marketing-team"
    deployment = DeploymentSpec { environment = "production" }
}

campaignAnalytics = Product {
    id = "campaign-analytics"
    domainId = "marketing-domain"
    kind = "dataset"
    dependsOn = ["customer-profile"]  # Cross-domain dependency
    tags = ["PII"]  # Inherits PII constraint from customer-profile
    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Cross-domain data sharing via product dependencies
- Constraint propagation (PII tag inherited)
- Clear ownership (customer team owns profile, marketing team owns analytics)
- Data lineage tracking (upstream dependencies)

### Best Practices

1. **Align Domains with Business Capabilities**: Finance, Customer, Supply Chain (not Technical, Data Lake)
2. **Assign Clear Ownership**: Specify team/individual responsible for domain
3. **Use Domain-Specific Tags**: Trigger relevant policy mixins (Finance → SOC2)
4. **Document Domain Boundaries**: Clear description of domain scope
5. **Enable Cross-Domain Collaboration**: Use product dependencies for data sharing

---

## Product: Autonomous Deployable Unit (Level 3)

### Design Philosophy

**Product** defines an autonomous, deployable unit that treats resources as first-class products. In Data Mesh terms, a Product embodies **Data as a Product**—it is an autonomous unit with:
- **Clear interface**: Ports define input/output boundaries
- **Discoverable**: Registered in mesh catalog
- **Quality SLAs**: Defined metrics for freshness, completeness, availability
- **Self-describing**: Comprehensive metadata and documentation

Products support **two composition patterns**:
1. **Atomic Products**: Single-component products (simple use cases)
2. **Composite Products**: Multi-component products (complex pipelines, microservices)

### Architecture and Hierarchy Position

**Level**: 3
**DDD Pattern**: Aggregate Root
**Data Mesh Principle**: Data as a Product
**Extends**: MeshNode
**Graph Relationships**:
- OWNED_BY → Domain (many-to-one)
- COMPOSES → Component (one-to-many)
- EXPOSES → Port (one-to-many, product-level external ports)
- DEPENDS_ON → Product (many-to-many)

### Key Attributes

#### Inherited from MeshNode

All MeshNode attributes (id, name, description, deployment, policies, semantics, version, status, owner, tags)

#### Product-Specific Attributes

| Attribute | Type | Default | Purpose |
|-----------|------|---------|---------|
| `domainId` | str | Optional | Reference to parent Domain (required for domain ownership) |
| `kind` | str | "dataset" | Product classifier (dataset, api, stream, dashboard, algorithm, service) |
| `components` | [str] | Optional | Component IDs for composition (empty/None = atomic product) |
| `componentGraph` | [ComponentEdge] | Optional | Data flow wiring between components (required for composite) |
| `ports` | [Port] | Optional | Product-level external ports (interfaces) |
| `dependsOn` | [str] | Optional | Product dependencies for lineage and constraint propagation |

**Policy Cascading**:
```
Product.policies = Domain.policies ⊕ Product.localPolicies
Product.policies = Organization.policies ⊕ Mesh.policies ⊕ Domain.policies ⊕ Product.localPolicies
```

### Product Kinds

Products support multiple resource types through the `kind` discriminator:

| Kind | Description | Use Cases | Port Types |
|------|-------------|-----------|------------|
| `dataset` | Traditional data products | Tables, files, data lakes | data |
| `api` | RESTful/gRPC service endpoints | Microservices, REST APIs | service |
| `stream` | Event streams | Kafka topics, Kinesis streams | event |
| `dashboard` | Analytical visualizations | BI dashboards, reports | service |
| `algorithm` | ML models and pipelines | Feature engineering, inference | data |
| `service` | General microservices | Authentication, notifications | service |

**Validation**: Product kind determines valid port types (dataset → data ports only, api → service ports only)

### Product Composition Patterns

#### Pattern 1: Atomic Product (Backward Compatible)

**Definition**: Single-component or legacy products
- `components = []` or `None`
- Direct port exposure
- Simple use cases

**Example**:
```kcl
customerProfile = Product {
    id = "customer-profile"
    name = "Customer Profile"
    domainId = "customer-domain"
    kind = "dataset"
    version = "1.0.0"
    status = "live"
    tags = ["PII", "GDPR"]

    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig { atRest = true }
    }

    ports = [
        Port {
            name = "customer-data"
            direction = "output"
            portType = "data"
            format = "parquet"
            catalog = "gold.customers"
            classification = "confidential"
            sla = {
                "freshness": "1h"
                "completeness": "99%"
            }
        }
    ]
}
```

**Use Cases**:
- Simple data products (single table)
- Legacy products (existing without composition)
- Standalone microservices (single service)

#### Pattern 2: Composite Product (Multi-Component)

**Definition**: Multi-component products with explicit wiring
- `components = [component-id-1, component-id-2, ...]`
- `componentGraph` defines data flow between components
- Product ports expose selected component ports externally

**Example**:
```kcl
customerETL = Product {
    id = "customer-etl-pipeline"
    name = "Customer ETL Pipeline"
    description = "End-to-end customer data pipeline: bronze → silver → gold"
    domainId = "customer-domain"
    kind = "dataset"
    version = "1.0.0"
    status = "live"
    tags = ["PII", "GDPR", "pipeline"]

    deployment = DeploymentSpec { environment = "production" }

    # Component composition
    components = [
        "kafka-to-delta-bronze",
        "bronze-to-silver-transform",
        "silver-to-gold-aggregate"
    ]

    # Component wiring (data flow)
    componentGraph = [
        ComponentEdge {
            sourceComponent = "kafka-to-delta-bronze"
            sourcePort = "delta-output"
            targetComponent = "bronze-to-silver-transform"
            targetPort = "delta-input"
        },
        ComponentEdge {
            sourceComponent = "bronze-to-silver-transform"
            sourcePort = "delta-output"
            targetComponent = "silver-to-gold-aggregate"
            targetPort = "delta-input"
            transformation = "filter(is_valid == true)"
        }
    ]

    # Product exposes only gold layer externally
    ports = [
        Port {
            name = "customer-gold"
            description = "Curated customer data (gold layer)"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "gold.customers"
            classification = "confidential"
            sla = {
                "freshness": "1h"
                "completeness": "99%"
            }
        }
    ]

    dependsOn = []
}
```

**Use Cases**:
- ETL pipelines (Kafka → Bronze → Silver → Gold)
- Microservices platforms (API Gateway → Auth → User → Notification)
- ML pipelines (Feature Store → Training → Inference)
- Complex data products (multiple transformation stages)

### Data Mesh Principle: Data as a Product

Products implement **data as a product** through:

1. **Discoverability**: Registered in catalog with comprehensive metadata
2. **Addressability**: Unique ID and versioned API
3. **Quality**: Defined SLAs for freshness, completeness, availability
4. **Security**: Classification, encryption, access controls
5. **Self-describing**: Ports define clear interfaces
6. **Interoperable**: Standard formats and protocols

### Use Cases

#### Use Case 3: Microservices API Platform

**Scenario**: A composite product with API Gateway, Auth Service, User Service.

**Solution**:
```kcl
customerAPIPlatform = Product {
    id = "customer-api-platform"
    name = "Customer API Platform"
    description = "Microservices platform for customer management"
    domainId = "customer-domain"
    kind = "api"
    version = "2.0.0"
    status = "live"

    deployment = DeploymentSpec { environment = "production" }

    components = [
        "api-gateway-1",
        "auth-service-instance",
        "user-service-instance"
    ]

    componentGraph = [
        ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "auth-route"
            targetComponent = "auth-service-instance"
            targetPort = "auth-api"
        },
        ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "user-route"
            targetComponent = "user-service-instance"
            targetPort = "user-api"
        },
        ComponentEdge {
            sourceComponent = "user-service-instance"
            sourcePort = "auth-client"
            targetComponent = "auth-service-instance"
            targetPort = "auth-api"
        }
    ]

    ports = [
        Port {
            name = "public-api"
            description = "Unified customer management API"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/customer-mgmt/openapi.yaml"
            authentication = "oauth2"
            classification = "internal"
            sla = {
                "availability": "99.95%"
                "latency_p95": "200ms"
            }
        }
    ]
}
```

**Benefits**:
- Unified product abstraction (single API product, multiple services)
- Internal composition hidden (consumers see only public-api port)
- Service dependencies explicit (API Gateway → Auth, User → Auth)
- SLA enforcement (availability, latency)

#### Use Case 4: ML Pipeline Product

**Scenario**: A recommendation engine that depends on customer profile and product catalog.

**Solution**:
```kcl
recommendationEngine = Product {
    id = "recommendation-engine"
    name = "Recommendation Engine"
    domainId = "marketing-domain"
    kind = "algorithm"
    version = "1.5.0"
    status = "live"

    dependsOn = ["customer-profile", "product-catalog"]
    tags = ["PII"]  # Inherits from customer-profile

    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig { atRest = true }  # Required due to PII tag
    }

    ports = [
        Port {
            name = "recommendations-api"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            classification = "internal"
            sla = {
                "latency_p95": "100ms"
                "availability": "99.9%"
            }
        }
    ]
}
```

**Benefits**:
- Constraint propagation (PII tag inherited from customer-profile)
- Data lineage tracking (upstream dependencies visible)
- Compile-time validation (encryption enforced due to PII)

### Best Practices

1. **Use Composite Products for Pipelines**: ETL, microservices, ML workflows
2. **Expose Only Necessary Ports**: Hide internal component ports
3. **Set Clear SLAs**: Define freshness, completeness, availability metrics
4. **Tag for Constraint Propagation**: PII, GDPR, SOC2 trigger policy enforcement
5. **Version Semantically**: Follow semver for compatibility tracking
6. **Document Component Graph**: Clear data flow visualization

### Validation Rules

- `dataset` products should only have data ports
- `api`/`service` products should only have service ports
- `stream` products should only have event ports
- Composite products (with components) must define `componentGraph`
- `componentGraph` requires `components` to be defined

---

## Component: Atomic Building Block (Level 4)

### Design Philosophy

**Component** represents the smallest deployable quantum that can be combined to build complex products. Components are the **fundamental building blocks** of composable architectures, inspired by:
- **Backstage**: Component as first-class catalog entity
- **Crossplane**: Composition resources as reusable components
- **OAM**: Component definitions for cloud-native apps
- **Terraform**: Modules as reusable infrastructure components

Components support **two usage patterns**:
1. **Template Components**: Reusable definitions in catalog (template = None)
2. **Instance Components**: Configured from template (template = component-id)

### Architecture and Hierarchy Position

**Level**: 4
**DDD Pattern**: Aggregate Root (independent lifecycle)
**CMA Principle**: Component reusability and composition
**Extends**: MeshNode
**Graph Relationships**:
- COMPOSED_BY → Product (many-to-one)
- EXPOSES → Port (one-to-many, component-level internal ports)
- DEPENDS_ON → Component (many-to-many)
- INSTANTIATES → Component (template-instance relationship)

### Key Attributes

#### Inherited from MeshNode

All MeshNode attributes (id, name, description, deployment, policies, semantics, version, status, owner, tags)

#### Component-Specific Attributes

| Attribute | Type | Default | Purpose |
|-----------|------|---------|---------|
| `productId` | str | Optional | Reference to parent Product (instances only, templates have None) |
| `kind` | str | Required | Component classifier (ingestion, transformation, service, etc.) |
| `ports` | [Port] | Optional | Component-owned ports (internal interfaces) |
| `dependsOn` | [str] | Optional | Component dependencies for deployment ordering |
| `template` | str | Optional | Template component ID (None = this IS a template) |
| `reusable` | bool | True | Whether component can be reused across products |
| `runtime` | str | Optional | Target runtime (databricks, kubernetes, airflow, etc.) |
| `config` | {str: str} | Optional | Component configuration parameters |

### Component Kinds

| Kind | Description | Examples | Runtime |
|------|-------------|----------|---------|
| `ingestion` | Data ingestion | KafkaToDelta, APIToS3, JDBCToParquet | Databricks, Spark |
| `transformation` | Data transformation | DeltaTransform, SQLTransform, SparkJob | Databricks, Spark |
| `aggregation` | Data aggregation | Rollup, Summarize, GroupBy | Databricks, Spark |
| `serving` | Data serving | DeltaToAPI, DeltaToBI, TableToCache | Kubernetes, Databricks |
| `orchestration` | Workflow orchestration | Airflow, Prefect, StepFunctions | Airflow, AWS |
| `service` | Microservices | AuthService, UserService, PaymentService | Kubernetes |
| `infrastructure` | Infrastructure | Database, Queue, Cache | Kubernetes, AWS |

### Component Usage Patterns

#### Pattern 1: Template Component (Reusable)

**Definition**: Reusable component definition stored in catalog
- `template = None` (this IS a template)
- `reusable = true`
- Parameterized ports and configuration
- No `productId` (not tied to specific product)

**Example**:
```kcl
kafka_to_delta_template = Component {
    id = "kafka-to-delta-v1"
    name = "Kafka to Delta Ingestion"
    description = "Streaming ingestion from Kafka to Delta Lake"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    reusable = true
    template = None  # This IS a template

    deployment = DeploymentSpec { environment = "production" }

    ports = [
        Port {
            name = "kafka-input"
            direction = "input"
            portType = "event"
            topic = "${kafka.topic}"  # Parameterized
            messageFormat = "avro"
        },
        Port {
            name = "delta-output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "${delta.catalog}"  # Parameterized
        }
    ]

    tags = ["streaming", "ingestion", "template"]
}
```

**Benefits**:
- Reusable across products (Kafka→Delta pattern common)
- Version-controlled (upgrade all instances by updating template)
- Best practices encoded (standardized configuration)
- Catalog-discoverable (search for "Kafka to Delta" template)

#### Pattern 2: Instance Component (Configured)

**Definition**: Configured component derived from template
- `template = template-component-id`
- `productId = product-id` (belongs to specific product)
- Concrete port configuration (no parameterization)
- Concrete config values

**Example**:
```kcl
kafka_to_delta_bronze = Component {
    id = "kafka-to-delta-bronze"
    name = "Kafka to Bronze Layer"
    description = "Ingest customer data to bronze layer"
    productId = "customer-etl-pipeline"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    template = "kafka-to-delta-v1"  # References template

    deployment = DeploymentSpec { environment = "production" }

    ports = [
        Port {
            name = "kafka-input"
            direction = "input"
            portType = "event"
            topic = "customers.raw"  # Concrete value
            messageFormat = "avro"
        },
        Port {
            name = "delta-output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "bronze.customers"  # Concrete value
        }
    ]

    config = {
        "kafka.bootstrap.servers": "kafka.example.com:9092"
        "kafka.consumer.group": "customer-bronze-consumer"
        "delta.merge.schema": "true"
    }

    tags = ["streaming", "ingestion", "bronze", "PII"]
}
```

**Benefits**:
- Template benefits (standardization, best practices)
- Product-specific configuration (concrete Kafka topic, Delta table)
- Independent deployment (deploy bronze without silver/gold)
- Component lineage (trace back to template)

### Use Cases

#### Use Case 1: Data Transformation Pipeline

**Scenario**: Transform bronze layer to silver layer with quality checks.

**Solution**:
```kcl
bronze_to_silver = Component {
    id = "customer-bronze-to-silver"
    name = "Customer Bronze to Silver Transform"
    productId = "customer-etl-pipeline"
    kind = "transformation"
    runtime = "databricks"
    version = "1.0.0"
    template = "delta-transform-v1"

    deployment = DeploymentSpec { environment = "production" }

    ports = [
        Port {
            name = "bronze-input"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "bronze.customers"
        },
        Port {
            name = "silver-output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "silver.customers"
        }
    ]

    config = {
        "transformation.sql": "SELECT * FROM bronze.customers WHERE is_valid = true"
        "quality.rules": "not_null(customer_id), email_format(email)"
    }

    dependsOn = ["kafka-to-delta-bronze"]
    tags = ["transformation", "silver", "PII"]
}
```

**Benefits**:
- Clear dependencies (depends on bronze ingestion)
- Quality rules in config (compile-time documentation)
- Delta format consistency (bronze → silver)

#### Use Case 2: Microservice Component

**Scenario**: Authentication service for API platform.

**Solution**:
```kcl
auth_service_instance = Component {
    id = "auth-service-prod"
    name = "Authentication Service (Production)"
    productId = "customer-api-platform"
    kind = "service"
    runtime = "kubernetes"
    version = "2.1.0"
    template = "auth-service-v2"

    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/platform"
            branch = "main"
            path = "services/auth"
        }
    }

    ports = [
        Port {
            name = "auth-api"
            direction = "bidirectional"
            portType = "service"
            protocol = "grpc"
            openApiSpec = "https://api.example.com/protos/auth.proto"
            authentication = "mtls"
        }
    ]

    config = {
        "database.url": "postgresql://auth-db:5432/auth"
        "jwt.secret": "ref://vault/jwt-secret"
        "token.expiry": "3600"
    }

    tags = ["microservice", "authentication", "security"]
}
```

**Benefits**:
- Template reusability (auth-service-v2 template)
- Environment-specific config (prod database URL)
- Secret management (JWT secret in Vault)

### Best Practices

1. **Create Templates for Reusable Patterns**: Kafka→Delta, REST APIs, DB connectors
2. **Use Descriptive Component Names**: Include purpose and layer (bronze, silver, gold)
3. **Document Configuration Parameters**: Clear config descriptions in template
4. **Set Runtime Explicitly**: databricks, kubernetes, airflow (enables platform-specific code gen)
5. **Specify Dependencies**: Enable deployment ordering and lineage tracking
6. **Version Templates Independently**: Template version ≠ instance version

### Validation Rules

- Component instances (with `template`) must specify `productId`
- Reusable components must have `description`
- Template reference must not be empty if specified
- All MeshNode validation rules apply

---

## Port: Interface Boundary (Level 5)

### Design Philosophy

**Port** represents a polymorphic interface boundary for data/service/event flows. In Data Mesh terms, a Port is the **standardized interface** that enables interoperability across the mesh—it is the contract point where products expose capabilities or declare dependencies.

In Domain-Driven Design terms, a Port is a **Value Object**:
- **No independent identity**: Ports are compared by attribute values
- **Immutable**: Once defined, ports don't change (version product instead)
- **Part of aggregate**: Embedded in Product or Component

Ports unify three resource types under a single abstraction:
- **Data ports**: Datasets, files, tables (Parquet, Delta, CSV)
- **Service ports**: APIs, microservices (REST, gRPC, GraphQL)
- **Event ports**: Event streams (Kafka, Kinesis, MQTT)

### Architecture and Hierarchy Position

**Level**: 5 (Value Object, not a MeshNode)
**DDD Pattern**: Value Object (no independent identity)
**Data Mesh Principle**: Self-Serve Platform through standardized interfaces
**Graph Relationships**:
- EXPOSED_BY → Component (many-to-one, internal ports)
- EXPOSED_BY → Product (many-to-one, external ports)

### Port Ownership Models

Ports can be owned by either Components or Products:

1. **Component Ports**: Owned by Component (`componentId` set)
   - Internal interfaces between components
   - Reusable with component templates
   - Hidden from external consumers

2. **Product Ports**: Owned by Product (`componentId = None`)
   - External interfaces exposed to consumers
   - May reference/delegate to component ports
   - Discoverable in catalog

### Key Attributes

#### Common Attributes

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `name` | str | Yes | Port name (e.g., "customer-data", "rest-api") |
| `description` | str | Optional | Port purpose and usage |
| `componentId` | str | Optional | Parent Component ID (internal ports only) |
| `direction` | str | Yes | Flow direction (input, output, bidirectional) |
| `portType` | str | Yes | Type discriminator (data, service, event) |
| `sla` | {str: str} | Optional | SLA metrics (freshness, availability, latency) |
| `classification` | str | Optional | Sensitivity (public, internal, confidential, restricted) |

#### Data-Specific Attributes (portType = "data")

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `format` | str | Yes | Data format (parquet, avro, json, csv, delta) |
| `schema` | str | Optional | Schema reference (URL, URN, or inline) |
| `catalog` | str | Optional | Catalog location (S3, JDBC, etc.) |

#### Service-Specific Attributes (portType = "service")

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `protocol` | str | Yes | Service protocol (rest, grpc, graphql, soap) |
| `openApiSpec` | str | Optional | OpenAPI/Swagger spec URL |
| `authentication` | str | Optional | Auth mechanism (oauth2, jwt, api-key, mtls) |

#### Event-Specific Attributes (portType = "event")

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `topic` | str | Yes | Event topic/stream name |
| `eventSchema` | str | Optional | Event schema (Avro, Protobuf, JSON Schema) |
| `messageFormat` | str | Optional | Message format (avro, protobuf, json, cloudevents) |

### Port Types

#### Type 1: Data Port

**Definition**: Traditional data interfaces (tables, files, datasets)

**Example**:
```kcl
dataPort = Port {
    name = "customer-data"
    description = "Customer profile dataset"
    direction = "output"
    portType = "data"
    format = "parquet"
    schema = "s3://bucket/schemas/customer.avsc"
    catalog = "s3://bucket/data/customers"
    classification = "confidential"
    sla = {
        "freshness": "1h"
        "completeness": "99%"
    }
}
```

**Use Cases**:
- Data lake tables (Parquet, ORC)
- Delta Lake tables (Databricks)
- CSV/JSON files (legacy systems)
- Database tables (JDBC)

#### Type 2: Service Port

**Definition**: Synchronous service endpoints (REST, gRPC, GraphQL)

**Example**:
```kcl
servicePort = Port {
    name = "customer-api"
    description = "Customer management REST API"
    direction = "bidirectional"
    portType = "service"
    protocol = "rest"
    openApiSpec = "https://api.example.com/openapi.yaml"
    authentication = "oauth2"
    classification = "internal"
    sla = {
        "availability": "99.95%"
        "latency_p95": "200ms"
    }
}
```

**Use Cases**:
- REST APIs (HTTP/JSON)
- gRPC services (HTTP/2, Protobuf)
- GraphQL APIs (schema-driven)
- SOAP services (legacy)

#### Type 3: Event Port

**Definition**: Asynchronous event streams (Kafka, Kinesis, MQTT)

**Example**:
```kcl
eventPort = Port {
    name = "customer-events"
    description = "Customer lifecycle event stream"
    direction = "output"
    portType = "event"
    topic = "customers.profile.updated"
    eventSchema = "https://registry.example.com/schemas/customer-event.avsc"
    messageFormat = "avro"
    classification = "confidential"
    sla = {
        "throughput": "10000 msg/s"
        "retention": "7d"
    }
}
```

**Use Cases**:
- Kafka topics (event streaming)
- Kinesis streams (AWS)
- Azure Event Hubs
- MQTT topics (IoT)

### Data Mesh Principle: Interoperability

Ports enable **interoperability** across the mesh through:
- **Standard formats**: Parquet, Avro, JSON (data portability)
- **Standard protocols**: REST, gRPC, GraphQL (service compatibility)
- **Schema definitions**: OpenAPI, Avro, Protobuf (contract verification)
- **SLA guarantees**: Freshness, availability, latency (quality assurance)

### Use Cases

#### Use Case 1: Multi-Format Data Product

**Scenario**: Expose customer data in multiple formats (Parquet for analytics, JSON for APIs).

**Solution**:
```kcl
product = Product {
    id = "customer-360"
    name = "Customer 360"
    domainId = "customer-domain"
    kind = "dataset"

    ports = [
        Port {
            name = "parquet-output"
            direction = "output"
            portType = "data"
            format = "parquet"
            catalog = "s3://data-lake/customer-360"
            classification = "confidential"
            sla = { "freshness": "1h" }
        },
        Port {
            name = "json-api"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/customer-360/openapi.yaml"
            authentication = "oauth2"
            sla = { "latency_p95": "100ms" }
        }
    ]

    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Multi-consumer support (analysts use Parquet, apps use REST API)
- Format-specific SLAs (freshness for batch, latency for API)
- Unified product (single catalog entry)

#### Use Case 2: Event-Driven Architecture

**Scenario**: Customer service emits events consumed by downstream services.

**Solution**:
```kcl
customerService = Product {
    id = "customer-service"
    name = "Customer Service"
    domainId = "customer-domain"
    kind = "service"

    ports = [
        Port {
            name = "customer-api"
            direction = "bidirectional"
            portType = "service"
            protocol = "grpc"
            openApiSpec = "https://api.example.com/protos/customer.proto"
            authentication = "mtls"
        },
        Port {
            name = "customer-events"
            direction = "output"
            portType = "event"
            topic = "customers.lifecycle"
            eventSchema = "https://registry.example.com/customer-events.avsc"
            messageFormat = "avro"
        }
    ]

    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Synchronous API (gRPC for queries)
- Asynchronous events (Kafka for notifications)
- Decoupled consumers (event-driven architecture)

### Best Practices

1. **Use Descriptive Port Names**: Include resource type (customer-data, order-api)
2. **Set Classification**: Determines access control policies
3. **Define SLAs**: Freshness for data, latency for services, throughput for events
4. **Specify Schemas**: Enable contract validation and code generation
5. **Match Port Type to Product Kind**: dataset → data ports, api → service ports
6. **Document Port Purpose**: Clear description for consumers

### Validation Rules

- Data ports require `format` field
- Service ports require `protocol` field
- Event ports require `topic` field
- Service ports should be `bidirectional` rather than `input`
- Restricted data must have defined SLAs for compliance tracking

---

## ComponentEdge: Data Flow Wiring

### Design Philosophy

**ComponentEdge** represents a directed edge in the component graph, defining **data flow** between components. It enables:
- **Explicit wiring**: Clear visualization of data flow
- **Dependency analysis**: Impact assessment for changes
- **Deployment ordering**: Topological sort for deployment
- **Lineage tracking**: Data provenance through components

ComponentEdge is a **Value Object** in DDD terms—it has no independent identity and is immutable.

### Architecture

**DDD Pattern**: Value Object (immutable descriptor)
**CMA Principle**: Explicit component wiring for composition
**Graph Properties**:
- **Directed**: sourceComponent → targetComponent
- **Acyclic**: No circular dependencies (DAG required)
- **Port-specific**: Connects specific ports, not just components

### Key Attributes

| Attribute | Type | Required | Purpose |
|-----------|------|----------|---------|
| `sourceComponent` | str | Yes | Source component ID (data producer) |
| `sourcePort` | str | Yes | Output port name on source component |
| `targetComponent` | str | Yes | Target component ID (data consumer) |
| `targetPort` | str | Yes | Input port name on target component |
| `transformation` | str | Optional | Optional transformation applied to data in transit |
| `metadata` | {str: str} | Optional | Additional edge metadata (lineage, SLAs) |

### Use Cases

#### Use Case 1: ETL Pipeline Wiring

**Scenario**: Wire bronze → silver → gold layers in ETL pipeline.

**Solution**:
```kcl
customerETL = Product {
    id = "customer-etl"
    components = [
        "kafka-to-delta-bronze",
        "bronze-to-silver-transform",
        "silver-to-gold-aggregate"
    ]

    componentGraph = [
        ComponentEdge {
            sourceComponent = "kafka-to-delta-bronze"
            sourcePort = "delta-output"
            targetComponent = "bronze-to-silver-transform"
            targetPort = "delta-input"
        },
        ComponentEdge {
            sourceComponent = "bronze-to-silver-transform"
            sourcePort = "delta-output"
            targetComponent = "silver-to-gold-aggregate"
            targetPort = "delta-input"
            transformation = "filter(is_valid == true)"
        }
    ]

    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Clear data flow (bronze → silver → gold)
- Transformation visibility (filter applied to silver→gold)
- Deployment ordering (bronze first, then silver, then gold)

#### Use Case 2: Microservices Call Graph

**Scenario**: API Gateway routes to Auth and User services.

**Solution**:
```kcl
apiPlatform = Product {
    id = "api-platform"
    components = ["api-gateway", "auth-service", "user-service"]

    componentGraph = [
        ComponentEdge {
            sourceComponent = "api-gateway"
            sourcePort = "auth-route"
            targetComponent = "auth-service"
            targetPort = "auth-api"
            metadata = {
                "protocol": "grpc"
                "authentication": "mtls"
            }
        },
        ComponentEdge {
            sourceComponent = "api-gateway"
            sourcePort = "user-route"
            targetComponent = "user-service"
            targetPort = "user-api"
        },
        ComponentEdge {
            sourceComponent = "user-service"
            sourcePort = "auth-client"
            targetComponent = "auth-service"
            targetPort = "auth-api"
        }
    ]

    deployment = DeploymentSpec { environment = "production" }
}
```

**Benefits**:
- Service dependencies visible (User → Auth)
- Protocol metadata (gRPC, mTLS)
- Call graph for debugging

### Best Practices

1. **Ensure DAG Structure**: No cycles in component graph
2. **Use Port-Specific Wiring**: Connect specific ports, not just components
3. **Document Transformations**: Specify filters, maps, aggregations
4. **Add Metadata for SLAs**: Latency requirements, data quality rules
5. **Validate Port Compatibility**: Source output port → target input port

### Validation Rules

- `sourceComponent` must not be empty
- `sourcePort` must not be empty
- `targetComponent` must not be empty
- `targetPort` must not be empty
- `sourceComponent != targetComponent` (no self-referential edges)

---

## Integration with Other Schemas

### Core Integration

All discovery entities (Organization, Mesh, Domain, Product, Component) extend **MeshNode**:
- Inherit identity (id), lifecycle (version, status), governance (policies)
- Enable unified catalog management
- Support policy cascading (O(D) complexity)

### Deployment Integration

Every discovery entity has a **deployment** attribute:
- DeploymentSpec for operational context
- SourceRepository for GitOps integration
- Environment-specific configuration

### Governance Integration

Discovery entities support **policy cascading**:
- Organization → Mesh → Domain → Product → Component
- Compile-time validation via constraints
- Tag-triggered policy mixins (PII, GDPR, SOC2)

### Semantic Integration

Discovery entities can have **SemanticMetadata**:
- RDF type mapping for knowledge graphs
- Business glossary integration
- Data classification and lineage

---

## Academic Foundation

Discovery schemas are grounded in academic research:

### Data Mesh Principles (Dehghani, 2022; van der Werf et al., 2025)

- **Domain Ownership**: Domain as business capability boundary
- **Data as a Product**: Product with clear interfaces and SLAs
- **Self-Serve Platform**: Ports as standardized interfaces
- **Federated Governance**: O(D) policy cascading

### Domain-Driven Design (Evans, 2003)

- **Aggregate Roots**: Organization, Mesh, Domain, Product, Component
- **Bounded Context**: Domain represents business capability
- **Value Objects**: Port, ComponentEdge (immutable, no identity)
- **Ubiquitous Language**: Business-aligned naming (Finance, Customer)

### Composable Architecture (Backstage, Crossplane, OAM)

- **Component-based composition**: Reusable building blocks
- **Template + Instance pattern**: Component reusability
- **Explicit wiring**: ComponentEdge for data flow
- **Unified abstraction**: Port polymorphism for heterogeneous resources

### Federated Governance (Dolhopolov et al., 2024)

- **Hierarchical propagation**: O(D) vs O(T) complexity
- **Compile-time validation**: Shift-left governance
- **Tag-based activation**: Policy mixins (PII, GDPR, SOC2)

---

## Related Documentation

- **[Architecture Overview](../architecture.md)** - Comprehensive architecture documentation
- **[Core Schemas](core.md)** - MeshNode base schema
- **[Deployment Schemas](deploy.md)** - DeploymentSpec, SourceRepository
- **[Governance Schemas](governance.md)** - Policy, Constraint, Mixins
- **[Semantic Schemas](semantics.md)** - SemanticMetadata

---

**Schema Locations**: `discovery/*.k`
**DDD Patterns**: Aggregate Root (Organization, Mesh, Domain, Product, Component), Value Object (Port, ComponentEdge)
**Data Mesh Principles**: Domain Ownership, Data as a Product, Self-Serve Platform, Federated Governance
**CMA Pillars**: Semantic Driven Design, Contract Driven Infrastructure, Contract Driven Lifecycle
