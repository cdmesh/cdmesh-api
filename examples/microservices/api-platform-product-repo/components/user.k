import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

userServiceInstance = comp.Component {
    id = "user-service-instance"
    name = "User Management Service"
    description = "User CRUD operations and profile management"
    productId = "customer-api-platform"
    kind = "service"
    runtime = "kubernetes"
    version = "1.5.0"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "user-api"
            componentId = "user-service-instance"
            description = "User management REST API"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/user/openapi.yaml"
            authentication = "jwt"
            classification = "internal"
            sla = {
                "availability": "99.9%"
                "latency_p95": "200ms"
            }
        },
        port.Port {
            name = "auth-client"
            componentId = "user-service-instance"
            description = "Client connection to auth service"
            direction = "output"
            portType = "service"
            protocol = "grpc"
        }
    ]

    config = {
        "database.url": "postgresql://users-db:5432/users"
        "cache.enabled": "true"
        "cache.ttl.seconds": "300"
    }

    dependsOn = ["auth-service-instance"]
    tags = ["microservice", "user-management", "PII"]
}
