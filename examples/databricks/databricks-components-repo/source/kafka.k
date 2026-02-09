import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

databricksKafkaSource = comp.Component {
    id = "databricks-kafka-source"
    name = "Kafka to Delta Ingestion"
    description = "Streaming ingestion from Kafka to Delta Lake"
    kind = "ingestion"
    runtime = "databricks"
    version = "1.2.0"
    reusable = True
    template = Undefined

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }

    ports = [
        port.Port {
            name = "kafka-input"
            description = "Kafka topic input"
            direction = "input"
            portType = "event"
            messageFormat = "avro"
            topic = "PARAM"  # Parameterized
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

    tags = ["streaming", "source", "template"]
}