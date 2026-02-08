# Deployment Schemas

**Module**: `deploy/`
**Schemas**: `DeploymentSpec`, `SourceRepository`
**Files**: `deploy/spec.k`, `deploy/repository.k`

## Overview

The `deploy` module defines schemas for operational deployment and source code management in the Composable Mesh Architecture (CMA). These schemas enable **GitOps-driven infrastructure provisioning** and support the **Self-Serve Data Platform** principle from Data Mesh.

The deployment schemas follow Domain-Driven Design patterns:
- **DeploymentSpec**: Specification Object (part of MeshNode aggregate)
- **SourceRepository**: Value Object (immutable descriptor)

Together, they provide a declarative, version-controlled approach to infrastructure management, where deployment configuration is co-located with application code in Git repositories.

## DeploymentSpec: Operational Context

### Design Philosophy

**DeploymentSpec** defines the operational context and source configuration for a MeshNode. It describes **"how"** and **"where"** a mesh entity is deployed, without having independent identity or lifecycle.

In DDD terms, DeploymentSpec is a **Specification Object**:
- Belongs to the MeshNode aggregate
- Has no independent identity
- Cannot exist outside its parent MeshNode
- Encapsulates deployment logic and configuration

### Architecture

DeploymentSpec is embedded in every MeshNode:

```
MeshNode
├── id
├── name
├── deployment: DeploymentSpec ✓
│   ├── environment
│   ├── source: SourceRepository
│   ├── region (optional)
│   ├── encryption (optional)
│   └── accessLogging (optional)
└── ...
```

**Key Characteristics**:
- **Part-of relationship**: DeploymentSpec is part of MeshNode, not a separate entity
- **Specification pattern**: Defines "how" to deploy, not "what" to deploy
- **Single responsibility**: Operational configuration only
- **GitOps-ready**: Source repository reference enables automated synchronization

### Key Attributes

#### environment (required)

Defines the deployment target environment:
- **production**: Live production environment
- **staging**: Pre-production staging environment
- **development**: Development/testing environment
- **custom**: Any custom environment name (e.g., "qa", "demo", "sandbox")

**Purpose**:
- Environment-specific configuration (different for dev/staging/prod)
- Resource isolation (separate infrastructure per environment)
- Access control (different permissions per environment)
- Cost management (track spending by environment)

**Example**:
```kcl
deployment = DeploymentSpec {
    environment = "production"
}
```

#### source (optional)

Reference to the Git repository containing the component's source code.

**Type**: `SourceRepository` (Value Object)

**Purpose**:
- GitOps synchronization (automated deployment from Git)
- Version control (track changes over time)
- Audit trail (who changed what, when)
- Disaster recovery (restore from Git history)

**When to use**:
- All production deployments (enable GitOps)
- Automated CI/CD pipelines (trigger on Git push)
- Infrastructure as Code (Terraform, Pulumi, Crossplane)
- Configuration management (Helm charts, Kustomize)

**When to omit**:
- Ephemeral testing (temporary deployments)
- Manual deployments (no Git integration)
- External systems (source not in Git)

**Example**:
```kcl
deployment = DeploymentSpec {
    environment = "production"
    source = SourceRepository {
        url = "https://github.com/my-org/customer-api"
        branch = "main"
        path = "services/customer-api"
    }
}
```

#### region (optional, future)

Cloud provider region for deployment (e.g., "us-east-1", "eu-west-1", "ap-southeast-2").

**Purpose**:
- Geographic distribution (low-latency access)
- Data sovereignty (comply with regional regulations)
- Disaster recovery (multi-region failover)
- Cost optimization (cheaper regions)

#### encryption (optional, future)

Encryption configuration for data at rest and in transit.

**Purpose**:
- Compliance (GDPR, PCI-DSS, HIPAA)
- Security (protect sensitive data)
- Policy enforcement (validate encryption requirements)

**Triggered by tags**:
- `PII`: PIIMixin enforces `encryption.atRest = true`
- `PCI-DSS`: PCIDSSMixin enforces `encryption.atRest = true`

#### accessLogging (optional, future)

Access logging configuration for audit trails.

**Purpose**:
- Compliance (SOC 2, PCI-DSS)
- Security monitoring (detect anomalies)
- Debugging (trace access patterns)

**Triggered by tags**:
- `PII`: PIIMixin enforces `accessLogging.enabled = true`
- `SOC2`: SOC2Mixin enforces `accessLogging.enabled = true`

### Use Cases

#### Use Case 1: GitOps-Driven Deployment

**Scenario**: Automated deployment from Git repository on every merge to main.

