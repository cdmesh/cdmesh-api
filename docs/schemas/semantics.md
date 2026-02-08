# Semantic Schemas

**Module**: `semantics/`
**Schema**: `SemanticMetadata`
**File**: `semantics/ontology.k`

## Overview

The `semantics` module implements the **Semantic Driven Design (SDD)** pillar of the Composable Mesh Architecture (CMA). It provides schemas for semantic annotations that enable **knowledge graph construction** and **ontological reasoning** across the mesh.

SemanticMetadata bridges the gap between:
- **Technical schemas** (KCL) ↔ **Semantic ontologies** (RDF/OWL)
- **Database schemas** (SQL) ↔ **Business concepts** (glossary terms)
- **System identifiers** (IDs) ↔ **URI namespaces** (semantic web)

This enables:
- Automated RDF triple generation for knowledge graphs
- Business glossary integration
- Data lineage tracking (upstream/downstream)
- Access control based on classification
- Semantic search across the mesh
- Compliance reporting (e.g., GDPR data inventory)

## Semantic Driven Design (SDD)

### Design Philosophy

**Semantic Driven Design** is one of the three foundational pillars of CMA (alongside CDI and CDL). SDD treats KCL schemas as **executable ontologies**:

1. **Schemas as Ontologies**: KCL schemas define both structure AND semantics
2. **RDF Integration**: Automatic mapping to RDF/OWL for semantic web
3. **Business Alignment**: Link technical entities to business concepts
4. **Knowledge Graphs**: Enable graph-based reasoning and discovery

### Why Semantic Metadata?

Traditional data catalogs store metadata in relational databases, leading to:
- Silos: Different teams maintain separate metadata repositories
- Inconsistency: Same concept represented differently across domains
- Limited reasoning: SQL doesn't support ontological inference
- Poor discoverability: Text search instead of semantic search

Semantic metadata enables:
- **Unified ontology**: Single semantic model across organization
- **Standardization**: Schema.org, DCAT 2.0, SKOS vocabularies
- **Reasoning**: Infer relationships (IS_A, PART_OF, DERIVES_FROM)
- **Discovery**: Query by concept, not just keyword

### Architecture

SemanticMetadata is embedded in every MeshNode:

```
MeshNode
├── id
├── name
├── semantics: SemanticMetadata ✓
│   ├── rdfType (ontology class)
│   ├── namespace (URI prefix)
│   ├── businessGlossaryTerms (domain concepts)
│   ├── dataClassification (sensitivity level)
│   ├── upstreamDependencies (data lineage)
│   └── downstreamConsumers (data lineage)
└── ...
```

## SemanticMetadata Schema

### Design Philosophy

**SemanticMetadata** is a **Value Object** in DDD terms:
- No independent identity
- Embedded in MeshNode aggregate
- Immutable descriptor of semantic properties
- Compared by attribute values, not identity

### Key Attributes

#### rdfType (optional)

RDF class URI from a standard ontology.

**Purpose**: Map MeshNodes to formal ontology classes for semantic web integration.

**Standard vocabularies**:
- **Schema.org**: General-purpose vocabulary (Dataset, WebAPI, Service)
- **DCAT 2.0**: W3C Data Catalog Vocabulary (Dataset, Distribution, DataService)
- **PROV**: W3C Provenance Ontology (Entity, Activity, Agent)
- **SKOS**: Simple Knowledge Organization System (Concept, ConceptScheme)
- **Dublin Core**: Metadata element set (Collection, Service)

**Common mappings**:

| MeshNode Type | RDF Class (rdfType) | Ontology |
|---------------|---------------------|----------|
| Product (dataset) | `http://schema.org/Dataset` | Schema.org |
| Product (api) | `http://schema.org/WebAPI` | Schema.org |
| Product (service) | `http://schema.org/Service` | Schema.org |
| Product (stream) | `http://www.w3.org/ns/dcat#DataService` | DCAT 2.0 |
| Port (data) | `http://www.w3.org/ns/dcat#Distribution` | DCAT 2.0 |
| Domain | `http://www.w3.org/ns/org#OrganizationalUnit` | W3C Organization |
| Organization | `http://www.w3.org/ns/org#Organization` | W3C Organization |

