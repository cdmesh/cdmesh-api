"""
MeshNode: Universal abstraction for catalog-managed entities in CMA.

This module defines the base schema for all catalog-discoverable entities
in the Composable Mesh Architecture (CMA). MeshNode provides a semantically
precise and governance-aware foundation for mesh topology nodes.

Core Concepts:
-------------
- MeshNode: Catalog-managed entity in the mesh topology
- Aggregate Root: DDD pattern - independent identity and lifecycle
- Policy Cascading: O(D) governance propagation via inheritance
- Semantic Metadata: Knowledge graph integration

CMA Architecture:
----------------
MeshNode forms the root of the 5-level hierarchy:
Organization → Mesh → Domain → Product → Port

Where:
- Organization, Mesh, Domain, Product are MeshNodes (Aggregate Roots)
- Port is a Value Object (no independent identity, embedded in Product)

Academic References:
-------------------
- van der Werf et al. (2025): Towards a Data Mesh Reference Architecture
- Dolhopolov et al. (2024): Implementing Federated Governance in Data Mesh
- Goedegebuure et al. (2023): Data Mesh: a Systematic Gray Literature Review
"""

import regex
import ..deploy.spec as deploy
import ..governance.policy as gov
import ..semantics.ontology as sem

schema MeshNode:
    """
    Universal abstraction for catalog-managed entities in the Composable Mesh Architecture.

    MeshNode represents the base schema for all autonomous, catalog-discoverable
    entities in CDMesh. They are:
    - Independently managed in the platform catalog
    - Mapped as vertices in the CDMesh Knowledge Graph
    - Subject to hierarchical governance policies
    - Semantically annotated for ontological reasoning

    In Domain-Driven Design terms, MeshNodes are Aggregate Roots with:
    - Independent identity (id field)
    - Independent lifecycle (version, status fields)
    - Ownership boundaries (owner field)
    - Internal specifications (deployment, policies)

    MeshNode Hierarchy:
    ------------------
    Organization → Mesh → Domain → Product

    All catalog entities extend MeshNode:
    - Organization: Global governance boundary (multi-tenant root)
    - Mesh: Organizational/tenant boundary (business unit)
    - Domain: Business capability boundary (domain ownership)
    - Product: Autonomous deployable unit (data/service/ML)

    NOT MeshNodes:
    -------------
    - Port: Value Object embedded in Product
    - DeploymentSpec: Specification Object owned by MeshNode
    - Policy: Governance metadata applied to MeshNodes
    - SemanticMetadata: Ontological metadata attached to MeshNodes

    Governance Model:
    ----------------
    MeshNodes inherit policies from parent nodes via schema inheritance:

    C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Local

    This federated inheritance pattern achieves O(D) complexity for policy
    updates (where D = hierarchy depth ≈ 3-4) vs O(T) for tuple-level updates
    (where T = table count ≈ 10,000).

    Attributes
    ----------
    id: str, required.
        Globally unique identifier for catalog lookup and graph relations.
        Format: kebab-case or UUID
        Examples: "customer-profile", "recommendation-engine"
    name: str, required.
        Human-readable name for the node.
        Examples: "Customer Profile", "Recommendation Engine"
    description: str, optional.
        Detailed description of the node's purpose and scope.
    semantics: sem.SemanticMetadata, optional.
        Semantic annotations for knowledge graph construction.
        Enables RDF export, business glossary integration, data lineage.
    policies: [gov.Policy], default [].
        Governance policies applicable to this node.
        Cascades from parent nodes via inheritance.
    constraints: [gov.Constraint], default [].
        Direct compile-time constraints (alternative to policy-based constraints).
        Useful for node-specific validations not part of reusable policies.
    deployment: deploy.DeploymentSpec, required.
        Deployment specification (environment, source repository).
        Part of the MeshNode aggregate (Specification Object pattern).
    version: str, default "0.1.0".
        Semantic version of this node (X.Y.Z format).
        Follows semver conventions for compatibility tracking.
    status: str, default "proposed".
        Lifecycle status of this node.
        Valid values:
        - "proposed": Design phase, not yet implemented
        - "experimental": Early implementation, unstable API
        - "live": Production-ready, stable API
        - "deprecated": Scheduled for removal, use alternatives
        - "retired": No longer available
    owner: str, optional.
        Owner or team responsible for this node.
        Examples: "data-platform-team", "finance-domain"
    tags: [str], default [].
        Freeform tags for categorization and policy triggering.
        Special tags trigger policy mixins:
        - "PII": Triggers PIIMixin (encryption, masking)
        - "GDPR": Triggers GDPRMixin (retention, consent)
        - "PCI-DSS": Triggers PCI compliance policies

    Examples
    --------
    # Basic MeshNode
    customerProduct = MeshNode {
        id = "customer-profile"
        name = "Customer Profile"
        description = "Customer master data and profile information"
        deployment = DeploymentSpec {
            environment = "production"
        }
        version = "1.2.3"
        status = "live"
        owner = "customer-domain-team"
        tags = ["PII", "GDPR"]
    }

    # MeshNode with Semantics
    apiService = MeshNode {
        id = "customer-api"
        name = "Customer API"
        semantics = sem.SemanticMetadata {
            rdfType = "http://schema.org/WebAPI"
            businessGlossaryTerms = ["CustomerManagement", "REST-API"]
            dataClassification = "internal"
        }
        deployment = DeploymentSpec {
            environment = "production"
        }
    }

    # MeshNode with Policies
    financialProduct = MeshNode {
        id = "transaction-ledger"
        name = "Transaction Ledger"
        policies = [
            gov.Policy {
                id = "encryption-required"
                name = "Encryption Required"
                scope = "product"
                policyType = "security"
                enforcement = "blocking"
                constraints = [
                    gov.Constraint {
                        expression = "deployment.encryption.atRest == true"
                        message = "Financial data must be encrypted at rest"
                        severity = "error"
                    }
                ]
            }
        ]
        deployment = DeploymentSpec {
            environment = "production"
        }
        tags = ["financial", "regulated"]
    }
    """
    # Identity
    id: str
    name: str
    description?: str

    # Semantics
    semantics?: sem.SemanticMetadata

    # Governance
    policies: [gov.Policy] = []
    constraints: [gov.Constraint] = []

    # Deployment
    deployment: deploy.DeploymentSpec

    # Lifecycle
    version: str = "0.1.0"
    status: "proposed" | "experimental" | "live" | "deprecated" | "retired" = "proposed"
    owner?: str
    tags: [str] = []

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
        regex.match(version, r"^\d+\.\d+\.\d+$"), "version must follow semantic versioning (X.Y.Z)"
