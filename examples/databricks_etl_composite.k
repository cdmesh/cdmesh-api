"""
Example: Databricks ETL Composite Product

This example demonstrates a composite product composed of multiple
reusable components implementing a bronze→silver→gold data pipeline.

Architecture:
------------
Product: Customer ETL Pipeline
├── Component: Kafka to Delta (Bronze ingestion)
│   ├── Input Port: Kafka topic
│   └── Output Port: Bronze Delta table
├── Component: Delta Transform (Bronze → Silver)
│   ├── Input Port: Bronze Delta table
│   └── Output Port: Silver Delta table
└── Component: Delta Transform (Silver → Gold)
    ├── Input Port: Silver Delta table
    └── Output Port: Gold Delta table (exposed as product port)

Pattern: Template + Instance Reusability
"""

import ..discovery.organization as org
import ..discovery.mesh
import ..discovery.domain
import ..discovery.product as prod
import ..discovery.component as comp
import ..discovery.edge
import ..discovery.port
import ..deploy.spec as deploy

# ========================================
# Organization & Hierarchy
# ========================================

acmeOrg = org.Organization {
    id = "acme-corp"
    name = "Acme Corporation"
    jurisdiction = "US"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

dataMesh = mesh.Mesh {
    id = "data-mesh"
    name = "Acme Data Mesh"
    organizationId = "acme-corp"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

customerDomain = domain.Domain {
    id = "customer-domain"
    name = "Customer Domain"
    meshId = "data-mesh"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

# ========================================
# Component Templates (Reusable)
# ========================================

kafkaToDeltaTemplate = comp.Component {
    id = "kafka-to-delta-v1"
    name = "Kafka to Delta Ingestion"
    description = "Streaming ingestion from Kafka to Delta Lake"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    reusable = True
    template = Undefined  # This IS a template

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "kafka-input"
            description = "Kafka topic input"
            direction = "input"
            portType = "event"
            topic = "PARAM"  # Parameterized
            messageFormat = "avro"
        },
        port.Port {
            name = "delta-output"
            description = "Delta table output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "PARAM"  # Parameterized
        }
    ]

    tags = ["streaming", "ingestion", "template"]
}

deltaTransformTemplate = comp.Component {
    id = "delta-transform-v1"
    name = "Delta Table Transformation"
    description = "Batch transformation of Delta tables"
    kind = "transformation"
    runtime = "databricks"
    version = "2.0.0"
    reusable = True
    template = Undefined  # This IS a template

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "delta-input"
            description = "Delta table input"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "PARAM"  # Parameterized
        },
        port.Port {
            name = "delta-output"
            description = "Delta table output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "PARAM"  # Parameterized
        }
    ]

    tags = ["transformation", "template"]
}

# ========================================
# Component Instances (Configured)
# ========================================

kafkaToDeltaBronze = comp.Component {
    id = "kafka-to-delta-bronze"
    name = "Kafka to Bronze Layer"
    description = "Ingest customer events to bronze layer"
    productId = "customer-etl-pipeline"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    template = "kafka-to-delta-v1"  # References template

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "kafka-input"
            componentId = "kafka-to-delta-bronze"
            description = "Raw customer events from Kafka"
            direction = "input"
            portType = "event"
            topic = "customers.raw"  # Concrete value
            messageFormat = "avro"
            eventSchema = "https://registry.example.com/schemas/customer-raw.avsc"
        },
        port.Port {
            name = "delta-output"
            componentId = "kafka-to-delta-bronze"
            description = "Bronze layer customer data"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "bronze.customers"  # Concrete value
        }
    ]

    config = {
        "kafka.bootstrap.servers": "kafka.acme.com:9092"
        "kafka.consumer.group": "customer-bronze-consumer"
        "delta.merge.schema": "true"
        "checkpoint.location": "/mnt/checkpoints/customer-bronze"
    }

    tags = ["streaming", "ingestion", "bronze", "PII"]
}

