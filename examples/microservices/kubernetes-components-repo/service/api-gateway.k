import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

apiGatewayTemplate = comp.Component {
    id = "api-gateway-v1"
    name = "API Gateway"
    description = "Kong API Gateway for routing and rate limiting"
    kind = "service"
    runtime = "kubernetes"
    version = "1.0.0"
    reusable = True
    template = Undefined

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "public-endpoint"
            description = "Public HTTP/HTTPS endpoint"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            authentication = "api-key"
        },
        port.Port {
            name = "service-routes"
            description = "Routes to internal services"
            direction = "output"
            portType = "service"
            protocol = "http"
        }
    ]

    tags = ["gateway", "routing", "template"]
}
