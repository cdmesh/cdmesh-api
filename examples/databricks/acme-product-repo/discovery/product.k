import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.edge as edge
import cdmesh_api.discovery.port as port
import cdmesh_api.discovery.product as prod

import ..components.bronze as bronze
import ..components.silver as silver
import ..components.gold as gold

bronzeComponent = bronze.kafkaToDeltaBronze
silverComponent = silver.bronzeToSilverTransform
goldComponent = gold.silverToGoldAggregate
goldComponentOutput = goldComponent.ports[1]

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
        environment = "dev"
    }

    # Component composition
    components = [
        bronzeComponent.id,
        silverComponent.id,
        goldComponent.id,
    ]

    # Component wiring (data flow DAG)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = bronzeComponent.id
            sourcePort = bronzeComponent.ports[1].name
            targetComponent = silverComponent.id
            targetPort = silverComponent.ports[0].name

            metadata = {
                "latency.sla": "5m"
                "data.classification": "PII"
            }
        },
        edge.ComponentEdge {
            sourceComponent = silverComponent.id
            sourcePort = silverComponent.ports[1].name
            targetComponent = goldComponent.id
            targetPort = goldComponent.ports[0].name

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
            name = goldComponentOutput.name
            description = goldComponentOutput.description
            direction = goldComponentOutput.direction
            portType = goldComponentOutput.portType
            format = goldComponentOutput.format
            catalog = goldComponentOutput.catalog

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