import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

apiGatewayInstance = comp.Component {
    id = "api-gateway-1"
    name = "Customer API Gateway"
    description = "API Gateway for customer management platform"
    productId = "customer-api-platform"
    kind = "service"
    runtime = "kubernetes"
    version = "1.0.0"
    template = "api-gateway-v1"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "public-endpoint"
            componentId = "api-gateway-1"
            description = "Public HTTPS endpoint"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/gateway/openapi.yaml"
            authentication = "oauth2"
            classification = "public"
            sla = {
                "availability": "99.99%"
                "latency_p95": "100ms"
            }
        },
        port.Port {
            name = "auth-route"
            componentId = "api-gateway-1"
            direction = "output"
            portType = "service"
            protocol = "grpc"
        },
        port.Port {
            name = "user-route"
            componentId = "api-gateway-1"
            direction = "output"
            portType = "service"
            protocol = "http"
        },
        port.Port {
            name = "notification-route"
            componentId = "api-gateway-1"
            direction = "output"
            portType = "service"
            protocol = "http"
        }
    ]

    config = {
        "rate_limit.requests_per_second": "1000"
        "rate_limit.burst": "2000"
        "cors.enabled": "true"
        "logging.level": "info"
    }

    tags = ["gateway", "routing", "public"]
}
