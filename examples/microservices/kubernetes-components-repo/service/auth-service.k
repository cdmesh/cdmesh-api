import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

authServiceTemplate = comp.Component {
    id = "auth-service-v2"
    name = "Authentication Service"
    description = "gRPC authentication and authorization service"
    kind = "service"
    runtime = "kubernetes"
    version = "2.1.0"
    reusable = True
    template = Undefined

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "auth-api"
            description = "Authentication gRPC API"
            direction = "bidirectional"
            portType = "service"
            protocol = "grpc"
            openApiSpec = "PARAM"  # Parameterized
            authentication = "mtls"
        }
    ]

    tags = ["microservice", "authentication", "template"]
}
