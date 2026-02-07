"""
Example: Microservices API Platform Composite Product

This example demonstrates a composite product composed of multiple
service components implementing a microservices architecture.

Architecture:
------------
Product: Customer API Platform
├── Component: API Gateway
│   ├── Input Port: Public HTTP endpoint
│   └── Output Ports: Routes to internal services
├── Component: Auth Service (gRPC)
│   └── Bidirectional Port: Authentication API
├── Component: User Service (REST)
│   ├── Bidirectional Port: User management API
│   └── Output Port: Auth client (depends on auth-service)
└── Component: Notification Service (REST)
    └── Bidirectional Port: Notification API

Pattern: Microservices with service mesh
"""

import ..discovery.organization as org
import ..discovery.mesh
import ..discovery.domain
import ..discovery.product as prod
import ..discovery.component as comp
import ..discovery.edge
import ..discovery.port
import ..deploy.spec as deploy

# ========================================
# Hierarchy
# ========================================

acmeOrg = org.Organization {
    id = "acme-corp"
    name = "Acme Corporation"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

serviceMesh = mesh.Mesh {
    id = "service-mesh"
    name = "Acme Service Mesh"
    organizationId = "acme-corp"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

customerDomain = domain.Domain {
    id = "customer-domain"
    name = "Customer Domain"
    meshId = "service-mesh"
    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}

# ========================================
# Component Templates (Reusable Services)
# ========================================

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

# ========================================
# Component Instances (Configured Services)
# ========================================

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

notificationServiceInstance = comp.Component {
    id = "notification-service-instance"
    name = "Notification Service"
    description = "Email and push notification service"
    productId = "customer-api-platform"
    kind = "service"
    runtime = "kubernetes"
    version = "1.2.0"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    ports = [
        port.Port {
            name = "notification-api"
            componentId = "notification-service-instance"
            description = "Notification API"
            direction = "bidirectional"
            portType = "service"
            protocol = "rest"
            openApiSpec = "https://api.example.com/notification/openapi.yaml"
            authentication = "jwt"
            classification = "internal"
        }
    ]

    config = {
        "email.provider": "sendgrid"
        "push.provider": "firebase"
        "queue.url": "sqs://notifications-queue"
    }

    tags = ["microservice", "notifications"]
}

# ========================================
# Composite Product (Microservices Platform)
# ========================================

customerAPIPlatform = prod.Product {
    id = "customer-api-platform"
    name = "Customer API Platform"
    description = "Microservices platform for customer management"
    domainId = "customer-domain"
    kind = "api"
    version = "2.0.0"
    status = "live"
    owner = "platform-team"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }

    # Service composition
    components = [
        "api-gateway-1",
        "auth-service-instance",
        "user-service-instance",
        "notification-service-instance"
    ]

    # Service call graph (dependencies)
    componentGraph = [
        edge.ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "auth-route"
            targetComponent = "auth-service-instance"
            targetPort = "auth-api"
            metadata = {
                "circuit_breaker": "enabled"
                "retry_policy": "exponential_backoff"
            }
        },
        edge.ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "user-route"
            targetComponent = "user-service-instance"
            targetPort = "user-api"
            metadata = {
                "circuit_breaker": "enabled"
                "timeout_ms": "5000"
            }
        },
        edge.ComponentEdge {
            sourceComponent = "api-gateway-1"
            sourcePort = "notification-route"
            targetComponent = "notification-service-instance"
            targetPort = "notification-api"
            metadata = {
                "async": "true"
                "queue": "notifications"
            }
        },
        edge.ComponentEdge {
            sourceComponent = "user-service-instance"
            sourcePort = "auth-client"
            targetComponent = "auth-service-instance"
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