**Solution**:
```kcl
product = Product {
    id = "customer-api"
    name = "Customer API"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/customer-api"
            branch = "main"
            tag = "v1.2.3"
        }
    }
}
```

**Benefits**:
- Automated CI/CD (GitHub Actions, GitLab CI, Argo CD)
- Version control (rollback to previous commit)
- Audit trail (Git commit history)
- Consistency (single source of truth)

#### Use Case 2: Environment-Specific Configuration

**Scenario**: Different configurations for dev, staging, and production environments.

**Solution**:
```kcl
# Development environment
devProduct = Product {
    id = "customer-api-dev"
    deployment = DeploymentSpec {
        environment = "development"
        source = SourceRepository {
            url = "https://github.com/my-org/customer-api"
            branch = "develop"  # Deploy from develop branch
        }
    }
}

# Production environment
prodProduct = Product {
    id = "customer-api"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/customer-api"
            branch = "main"  # Deploy from main branch
            tag = "v1.2.3"  # Pin to specific release
        }
    }
}
```

**Benefits**:
- Environment isolation (dev changes don't affect prod)
- Branch-based deployment (develop → dev, main → prod)
- Version pinning (prod uses tagged releases)

#### Use Case 3: Monorepo with Path-Based Deployment

**Scenario**: Multiple components in a single Git repository.

**Solution**:
```kcl
componentA = Component {
    id = "auth-service"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/platform"
            branch = "main"
            path = "services/auth"  # Deploy only auth service
        }
    }
}

componentB = Component {
    id = "user-service"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/platform"
            branch = "main"
            path = "services/user"  # Deploy only user service
        }
    }
}
```

**Benefits**:
- Monorepo support (single repo, multiple services)
- Independent deployment (deploy auth without user)
- Shared codebase (common libraries in same repo)

## SourceRepository: Git Integration

### Design Philosophy

**SourceRepository** defines the Git repository location and access configuration for component source code. It is a **Value Object** in DDD terms:

- **Immutable**: Once created, values don't change
- **No identity**: Two repositories are equal if all attributes match
- **Part of aggregate**: Embedded in DeploymentSpec
- **Self-describing**: Contains all information needed to clone the repo

### Architecture

SourceRepository is embedded in DeploymentSpec:

```
DeploymentSpec
├── environment
└── source: SourceRepository ✓
    ├── url (required)
    ├── branch (optional)
    ├── tag (optional)
    ├── path (optional)
    ├── sshHostFingerprint (optional)
    └── sshPrivateKey (optional)
```

### Key Attributes

#### url (required)

Git repository URL.

**Supported formats**:
- HTTPS: `https://github.com/my-org/my-repo`
- SSH: `git@github.com:my-org/my-repo.git`
- Git protocol: `git://github.com/my-org/my-repo`

**Purpose**:
- Clone repository (git clone)
- Fetch updates (git fetch, git pull)
- Identify repository (unique URL)

#### branch (optional)

Git branch name.

**Examples**: `main`, `develop`, `feature/new-api`, `release/1.2.x`

**Purpose**:
- Branch-based deployment (deploy from specific branch)
- Environment mapping (develop → dev, main → prod)
- Feature branches (test in isolation)

**Default**: If omitted, uses repository's default branch (usually `main` or `master`)

#### tag (optional)

Git tag name (usually a version tag).

**Examples**: `v1.2.3`, `release-2024-01`, `latest`

**Purpose**:
- Version pinning (deploy specific release)
- Immutable deployments (tag doesn't change)
- Rollback (revert to previous tag)

**Best practice**: Use tags for production deployments to ensure consistency.

#### path (optional)

Relative path within the repository.

**Examples**: `services/customer-api`, `components/auth`, `terraform/modules/database`

**Purpose**:
- Monorepo support (multiple components in one repo)
- Subdirectory deployment (deploy only part of repo)
- Workspace isolation (separate concerns)

**Default**: If omitted, uses repository root.

#### sshHostFingerprint (optional)

SSH public host fingerprint for secure connection.

**Format**: Base64-encoded SSH host key fingerprint

**Purpose**:
- Verify SSH host identity (prevent man-in-the-middle attacks)
- Secure private repository access
- Automated deployments (no manual host verification)

**When to use**:
- Private repositories over SSH
- Automated CI/CD pipelines
- High-security environments

#### sshPrivateKey (optional)

SSH private key for authentication to private repositories.

**Format**: Base64-encoded SSH private key or reference to secret manager

**Purpose**:
- Authenticate to private repositories
- Automated deployments (no interactive login)
- Service account access (non-human user)

**Security considerations**:
- **NEVER commit private keys to Git**
- Use secret management (HashiCorp Vault, AWS Secrets Manager, Kubernetes Secrets)
- Rotate keys regularly
- Use deploy keys (read-only access)

**Best practice**: Store reference to secret, not the key itself:
```kcl
source = SourceRepository {
    url = "git@github.com:my-org/private-repo.git"
    sshPrivateKey = "ref://secrets-manager/github-deploy-key"  # Reference, not actual key
}
```

### Use Cases

#### Use Case 1: Public Repository (HTTPS)

**Scenario**: Deploy from public GitHub repository.

**Solution**:
```kcl
deployment = DeploymentSpec {
    environment = "production"
    source = SourceRepository {
        url = "https://github.com/my-org/open-source-api"
        branch = "main"
        tag = "v2.1.0"
    }
}
```

**Benefits**:
- No authentication required
- Easy to clone and test
- Community contributions

#### Use Case 2: Private Repository (SSH)

**Scenario**: Deploy from private repository with SSH authentication.

**Solution**:
```kcl
deployment = DeploymentSpec {
    environment = "production"
    source = SourceRepository {
        url = "git@github.com:my-org/proprietary-api.git"
        branch = "main"
        sshHostFingerprint = "AAAAB3NzaC1yc2EAAAADAQABAAAB..."
        sshPrivateKey = "ref://vault/github-deploy-key"  # Secret reference
    }
}
```

**Benefits**:
- Secure access to private code
- Automated deployment (no manual login)
- Audit trail (who accessed what)

#### Use Case 3: Monorepo with Multiple Components

**Scenario**: Multiple microservices in a single repository.

**Solution**:
```kcl
authService = Component {
    id = "auth-service"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/platform"
            branch = "main"
            path = "services/auth"
        }
    }
}

userService = Component {
    id = "user-service"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/platform"
            branch = "main"
            path = "services/user"
        }
    }
}
```

**Benefits**:
- Single repository (easier to manage)
- Independent deployment (deploy auth without user)
- Code reuse (shared libraries in same repo)

#### Use Case 4: Branch-Based Environments

**Scenario**: Automatic deployment to dev environment on push to `develop` branch.

**Solution**:
```kcl
# Dev environment (deploy from develop branch)
devProduct = Product {
    id = "api-dev"
    deployment = DeploymentSpec {
        environment = "development"
        source = SourceRepository {
            url = "https://github.com/my-org/api"
            branch = "develop"
        }
    }
}

# Staging environment (deploy from release branch)
stagingProduct = Product {
    id = "api-staging"
    deployment = DeploymentSpec {
        environment = "staging"
        source = SourceRepository {
            url = "https://github.com/my-org/api"
            branch = "release/1.2.x"
        }
    }
}

# Production environment (deploy from tagged release)
prodProduct = Product {
    id = "api"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/api"
            branch = "main"
            tag = "v1.2.3"
        }
    }
}
```

**Benefits**:
- Automated workflows (push to develop → deploy to dev)
- Environment consistency (same code path: dev → staging → prod)
- Version control (tagged releases for prod)

## GitOps Integration

### GitOps Workflow

DeploymentSpec + SourceRepository enable **GitOps workflows**:

1. **Developer**: Commits code to Git repository
2. **CI/CD**: Detects change, builds artifacts
3. **Platform**: Reads DeploymentSpec from CDMesh catalog
4. **Sync Engine**: Clones SourceRepository, deploys to environment
5. **Monitoring**: Tracks deployment status, sends notifications

```mermaid
graph LR
    Dev[Developer] -->|git push| Repo[Git Repository]
    Repo -->|webhook| CI[CI/CD Pipeline]
    CI -->|build| Artifact[Container Image]
    CI -->|update| Catalog[CDMesh Catalog]
    Catalog -->|read| Sync[Sync Engine]
    Sync -->|clone| Repo
    Sync -->|deploy| Env[Environment]
    Env -->|metrics| Monitor[Monitoring]
    Monitor -->|alert| Dev

    style Repo fill:#F39C12,stroke:#D68910,color:#fff
    style Catalog fill:#3498DB,stroke:#2980B9,color:#fff
    style Sync fill:#9B59B6,stroke:#8E44AD,color:#fff
    style Env fill:#1ABC9C,stroke:#16A085,color:#fff
```

### Platform Adapters

DeploymentSpec can be consumed by various platform adapters:

| Platform | Adapter | Deployment Method |
|----------|---------|-------------------|
| Kubernetes | K8s Adapter | Generate Deployment/Service manifests |
| Databricks | Databricks Adapter | Submit jobs via Databricks API |
| Airflow | Airflow Adapter | Create DAGs from component definitions |
| Terraform | Terraform Adapter | Generate .tf files for infrastructure |
| Crossplane | Crossplane Adapter | Create Composition/XRD resources |

**Example: Kubernetes Adapter**
```kcl
# CDMesh Product
product = Product {
    id = "customer-api"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/customer-api"
            tag = "v1.2.3"
        }
    }
}

# Adapter generates Kubernetes manifests:
# ---
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: customer-api
# spec:
#   replicas: 3
#   template:
#     spec:
#       containers:
#       - name: api
#         image: ghcr.io/my-org/customer-api:v1.2.3
```

## Data Mesh Principle: Self-Serve Platform

DeploymentSpec supports the **Self-Serve Data Platform** principle from Data Mesh:

### Declarative Configuration

Users declare **what** they want to deploy, not **how** to deploy it:

```kcl
# User declares intent
product = Product {
    id = "customer-analytics"
    deployment = DeploymentSpec {
        environment = "production"
        source = SourceRepository {
            url = "https://github.com/my-org/analytics"
            branch = "main"
        }
    }
}

# Platform automatically:
# - Clones repository
# - Builds container image
# - Deploys to Kubernetes
# - Configures monitoring
# - Sets up access controls
```

### Self-Service Deployment

Domain teams can deploy products independently:

- **No platform team involvement**: Automated deployment from Git
- **No manual configuration**: Platform derives infrastructure from DeploymentSpec
- **No operational overhead**: Platform handles scaling, monitoring, backups

### GitOps-Managed Infrastructure

All changes are version-controlled:

- **Audit trail**: Who changed what, when
- **Rollback**: Revert to previous commit
- **Consistency**: Single source of truth (Git)
- **Collaboration**: Code review via pull requests

## Best Practices

### 1. Use Environment-Specific Branches

Map Git branches to environments:
```kcl
# Dev: deploy from develop branch
environment = "development"
branch = "develop"

# Staging: deploy from release branch
environment = "staging"
branch = "release/1.2.x"

# Prod: deploy from main branch with tag
environment = "production"
branch = "main"
tag = "v1.2.3"
```

### 2. Pin Production to Tags

Always use tags for production:
```kcl
✅ Good: tag = "v1.2.3"  # Immutable, specific version
❌ Bad:  branch = "main"  # Mutable, can change
```

### 3. Use Monorepo Paths

Organize components in subdirectories:
```kcl
✅ Good: path = "services/auth"  # Clear structure
❌ Bad:  path = ""  # Root of repo
```

### 4. Secure Private Keys

Never commit SSH keys to Git:
```kcl
✅ Good: sshPrivateKey = "ref://vault/deploy-key"  # Secret reference
❌ Bad:  sshPrivateKey = "-----BEGIN RSA PRIVATE KEY-----..."  # Actual key
```

### 5. Use Deploy Keys

Create read-only deploy keys for repositories:
```bash
# Generate deploy key (read-only)
ssh-keygen -t ed25519 -C "deploy@cdmesh-platform" -f deploy_key

# Add public key to GitHub (Settings > Deploy keys)
# Check "Allow read access"

# Store private key in secret manager
vault write secret/github/deploy-key value=@deploy_key
```

## Validation Rules

DeploymentSpec enforces these rules:

1. **Required environment**: Must be provided
2. **Valid repository URL**: If `source` is provided, `url` is required
3. **Branch OR tag**: Can specify both, but at least one is recommended for production
4. **Valid SSH keys**: If SSH authentication is used, both host fingerprint and private key should be provided

## Integration with Other Schemas

### MeshNode Integration

Every MeshNode has a `deployment` attribute:
- Organization, Mesh, Domain, Product, Component all include DeploymentSpec
- Enables environment-specific configuration
- Supports GitOps workflows

### Policy Integration

DeploymentSpec attributes can be validated by policies:
```kcl
# Example: Enforce production encryption
Policy {
    id = "prod-encryption-required"
    constraints = [
        Constraint {
            expression = "deployment.environment == 'production' implies deployment.encryption.atRest == true"
            message = "Production deployments must enable encryption at rest"
        }
    ]
}
```

## Related Documentation

- **[Architecture Overview](../architecture.md)** - Comprehensive architecture documentation
- **[Core Schemas](core.md)** - MeshNode base schema
- **[Discovery Schemas](discovery.md)** - Organization, Mesh, Domain, Product, Component
- **[Governance Schemas](governance.md)** - Policy validation for deployment configuration

---

**Schema Locations**: `deploy/spec.k`, `deploy/repository.k`
**DDD Patterns**: Specification Object (DeploymentSpec), Value Object (SourceRepository)
**Data Mesh Principle**: Self-Serve Data Platform
