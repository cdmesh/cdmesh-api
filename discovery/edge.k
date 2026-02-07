"""
Graph edge definitions for component and product relationships.

This module defines edge schemas that represent data flow and dependencies
between components within product compositions.

These edges enable:
- Explicit component wiring (data flow visualization)
- Dependency analysis (impact assessment)
- Deployment ordering (topological sort)
- Lineage tracking (data provenance)

Academic References:
-------------------
- Graph Theory: Directed Acyclic Graphs (DAGs) for pipeline modeling
- Data Lineage: OpenLineage edge representations
- Workflow Orchestration: Airflow DAG definitions
"""

schema ComponentEdge:
    """
    Defines data flow between components in a product composition.

    ComponentEdge represents a directed edge in the component graph,
    indicating that data flows from one component's output port to
    another component's input port.

    This enables:
    1. **Explicit Wiring**: Clear data flow paths
    2. **Validation**: Ensure port compatibility (format, schema)
    3. **Deployment**: Order components based on dependencies
    4. **Lineage**: Track data provenance through components
    5. **Impact Analysis**: Understand downstream effects of changes

    Graph Properties:
    ----------------
    - **Directed**: sourceComponent → targetComponent
    - **Acyclic**: No circular dependencies (DAG required)
    - **Port-specific**: Connects specific ports (not just components)

    Attributes
    ----------
    sourceComponent: str, required.
        Source component ID (data producer).
        Must be a valid Component ID in the product composition.
    sourcePort: str, required.
        Name of the output port on source component.
        Must be a port with direction = "output" or "bidirectional".
    targetComponent: str, required.
        Target component ID (data consumer).
        Must be a valid Component ID in the product composition.
    targetPort: str, required.
        Name of the input port on target component.
        Must be a port with direction = "input" or "bidirectional".
    transformation: str, optional.
        Optional transformation applied to data in transit.
        Examples:
        - "filter(status == 'active')" - Filter transformation
        - "map(rename_columns)" - Column mapping
        - "aggregate(group_by='customer_id')" - Aggregation
        If None, data passes through unchanged.
    metadata: {str: str}, optional.
        Additional edge metadata for lineage or governance.
        Examples:
        - {"lineage.system": "openlineage"}
        - {"data.classification": "PII"}
        - {"sla.latency": "5m"}

    Examples
    --------
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
    """
    sourceComponent: str
    sourcePort: str
    targetComponent: str
    targetPort: str
    transformation?: str
    metadata?: {str: str}

    check:
        len(sourceComponent) > 0, "sourceComponent must not be empty"
        len(sourcePort) > 0, "sourcePort must not be empty"
        len(targetComponent) > 0, "targetComponent must not be empty"
        len(targetPort) > 0, "targetPort must not be empty"
        sourceComponent != targetComponent, "self-referential edges not allowed (would create cycle)"
