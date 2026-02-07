import regex
import .port
import .edge
import ..core.node

schema Product(node.MeshNode):
    """
    Product defines an autonomous, deployable unit in the Composable Mesh Architecture.

    In Data Mesh terms, a Product embodies the principle of Data as a Product. It is an
    autonomous unit with a clear interface, discoverable through the mesh catalog, and
    accountable for quality and SLOs. Products expose their capabilities through Ports
    (input/output interfaces) and can depend on other products to form a network of services.

    In Domain-Driven Design terms, a Product is an Aggregate Root within a Domain's Bounded
    Context. It has independent lifecycle, identity, and transactional consistency boundaries.
    Products encapsulate transformation logic, storage, and interface contracts.

    Product Composition:
    -------------------
    Products can be:
    1. **Atomic**: Single-component products (simple use cases)
       - components = [] or None
       - Direct port exposure
    2. **Composite**: Multi-component products (complex pipelines)
       - components = [component-id-1, component-id-2, ...]
       - componentGraph defines data flow between components
       - Product ports expose selected component ports externally

    Product Kinds:
    -------------
    Products support multiple resource types:
    - dataset: Traditional data products (tables, files)
    - api: RESTful/gRPC service endpoints
    - stream: Event streams (Kafka, Kinesis)
    - dashboard: Analytical visualizations
    - algorithm: ML models and pipelines
    - service: General microservices

    Hierarchy Position: Level 3
    Organization → Mesh → Domain → Product → Component → Port

    Graph Relationships:
    - Owned by: Domain (via OWNS relationship)
    - COMPOSES → Component (one-to-many, product composition)
    - EXPOSES → Port (one-to-many, product-level ports)
    - DEPENDS_ON → Product (many-to-many, product dependencies)

    Inherits from MeshNode:
    - id: Unique product identifier
    - name: Human-readable product name
    - description: Product purpose and capabilities
    - deployment: Deployment specification for this product
    - policies: Product-level policies (cascaded from Domain + local)
    - semantics: Ontological metadata for the product
    - version: Semantic version (inherited but can override)
    - status: Lifecycle status (inherited but can override)
    - owner: Product owner (inherited but can override)
    - tags: Product tags (triggers policy mixins like PIIMixin)

    Attributes
    ----------
    domainId: str, optional.
        Reference to parent Domain.
        If specified, this product inherits policies from the domain.
        Required for hierarchical governance and domain ownership.
    kind: str, default "dataset".
        The classifier for the product type.
        Valid values: "dataset", "api", "stream", "dashboard", "algorithm", "service"
        Determines which port types are valid (data/service/event).
    components: [str], optional.
        List of Component IDs that compose this product.
        Empty or None = atomic product (single component, backward compatible)
        Non-empty = composite product (multiple components)
        Components are referenced by ID (not embedded).
        Examples:
        - ["kafka-to-delta-bronze", "bronze-to-silver", "silver-to-gold"]
        - ["api-gateway", "auth-service", "user-service"]
    componentGraph: [edge.ComponentEdge], optional.
        Defines data flow between components in composition.
        Required for composite products (components.length > 1).
        Each edge connects a source component port to target component port.
        Must form a Directed Acyclic Graph (DAG) - no cycles allowed.
    ports: [port.Port], optional.
        Product-level ports (external interfaces).
        For atomic products: Direct port exposure
        For composite products: Selected component ports exposed externally
        Examples:
        - Atomic: Product has 2 ports directly
        - Composite: Product exposes only "gold" layer port (internal bronze/silver hidden)
    dependsOn: [str], optional.
        List of product IDs this product depends on.
        Used for:
        - Data lineage tracking
        - Constraint propagation (PII, sensitivity)
        - Deployment ordering
        - Impact analysis

    Examples
    --------
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
    """
    domainId?: str
    kind: "dataset" | "api" | "stream" | "dashboard" | "algorithm" | "service" = "dataset"

    # Composition (NEW)
    components?: [str]
    componentGraph?: [edge.ComponentEdge]

    # Product-level ports (Option B: both components and products have ports)
    ports?: [port.Port]
    dependsOn?: [str]

    check:
        kind != "dataset" or ports == None or all port in ports { port.portType == "data" }, \
            "dataset products should only have data ports"
        (kind != "api" and kind != "service") or ports == None or all port in ports { port.portType == "service" }, \
            "api/service products should only have service ports"
        kind != "stream" or ports == None or all port in ports { port.portType == "event" }, \
            "stream products should only have event ports"

        # Composite product validation
        components == None or len(components) == 0 or componentGraph != None, \
            "composite products (with components) must define componentGraph"
        componentGraph == None or (components != None and len(components) > 0), \
            "componentGraph requires components to be defined"