**Example**:
```kcl
semantics = SemanticMetadata {
    rdfType = "http://schema.org/Dataset"
}
```

**Validation**: Must be a valid URI starting with `http://` or `https://`

#### namespace (optional)

URI prefix for generating unique identifiers in the semantic web.

**Purpose**: Generate globally unique URIs for MeshNodes in RDF triples.

**Format**: Base URI ending with `/` or `#`

**Examples**:
- `"https://cdmesh.example.com/products/"`
- `"https://data.example.com/datasets#"`
- `"https://api.example.com/services/"`

**URI generation**:
```
URI = namespace + node.id
```

**Example**:
```kcl
product = Product {
    id = "customer-profile"
    semantics = SemanticMetadata {
        namespace = "https://cdmesh.example.com/products/"
    }
}

# Results in URI: https://cdmesh.example.com/products/customer-profile
```

**RDF triple generation**:
```turtle
<https://cdmesh.example.com/products/customer-profile>
    a schema:Dataset ;
    rdfs:label "Customer Profile" ;
    dct:description "Customer master data and profile information" .
```

**Validation**: Must be a valid URI starting with `http://` or `https://`

#### businessGlossaryTerms (optional)

Human-readable business concepts associated with this node.

**Purpose**: Link technical entities to business glossary or data dictionary.

**Examples**:
- `["CustomerData", "PersonalInformation", "CRM"]`
- `["TransactionData", "AccountBalance", "PCI-DSS"]`
- `["SalesMetrics", "Revenue", "KPI"]`

**Use cases**:
- **Business alignment**: Map technical schemas to business concepts
- **Discovery**: Search by business term, not technical field name
- **Compliance**: Identify which systems handle specific data types (e.g., "PII")
- **Knowledge graphs**: Link concepts across domains

**Example**:
```kcl
semantics = SemanticMetadata {
    businessGlossaryTerms = ["CustomerData", "PersonalInformation", "GDPR", "PII"]
}
```

**Best practice**: Use PascalCase or camelCase for consistency.

#### dataClassification (optional)

Sensitivity/confidentiality level for access control.

**Valid values**:
- `"public"`: Publicly accessible (no restrictions)
- `"internal"`: Internal use only (organization-wide access)
- `"confidential"`: Confidential (restricted access, need-to-know basis)
- `"restricted"`: Highly restricted (executive/legal access only)

**Purpose**:
- **Access control**: Automatically set permissions based on classification
- **Policy enforcement**: Trigger security policies (encryption, logging)
- **Compliance**: Data inventory for GDPR, CCPA, HIPAA
- **Risk management**: Identify high-risk data assets

**Policy triggers**:

| Classification | Triggered Policies |
|----------------|-------------------|
| `public` | None (open access) |
| `internal` | Authentication required |
| `confidential` | RBAC, access logging, encryption recommended |
| `restricted` | RBAC, access logging, encryption required, audit trail |

**Example**:
```kcl
semantics = SemanticMetadata {
    dataClassification = "restricted"
    businessGlossaryTerms = ["CreditCardNumbers", "PCI-DSS"]  # Required for restricted
}
```

**Validation**: `restricted` classification requires `businessGlossaryTerms` for compliance tracking.

#### upstreamDependencies (optional)

List of node IDs that this node consumes data from.

**Purpose**: Data lineage tracking (sources).

**Use cases**:
- **Lineage visualization**: Graph of data flows
- **Impact analysis**: "What breaks if upstream source changes?"
- **Constraint propagation**: Inherit PII/sensitivity from sources
- **Root cause analysis**: Trace data quality issues to source
- **Compliance**: GDPR Article 30 (Records of processing activities)

**Example**:
```kcl
# Product C consumes from Product A and Product B
productC = Product {
    id = "customer-360"
    semantics = SemanticMetadata {
        upstreamDependencies = ["customer-profile", "purchase-history"]
    }
}
```

