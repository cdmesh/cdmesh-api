# Microservices API Platform Example

This example demonstrates a **composite product** composed of multiple microservice components implementing a modern microservices architecture with API gateway pattern.

## Architecture

```
Product: Customer API Platform
├── Component: API Gateway (Kong)
│   ├── Input Port: Public HTTPS endpoint
│   └── Output Ports: Routes to internal services
├── Component: Auth Service (gRPC)
│   └── Bidirectional Port: Authentication API
├── Component: User Service (REST)
│   ├── Bidirectional Port: User management API
│   └── Output Port: Auth client (depends on auth-service)
└── Component: Notification Service (REST)
    └── Bidirectional Port: Notification API
```

## Modular Structure

This example follows the **convention-over-configuration** pattern with separate repositories for each level of the hierarchy:

```
microservices/
├── platform-org-repo/           # Organization (Platform Corporation)
│   ├── discovery/platform-org.k
│   └── kcl.mod
├── api-mesh-repo/               # Mesh (API Service Mesh)
│   ├── discovery/api-mesh.k
│   └── kcl.mod
├── identity-domain-repo/        # Domain (Identity & Access Management)
│   ├── discovery/identity.k
│   └── kcl.mod
├── api-platform-product-repo/   # Product (Customer API Platform)
│   ├── discovery/product.k
│   ├── components/
│   │   ├── gateway.k           # API Gateway instance
│   │   ├── auth.k              # Auth Service instance
│   │   ├── user.k              # User Service instance
│   │   └── notification.k      # Notification Service instance
│   └── kcl.mod
└── kubernetes-components-repo/  # Reusable K8s component templates
    ├── service/
    │   ├── api-gateway.k       # API Gateway template
    │   └── auth-service.k      # Auth Service template
    └── kcl.mod
```

## Key Patterns Demonstrated

### 1. **Module Imports**
Each repository imports from parent levels:
- `api-mesh-repo` imports from `platform-org-repo`
- `identity-domain-repo` imports from `api-mesh-repo`
- `api-platform-product-repo` imports from `identity-domain-repo` and `kubernetes-components-repo`

### 2. **Component Reusability**
- **Templates** (`kubernetes-components-repo`): Reusable component definitions with parameterized configurations
- **Instances** (`api-platform-product-repo/components/`): Concrete implementations referencing templates

### 3. **Service Composition**
The product defines:
- **Components**: List of microservice IDs
- **Component Graph**: Service-to-service dependencies (API Gateway → Auth → User → Notification)
- **Ports**: Unified public API exposed externally

### 4. **Governance Cascade**
Policies flow from Organization → Mesh → Domain → Product → Component

## Running the Example

Compile and validate the product:

```bash
cd api-platform-product-repo
kcl run discovery/product.k
```

Export to YAML (Kubernetes manifests):

```bash
kcl run discovery/product.k -o kubernetes.yaml
```

Export to JSON (Terraform):

```bash
kcl run discovery/product.k -o terraform.json
```

## Module Dependencies

```
platform-org → cdmesh-api
api-mesh → platform-org, cdmesh-api
identity-domain → api-mesh, cdmesh-api
api-platform-product → identity-domain, kubernetes-components, cdmesh-api
kubernetes-components → cdmesh-api
```

## Technologies

- **Runtime**: Kubernetes
- **API Gateway**: Kong
- **Auth**: gRPC with mTLS
- **Services**: REST APIs with JWT authentication
- **Patterns**: Service mesh, circuit breakers, retry policies

## Next Steps

1. Add more component templates (e.g., gRPC services, GraphQL APIs)
2. Implement policy mixins for microservices governance (rate limiting, circuit breakers)
3. Add observability components (Prometheus, Grafana)
4. Generate Kubernetes manifests and Helm charts