bronzeToSilverTransform = comp.Component {
    id = "bronze-to-silver-transform"
    name = "Bronze to Silver Transformation"
    description = "Clean and validate customer data for silver layer"
    productId = "customer-etl-pipeline"
    kind = "transformation"
    runtime = "databricks"
    version = "2.0.0"
    template = "delta-transform-v1"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "delta-input"
            componentId = "bronze-to-silver-transform"
            description = "Bronze layer input"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "bronze.customers"
        },
        port.Port {
            name = "delta-output"
            componentId = "bronze-to-silver-transform"
            description = "Silver layer output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "silver.customers"
        }
    ]

    config = {
        "transformation.sql": """
            SELECT
                customer_id,
                email,
                first_name,
                last_name,
                created_at,
                updated_at
            FROM bronze.customers
            WHERE is_valid = True
                AND email IS NOT NULL
        """
        "quality.rules": "not_null(customer_id), email_format(email)"
        "deduplication.keys": "customer_id"
    }

    dependsOn = ["kafka-to-delta-bronze"]
    tags = ["transformation", "silver", "PII", "GDPR"]
}

silverToGoldAggregate = comp.Component {
    id = "silver-to-gold-aggregate"
    name = "Silver to Gold Aggregation"
    description = "Aggregate customer data for gold layer analytics"
    productId = "customer-etl-pipeline"
    kind = "aggregation"
    runtime = "databricks"
    version = "2.0.0"
    template = "delta-transform-v1"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "delta-input"
            componentId = "silver-to-gold-aggregate"
            description = "Silver layer input"
            direction = "input"
            portType = "data"
            format = "delta"
            catalog = "silver.customers"
        },
        port.Port {
            name = "delta-output"
            componentId = "silver-to-gold-aggregate"
            description = "Gold layer output"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "gold.customer_summary"
        }
    ]

    config = {
        "transformation.sql": """
            SELECT
                DATE_TRUNC('month', created_at) as month,
                COUNT(DISTINCT customer_id) as total_customers,
                COUNT(DISTINCT CASE WHEN updated_at > current_date - 30 THEN customer_id END) as active_customers
            FROM silver.customers
            GROUP BY month
        """
        "aggregation.level": "monthly"
    }

    dependsOn = ["bronze-to-silver-transform"]
    tags = ["aggregation", "gold"]
}

# ========================================
# Composite Product
# ========================================

customerETLPipeline = prod.Product {
    id = "customer-etl-pipeline"
    name = "Customer ETL Pipeline"
    description = "End-to-end customer data pipeline: bronze → silver → gold"
    domainId = "customer-domain"
    kind = "dataset"
    version = "1.0.0"
    status = "live"
    owner = "customer-data-team"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    # Component composition
    components = [
        "kafka-to-delta-bronze",
        "bronze-to-silver-transform",
        "silver-to-gold-aggregate"
    ]

    # Component wiring (data flow DAG)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = "kafka-to-delta-bronze"
            sourcePort = "delta-output"
            targetComponent = "bronze-to-silver-transform"
            targetPort = "delta-input"
            metadata = {
                "latency.sla": "5m"
                "data.classification": "PII"
            }
        },
        edge.ComponentEdge {
            sourceComponent = "bronze-to-silver-transform"
            sourcePort = "delta-output"
            targetComponent = "silver-to-gold-aggregate"
            targetPort = "delta-input"
            transformation = "filter(updated_at > current_date - 90)"
            metadata = {
                "latency.sla": "15m"
                "data.quality": "validated"
            }
        }
    ]

    # Product exposes only gold layer externally
    ports = [
        port.Port {
            name = "customer-gold"
            description = "Curated customer analytics (gold layer)"
            direction = "output"
            portType = "data"
            format = "delta"
            catalog = "gold.customer_summary"
            classification = "internal"
            sla = {
                "freshness": "1h"
                "completeness": "99%"
                "availability": "99.9%"
            }
        }
    ]

    dependsOn = []  # No external product dependencies

    tags = ["PII", "GDPR", "pipeline", "analytics"]
}