**Constraint propagation**:
If any upstream dependency has tag `"PII"`, this node must also handle PII correctly (taint analysis).

#### downstreamConsumers (optional)

List of node IDs that consume data from this node.

**Purpose**: Data lineage tracking (consumers).

**Use cases**:
- **Lineage visualization**: Graph of data flows
- **Impact analysis**: "Who is affected by changes to this node?"
- **Access control**: "Who needs read permissions?"
- **Deprecation planning**: "What breaks if we retire this product?"
- **Usage tracking**: "Which teams depend on this data?"

**Example**:
```kcl
# Product A is consumed by Product C and Product D
productA = Product {
    id = "customer-profile"
    semantics = SemanticMetadata {
        downstreamConsumers = ["customer-360", "recommendation-engine"]
    }
}
```

**Access control**:
Grant read permissions to owners of downstream consumer products.

## Use Cases

### Use Case 1: Knowledge Graph Construction

**Scenario**: Build an enterprise knowledge graph for semantic search and discovery.

**Solution**: Annotate all products with RDF types and namespaces.

```kcl
# Data product
customerData = Product {
    id = "customer-profile"
    name = "Customer Profile"
    semantics = SemanticMetadata {
        rdfType = "http://schema.org/Dataset"
        namespace = "https://cdmesh.company.com/data/"
        businessGlossaryTerms = ["CustomerData", "CRM", "PII"]
        dataClassification = "confidential"
    }
}

# Service product
customerAPI = Product {
    id = "customer-api"
    name = "Customer API"
    semantics = SemanticMetadata {
        rdfType = "http://schema.org/WebAPI"
        namespace = "https://cdmesh.company.com/services/"
        businessGlossaryTerms = ["CustomerManagement", "REST-API"]
        dataClassification = "internal"
    }
}

# Event stream product
customerEvents = Product {
    id = "customer-events"
    name = "Customer Event Stream"
    semantics = SemanticMetadata {
        rdfType = "http://www.w3.org/ns/dcat#DataService"
        namespace = "https://cdmesh.company.com/streams/"
        businessGlossaryTerms = ["CustomerEvents", "Kafka", "EventDriven"]
        dataClassification = "internal"
    }
}
```

**RDF export** (Turtle format):
```turtle
<https://cdmesh.company.com/data/customer-profile>
    a schema:Dataset ;
    rdfs:label "Customer Profile" ;
    dct:subject "CustomerData", "CRM", "PII" ;
    cdmesh:dataClassification "confidential" .

<https://cdmesh.company.com/services/customer-api>
    a schema:WebAPI ;
    rdfs:label "Customer API" ;
    dct:subject "CustomerManagement", "REST-API" ;
    cdmesh:dataClassification "internal" .

<https://cdmesh.company.com/streams/customer-events>
    a dcat:DataService ;
    rdfs:label "Customer Event Stream" ;
    dct:subject "CustomerEvents", "Kafka", "EventDriven" ;
    cdmesh:dataClassification "internal" .
```

**Benefits**:
- Unified knowledge graph across data/services/events
- SPARQL queries for semantic search
- Ontological reasoning (infer relationships)

### Use Case 2: Data Lineage Tracking

**Scenario**: Track data lineage for GDPR compliance and impact analysis.

**Solution**: Use `upstreamDependencies` and `downstreamConsumers`.

```kcl
# Source: Raw customer data
rawCustomers = Product {
    id = "raw-customers"
    semantics = SemanticMetadata {
        downstreamConsumers = ["cleaned-customers"]
    }
}

# Transform: Cleaned customer data
cleanedCustomers = Product {
    id = "cleaned-customers"
    semantics = SemanticMetadata {
        upstreamDependencies = ["raw-customers"]
        downstreamConsumers = ["customer-360", "customer-segmentation"]
    }
}

# Aggregate: Customer 360 view
customer360 = Product {
    id = "customer-360"
    semantics = SemanticMetadata {
        upstreamDependencies = ["cleaned-customers", "purchase-history", "support-tickets"]
        downstreamConsumers = ["recommendation-engine", "analytics-dashboard"]
    }
}

# Downstream: Recommendation engine
recommendationEngine = Product {
    id = "recommendation-engine"
    semantics = SemanticMetadata {
        upstreamDependencies = ["customer-360"]
    }
}
```

