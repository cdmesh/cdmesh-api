"""
Port: Polymorphic interface boundary for Products in CMA.

This module implements a unified Port abstraction that supports:
- Data ports (datasets, files, tables)
- Service ports (REST, gRPC, GraphQL)
- Event ports (Kafka topics, event streams)

Design Rationale:
----------------
Single polymorphic schema with portType discriminator:
- Simpler catalog model and unified interface
- Easier to extend with new port types
- Conditional validation based on portType

Academic References:
-------------------
- ODCS v3.1.0: Open Data Contract Standard (data-centric ports)
- DCAT 2.0: Distribution concept (similar to ports)
"""

schema Port:
    """
    Polymorphic interface boundary for data/service/event flows.

    In Data Mesh terms, a Port represents the standardized interface that enables interoperability
    across the mesh. Ports are the contract points where products expose their capabilities
    (output ports), declare their dependencies (input ports), or enable bidirectional communication.

    In Domain-Driven Design terms, a Port is a Value Object - it has no independent identity
    and exists only within the context of its parent Product. Ports are immutable descriptors
    of interfaces and are compared by their attribute values rather than identity.

    Port Types:
    ----------
    - data: Traditional data interfaces (SQL, Parquet, CSV)
    - service: Synchronous service endpoints (REST, gRPC, GraphQL)
    - event: Asynchronous event streams (Kafka, Kinesis, MQTT)

    This enables Composable Mesh Architecture to unify data products, microservices,
    event-driven systems, and ML pipelines under a single abstraction.

    Hierarchy Position: Level 5 (Value Object, not a MeshNode)
    Organization → Mesh → Domain → Product → Component → Port

    Ownership Model (Option B):
    ---------------------------
    Ports can be owned by either Components or Products:
    1. **Component Ports**: Owned by Component (componentId specified)
       - Internal interfaces between components
       - Reusable with component templates
    2. **Product Ports**: Owned by Product (componentId = None)
       - External interfaces exposed to consumers
       - May reference/delegate to component ports

    Graph Relationships:
    - Embedded within: Component OR Product (no independent graph node)
    - Validates: Parent's policies (governance constraints)

    Attributes
    ----------
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

    Examples
    --------
    # Data Port (Parquet dataset)
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

    # Service Port (REST API)
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

    # Event Port (Kafka stream)
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

    # gRPC Service Port
    grpcPort = Port {
        name = "order-service"
        description = "Order management gRPC service"
        direction = "bidirectional"
        portType = "service"
        protocol = "grpc"
        openApiSpec = "https://api.example.com/proto/order.proto"
        authentication = "mtls"
        sla = {
            "availability": "99.99%"
            "latency_p99": "50ms"
        }
    }

    # GraphQL API Port
    graphqlPort = Port {
        name = "unified-api"
        description = "Unified GraphQL API"
        direction = "bidirectional"
        portType = "service"
        protocol = "graphql"
        openApiSpec = "https://api.example.com/graphql/schema.graphql"
        authentication = "jwt"
    }
    """
    # Common attributes
    name: str
    description?: str
    componentId?: str  # Optional: parent component (if component port)
    direction: "input" | "output" | "bidirectional"
    portType: "data" | "service" | "event"

    # Data-specific (required if portType == "data")
    format?: str
    $schema?: str
    catalog?: str

    # Service-specific (required if portType == "service")
    protocol?: str
    openApiSpec?: str
    authentication?: str

    # Event-specific (required if portType == "event")
    topic?: str
    eventSchema?: str
    messageFormat?: str

    # Common governance
    sla?: {str: str}
    classification?: "public" | "internal" | "confidential" | "restricted"

    check:
        len(name) > 0, "name must not be empty"

        # Data port validations
        portType != "data" or format != None, \
            "data ports require 'format' field (e.g., 'parquet', 'json', 'avro')"

        # Service port validations
        portType != "service" or protocol != None, \
            "service ports require 'protocol' field (e.g., 'rest', 'grpc', 'graphql')"

        # Event port validations
        portType != "event" or topic != None, \
            "event ports require 'topic' field (e.g., 'customers.profile.updated')"

        # Direction-specific validations
        direction != "input" or portType != "service", \
            "service ports should be 'bidirectional' rather than 'input'"

        # Classification-based validations
        classification != "restricted" or sla != None, \
            "restricted data must have defined SLAs for compliance tracking"
