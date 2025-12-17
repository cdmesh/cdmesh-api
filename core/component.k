import ..deploy.spec as deploy

schema Component:
    """
    Component defines a catalog-managed architectural unit in the CDMesh platform.

    Components represent autonomous, deployable resources that form the topology
    of the data mesh. They are:
    - Independently managed in the platform catalog
    - Mapped as nodes in the CDMesh Knowledge Graph
    - Analogous to Backstage Components or Kubernetes Custom Resources

    Components include:
    - Mesh: Organizational or tenant boundary
    - Domain: Business capability grouping
    - Product: Autonomous data product

    NOT Components (use different base schemas):
    - Configuration specifications (use *Specification Object)
    - Embedded properties (use *Value Object)
    - Metadata objects without independent lifecycle

    In Domain-Driven Design terms, Components are Aggregate Roots with independent
    identity and lifecycle. They own their specifications and embedded value objects.

    Attributes
    ----------
    id: str, required.
        Globally unique identifier for catalog lookup and graph relations.
    name: str, required.
        Human-readable name for the component.
    description: str, optional.
        Detailed description of the component's purpose and scope.
    deployment: deploy.DeploymentSpec, required.
        The deployment specification defining how this component is deployed.
        As part of the Component aggregate, it describes the deployment
        configuration including environment and source repository metadata.
    """
    id: str
    name: str
    description?: str
    deployment: deploy.DeploymentSpec

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