**Lineage graph**:
```
raw-customers
    ↓
cleaned-customers
    ↓                    ↘
customer-360 ← purchase-history, support-tickets
    ↓
recommendation-engine
```

**Benefits**:
- **Impact analysis**: "If cleaned-customers schema changes, what breaks?"
- **Root cause analysis**: "Recommendation engine is wrong, where did bad data come from?"
- **GDPR compliance**: "Where does customer data flow? Can we trace erasure?"

### Use Case 3: Access Control by Classification

**Scenario**: Automatically set access permissions based on data classification.

**Solution**: Use `dataClassification` to trigger RBAC policies.

```kcl
# Public data: No restrictions
publicMetrics = Product {
    id = "public-metrics"
    semantics = SemanticMetadata {
        dataClassification = "public"
    }
}
# Access: Anyone (including external)

# Internal data: Organization-wide access
internalReports = Product {
    id = "internal-reports"
    semantics = SemanticMetadata {
        dataClassification = "internal"
    }
}
# Access: Any authenticated employee

# Confidential data: Need-to-know basis
customerData = Product {
    id = "customer-data"
    semantics = SemanticMetadata {
        dataClassification = "confidential"
        businessGlossaryTerms = ["CustomerData", "PII"]
    }
}
# Access: Customer domain team only, RBAC required

# Restricted data: Executive/legal only
financialLedger = Product {
    id = "financial-ledger"
    semantics = SemanticMetadata {
        dataClassification = "restricted"
        businessGlossaryTerms = ["FinancialRecords", "AuditTrail", "SOX"]
    }
}
# Access: Finance executives, legal team, audit required
```

**Benefits**:
- Automated access control (no manual permission management)
- Consistent security posture (classification-based)
- Compliance reporting (data inventory by classification)

### Use Case 4: Business Glossary Integration

**Scenario**: Link technical data products to business glossary terms.

**Solution**: Use `businessGlossaryTerms` for semantic mapping.

```kcl
# Technical product: customer_profile_v2
customerProfile = Product {
    id = "customer-profile-v2"
    name = "Customer Profile (Technical)"
    semantics = SemanticMetadata {
        businessGlossaryTerms = [
            "CustomerData",         # Business term
            "PersonalInformation",  # Business term
            "CRM",                   # System/domain
            "PII"                    # Compliance tag
        ]
    }
}

# Business user searches for "CustomerData"
# → Finds customer-profile-v2 product
```

**Benefits**:
- Business users find data without knowing technical names
- Consistent terminology across organization
- Semantic search (query by concept, not keyword)

### Use Case 5: Compliance Reporting (GDPR Data Inventory)

**Scenario**: Generate GDPR Article 30 data inventory report.

**Solution**: Query all products with PII-related business glossary terms.

```kcl
# Product 1: Customer profiles
customerProfile = Product {
    id = "customer-profile"
    semantics = SemanticMetadata {
        businessGlossaryTerms = ["CustomerData", "PII", "GDPR"]
        dataClassification = "confidential"
        upstreamDependencies = ["crm-database"]
        downstreamConsumers = ["analytics-platform"]
    }
}

# Product 2: Employee records
employeeRecords = Product {
    id = "employee-records"
    semantics = SemanticMetadata {
        businessGlossaryTerms = ["EmployeeData", "PII", "GDPR"]
        dataClassification = "restricted"
        upstreamDependencies = ["hr-system"]
        downstreamConsumers = ["payroll-system"]
    }
}

# Query: Find all products with "PII" in businessGlossaryTerms
# Result: [customer-profile, employee-records]
```

**GDPR Article 30 report**:
| Product | Classification | Data Types | Sources | Consumers |
|---------|----------------|-----------|---------|-----------|
| customer-profile | confidential | CustomerData, PII | crm-database | analytics-platform |
| employee-records | restricted | EmployeeData, PII | hr-system | payroll-system |

