import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.component as comp
import cdmesh_api.discovery.port

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
