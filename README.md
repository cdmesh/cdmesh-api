# CDMesh API

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![KCL](https://img.shields.io/badge/KCL-v0.11.2-green.svg)](https://kcl-lang.io)
[![Version](https://img.shields.io/badge/version-0.2.0--alpha-orange.svg)](https://github.com/yourusername/cdmesh-api/releases)

> **⚠️ Early Development Notice**
>
> CDMesh API is currently in the early alpha stage (v0.2.0-alpha). The API specification is under active development and
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
services, traditional tuple-based governance systems require O(T) operations for policy updates, where T ≈ 10,000. This
creates bottlenecks in compliance, security, and operational efficiency.

### The Solution

CDMesh API implements **Composable Mesh Architecture (CMA)** with three foundational pillars:

1. **Semantic Driven Design (SDD)**: KCL schemas as executable ontologies with RDF/OWL integration
2. **Contract Driven Infrastructure (CDI)**: Infrastructure derived from contracts with federated policy inheritance
   achieving O(D) complexity where D ≈ 4
3. **Contract Driven Lifecycle (CDL)**: Compile-time governance verification with shift-left validation

This approach reduces governance overhead by **2,500x** compared to traditional tuple-based systems, enabling scalable
federated governance across heterogeneous data and service architectures.

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
- [Academic Foundation](#academic-foundation)
    - [Foundational Papers](#foundational-papers)
    - [Books](#books)
- [Development](#development)
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
just example-databricks-etl
```

Demonstrates a multi-component ETL pipeline with bronze, silver, and gold layers using Databricks.

**Microservices Composite Example:**

```bash
just example-microservices
```

Demonstrates a microservices API platform with service mesh patterns.

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

The `examples/` directory contains reference implementations demonstrating CMA patterns:

- **`databricks_etl_composite.k`**: Multi-component ETL pipeline with bronze→silver→gold data flow
- **`microservices_composite.k`**: Microservices API platform with service mesh composition

Each example showcases:

- Product composition with multiple components
- Component graph wiring with explicit data flow
- Port-based interfaces (data/service/event)
- Policy cascading and governance
- Semantic metadata integration

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

- **ODCS v3.1.0** (Open Data Contract Standard) – Phase 5
- **OpenLineage** – Data lineage tracking (Priority 3)
- **W3C PROV** - Provenance vocabulary (Priority 3)
- **ReBAC** - Relationship-Based Access Control (Phase 7)

## Academic Foundation

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
- **Version**: `0.2.0-alpha`
- **Registry**: `oci://ghcr.io/<owner>/cdmesh-api`

### Release Process

Releases are automated via GitHub Actions:

- Tag format: `v*` (e.g., `v0.2.0`)
- Workflow: `.github/workflows/release.yaml`
- Publishes to GitHub Container Registry (GHCR)

## Contributing

Contributions are welcome! Please note that this project is in early alpha stage. Before contributing:

1. Review the [Architecture Documentation](docs/architecture.md)
2. Check existing issues and discussions
3. Follow KCL coding conventions (`kcl fmt`, `kcl lint`)
4. Ensure all schemas validate (`kcl run .`)
5. Add tests for new functionality (`kcl test`)

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.

---

**Built with [KCL](https://kcl-lang.io)** | **Powered by Composable Mesh Architecture (CMA)**