**Benefits**:
- Automated compliance reporting
- Data inventory always up-to-date
- Prove GDPR compliance to auditors

## Standards Alignment

### DCAT 2.0 (W3C Data Catalog Vocabulary)

**Mapping**:
- `MeshNode` → `dcat:Dataset` or `dcat:DataService`
- `Port` → `dcat:Distribution`
- `semantics.rdfType` → `rdf:type`
- `semantics.upstreamDependencies` → `prov:wasDerivedFrom`

**Example**:
```turtle
<https://cdmesh.company.com/products/customer-profile>
    a dcat:Dataset ;
    dct:title "Customer Profile" ;
    dct:description "Customer master data" ;
    dcat:distribution <https://cdmesh.company.com/distributions/customer-parquet> .
```

### Schema.org (Structured Data Vocabulary)

**Mapping**:
- `Product (dataset)` → `schema:Dataset`
- `Product (api)` → `schema:WebAPI`
- `Product (service)` → `schema:Service`
- `Organization` → `schema:Organization`

**Example**:
```json
{
  "@context": "https://schema.org",
  "@type": "Dataset",
  "name": "Customer Profile",
  "description": "Customer master data and profile information",
  "keywords": ["CustomerData", "PII", "GDPR"],
  "license": "Internal Use Only"
}
```

### SKOS (Simple Knowledge Organization System)

**Mapping**:
- `businessGlossaryTerms` → `skos:Concept`
- `Domain` → `skos:ConceptScheme`

**Example**:
```turtle
<https://cdmesh.company.com/concepts/CustomerData>
    a skos:Concept ;
    skos:prefLabel "Customer Data" ;
    skos:definition "Data related to customer profiles and interactions" ;
    skos:broader <https://cdmesh.company.com/concepts/PersonalInformation> .
```

### W3C PROV (Provenance Ontology)

**Mapping**:
- `MeshNode` → `prov:Entity`
- `upstreamDependencies` → `prov:wasDerivedFrom`
- `downstreamConsumers` → inverse of `prov:wasDerivedFrom`

**Example**:
```turtle
<https://cdmesh.company.com/products/customer-360>
    a prov:Entity ;
    prov:wasDerivedFrom <https://cdmesh.company.com/products/customer-profile> ,
                        <https://cdmesh.company.com/products/purchase-history> .
```

## RDF Triple Generation

### Turtle Format

SemanticMetadata enables automatic RDF triple generation:

```kcl
# KCL Product
product = Product {
    id = "customer-profile"
    name = "Customer Profile"
    description = "Customer master data and profile information"
    semantics = SemanticMetadata {
        rdfType = "http://schema.org/Dataset"
        namespace = "https://cdmesh.company.com/products/"
        businessGlossaryTerms = ["CustomerData", "PII", "GDPR"]
        dataClassification = "confidential"
        upstreamDependencies = ["crm-database"]
        downstreamConsumers = ["analytics-platform", "recommendation-engine"]
    }
}
```

**Generated RDF (Turtle)**:
```turtle
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix schema: <http://schema.org/> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix cdmesh: <https://cdmesh.company.com/vocab/> .

<https://cdmesh.company.com/products/customer-profile>
    a schema:Dataset ;
    rdfs:label "Customer Profile" ;
    dct:description "Customer master data and profile information" ;
    dct:subject "CustomerData", "PII", "GDPR" ;
    cdmesh:dataClassification "confidential" ;
    prov:wasDerivedFrom <https://cdmesh.company.com/products/crm-database> ;
    cdmesh:hasConsumer <https://cdmesh.company.com/products/analytics-platform> ,
                       <https://cdmesh.company.com/products/recommendation-engine> .
```

### SPARQL Queries

Once RDF triples are generated, you can query the knowledge graph using SPARQL:

**Query 1: Find all PII data products**
```sparql
SELECT ?product ?name
WHERE {
    ?product a schema:Dataset ;
             rdfs:label ?name ;
             dct:subject "PII" .
}
```

