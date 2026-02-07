"""
Component: Atomic, reusable building block in CMA.

This module defines the Component schema, which represents the smallest
deployable quantum that can be combined to build complex products.

Components are the fundamental building blocks of composable architectures:
- Data pipelines: KafkaToDelta, DeltaTransform, DeltaToAPI
- Microservices: AuthService, UserService, NotificationService
- ML pipelines: FeatureExtractor, ModelTrainer, InferenceService
- Infrastructure: Database, MessageQueue, Cache

Components support two usage patterns:
1. **Template**: Reusable component definition in catalog (template = null)
2. **Instance**: Configured component derived from template (template = component-id)

Hierarchy Position: Level 4
Organization → Mesh → Domain → Product → Component → Port

Academic References:
-------------------
- Backstage (Spotify): Component as first-class catalog entity
- Crossplane: Composition resources as reusable components
- OAM (Open Application Model): Component definitions
- Terraform: Modules as reusable components
- DDD: Component as Aggregate Root with independent lifecycle
"""

import ..core.node
import .port

schema Component(node.MeshNode):
    """
    Atomic, reusable building block for product compositions.

    Component represents the smallest deployable quantum that can be
    combined to build complex products. Components are independently:
    - Versioned (semantic versioning)
    - Deployed (can run standalone or within product)
    - Governed (own policies and constraints)
    - Discovered (catalog entities)

    Usage Patterns:
    --------------
    1. **Template Component** (Reusable definition):
       - Stored in catalog for reuse
       - template = None
       - Parameterized ports and configuration
       - Example: "kafka-to-delta-v1" template

    2. **Instance Component** (Configured from template):
       - Belongs to specific product
       - template = template-component-id
       - Concrete port configuration
       - Example: "kafka-to-delta-bronze" instance

    In Domain-Driven Design terms, Component is an Aggregate Root with:
    - Independent identity (id field)
    - Independent lifecycle (version, status)
    - Own policies and governance
    - Owned ports (interface boundaries)

    Graph Relationships:
    -------------------
    - Owned by: Product (via product.components reference)
    - EXPOSES → Port (one-to-many, Component owns ports)
    - DEPENDS_ON → Component (many-to-many, component dependencies)
    - INSTANTIATES → Component (template → instance relationship)

    Attributes
    ----------
    productId: str, optional.
        Reference to parent Product if this is a component instance.
        Template components have productId = None.
    kind: str, required.
        Component type classification.
        Valid values:
        - "ingestion": Data ingestion components (KafkaToDelta, APIToS3)
        - "transformation": Data transformation (DeltaTransform, SQLTransform)
        - "aggregation": Data aggregation (Rollup, Summarize)
        - "serving": Data serving components (DeltaToAPI, DeltaToBI)
        - "orchestration": Workflow orchestration (Airflow, Prefect)
        - "service": Microservice components (AuthService, UserService)
        - "infrastructure": Infrastructure components (Database, Queue)
    ports: [port.Port], optional.
        Component-owned ports (interface boundaries).
        Both template and instance components have ports.
        Templates use parameterized ports, instances use concrete values.
    dependsOn: [str], optional.
        List of component IDs this component depends on.
        Used for:
        - Deployment ordering (deploy dependencies first)
        - Data lineage (upstream components)
        - Impact analysis (what breaks if dependency changes)
    template: str, optional.
        Reference to template component ID if this is an instance.
        If None, this component IS a template (reusable).
        If specified, this component is instantiated from that template.
        Example: template = "kafka-to-delta-v1"
    reusable: bool, default True.
        Whether this component can be reused across products.
        Templates are always reusable.
        Instances can be marked reusable for sharing within organization.
    runtime: str, optional.
        Target runtime environment for this component.
        Valid values: "databricks", "kubernetes", "airflow", "dbt", "spark", "custom"
        Used for platform-specific code generation and deployment.
    config: {str: str}, optional.
        Component-specific configuration parameters.
        For templates: default values or parameter schemas
        For instances: concrete configuration values
        Examples:
        - {"kafka.topic": "customers.raw"}
        - {"delta.table": "bronze.customers"}
        - {"spark.executor.memory": "4g"}

    Examples
    --------
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
    """
    # Product reference (for instance components)
    productId?: str

    # Component classification
    kind: "ingestion" | "transformation" | "aggregation" | "serving" | "orchestration" | "service" | "infrastructure"

    # Component-owned ports (interfaces)
    ports?: [port.Port]

    # Component dependencies
    dependsOn?: [str]

    # Template pattern
    template?: str  # If None, this IS a template; if set, this is an instance
    reusable: bool = True

    # Runtime environment
    runtime?: "databricks" | "kubernetes" | "airflow" | "dbt" | "spark" | "flink" | "custom"

    # Component configuration
    config?: {str: str}

    check:
        # Template components should not have productId
        template == None or template == Undefined or (productId != None and productId != Undefined), \
            "component instances (with template) must specify productId"

        # Reusable components should be well-documented
        reusable == False or (description != None and description != Undefined and len(description) > 0), \
            "reusable components must have description"

        # Component instances should reference valid template
        template == None or template == Undefined or len(template) > 0, \
            "template reference must not be empty if specified"
