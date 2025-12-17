import ..core.component

schema Mesh(component.Component):
    """
    Mesh defines the top-level organizational or tenant boundary in the Data Mesh architecture.

    In Data Mesh terms, a Mesh represents the entire data ecosystem within an organization,
    encompassing all domains and their data products. It establishes the scope of the mesh
    and provides the root context for domain organization and discovery.

    In Domain-Driven Design terms, the Mesh is an Aggregate Root that defines the
    outermost Bounded Context, containing multiple Domain bounded contexts beneath it.
    It serves as the organizational partition for multi-tenant deployments.

    Graph Relationships:
    - CONTAINS → Domain (one-to-many)

    Inherits from Component:
    - id: Unique mesh identifier
    - name: Human-readable mesh name
    - description: Purpose and scope of this mesh
    - deployment: Deployment specification for mesh-level configuration
    """
