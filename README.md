# CDMesh API

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![KCL](https://img.shields.io/badge/KCL-v0.11.2-green.svg)](https://kcl-lang.io)
[![Version](https://img.shields.io/badge/version-0.2.1--alpha-orange.svg)](https://github.com/yourusername/cdmesh-api/releases)

> **⚠️ Early Development Notice**
>
> CDMesh API is currently in the early alpha stage (v0.2.1-alpha). The API specification is under active development and
> subject to breaking changes. This project is intended for research, experimentation, and early feedback. Production use
> is not recommended at this stage.

## Overview

**CDMesh API** is a Contract-Driven Mesh API specification implementing **Composable Mesh Architecture (CMA)**. It
provides a universal abstraction that unifies data products, microservices, event streams, and ML pipelines under a
single governance framework using executable schemas.

The project combines:

- **Data Mesh principles**: Domain Ownership, Data as a Product, Self-Serve Platform, Federated Governance
- **Domain-Driven Design patterns**: Aggregate Roots, Value Objects, Specification Objects, Bounded Contexts
- **Composable architecture**: Unified abstraction for heterogeneous resources with O(D) governance complexity

### The Problem

Modern data platforms face a critical governance challenge: as organizations scale to thousands of data products and
services, traditional tuple-based governance systems require O(T) operations for policy updates, where T is the number of tuples. 
This creates bottlenecks in compliance, security, and operational efficiency.

### The Solution

CDMesh API implements **Composable Mesh Architecture (CMA)** with three foundational pillars:

1. **Semantic Driven Design (SDD)**: KCL schemas as executable ontologies with RDF/OWL integration
2. **Contract Driven Infrastructure (CDI)**: Infrastructure derived from contracts with federated policy inheritance
   achieving O(D) complexity where D ≈ 4
3. **Contract Driven Lifecycle (CDL)**: Compile-time governance verification with shift-left validation

## Composable Mesh Architecture Vision

CMA represents a paradigm evolution from "governance management" to **"governance engineering"** – positioning CDMesh API as an open-source standard for AI-first distributed applications.

### 1. Governance Programming DSL
Transform governance from configuration to **executable code** with:
- Policy mixins as **composable governance modules**
- Lambda-based constraints for dynamic computation
- Smart defaults via context-aware governance
- Shift from "what policies exist" to "how policies compute"

### 2. KCL Modular Ecosystem
Build a reusable component marketplace with:
- Organization modules as **reusable governance packages**
- Domain modules as **business capability libraries**
- Provider-specific abstractions (GCP, AWS, Azure, Databricks, Snowflake)
- Convention-over-configuration repository structure
- OCI registry for module publishing and versioning

### 3. Contract Driven Lifecycle (CDL)
Expand beyond infrastructure to **full project lifecycle**:
- Generate Agile artifacts (epics, stories, Definition of Ready)
- Support all phases: plan → build → deploy → govern → operate

### 4. AI-First Architecture
Enable autonomous governance through AI:
- Knowledge Graph construction from semantic metadata
- GraphRAG integration for AI agent reasoning
- Declarative DSL as **semantic context** for LLM agents
- Automated governance validation through AI-assisted checks

### 5. Multi-Cloud & Portability
Achieve true vendor-agnostic abstractions:
- Single contract → multiple cloud deployments
- Provider modules for cloud portability (AWS, GCP, Azure, Databricks)
- Export to YAML, JSON, OpenAPI, Terraform, ODCS
- Industry alignment with emerging standards (MCP, A2A protocols)

## Why KCL for CMA DSL

CDMesh API is built with **KCL (Kubernetes Configuration Language)** to solve critical limitations of YAML-based configuration management.

### YAML Limitations

Traditional YAML configurations suffer from:
- ❌ **No Modularity** – Monolithic 1000+ line files with massive duplication
- ❌ **No Programming Constructs** – No variables, functions, conditionals, or loops
- ❌ **Runtime-Only Validation** – Errors discovered at deployment time (minutes/hours)
- ❌ **No Semantic Layer** - Cannot model relationships or data lineage
- ❌ **Fragmented Tooling** – Different templating for each use case (Helm, Jinja2, etc.)

### KCL Advantages

KCL provides:
- ✅ **True Modularity** - Project-based structure with `kcl.mod` and dependency management
- ✅ **Full Programming** – Lambdas, conditionals, loops, type checking, inheritance
- ✅ **Compile-Time Validation** – Fast feedback (seconds) with shift-left governance
- ✅ **Rich Semantics** – RDF integration for knowledge graphs and AI reasoning
- ✅ **Universal Export** – Generate YAML, JSON, OpenAPI, ODCS, Terraform from single source
- ✅ **Multi-Language SDKs** – Python, Go, Java, Node.js, Rust for tool integration

### Example: Reusability

**YAML (copy-paste for every service):**
```yaml
# Repeated for EVERY microservice
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-a
  labels:
    app: service-a
# ... 50+ lines duplicated
```

**KCL (reusable module):**
```kcl
# Define once, import everywhere
import kubernetes_components.service.rest_api as api

myService = api.restApiTemplate {
    name = "service-a"
}
```

### Export Compatibility

KCL maintains **full backward compatibility**:

```bash
# Compile KCL to YAML for Kubernetes
kcl run product.k -o kubernetes.yaml

# Compile KCL to JSON for Terraform
kcl run product.k -o terraform.json

# Compile KCL to OpenAPI spec
kcl run product.k -o openapi.yaml

# Compile KCL to ODCS contract
kcl run product.k -o odcs-v3.yaml
```

**Learn more**: [KCL Official Website](https://www.kcl-lang.io/)

## Table of Contents

- [Documentation](#documentation)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Usage](#usage)
    - [Command Line Interface](#command-line-interface)
    - [Examples](#examples)
- [Architecture](#architecture)
- [Schema Reference](#schema-reference)
- [Standards Compliance](#standards-compliance)
- [Theoretical Foundation](#theoretical-foundation)
    - [Foundational Papers](#foundational-papers)
    - [Books](#books)
- [Development](#development)
- [What's Next?](#whats-next)
- [Contributing](#contributing)
- [License](#license)

## Documentation

- **[Architecture Overview](docs/architecture.md)** – Comprehensive architecture documentation with domain model,
  hierarchy, and CMA pillars
- **[CDMesh API Reference](docs/cdmesh-api.md)** – Complete API reference generated from KCL schemas
- **Schema Documentation**
    - [Core Schemas](docs/schemas/core.md) – MeshNode base schema and foundational types
    - [Discovery Schemas](docs/schemas/discovery.md) – Organization, Mesh, Domain, Product, Component, Port, Edge
    - [Governance Schemas](docs/schemas/governance.md) – Policy, Constraint, and compliance mixins
    - [Deployment Schemas](docs/schemas/deploy.md) – DeploymentSpec and SourceRepository
    - [Semantic Schemas](docs/schemas/semantics.md) – SemanticMetadata for knowledge graphs

## Getting Started

### Prerequisites

CDMesh API requires the following tools:

1. **KCL (Kubernetes Configuration Language)** – v0.11.2 or later
2. **just** - Command runner for development tasks (optional but recommended)

### Installation

#### Install KCL CLI and Tools

Follow the official KCL installation
guide: [https://www.kcl-lang.io/docs/user_docs/getting-started/install](https://www.kcl-lang.io/docs/user_docs/getting-started/install)

**Quick install (Linux/macOS):**

```bash
curl -fsSL https://kcl-lang.io/script/install-cli.sh | /bin/bash
```

**Verify installation:**

```bash
kcl --version
# Should output: KCL version v0.11.2 or later
```

#### Install just (Optional)

`just` is a command runner that simplifies common tasks.

**Linux/macOS:**

```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
```

**macOS (Homebrew):**

```bash
brew install just
```

**Verify installation:**

```bash
just --version
```

For other platforms, see: [https://github.com/casey/just#installation](https://github.com/casey/just#installation)

#### Clone the Repository

```bash
git clone https://github.com/yourusername/cdmesh-api.git
cd cdmesh-api
```

#### Install Module Dependencies

```bash
kcl mod download
```

## Usage

### Command Line Interface

CDMesh API provides several commands for working with schemas. You can use either `just` commands or direct `kcl`
commands.

#### Generate API Documentation

```bash
just docs-api
```

This generates the complete API reference documentation from KCL schemas to `docs/cdmesh-api.md`.

#### Run Examples

**Databricks ETL Composite Example:**

```bash
just example-databricks
```

Demonstrates a multi-component ETL pipeline with bronze, silver, and gold layers using Databricks.

**Microservices Composite Example:**

```bash
just example-microservices
```

Demonstrates a microservices API platform with service mesh patterns using **multi-repo structure** with module imports.

#### Validate Schemas

```bash
kcl run .
```

Validates all KCL schemas in the project, checking for syntax errors, type mismatches, and constraint violations.

#### Format Code

```bash
kcl fmt <file>.k
```

Formats KCL schema files according to standard conventions.

#### Lint Code

```bash
kcl lint <file>.k
```

Performs static analysis to detect potential issues.

#### Run Tests

```bash
kcl test
```

Executes KCL test suites.

### Examples

The `examples/` directory contains reference implementations demonstrating CMA patterns using **modular multi-repo structure**:

#### Databricks ETL Pipeline (`examples/databricks/`)
Multi-component ETL pipeline with bronze→silver→gold data flow:
- `acme-org-repo/` - Organization definition
- `acme-mesh-repo/` - Data Mesh definition
- `acme-domain-repo/` - Customer domain
- `acme-product-repo/` - ETL Product with component composition
- `databricks-components-repo/` - Reusable Databricks component templates

#### Microservices API Platform (`examples/microservices/`)
Microservices API platform with service mesh composition:
- `platform-org-repo/` - Platform organization
- `api-mesh-repo/` - API service mesh
- `identity-domain-repo/` - Identity & access management domain
- `api-platform-product-repo/` - API platform with microservice composition
- `kubernetes-components-repo/` - Reusable Kubernetes component templates

Each example showcases:

- **Module-based structure** with `kcl.mod` dependencies
- **Governance cascade** from Organization → Mesh → Domain → Product
- **Component reusability** via template + instance pattern
- **Product composition** with multiple components
- **Component graph wiring** with explicit data flow
- **Port-based interfaces** (data/service/event)
- **Convention-over-configuration** repository layout

## Architecture

CDMesh API implements a **6-level hierarchical model**:

```
Organization (Level 0) - Global governance boundary
└── Mesh (Level 1) - Organizational/tenant boundary
    └── Domain (Level 2) - Business capability grouping
        └── Product (Level 3) - Composite business capability
            └── Component (Level 4) - Atomic, reusable building block
                └── Port (Level 5) - Interface boundary (data/service/event)
```

**Key Architectural Concepts:**

- **MeshNode**: Universal base schema for all catalog-managed entities (Aggregate Root pattern)
- **Product Composition**: Products can be atomic (single-component) or composite (multi-component with explicit wiring)
- **Component Reusability**: Template + instance pattern for reusable building blocks
- **Port Polymorphism**: Unified interface abstraction for data, service, and event boundaries
- **Policy Cascading**: O(D) governance propagation via federated inheritance
- **Semantic Integration**: RDF/OWL integration for knowledge graph construction

For detailed architecture documentation, see [docs/architecture.md](docs/architecture.md).

## Schema Reference

CDMesh API schemas are organized into five core modules:

| Module          | Description                                             | Key Schemas                                                     |
|-----------------|---------------------------------------------------------|-----------------------------------------------------------------|
| **core/**       | Base schemas and foundational types                     | MeshNode                                                        |
| **discovery/**  | Catalog-discoverable entities (6-level hierarchy)       | Organization, Mesh, Domain, Product, Component, Port, Edge      |
| **governance/** | Governance policies, constraints, and compliance mixins | Policy, Constraint, PIIMixin, GDPRMixin, PCIDSSMixin, SOC2Mixin |
| **deploy/**     | Deployment and source repository specifications         | DeploymentSpec, SourceRepository                                |
| **semantics/**  | Semantic metadata for knowledge graphs                  | SemanticMetadata                                                |

For complete API reference, see [docs/cdmesh-api.md](docs/cdmesh-api.md).

## Standards Compliance

CDMesh API aligns with multiple industry and academic standards:

### Privacy & Compliance

- **GDPR** (General Data Protection Regulation) – via GDPRMixin
- **CCPA** (California Consumer Privacy Act) – via PIIMixin
- **PCI-DSS** (Payment Card Industry Data Security Standard) – via PCIDSSMixin
- **SOC 2** (Service Organization Control) – via SOC2Mixin

### Data Catalogs & Semantics

- **DCAT 2.0** (W3C Data Catalog Vocabulary) - via SemanticMetadata
- **Schema.org** - Structured data vocabulary
- **SKOS** – Simple Knowledge Organization System

### Component Models

- **Backstage Component** – Aligned with Spotify's Backstage model
- **Crossplane Composition** – Aligned with Crossplane's composition pattern
- **Open Application Model (OAM)** - Aligned with CNCF's OAM specification
- **Terraform Modules** - Template + instance pattern

### Planned Standards

- **ODCS v3.1.0** (Open Data Contract Standard)
- **OpenLineage** – Data lineage tracking
- **W3C PROV** - Provenance vocabulary
- **ReBAC** - Relationship-Based Access Control

## Theoretical Foundation

CDMesh API is grounded in peer-reviewed research and industry best practices.

### Foundational Papers

**Data Mesh & Architecture**

- **Goedegebuure et al. (2023)**: "Data Mesh: a Systematic Gray Literature Review" - *ACM Computing Surveys*
- **van der Werf et al. (2025)**: "Towards a Data Mesh Reference Architecture" – *Springer LNBIP*
- **Kumara et al. (2024)**: "Data Mesh Architecture: From Theory to Practice" – *ICSA 2024 (IEEE)*
- **Dolhopolov et al. (2024)**: "Implementing Federated Governance in Data Mesh Architecture" – *MDPI Future Internet*
- **Brambilla & Plebani (2025)**: "Scalable Policy-as-Code Decision Points for Data Products" - *ICWS 2025 (IEEE)*
- **Pingos et al. (2024)**: "Transforming Data Lakes to Data Meshes Using Semantic Data Blueprints" – *ENASE 2024*
- **Liskov (1987)**: "Data Abstraction and Hierarchy" (Liskov Substitution Principle) - *OOPSLA '87*

**Semantic & Knowledge Graphs**

- **Hogan et al. (2021)**: "Knowledge Graphs" - *ACM Computing Surveys*
- **Moraes et al. (2025)**: "Semantic Data Management in Data Mesh" - *SBBD 2025*
- **Wider et al. (2025)**: "AI-Assisted Data Governance with Data Mesh Manager" – *ICWS 2025 (IEEE)*

**Data Governance Research**

- **Duzha et al. (2023)**: "From Data Governance by Design to Data Governance as a Service"
- **Huber et al. (2024)**: "Datafication Dilemmas: Data Governance in the Public Interest"
- **Keyes et al. (2024)**: "New Ways of Thinking About Data Governance"
- **Vargas-Murillo et al. (2024)**: "Digital Open Data Governance: Enhancing E-Government Accountability"
- **Fu et al. (2025)**: "Data Governance Framework and Intelligent Decision-Making System"
- **Legris et al. (2025)**: "Towards Agile and Transparent Data Management: New Generative AI-Driven Tools"
- **Shen et al. (2025)**: "Data Governance Visualization Application Based on Large Language Models"
- **Zhou et al. (2025)**: "GEME In Government Data Governance: Graph Entropy And Attention Coordination"

### Books

- **"Data Mesh: Delivering Data-Driven Value at Scale"** by Zhamak Dehghani (O'Reilly, 2022)
    - Foundation for domain ownership, data as a product, self-serve platform, and federated governance
- **"Data Contracts: Developing Production-Grade Pipelines at Scale"** by Chad Sanderson (O'Reilly, 2026)
    - Contract-driven development patterns for data platforms

### Design Patterns

- **Evans (2003)**: "Domain-Driven Design" – Aggregate Root, Value Object, Specification Object patterns
- **Gang of Four (1994)**: "Design Patterns" – Composite, Template Method, Strategy patterns

## Development

### Project Structure

```
cdmesh-api/
├── core/              # Base schemas (MeshNode)
├── discovery/         # Catalog entities (Organization, Mesh, Domain, Product, Component, Port, Edge)
├── governance/        # Policies and compliance mixins
├── semantics/         # Semantic metadata
├── deploy/            # Deployment specifications
├── examples/          # Reference implementations
├── docs/              # Documentation
├── kcl.mod            # KCL module configuration
└── justfile           # Command runner recipes

```

### Module Configuration

- **Module name**: `cdmesh-api`
- **KCL edition**: `v0.11.2`
- **Version**: `0.2.1-alpha`
- **Registry**: `oci://ghcr.io/<owner>/cdmesh-api`

### Release Process

Releases are automated via GitHub Actions:

- Tag format: `v*` (e.g., `v0.2.0`)
- Workflow: `.github/workflows/release.yaml`
- Publishes to GitHub Container Registry (GHCR)

## What's Next?

CDMesh API roadmap includes ambitious features to realize the full governance engineering vision:

### Phase 1: Module Ecosystem
- Publish provider modules to the OCI registry (GHCR)
- Create a reusable component marketplace (Databricks, K8s, AWS)
- Establish convention-over-configuration patterns

### Phase 2: Examples Expansion
- ✅ Microservices multi-repo structure (Complete)
- ML Pipeline example with MLOps patterns
- Multi-cloud deployment examples (AWS Data Lake, GCP BigQuery)

### Phase 3: Governance Programming
- Lambda-based constraints in Policy schema
- Context-aware policies (dev/staging/prod)
- Smart defaults (encryption algorithms based on classification)

### Phase 4: AI-First Integration
- Enhanced semantic metadata (Relationship, ReasoningContext, ProvenanceMetadata)
- Knowledge graph construction pipeline (KCL → RDF → SurrealDB)
- GraphRAG proof-of-concept for policy impact analysis

### Phase 5: CDL Artifact Generation
- Epic generator (Product → Epic template with KCL Python SDK)
- User story generator (Component → Story with technical specs)
- CLI tools using KCL SDKs (`cdmesh-cli generate`)

### Phase 6: Multi-Cloud Portability
- Component resolution logic (`cdmesh-cli resolve`)
- Same product deployed to AWS, GCP, Azure
- Cost optimization recommendations

### Phase 7: Documentation & Standards
- Comprehensive guides (governance programming, module ecosystem, AI integration)
- Academic paper updates
- CNCF sandbox project submission (if ready)

### Phase 8: Testing & Release
- v0.2.1-alpha release with all modules published
- Community announcement and ecosystem launch

### Future Releases
- ODCS bidirectional adapter
- ReBAC (Relationship-Based Access Control)
- Full AI agent framework for autonomous governance
- VS Code extension with KCL LSP integration
- Enterprise features (RBAC, audit trails)

## Contributing

Contributions are welcome! Please note that this project is in early alpha stage. Before contributing:

1. Review the [Architecture Documentation](docs/architecture.md)
2. Check existing issues and discussions
3. Follow KCL coding conventions (`kcl fmt`, `kcl lint`)
4. Ensure all schemas validate (`kcl run .`)
5. Add tests for new functionality (`kcl test`)

## License

Apache License 2.0 – See [LICENSE](LICENSE) for details.

---

**Built with [KCL](https://kcl-lang.io)** | **Powered by Composable Mesh Architecture (CMA)**
