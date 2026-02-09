import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.edge as edge
import cdmesh_api.discovery.port as port
import cdmesh_api.discovery.product as prod

import ..components.gateway as gateway
import ..components.auth as auth
import ..components.user as user
import ..components.notification as notification

apiGateway = gateway.apiGatewayInstance
authService = auth.authServiceInstance
userService = user.userServiceInstance
notificationService = notification.notificationServiceInstance

customerAPIPlatform = prod.Product {
    id = "customer-api-platform"
    name = "Customer API Platform"
    description = "Microservices platform for customer management"
    domainId = "identity-domain"
    kind = "api"
    version = "2.0.0"
    status = "live"
    owner = "platform-team"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    # Service composition
    components = [
        apiGateway.id,
        authService.id,
        userService.id,
        notificationService.id
    ]

    # Service call graph (dependencies)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = apiGateway.id
            sourcePort = "auth-route"
            targetComponent = authService.id
            targetPort = "auth-api"
            metadata = {
                "circuit_breaker": "enabled"
                "retry_policy": "exponential_backoff"
            }
        },
        edge.ComponentEdge {
            sourceComponent = apiGateway.id
            sourcePort = "user-route"
            targetComponent = userService.id
            targetPort = "user-api"
            metadata = {
                "circuit_breaker": "enabled"
                "timeout_ms": "5000"
            }
        },
        edge.ComponentEdge {
            sourceComponent = apiGateway.id
            sourcePort = "notification-route"
            targetComponent = notificationService.id
            targetPort = "notification-api"
            metadata = {
                "async": "true"
                "queue": "notifications"
            }
        },
        edge.ComponentEdge {
            sourceComponent = userService.id
            sourcePort = "auth-client"
            targetComponent = authService.id
            targetPort = "auth-api"
            metadata = {
                "purpose": "token_validation"
            }
        }
    ]

    # Product exposes unified public API
    ports = [
        port.Port {
            name = "public-api"
            description = "Unified customer management API"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/customer-mgmt/openapi.yaml"
            authentication = "oauth2"
            classification = "public"
            sla = {
                "availability": "99.95%"
                "latency_p95": "300ms"
                "rate_limit": "1000 req/s"
            }
        }
    ]

    dependsOn = []

    tags = ["microservices", "api-platform", "PII"]
}
