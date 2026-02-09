import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

authServiceInstance = comp.Component {
    id = "auth-service-instance"
    name = "Customer Auth Service"
    description = "Authentication service for customer platform"
    productId = "customer-api-platform"
    kind = "service"
    runtime = "kubernetes"
    version = "2.1.0"
    template = "auth-service-v2"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "auth-api"
            componentId = "auth-service-instance"
            description = "Authentication gRPC API"
            direction = "bidirectional"
            portType = "service"
            protocol = "grpc"
            openApiSpec = "https://api.example.com/protos/auth.proto"
            authentication = "mtls"
            classification = "internal"
            sla = {
                "availability": "99.95%"
                "latency_p99": "50ms"
            }
        }
    ]

    config = {
        "jwt.secret.name": "auth-jwt-secret"
        "jwt.expiry.minutes": "60"
        "session.timeout.minutes": "480"
        "mfa.enabled": "true"
    }

    tags = ["microservice", "authentication", "security"]
}
