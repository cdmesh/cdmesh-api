import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

import databricks_components.transform.delta as transform

silverTransform = transform.databricksDeltaTransform
silverInput = silverTransform.ports[0]
silverOutput = silverTransform.ports[1]

bronzeToSilverTransform = comp.Component {
    kind = silverTransform.kind
    runtime = silverTransform.runtime
    template = silverTransform.id

    id = "bronze-to-silver-transform"
    name = "Bronze to Silver Transformation"
    description = "Clean and validate customer data for silver layer"
    productId = "customer-etl-pipeline"
    version = "2.0.0"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }

    ports = [
        port.Port {
            name = silverInput.name
            description = silverInput.description
            direction = silverInput.direction
            portType = silverInput.portType
            format = silverInput.format

            componentId = "bronze-to-silver-transform"
            catalog = "bronze.customers"
        },
        port.Port {
            name = silverOutput.name
            description = silverOutput.description
            direction = silverOutput.direction
            portType = silverOutput.portType
            format = silverOutput.format

            componentId = "bronze-to-silver-transform"
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