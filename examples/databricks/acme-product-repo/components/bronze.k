import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

import databricks_components.source.kafka as source

bronzeSource = source.databricksKafkaSource
bronzeInput = bronzeSource.ports[0]
bronzeOutput = bronzeSource.ports[1]

kafkaToDeltaBronze = comp.Component {
    kind = bronzeSource.kind
    template = bronzeSource.id
    runtime = bronzeSource.runtime

    id = "kafka-to-delta-bronze"
    name = "Kafka to Bronze Layer"
    description = "Ingest customer events to bronze layer"
    productId = "customer-etl-pipeline"
    version = "1.2.0"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }

    ports = [
        port.Port {
            name = bronzeInput.name
            description = bronzeInput.description
            direction = bronzeInput.direction
            portType = bronzeInput.portType
            messageFormat = bronzeInput.messageFormat

            componentId = "kafka-to-delta-bronze"
            topic = "customers.raw"
            eventSchema = "https://registry.example.com/schemas/customer-raw.avsc"
        },
        port.Port {
            name = bronzeOutput.name
            description = bronzeOutput.description
            direction = bronzeOutput.direction
            portType = bronzeOutput.portType
            format = bronzeOutput.format

            componentId = "kafka-to-delta-bronze"
            catalog = "bronze.customers"
        }
    ]

    config = {
        "kafka.bootstrap.servers": "kafka.acme.com:9092"
        "kafka.consumer.group": "customer-bronze-consumer"
        "delta.merge.schema": "true"
        "checkpoint.location": "/mnt/checkpoints/customer-bronze"
    }

    tags = ["streaming", "source", "bronze", "PII"]
}