**Query 2: Find all data sources for a product**
```sparql
SELECT ?source ?name
WHERE {
    <https://cdmesh.company.com/products/customer-360>
        prov:wasDerivedFrom ?source .
    ?source rdfs:label ?name .
}
```

**Query 3: Find all downstream consumers of a product**
```sparql
SELECT ?consumer ?name
WHERE {
    <https://cdmesh.company.com/products/customer-profile>
        cdmesh:hasConsumer ?consumer .
    ?consumer rdfs:label ?name .
}
```

## Best Practices

### 1. Use Standard Ontologies

Prefer well-known vocabularies:
```kcl
✅ Good: rdfType = "http://schema.org/Dataset"  # Standard vocabulary
❌ Bad:  rdfType = "http://company.com/CustomDataset"  # Custom class
```

### 2. Consistent Namespaces

Use consistent URI patterns:
```kcl
✅ Good: namespace = "https://cdmesh.company.com/products/"
❌ Bad:  namespace = "https://company.com/prod123/"
```

### 3. Descriptive Business Terms

Use clear, domain-specific terms:
```kcl
✅ Good: businessGlossaryTerms = ["CustomerData", "PersonalInformation", "CRM"]
❌ Bad:  businessGlossaryTerms = ["data", "info"]
```

### 4. Appropriate Classifications

Choose correct sensitivity level:
```kcl
✅ Good: dataClassification = "confidential"  # PII data
❌ Bad:  dataClassification = "public"  # Wrong for PII
```

### 5. Complete Lineage

Document both upstream and downstream:
```kcl
✅ Good:
    upstreamDependencies = ["source-a", "source-b"]
    downstreamConsumers = ["consumer-x", "consumer-y"]
❌ Bad:
    upstreamDependencies = []  # Missing lineage
```

## Validation Rules

SemanticMetadata enforces these rules:

1. **Valid RDF URIs**: `rdfType` and `namespace` must start with `http://` or `https://`
2. **Restricted data requires terms**: `dataClassification = "restricted"` requires `businessGlossaryTerms`
3. **Consistent classifications**: Use standard values (public, internal, confidential, restricted)

## Integration with Other Schemas

### MeshNode Integration

Every MeshNode includes optional `semantics` attribute:
- Organization, Mesh, Domain, Product, Component can all have semantic metadata
- Enables knowledge graph spanning entire hierarchy
- See [Core Schemas](core.md) for details

### Governance Integration

SemanticMetadata influences governance:
- `dataClassification` triggers access control policies
- `businessGlossaryTerms` with "PII" triggers PIIMixin
- Lineage enables constraint propagation
- See [Governance Schemas](governance.md) for details

## Academic Foundation

### Knowledge Graphs (Hogan et al., 2021)

- **Graph-based representation**: Entities (nodes) and relationships (edges)
- **Semantic enrichment**: RDF/OWL annotations enable reasoning
- **Query capabilities**: SPARQL for complex graph queries

### Semantic Data Blueprints (Pingos et al., 2024)

- **Data lake transformation**: Convert data lakes to semantic meshes
- **Blueprint patterns**: Reusable semantic patterns for common scenarios
- **Automated classification**: ML-assisted data classification

### Semantic Driven Design (CMA Pillar)

- **Schemas as Ontologies**: KCL schemas define both structure AND semantics
- **Knowledge graph integration**: Automatic RDF export
- **Business alignment**: Link technical to business concepts

## Related Documentation

- **[Architecture Overview](../architecture.md)** - SDD pillar and semantic integration
- **[Core Schemas](core.md)** - MeshNode with semantics attribute
- **[Discovery Schemas](discovery.md)** - Semantic annotations in hierarchy
- **[Governance Schemas](governance.md)** - Classification-based policies

---

**Schema Location**: `semantics/ontology.k`
**DDD Pattern**: Value Object (SemanticMetadata)
**CMA Pillar**: Semantic Driven Design (SDD)
**Standards**: DCAT 2.0, Schema.org, SKOS, W3C PROV
