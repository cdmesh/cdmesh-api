# cdmesh-api

## Index

- core
  - [MeshNode](#meshnode)
- deploy
  - [DeploymentSpec](#deploymentspec)
  - [SourceRepository](#sourcerepository)
- discovery
  - [Component](#component)
  - [ComponentEdge](#componentedge)
  - [Domain](#domain)
  - [Mesh](#mesh)
  - [Organization](#organization)
  - [Port](#port)
  - [Product](#product)
- governance
  - [Constraint](#constraint)
  - [GDPRMixin](#gdprmixin)
  - [PCIDSSMixin](#pcidssmixin)
  - [PIIMixin](#piimixin)
  - [Policy](#policy)
  - [SOC2Mixin](#soc2mixin)
- semantics
  - [SemanticMetadata](#semanticmetadata)

## Schemas

### MeshNode

Universal abstraction for catalog-managed entities in the Composable Mesh Architecture.  MeshNode represents the base schema for all autonomous, catalog-discoverable entities in CDMesh. They are: - Independently managed in the platform catalog - Mapped as vertices in the CDMesh Knowledge Graph - Subject to hierarchical governance policies - Semantically annotated for ontological reasoning  In Domain-Driven Design terms, MeshNodes are Aggregate Roots with: - Independent identity (id field) - Independent lifecycle (version, status fields) - Ownership boundaries (owner field) - Internal specifications (deployment, policies)  MeshNode Hierarchy: ------------------ Organization → Mesh → Domain → Product  All catalog entities extend MeshNode: - Organization: Global governance boundary (multi-tenant root) - Mesh: Organizational/tenant boundary (business unit) - Domain: Business capability boundary (domain ownership) - Product: Autonomous deployable unit (data/service/ML)  NOT MeshNodes: ------------- - Port: Value Object embedded in Product - DeploymentSpec: Specification Object owned by MeshNode - Policy: Governance metadata applied to MeshNodes - SemanticMetadata: Ontological metadata attached to MeshNodes  Governance Model: ---------------- MeshNodes inherit policies from parent nodes via schema inheritance:  C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Local  This federated inheritance pattern achieves O(D) complexity for policy updates (where D = hierarchy depth ≈ 3-4) vs O(T) for tuple-level updates (where T = table count ≈ 10,000).

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
#### Examples

```
# Basic MeshNode
customerProduct = MeshNode {
    id = "customer-profile"
    name = "Customer Profile"
    description = "Customer master data and profile information"
    deployment = DeploymentSpec {
        environment = "production"
    }
    version = "1.2.3"
    status = "live"
    owner = "customer-domain-team"
    tags = ["PII", "GDPR"]
}

# MeshNode with Semantics
apiService = MeshNode {
    id = "customer-api"
    name = "Customer API"
    semantics = sem.SemanticMetadata {
        rdfType = "http://schema.org/WebAPI"
        businessGlossaryTerms = ["CustomerManagement", "REST-API"]
        dataClassification = "internal"
    }
    deployment = DeploymentSpec {
        environment = "production"
    }
}

# MeshNode with Policies
financialProduct = MeshNode {
    id = "transaction-ledger"
    name = "Transaction Ledger"
    policies = [
        gov.Policy {
            id = "encryption-required"
            name = "Encryption Required"
            scope = "product"
            policyType = "security"
            enforcement = "blocking"
            constraints = [
                gov.Constraint {
                    expression = "deployment.encryption.atRest == true"
                    message = "Financial data must be encrypted at rest"
                    severity = "error"
                }
            ]
        }
    ]
    deployment = DeploymentSpec {
        environment = "production"
    }
    tags = ["financial", "regulated"]
}
```

### DeploymentSpec

DeploymentSpec defines the operational context and source configuration for a Component.  In Domain-Driven Design terms, DeploymentSpec is a Specification Object that belongs to the Component aggregate. It describes "how" and "where" a component is deployed, without having independent identity or lifecycle.  In Data Mesh terms, this enables the Self-Serve Data Platform principle by providing declarative deployment configuration. Each component (Mesh, Domain, or Product) specifies its target environment and source location, enabling automated provisioning and GitOps workflows.  DeploymentSpec is part of the Component's internal structure and cannot exist independently.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**environment** `required`|str|The environment where the component is deployed.||
|**source**|[SourceRepository](#sourcerepository)|The repository that hosts the component's source code.||
#### Examples

```
myDeployment = DeploymentSpec {
    environment = "dev"
    source = myRepository
}
```

### SourceRepository

SourceRepository defines the Git repository location and access configuration for component source code.  In Domain-Driven Design terms, SourceRepository is a Value Object - an immutable descriptor with no independent identity. Two repositories are considered equal if all their attributes match. It exists only within the context of a DeploymentSpec.  In Data Mesh terms, this supports the contract-driven, GitOps approach where all component definitions are version-controlled. The SourceRepository captures the precise location (URL, branch, tag, path) of the source code, enabling automated synchronization and deployment of mesh components.  SourceRepository specifies the necessary metadata for retrieving component source code, including optional SSH credentials for private repositories.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**branch**|str|A source code branch.||
|**path**|str|A source code local source path.||
|**sshHostFingerprint**|str|A SSH public host fingerprint of a source code repository.||
|**sshPrivateKey**|str|A SSH private key of a source code repository.||
|**tag**|str|A source code realease tag.||
|**url** `required`|str|A source code repository URL.||
#### Examples

```
myDevelopmentRepository = SourceRepository {
    url = "https://github.com/my-org/my-component"
    branch = "dev"
    path = "components/my-component"
    tag = "v0.5.1-dev"

    sshHostFingerprint = "my-secret-host-fingerprint"
    sshPrivateKey = "my-secret-ssh-private-key"
}
```

### Component

Atomic, reusable building block for product compositions.  Component represents the smallest deployable quantum that can be combined to build complex products. Components are independently: - Versioned (semantic versioning) - Deployed (can run standalone or within product) - Governed (own policies and constraints) - Discovered (catalog entities)  Usage Patterns: -------------- 1. **Template Component** (Reusable definition): - Stored in catalog for reuse - template = None - Parameterized ports and configuration - Example: "kafka-to-delta-v1" template  2. **Instance Component** (Configured from template): - Belongs to specific product - template = template-component-id - Concrete port configuration - Example: "kafka-to-delta-bronze" instance  In Domain-Driven Design terms, Component is an Aggregate Root with: - Independent identity (id field) - Independent lifecycle (version, status) - Own policies and governance - Owned ports (interface boundaries)  Graph Relationships: ------------------- - Owned by: Product (via product.components reference) - EXPOSES → Port (one-to-many, Component owns ports) - DEPENDS_ON → Component (many-to-many, component dependencies) - INSTANTIATES → Component (template → instance relationship)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**config**|{str:str}|Component-specific configuration parameters.<br />For templates: default values or parameter schemas<br />For instances: concrete configuration values<br />Examples:<br />- {"kafka.topic": "customers.raw"}<br />- {"delta.table": "bronze.customers"}<br />- {"spark.executor.memory": "4g"}||
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**dependsOn**|[str]|List of component IDs this component depends on.<br />Used for:<br />- Deployment ordering (deploy dependencies first)<br />- Data lineage (upstream components)<br />- Impact analysis (what breaks if dependency changes)||
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**kind** `required`|"ingestion" | "transformation" | "aggregation" | "serving" | "orchestration" | "service" | "infrastructure"|Component type classification.<br />Valid values:<br />- "ingestion": Data ingestion components (KafkaToDelta, APIToS3)<br />- "transformation": Data transformation (DeltaTransform, SQLTransform)<br />- "aggregation": Data aggregation (Rollup, Summarize)<br />- "serving": Data serving components (DeltaToAPI, DeltaToBI)<br />- "orchestration": Workflow orchestration (Airflow, Prefect)<br />- "service": Microservice components (AuthService, UserService)<br />- "infrastructure": Infrastructure components (Database, Queue)||
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**ports**|[[Port](#port)]|Component-owned ports (interface boundaries).<br />Both template and instance components have ports.<br />Templates use parameterized ports, instances use concrete values.||
|**productId**|str|Reference to parent Product if this is a component instance.<br />Template components have productId = None.||
|**reusable** `required`|bool|Whether this component can be reused across products.<br />Templates are always reusable.<br />Instances can be marked reusable for sharing within organization.|True|
|**runtime**|"databricks" | "kubernetes" | "airflow" | "dbt" | "spark" | "flink" | "custom"|Target runtime environment for this component.<br />Valid values: "databricks", "kubernetes", "airflow", "dbt", "spark", "custom"<br />Used for platform-specific code generation and deployment.||
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**template**|str|Reference to template component ID if this is an instance.<br />If None, this component IS a template (reusable).<br />If specified, this component is instantiated from that template.<br />Example: template = "kafka-to-delta-v1"||
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
#### Examples

```
# Template Component (Reusable)
kafka_to_delta_template = Component {
    id = "kafka-to-delta-v1"
    name = "Kafka to Delta Ingestion"
    description = "Streaming ingestion from Kafka to Delta Lake"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    reusable = true
    template = None  # This IS a template

    deployment = DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "kafka-input"
            direction = "input"
            portType = "event"
            topic = "${kafka.topic}"  # Parameterized
            messageFormat = "avro"
        },
        port.Port {
            name = "delta-output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "${delta.catalog}"  # Parameterized
        }
    ]

    tags = ["streaming", "ingestion", "template"]
}

# Instance Component (Configured from template)
kafka_to_delta_bronze = Component {
    id = "kafka-to-delta-bronze"
    name = "Kafka to Bronze Layer"
    description = "Ingest customer data to bronze layer"
    productId = "customer-etl-pipeline"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    template = "kafka-to-delta-v1"  # References template

    deployment = DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "kafka-input"
            direction = "input"
            portType = "event"
            topic = "customers.raw"  # Concrete value
            messageFormat = "avro"
        },
        port.Port {
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

# Microservice Component (Template)
auth_service_template = Component {
    id = "auth-service-v2"
    name = "Authentication Service"
    description = "gRPC authentication and authorization service"
    kind = "service"
    runtime = "kubernetes"
    version = "2.1.0"
    reusable = true

    deployment = DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "auth-api"
            direction = "bidirectional"
            portType = "service"
            protocol = "grpc"
            openApiSpec = "https://api.example.com/protos/auth.proto"
            authentication = "mtls"
        }
    ]

    tags = ["microservice", "authentication", "template"]
}

# Data Transformation Component (Instance)
bronze_to_silver = Component {
    id = "customer-bronze-to-silver"
    name = "Customer Bronze to Silver Transform"
    productId = "customer-etl-pipeline"
    kind = "transformation"
    runtime = "databricks"
    version = "1.0.0"
    template = "delta-transform-v1"

    deployment = DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "bronze-input"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "bronze.customers"
        },
        port.Port {
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

# ML Component (Instance)
model_training = Component {
    id = "customer-churn-trainer"
    name = "Customer Churn Model Training"
    productId = "churn-prediction-model"
    kind = "transformation"
    runtime = "databricks"
    version = "1.5.0"

    deployment = DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "training-data"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "features.customer_churn"
        },
        port.Port {
            name = "model-output"
            direction = "output"
            portType = "data"
            format = "mlflow"
            catalog = "models.customer_churn"
        }
    ]

    config = {
        "algorithm": "xgboost"
        "hyperparameters.max_depth": "10"
        "hyperparameters.learning_rate": "0.1"
    }

    tags = ["ml", "training", "algorithm"]
}
```

### ComponentEdge

Defines data flow between components in a product composition.  ComponentEdge represents a directed edge in the component graph, indicating that data flows from one component's output port to another component's input port.  This enables: 1. **Explicit Wiring**: Clear data flow paths 2. **Validation**: Ensure port compatibility (format, schema) 3. **Deployment**: Order components based on dependencies 4. **Lineage**: Track data provenance through components 5. **Impact Analysis**: Understand downstream effects of changes  Graph Properties: ---------------- - **Directed**: sourceComponent → targetComponent - **Acyclic**: No circular dependencies (DAG required) - **Port-specific**: Connects specific ports (not just components)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**metadata**|{str:str}|Additional edge metadata for lineage or governance.<br />Examples:<br />- {"lineage.system": "openlineage"}<br />- {"data.classification": "PII"}<br />- {"sla.latency": "5m"}||
|**sourceComponent** `required`|str|Source component ID (data producer).<br />Must be a valid Component ID in the product composition.||
|**sourcePort** `required`|str|Name of the output port on source component.<br />Must be a port with direction = "output" or "bidirectional".||
|**targetComponent** `required`|str|Target component ID (data consumer).<br />Must be a valid Component ID in the product composition.||
|**targetPort** `required`|str|Name of the input port on target component.<br />Must be a port with direction = "input" or "bidirectional".||
|**transformation**|str|Optional transformation applied to data in transit.<br />Examples:<br />- "filter(status == 'active')" - Filter transformation<br />- "map(rename_columns)" - Column mapping<br />- "aggregate(group_by='customer_id')" - Aggregation<br />If None, data passes through unchanged.||
#### Examples

```
# Simple data flow (Kafka → Delta)
ingestion_to_bronze = ComponentEdge {
    sourceComponent = "kafka-to-delta"
    sourcePort = "delta-output"
    targetComponent = "bronze-validator"
    targetPort = "delta-input"
}

# Data flow with transformation (Bronze → Silver)
bronze_to_silver = ComponentEdge {
    sourceComponent = "bronze-validator"
    sourcePort = "validated-output"
    targetComponent = "silver-transformer"
    targetPort = "bronze-input"
    transformation = "filter(is_valid == true) | deduplicate(customer_id)"
    metadata = {
        "lineage.transformation": "validation_and_dedup"
        "data.classification": "PII"
    }
}

# Service dependency (API Gateway → Auth Service)
gateway_to_auth = ComponentEdge {
    sourceComponent = "api-gateway"
    sourcePort = "auth-requests"
    targetComponent = "auth-service"
    targetPort = "auth-api"
    metadata = {
        "protocol": "grpc"
        "authentication": "mtls"
    }
}

# ML pipeline flow (Feature Store → Training)
features_to_training = ComponentEdge {
    sourceComponent = "feature-store"
    sourcePort = "features-output"
    targetComponent = "model-trainer"
    targetPort = "training-data"
    transformation = "sample(fraction=0.8, seed=42)"
    metadata = {
        "ml.split": "training"
        "ml.sample_rate": "0.8"
    }
}

# Complex ETL flow with aggregation
silver_to_gold = ComponentEdge {
    sourceComponent = "silver-enriched"
    sourcePort = "enriched-customers"
    targetComponent = "gold-aggregator"
    targetPort = "aggregation-input"
    transformation = "group_by(region, product_category) | agg(sum(revenue), count(orders))"
    metadata = {
        "aggregation.level": "region_product"
        "sla.freshness": "1h"
    }
}
```

### Domain

Domain defines a business capability boundary that owns and manages a collection of related data products.  In Data Mesh terms, a Domain embodies the principle of Domain Ownership. Each domain represents a cohesive business capability (e.g., Finance, Logistics, Customer) and is responsible for the lifecycle, quality, and discoverability of its data products. Domains are aligned with organizational structure and have dedicated teams.  In Domain-Driven Design terms, a Domain is a Bounded Context with its own ubiquitous language and model. It encapsulates domain logic and data products that serve both internal domain needs and expose capabilities to other domains through well-defined interfaces.  Hierarchy Position: Level 2 Organization → Mesh → Domain → Product → Port  Graph Relationships: - Contained by: Mesh (via CONTAINS relationship) - OWNS → Product (one-to-many)  Inherits from MeshNode: - id: Unique domain identifier - name: Human-readable domain name (e.g., "Finance", "Supply Chain") - description: Business capability and scope - deployment: Deployment specification for domain-level infrastructure - policies: Domain-level policies (cascaded from Mesh + local) - semantics: Ontological metadata for the domain

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**meshId**|str|Reference to parent Mesh.<br />If specified, this domain inherits policies from the mesh.<br />Required for hierarchical governance.||
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
### Mesh

Mesh defines an organizational or tenant boundary in the Composable Mesh Architecture.  In Data Mesh terms, a Mesh represents the entire data ecosystem within an organization, encompassing all domains and their data products. It establishes the scope of the mesh and provides the context for domain organization and discovery.  In Domain-Driven Design terms, the Mesh is an Aggregate Root that defines a Bounded Context, containing multiple Domain bounded contexts beneath it. It serves as the organizational partition for multi-tenant deployments.  Hierarchy Position: Level 1 Organization → Mesh → Domain → Product → Port  Graph Relationships: - Contained by: Organization (via CONTAINS relationship) - CONTAINS → Domain (one-to-many)  Inherits from MeshNode: - id: Unique mesh identifier - name: Human-readable mesh name - description: Purpose and scope of this mesh - deployment: Deployment specification for mesh-level configuration - policies: Mesh-level policies (cascaded from Organization + local) - semantics: Ontological metadata for the mesh

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**organizationId**|str|Reference to parent Organization.<br />If specified, this mesh inherits policies from the organization.<br />Required for multi-tenant deployments.||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
### Organization

Highest governance boundary in the Composable Mesh Architecture.  Organization defines the root of the hierarchical governance model. All policies defined at Organization level cascade down to all child Meshes, Domains, and Products within this organization.  Key Capabilities: ---------------- 1. Global Policy Definition: Policies apply to all child nodes 2. Multi-Tenancy: Isolate different customers/business units 3. Regulatory Compliance: Jurisdiction-specific governance 4. Cost Management: Track spending across entire organization  Policy Cascading: ---------------- Organization.policies automatically cascade to: - All Meshes (CONTAINS relationship) - All Domains (via Mesh) - All Products (via Domain) - All Ports (via Product)  Mathematical Model: C_Product = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Product_Local  Where ⊕ represents policy composition (union with child precedence).  Graph Relationships: ------------------- - CONTAINS → Mesh (one-to-many)  Inherits from MeshNode: ---------------------- - id: Unique organization identifier (e.g., "acme-corp", "eu-tenant-1") - name: Human-readable organization name (e.g., "Acme Corporation", "EU Region") - description: Organization purpose and scope - deployment: Organization-level infrastructure configuration - policies: Global policies (encryption, compliance, cost limits) - semantics: Ontological metadata (org classification, industry) - version: Organization schema version - status: Organization lifecycle status - owner: Organization administrator/owner - tags: Organization tags (triggers global policy mixins)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**billingAccountId**|str|Cloud provider billing account identifier.<br />Links to AWS Organizations, Azure Management Groups, GCP Organizations.||
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**costCenter**|str|Internal cost allocation identifier.<br />Used for chargeback/showback reporting.||
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**jurisdiction**|str|Primary legal jurisdiction for regulatory compliance.<br />ISO 3166-1 alpha-2 country codes recommended.<br />Examples: "US", "EU", "GB", "JP"<br />Determines which regulatory frameworks apply (GDPR, CCPA, etc.)||
|**legalName**|str|Legal registered name of the organization.<br />Used for contracts, compliance reporting, billing.<br />Example: "Acme Corporation LLC"||
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**regulatoryFramework**|[str]|List of regulatory compliance frameworks applicable.<br />Examples: ["GDPR", "CCPA", "HIPAA", "PCI-DSS", "SOC2", "ISO27001"]<br />Automatically applies corresponding compliance mixins.||
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
#### Examples

```
# Global enterprise organization
acmeOrg = Organization {
    id = "acme-corp"
    name = "Acme Corporation"
    legalName = "Acme Corporation LLC"
    jurisdiction = "US"
    regulatoryFramework = ["SOC2", "CCPA"]
    deployment = DeploymentSpec {
        environment = "production"
    }
    policies = [
        Policy {
            id = "global-encryption"
            name = "Global Encryption Policy"
            scope = "organization"
            policyType = "security"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.encryption.atRest == true"
                    message = "All data must be encrypted at rest (organization policy)"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["enterprise", "production"]
}

# EU-specific tenant organization (GDPR compliance)
euTenant = Organization {
    id = "eu-tenant"
    name = "European Region"
    jurisdiction = "EU"
    regulatoryFramework = ["GDPR", "ePrivacy"]
    deployment = DeploymentSpec {
        environment = "production"
        region = "eu-central-1"
    }
    policies = [
        Policy {
            id = "gdpr-baseline"
            name = "GDPR Baseline Requirements"
            scope = "organization"
            policyType = "compliance"
            enforcement = "blocking"
            constraints = [
                Constraint {
                    expression = "deployment.region.startswith('eu-')"
                    message = "EU tenant data must remain in EU regions (GDPR Article 44)"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["GDPR", "eu-region"]
}

# Healthcare organization (HIPAA compliance)
healthcareOrg = Organization {
    id = "healthcare-provider"
    name = "Healthcare Provider Inc."
    legalName = "Healthcare Provider Incorporated"
    jurisdiction = "US"
    regulatoryFramework = ["HIPAA", "HITECH", "FDA-21CFR11"]
    deployment = DeploymentSpec {
        environment = "production"
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
                    expression = "deployment.encryption.atRest == true and deployment.encryption.inTransit == true"
                    message = "HIPAA requires encryption at rest and in transit"
                    severity = "error"
                },
                Constraint {
                    expression = "deployment.accessLogging.enabled == true"
                    message = "HIPAA requires audit logging for all PHI access"
                    severity = "error"
                }
            ]
        }
    ]
    tags = ["healthcare", "PHI", "HIPAA"]
}
```

### Port

Polymorphic interface boundary for data/service/event flows.  In Data Mesh terms, a Port represents the standardized interface that enables interoperability across the mesh. Ports are the contract points where products expose their capabilities (output ports), declare their dependencies (input ports), or enable bidirectional communication.  In Domain-Driven Design terms, a Port is a Value Object - it has no independent identity and exists only within the context of its parent Product. Ports are immutable descriptors of interfaces and are compared by their attribute values rather than identity.  Port Types: ---------- - data: Traditional data interfaces (SQL, Parquet, CSV) - service: Synchronous service endpoints (REST, gRPC, GraphQL) - event: Asynchronous event streams (Kafka, Kinesis, MQTT)  This enables Composable Mesh Architecture to unify data products, microservices, event-driven systems, and ML pipelines under a single abstraction.  Hierarchy Position: Level 5 (Value Object, not a MeshNode) Organization → Mesh → Domain → Product → Component → Port

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**authentication**|str|||
|**catalog**|str|||
|**classification**|"public" | "internal" | "confidential" | "restricted"|||
|**componentId**|str|||
|**description**|str|||
|**direction** `required`|"input" | "output" | "bidirectional"|||
|**eventSchema**|str|||
|**format**|str|||
|**messageFormat**|str|||
|**name** `required`|str|||
|**openApiSpec**|str|||
|**portType** `required`|"data" | "service" | "event"|||
|**protocol**|str|||
|**schema**|str|||
|**sla**|{str:str}|||
|**topic**|str|||
#### Examples

```
name: str, required.
    The name of the port.
    Examples: "customer-data", "rest-api", "order-events"
description: str, optional.
    A description of the port's purpose.
componentId: str, optional.
    Reference to parent Component ID if this is a component port.
    If None, this port is owned by a Product (product-level port).
    Component ports are internal (between components).
    Product ports are external (exposed to consumers).
direction: str, required.
    The direction of data/service flow.
    Valid values:
    - "input": Consumes data/requests (dependencies)
    - "output": Produces data/responses (capabilities)
    - "bidirectional": Both input and output (APIs, interactive services)
portType: str, required.
    The type of interface this port represents.
    Valid values:
    - "data": Data interface (tables, files, datasets)
    - "service": Service endpoint (REST, gRPC, GraphQL)
    - "event": Event stream (Kafka, Kinesis, MQTT)
    This discriminator determines which optional fields are required.

Data-Specific Attributes (required if portType == "data"):
--------------------------------------------------------
format: str, optional but required for data ports.
    The data format.
    Examples: "sql", "parquet", "avro", "json", "csv", "orc"
schema: str, optional.
    Reference to the data schema (URN, URL, or inline).
    Examples:
    - "s3://bucket/schemas/customer.avsc" (Avro schema)
    - "https://api.example.com/schemas/customer.json" (JSON Schema)
    - "urn:schema:customer:v1" (URN reference)
catalog: str, optional.
    Catalog location for data discovery.
    Examples: "s3://bucket/data/customers", "jdbc:postgresql://..."

Service-Specific Attributes (required if portType == "service"):
---------------------------------------------------------------
protocol: str, optional but required for service ports.
    The service protocol.
    Examples: "rest", "grpc", "graphql", "soap", "thrift"
openApiSpec: str, optional.
    URL or path to OpenAPI/Swagger specification.
    Examples: "https://api.example.com/openapi.yaml"
authentication: str, optional.
    Authentication mechanism.
    Examples: "oauth2", "jwt", "api-key", "mtls", "none"

Event-Specific Attributes (required if portType == "event"):
----------------------------------------------------------
topic: str, optional but required for event ports.
    The event topic or stream name.
    Examples: "customers.profile.updated", "orders.created"
eventSchema: str, optional.
    URL or path to event schema (Avro, Protobuf, JSON Schema).
    Examples: "https://registry.example.com/schemas/customer-event.avsc"
messageFormat: str, optional.
    The message serialization format.
    Examples: "avro", "protobuf", "json", "cloudevents"

Common Governance Attributes:
----------------------------
sla: {str: str}, optional.
    Service Level Agreement metrics.
    Examples:
    - {"availability": "99.9%", "latency_p95": "100ms"}
    - {"freshness": "5min", "completeness": "100%"}
classification: str, optional.
    Data sensitivity classification.
    Valid values: "public", "internal", "confidential", "restricted"
    Triggers access control policies.
```

### Product

Product defines an autonomous, deployable unit in the Composable Mesh Architecture.  In Data Mesh terms, a Product embodies the principle of Data as a Product. It is an autonomous unit with a clear interface, discoverable through the mesh catalog, and accountable for quality and SLOs. Products expose their capabilities through Ports (input/output interfaces) and can depend on other products to form a network of services.  In Domain-Driven Design terms, a Product is an Aggregate Root within a Domain's Bounded Context. It has independent lifecycle, identity, and transactional consistency boundaries. Products encapsulate transformation logic, storage, and interface contracts.  Product Composition: ------------------- Products can be: 1. **Atomic**: Single-component products (simple use cases) - components = [] or None - Direct port exposure 2. **Composite**: Multi-component products (complex pipelines) - components = [component-id-1, component-id-2, ...] - componentGraph defines data flow between components - Product ports expose selected component ports externally  Product Kinds: ------------- Products support multiple resource types: - dataset: Traditional data products (tables, files) - api: RESTful/gRPC service endpoints - stream: Event streams (Kafka, Kinesis) - dashboard: Analytical visualizations - algorithm: ML models and pipelines - service: General microservices  Hierarchy Position: Level 3 Organization → Mesh → Domain → Product → Component → Port  Graph Relationships: - Owned by: Domain (via OWNS relationship) - COMPOSES → Component (one-to-many, product composition) - EXPOSES → Port (one-to-many, product-level ports) - DEPENDS_ON → Product (many-to-many, product dependencies)  Inherits from MeshNode: - id: Unique product identifier - name: Human-readable product name - description: Product purpose and capabilities - deployment: Deployment specification for this product - policies: Product-level policies (cascaded from Domain + local) - semantics: Ontological metadata for the product - version: Semantic version (inherited but can override) - status: Lifecycle status (inherited but can override) - owner: Product owner (inherited but can override) - tags: Product tags (triggers policy mixins like PIIMixin)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**componentGraph**|[[ComponentEdge](#componentedge)]|Defines data flow between components in composition.<br />Required for composite products (components.length > 1).<br />Each edge connects a source component port to target component port.<br />Must form a Directed Acyclic Graph (DAG) - no cycles allowed.||
|**components**|[str]|List of Component IDs that compose this product.<br />Empty or None = atomic product (single component, backward compatible)<br />Non-empty = composite product (multiple components)<br />Components are referenced by ID (not embedded).<br />Examples:<br />- ["kafka-to-delta-bronze", "bronze-to-silver", "silver-to-gold"]<br />- ["api-gateway", "auth-service", "user-service"]||
|**constraints** `required`|[[Constraint](#constraint)]|Direct compile-time constraints (alternative to policy-based constraints).<br />Useful for node-specific validations not part of reusable policies.|[]|
|**dependsOn**|[str]|List of product IDs this product depends on.<br />Used for:<br />- Data lineage tracking<br />- Constraint propagation (PII, sensitivity)<br />- Deployment ordering<br />- Impact analysis||
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|Deployment specification (environment, source repository).<br />Part of the MeshNode aggregate (Specification Object pattern).||
|**description**|str|Detailed description of the node's purpose and scope.||
|**domainId**|str|Reference to parent Domain.<br />If specified, this product inherits policies from the domain.<br />Required for hierarchical governance and domain ownership.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.<br />Format: kebab-case or UUID<br />Examples: "customer-profile", "recommendation-engine"||
|**kind** `required`|"dataset" | "api" | "stream" | "dashboard" | "algorithm" | "service"|The classifier for the product type.<br />Valid values: "dataset", "api", "stream", "dashboard", "algorithm", "service"<br />Determines which port types are valid (data/service/event).|"dataset"|
|**name** `required`|str|Human-readable name for the node.<br />Examples: "Customer Profile", "Recommendation Engine"||
|**owner**|str|Owner or team responsible for this node.<br />Examples: "data-platform-team", "finance-domain"||
|**policies** `required`|[[Policy](#policy)]|Governance policies applicable to this node.<br />Cascades from parent nodes via inheritance.|[]|
|**ports**|[[Port](#port)]|Product-level ports (external interfaces).<br />For atomic products: Direct port exposure<br />For composite products: Selected component ports exposed externally<br />Examples:<br />- Atomic: Product has 2 ports directly<br />- Composite: Product exposes only "gold" layer port (internal bronze/silver hidden)||
|**semantics**|[SemanticMetadata](#semanticmetadata)|Semantic annotations for knowledge graph construction.<br />Enables RDF export, business glossary integration, data lineage.||
|**status** `required`|"proposed" | "experimental" | "live" | "deprecated" | "retired"|Lifecycle status of this node.<br />Valid values:<br />- "proposed": Design phase, not yet implemented<br />- "experimental": Early implementation, unstable API<br />- "live": Production-ready, stable API<br />- "deprecated": Scheduled for removal, use alternatives<br />- "retired": No longer available|"proposed"|
|**tags** `required`|[str]|Freeform tags for categorization and policy triggering.<br />Special tags trigger policy mixins:<br />- "PII": Triggers PIIMixin (encryption, masking)<br />- "GDPR": Triggers GDPRMixin (retention, consent)<br />- "PCI-DSS": Triggers PCI compliance policies|[]|
|**version** `required`|str|Semantic version of this node (X.Y.Z format).<br />Follows semver conventions for compatibility tracking.|"0.1.0"|
#### Examples

```
# Atomic Product (Single component, backward compatible)
customerProfile = Product {
    id = "customer-profile"
    name = "Customer Profile"
    domainId = "customer-domain"
    kind = "dataset"
    tags = ["PII", "GDPR"]
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            atRest = true
            inTransit = true
        }
    }
    ports = [
        port.Port {
            name = "customer-data"
            direction = "output"
            portType = "data"
            format = "parquet"
        }
    ]
}

# Composite Product (Multi-component ETL pipeline)
customerETL = Product {
    id = "customer-etl-pipeline"
    name = "Customer ETL Pipeline"
    description = "End-to-end customer data pipeline: bronze → silver → gold"
    domainId = "customer-domain"
    kind = "dataset"
    version = "1.0.0"
    status = "live"
    tags = ["PII", "GDPR", "pipeline"]

    deployment = DeploymentSpec {
        environment = "production"
    }

    # Component composition
    components = [
        "kafka-to-delta-bronze",
        "bronze-to-silver-transform",
        "silver-to-gold-aggregate"
    ]

    # Component wiring (data flow)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = "kafka-to-delta-bronze"
            sourcePort = "delta-output"
            targetComponent = "bronze-to-silver-transform"
            targetPort = "delta-input"
        },
        edge.ComponentEdge {
            sourceComponent = "bronze-to-silver-transform"
            sourcePort = "delta-output"
            targetComponent = "silver-to-gold-aggregate"
            targetPort = "delta-input"
            transformation = "filter(is_valid == true)"
        }
    ]

    # Product exposes only gold layer externally
    ports = [
        port.Port {
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

    dependsOn = []  # No external product dependencies
}

# Composite Product (Microservices platform)
customerAPIPlatform = Product {
    id = "customer-api-platform"
    name = "Customer API Platform"
    description = "Microservices platform for customer management"
    domainId = "customer-domain"
    kind = "api"
    version = "2.0.0"
    status = "live"

    deployment = DeploymentSpec {
        environment = "production"
    }

    # Service composition
    components = [
        "api-gateway-1",
        "auth-service-instance",
        "user-service-instance",
        "notification-service-instance"
    ]

    # Service dependencies (call graph)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "auth-route"
            targetComponent = "auth-service-instance"
            targetPort = "auth-api"
        },
        edge.ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "user-route"
            targetComponent = "user-service-instance"
            targetPort = "user-api"
        },
        edge.ComponentEdge {
            sourceComponent = "user-service-instance"
            sourcePort = "auth-client"
            targetComponent = "auth-service-instance"
            targetPort = "auth-api"
        }
    ]

    # Product exposes unified public API
    ports = [
        port.Port {
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

# ML model with dependencies
recommendationEngine = Product {
    id = "recommendation-engine"
    name = "Recommendation Engine"
    domainId = "marketing-domain"
    kind = "algorithm"
    dependsOn = ["customer-profile", "product-catalog"]
    tags = ["PII"]  # Inherits from customer-profile
    deployment = DeploymentSpec {
        environment = "production"
        encryption = EncryptionConfig {
            atRest = true  # Required due to PII tag
        }
    }
}
```

### Constraint

A compile-time checkable expression that enforces a policy requirement.  Constraints are evaluated during KCL compilation (shift-left governance). They use KCL's native expression syntax for type-safe validation.  Constraint Propagation: ---------------------- When a node depends on another node with constraints, those constraints can propagate based on semantic tags (taint analysis):  Example: - Node A has tag "PII" → requires encryption - Node C consumes Node A → inherits PII requirement - Constraint validates: C.deployment.encryption.atRest == true

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**expression** `required`|str|KCL expression that evaluates to a boolean.<br />Must reference fields available in the node's schema.<br />Examples:<br />- "deployment.encryption.atRest == true"<br />- "retentionPolicy.maxDays <= 2555"<br />- "'PII' in tags implies deployment.encryption.atRest == true"||
|**message** `required`|str|User-facing error/warning message when constraint fails.||
|**severity** `required`|"error" | "warning"|Impact level of constraint violation.<br />Valid values:<br />- "error": Blocks compilation (for blocking policies)<br />- "warning": Warns but allows compilation (for warning policies)||
#### Examples

```
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
```

### GDPRMixin

Mixin for nodes subject to GDPR (General Data Protection Regulation).  Automatically applies when tags include "GDPR". Enforces: 1. Data retention limits (7 years max per GDPR Article 5) 2. Right to erasure capabilities (GDPR Article 17) 3. Data portability support (GDPR Article 20) 4. Consent tracking (GDPR Article 7)  Applies to: ---------- - Products processing EU resident data - Products storing personal data of EU citizens - Services offering to EU market  Regulatory Alignment: -------------------- - GDPR Article 5: Principles relating to processing - GDPR Article 17: Right to erasure ("right to be forgotten") - GDPR Article 20: Right to data portability - GDPR Article 7: Conditions for consent  Usage: ----- euProduct = Product { tags = ["GDPR"] retentionPolicy = RetentionPolicy { maxDays = 2555  # 7 years erasureCapable = true } dataPortability = DataPortabilityConfig { exportFormats = ["json", "csv", "xml"] } }  Constraint Propagation: ---------------------- If Product B (EU region) depends on Product A (global), then Product A must either: 1. Apply GDPRMixin (store only EU-compliant data) 2. Filter/partition data to separate EU from non-EU 3. Apply shortest retention period globally

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**gdprPolicy** `required`|[Policy](#policy)||policy.Policy {<br />    id = "gdpr-compliance-v1"<br />    name = "GDPR Compliance Requirements"<br />    scope = "product"<br />    policyType = "compliance"<br />    enforcement = "blocking"<br />    constraints = [<br />        policy.Constraint {<br />            expression = "retentionPolicy.maxDays <= 2555"<br />            message = "GDPR Article 5 requires data retention period <= 7 years (2555 days)"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "retentionPolicy.erasureCapable == true"<br />            message = "GDPR Article 17 requires right to erasure (right to be forgotten)"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "dataPortability.exportFormats != None and len(dataPortability.exportFormats) > 0"<br />            message = "GDPR Article 20 requires data portability in structured, commonly used formats"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.region.startswith('eu-') or deployment.region == 'eu-central'"<br />            message = "GDPR-tagged products should be deployed in EU regions for data sovereignty"<br />            severity = "warning"<br />        }<br />    ]<br />}|
### PCIDSSMixin

Mixin for nodes handling payment card data (PCI-DSS compliance).  Automatically applies when tags include "PCI-DSS". Enforces: 1. Strong encryption (AES-256) 2. Network segmentation 3. Access control (least privilege) 4. Regular security testing  Applies to: ---------- - Products processing credit card transactions - Products storing cardholder data (PAN, CVV) - Services in payment processing chain  Regulatory Alignment: -------------------- - PCI-DSS Requirement 3: Protect stored cardholder data - PCI-DSS Requirement 4: Encrypt transmission of cardholder data - PCI-DSS Requirement 7: Restrict access to cardholder data - PCI-DSS Requirement 11: Test security systems and processes  Usage: ----- paymentProduct = Product { tags = ["PCI-DSS"] deployment = DeploymentSpec { environment = "production" encryption = EncryptionConfig { atRest = true algorithm = "AES-256" } networkSegmentation = true } }

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**pciPolicy** `required`|[Policy](#policy)||policy.Policy {<br />    id = "pci-dss-v1"<br />    name = "PCI-DSS Compliance Requirements"<br />    scope = "product"<br />    policyType = "compliance"<br />    enforcement = "blocking"<br />    constraints = [<br />        policy.Constraint {<br />            expression = "deployment.encryption.atRest == true and deployment.encryption.algorithm == 'AES-256'"<br />            message = "PCI-DSS Requirement 3: Cardholder data must be encrypted with AES-256"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.encryption.inTransit == true"<br />            message = "PCI-DSS Requirement 4: Cardholder data must be encrypted in transit"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.networkSegmentation == true"<br />            message = "PCI-DSS Requirement 1: Network segmentation required for cardholder data environment"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.accessControl.principleOfLeastPrivilege == true"<br />            message = "PCI-DSS Requirement 7: Access to cardholder data must follow least privilege principle"<br />            severity = "error"<br />        }<br />    ]<br />}|
### PIIMixin

Mixin for nodes handling Personally Identifiable Information (PII).  Automatically applies when tags include "PII". Enforces: 1. Encryption at rest 2. Encryption in transit 3. Access logging 4. Data masking capabilities  This demonstrates constraint propagation: any product consuming PII-tagged data must inherit these constraints (taint analysis).  Regulatory Alignment: -------------------- - GDPR Article 32: Security of processing - CCPA Section 1798.150: Data security requirements - HIPAA Security Rule: Administrative, physical, technical safeguards  Usage: ----- # Automatic application based on tag piiProduct = Product { tags = ["PII"] # Mixin automatically adds encryption policy # Compilation fails if deployment.encryption.atRest != true }  Constraint Propagation: ---------------------- If Product B depends on Product A (PII-tagged), then Product B must either: 1. Apply PIIMixin (handle PII directly) 2. Apply MaskingMixin (de-identify PII) 3. Prove data is aggregated/anonymized

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**piiPolicy** `required`|[Policy](#policy)||policy.Policy {<br />    id = "pii-encryption-v1"<br />    name = "PII Encryption Required"<br />    scope = "product"<br />    policyType = "privacy"<br />    enforcement = "blocking"<br />    constraints = [<br />        policy.Constraint {<br />            expression = "deployment.encryption.atRest == true"<br />            message = "Products handling PII must enable encryption at rest (GDPR Article 32)"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.encryption.inTransit == true"<br />            message = "Products handling PII must enable encryption in transit"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.accessLogging.enabled == true"<br />            message = "Products handling PII must enable access logging for audit trails"<br />            severity = "error"<br />        }<br />    ]<br />}|
### Policy

A governance rule that can be applied at any level of the CMA hierarchy.  Policies consist of: 1. Metadata (id, name, scope, type) 2. Enforcement strategy (blocking, warning, audit) 3. Constraints (compile-time checkable expressions)  Policies cascade from parent to child nodes through mixin inheritance, implementing the federated governance pattern with O(D) complexity.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**constraints** `required`|[[Constraint](#constraint)]|List of compile-time checkable constraints that implement this policy.||
|**enforcement** `required`|"blocking" | "warning" | "audit"|How violations are handled.<br />Valid values:<br />- "blocking": Compilation fails on violation<br />- "warning": Compilation succeeds with warning<br />- "audit": No compilation impact, logged for post-deployment audit||
|**id** `required`|str|Globally unique policy identifier (e.g., "pii-encryption-v1").||
|**name** `required`|str|Human-readable policy name.||
|**policyType** `required`|"security" | "privacy" | "quality" | "compliance" | "cost"|Classification of the policy's domain.<br />Valid values: "security", "privacy", "quality", "compliance", "cost".||
|**scope** `required`|"organization" | "mesh" | "domain" | "product" | "port"|Hierarchical level at which this policy applies.<br />Valid values: "organization", "mesh", "domain", "product", "port".||
#### Examples

```
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
```

### SOC2Mixin

Mixin for nodes requiring SOC 2 compliance (Service Organization Control).  Automatically applies when tags include "SOC2". Enforces: 1. Change management tracking 2. Incident response procedures 3. Monitoring and alerting 4. Business continuity planning  Applies to: ---------- - SaaS products handling customer data - Cloud services with security commitments - Managed service providers  Trust Service Criteria: ---------------------- - Security: Protection against unauthorized access - Availability: System uptime and performance - Processing Integrity: Complete, accurate, timely processing - Confidentiality: Designated confidential information protected - Privacy: Personal information collected, used, retained, disclosed properly  Usage: ----- saasProduct = Product { tags = ["SOC2"] deployment = DeploymentSpec { environment = "production" monitoring = MonitoringConfig { enabled = true alerting = true } changeManagement = ChangeManagementConfig { approvalRequired = true } } }

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**soc2Policy** `required`|[Policy](#policy)||policy.Policy {<br />    id = "soc2-compliance-v1"<br />    name = "SOC 2 Compliance Requirements"<br />    scope = "product"<br />    policyType = "compliance"<br />    enforcement = "blocking"<br />    constraints = [<br />        policy.Constraint {<br />            expression = "deployment.monitoring.enabled == true and deployment.monitoring.alerting == true"<br />            message = "SOC 2: Monitoring and alerting required for security and availability"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.changeManagement.approvalRequired == true"<br />            message = "SOC 2: Change management with approval workflow required"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.incidentResponse.runbookUrl != None"<br />            message = "SOC 2: Incident response procedures must be documented"<br />            severity = "error"<br />        }<br />        policy.Constraint {<br />            expression = "deployment.monitoring.retentionDays >= 365"<br />            message = "SOC 2: Audit logs must be retained for at least 12 months"<br />            severity = "warning"<br />        }<br />    ]<br />}|
### SemanticMetadata

Semantic annotations for MeshNodes enabling knowledge graph construction.  SemanticMetadata bridges the gap between technical schemas (KCL) and semantic ontologies (RDF/OWL), supporting: 1. Automated RDF triple generation 2. Business glossary integration 3. Data lineage tracking 4. Access control based on classification  This enables: - Semantic search across the mesh - Automated policy inference from classifications - Cross-domain data discovery - Compliance reporting (e.g., GDPR data inventory)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**businessGlossaryTerms**|[str]|Human-readable business concepts associated with this node.<br />Links to enterprise business glossary or data dictionary.<br />Examples: ["CustomerData", "PersonalInformation", "GDPR", "PII"]||
|**dataClassification**|"public" | "internal" | "confidential" | "restricted"|Sensitivity/confidentiality level for access control.<br />Standard values: "public", "internal", "confidential", "restricted".<br />Triggers policy mixins based on classification level.||
|**downstreamConsumers**|[str]|List of node IDs that consume data from this node.<br />Used for:<br />- Data lineage graph construction<br />- Impact analysis (who is affected by changes?)<br />- Access control (who needs read permissions?)||
|**namespace**|str|URI prefix for generating unique identifiers.<br />Example: "https://cdmesh.example.com/products/"<br />Results in URIs like: https://cdmesh.example.com/products/customer-profile||
|**rdfType**|str|RDF class URI from a standard ontology.<br />Examples:<br />- "http://schema.org/Dataset" (for data products)<br />- "http://www.w3.org/ns/dcat#Distribution" (for data ports)<br />- "http://schema.org/WebAPI" (for service endpoints)<br />- "http://www.w3.org/ns/prov#Entity" (for provenance tracking)||
|**upstreamDependencies**|[str]|List of node IDs that this node consumes data from.<br />Used for:<br />- Data lineage graph construction<br />- Impact analysis (what breaks if upstream changes?)<br />- Constraint propagation (inherit PII/sensitivity from sources)||
#### Examples

```
# Financial Data Product
financialSemantics = SemanticMetadata {
    rdfType = "http://schema.org/Dataset"
    namespace = "https://bank.example.com/data/"
    businessGlossaryTerms = ["TransactionData", "AccountBalance", "PCI-DSS"]
    dataClassification = "restricted"
    upstreamDependencies = ["core-banking-system"]
    downstreamConsumers = ["fraud-detection", "reporting-platform"]
}

# Customer API Service
apiSemantics = SemanticMetadata {
    rdfType = "http://schema.org/WebAPI"
    namespace = "https://api.example.com/services/"
    businessGlossaryTerms = ["CustomerManagement", "REST-API"]
    dataClassification = "internal"
}
```

<!-- Auto generated by kcl-doc tool, please do not edit. -->
