import ..core.node

schema Mesh(node.MeshNode):
    """
    Mesh defines an organizational or tenant boundary in the Composable Mesh Architecture.

    In Data Mesh terms, a Mesh represents the entire data ecosystem within an organization,
    encompassing all domains and their data products. It establishes the scope of the mesh
    and provides the context for domain organization and discovery.

    In Domain-Driven Design terms, the Mesh is an Aggregate Root that defines a
    Bounded Context, containing multiple Domain bounded contexts beneath it.
    It serves as the organizational partition for multi-tenant deployments.

    Hierarchy Position: Level 1
    Organization → Mesh → Domain → Product → Port

    Graph Relationships:
    - Contained by: Organization (via CONTAINS relationship)
    - CONTAINS → Domain (one-to-many)

    Inherits from MeshNode:
    - id: Unique mesh identifier
    - name: Human-readable mesh name
    - description: Purpose and scope of this mesh
    - deployment: Deployment specification for mesh-level configuration
    - policies: Mesh-level policies (cascaded from Organization + local)
    - semantics: Ontological metadata for the mesh

    Attributes
    ----------
    organizationId: str, optional.
        Reference to parent Organization.
        If specified, this mesh inherits policies from the organization.
        Required for multi-tenant deployments.
    """
    organizationId?: str
