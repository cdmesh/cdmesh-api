"""
Organization: Top-level governance boundary in the CMA hierarchy.

The Organization schema represents the highest level of the mesh topology,
enabling multi-tenant scenarios and global policy cascading.

Hierarchy Position: Root (Level 0)
Organization → Mesh → Domain → Product → Port

Use Cases:
---------
- Multi-tenant SaaS platforms (separate customer organizations)
- Enterprise holding companies (multiple business units)
- Cloud provider organizations (AWS Organizations, Azure Management Groups)
- Regulatory compliance boundaries (jurisdictional requirements)

Academic References:
-------------------
- Dolhopolov et al. (2024): Hierarchical governance frameworks
- van der Werf et al. (2025): Reference architecture for federated governance
"""

import ..core.node

schema Organization(node.MeshNode):
    """
    Highest governance boundary in the Composable Mesh Architecture.

    Organization defines the root of the hierarchical governance model.
    All policies defined at Organization level cascade down to all child
    Meshes, Domains, and Products within this organization.

    Key Capabilities:
    ----------------
    1. Global Policy Definition: Policies apply to all child nodes
    2. Multi-Tenancy: Isolate different customers/business units
    3. Regulatory Compliance: Jurisdiction-specific governance
    4. Cost Management: Track spending across entire organization

    Policy Cascading:
    ----------------
    Organization.policies automatically cascade to:
    - All Meshes (CONTAINS relationship)
    - All Domains (via Mesh)
    - All Products (via Domain)
    - All Ports (via Product)

    Mathematical Model:
    C_Product = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Product_Local

    Where ⊕ represents policy composition (union with child precedence).

    Graph Relationships:
    -------------------
    - CONTAINS → Mesh (one-to-many)

    Inherits from MeshNode:
    ----------------------
    - id: Unique organization identifier (e.g., "acme-corp", "eu-tenant-1")
    - name: Human-readable organization name (e.g., "Acme Corporation", "EU Region")
    - description: Organization purpose and scope
    - deployment: Organization-level infrastructure configuration
    - policies: Global policies (encryption, compliance, cost limits)
    - semantics: Ontological metadata (org classification, industry)
    - version: Organization schema version
    - status: Organization lifecycle status
    - owner: Organization administrator/owner
    - tags: Organization tags (triggers global policy mixins)

    Attributes
    ----------
    legalName: str, optional.
        Legal registered name of the organization.
        Used for contracts, compliance reporting, billing.
        Example: "Acme Corporation LLC"
    jurisdiction: str, optional.
        Primary legal jurisdiction for regulatory compliance.
        ISO 3166-1 alpha-2 country codes recommended.
        Examples: "US", "EU", "GB", "JP"
        Determines which regulatory frameworks apply (GDPR, CCPA, etc.)
    regulatoryFramework: [str], optional.
        List of regulatory compliance frameworks applicable.
        Examples: ["GDPR", "CCPA", "HIPAA", "PCI-DSS", "SOC2", "ISO27001"]
        Automatically applies corresponding compliance mixins.
    billingAccountId: str, optional.
        Cloud provider billing account identifier.
        Links to AWS Organizations, Azure Management Groups, GCP Organizations.
    costCenter: str, optional.
        Internal cost allocation identifier.
        Used for chargeback/showback reporting.

    Examples
    --------
    # Global enterprise organization
    acmeOrg = Organization {
        id = "acme-corp"
        name = "Acme Corporation"
        legalName = "Acme Corporation LLC"
        jurisdiction = "US"
        regulatoryFramework = ["SOC2", "CCPA"]
        deployment = DeploymentSpec {
            environment = "production"
        }
        policies = [
            Policy {
                id = "global-encryption"
                name = "Global Encryption Policy"
                scope = "organization"
                policyType = "security"
                enforcement = "blocking"
                constraints = [
                    Constraint {
                        expression = "deployment.encryption.atRest == true"
                        message = "All data must be encrypted at rest (organization policy)"
                        severity = "error"
                    }
                ]
            }
        ]
        tags = ["enterprise", "production"]
    }

    # EU-specific tenant organization (GDPR compliance)
    euTenant = Organization {
        id = "eu-tenant"
        name = "European Region"
        jurisdiction = "EU"
        regulatoryFramework = ["GDPR", "ePrivacy"]
        deployment = DeploymentSpec {
            environment = "production"
            region = "eu-central-1"
        }
        policies = [
            Policy {
                id = "gdpr-baseline"
                name = "GDPR Baseline Requirements"
                scope = "organization"
                policyType = "compliance"
                enforcement = "blocking"
                constraints = [
                    Constraint {
                        expression = "deployment.region.startswith('eu-')"
                        message = "EU tenant data must remain in EU regions (GDPR Article 44)"
                        severity = "error"
                    }
                ]
            }
        ]
        tags = ["GDPR", "eu-region"]
    }

    # Healthcare organization (HIPAA compliance)
    healthcareOrg = Organization {
        id = "healthcare-provider"
        name = "Healthcare Provider Inc."
        legalName = "Healthcare Provider Incorporated"
        jurisdiction = "US"
        regulatoryFramework = ["HIPAA", "HITECH", "FDA-21CFR11"]
        deployment = DeploymentSpec {
            environment = "production"
        }
        policies = [
            Policy {
                id = "hipaa-baseline"
                name = "HIPAA Security Rule"
                scope = "organization"
                policyType = "compliance"
                enforcement = "blocking"
                constraints = [
                    Constraint {
                        expression = "deployment.encryption.atRest == true and deployment.encryption.inTransit == true"
                        message = "HIPAA requires encryption at rest and in transit"
                        severity = "error"
                    },
                    Constraint {
                        expression = "deployment.accessLogging.enabled == true"
                        message = "HIPAA requires audit logging for all PHI access"
                        severity = "error"
                    }
                ]
            }
        ]
        tags = ["healthcare", "PHI", "HIPAA"]
    }
    """
    legalName?: str
    jurisdiction?: str
    regulatoryFramework?: [str]
    billingAccountId?: str
    costCenter?: str

    check:
        jurisdiction == None or jurisdiction == Undefined or len(jurisdiction) == 2, \
            "jurisdiction should use ISO 3166-1 alpha-2 country codes (e.g., 'US', 'EU', 'GB')"
        regulatoryFramework == None or regulatoryFramework == Undefined or len(regulatoryFramework) > 0, \
            "if regulatoryFramework is specified, it must contain at least one framework"
