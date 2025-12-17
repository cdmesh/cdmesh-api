import .repository as repo

schema DeploymentSpec:
    """
    DeploymentSpec defines the operational context and source configuration for a Component.

    In Domain-Driven Design terms, DeploymentSpec is a Specification Object that belongs
    to the Component aggregate. It describes "how" and "where" a component is deployed,
    without having independent identity or lifecycle.

    In Data Mesh terms, this enables the Self-Serve Data Platform principle by providing
    declarative deployment configuration. Each component (Mesh, Domain, or Product) specifies
    its target environment and source location, enabling automated provisioning and GitOps workflows.

    DeploymentSpec is part of the Component's internal structure and cannot exist independently.

    Attributes
    ----------
    environment: str, default is Undefined, required.
        The environment where the component is deployed.
    source: repo.SourceRepository, default is Undefined, optional.
        The repository that hosts the component's source code.

    Examples
    --------
    myDeployment = DeploymentSpec {
        environment = "dev"
        source = myRepository
    }
    """
    environment: str
    source?: repo.SourceRepository
