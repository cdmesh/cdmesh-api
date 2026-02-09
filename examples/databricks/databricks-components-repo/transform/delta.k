import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

databricksDeltaTransform = comp.Component {
    id = "databricks-delta-transform"
    name = "Delta Table Transformation"
    description = "Batch transformation of Delta tables"
    kind = "transformation"
    runtime = "databricks"
    version = "2.0.0"
    reusable = True
    template = Undefined  # This IS a template

    deployment = deploy.DeploymentSpec {
        environment = "dev"
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