import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

import databricks_components.transform.delta as transform

goldTransform = transform.databricksDeltaTransform
goldInput = goldTransform.ports[0]
goldOutput = goldTransform.ports[1]

silverToGoldAggregate = comp.Component {
    kind = goldTransform.kind
    runtime = goldTransform.runtime
    template = goldTransform.id
        
    id = "silver-to-gold-aggregate"
    name = "Silver to Gold Aggregation"
    description = "Aggregate customer data for gold layer analytics"
    productId = "customer-etl-pipeline"
    version = "2.0.0"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }

    ports = [
        port.Port {
            name = goldInput.name
            description = goldInput.description
            direction = goldInput.direction
            portType = goldInput.portType
            format = goldInput.format
            
            componentId = "silver-to-gold-aggregate"
            catalog = "silver.customers"
        },
        port.Port {
            name = goldOutput.name
            description = goldOutput.description
            direction = goldOutput.direction
            portType = goldOutput.portType
            format = goldOutput.format
            
            componentId = "silver-to-gold-aggregate"
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