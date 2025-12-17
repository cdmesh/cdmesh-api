import regex
import .port
import ..core.component

schema Product(component.Component):
    """
    Product defines an autonomous, deployable data product that treats data as a first-class product.

    In Data Mesh terms, a Product embodies the principle of Data as a Product. It is an
    autonomous unit with a clear data interface, discoverable through the mesh catalog, and
    accountable for data quality and SLOs. Products expose their capabilities through Ports
    (input/output interfaces) and can depend on other products to form a network of data services.

    In Domain-Driven Design terms, a Product is an Aggregate Root within a Domain's Bounded
    Context. It has independent lifecycle, identity, and transactional consistency boundaries.
    Products encapsulate transformation logic, data storage, and interface contracts.

    Products can represent different types (kind): datasets, APIs, dashboards, algorithms, or apps.
    Each product progresses through lifecycle stages (status): experimental → live → deprecated.

    Graph Relationships:
    - Owned by: Domain (via OWNS relationship)
    - EXPOSES → Port (one-to-many, embedded value objects)
    - DEPENDS_ON → Product (many-to-many, product dependencies)

    Inherits from Component:
    - id: Unique product identifier
    - name: Human-readable product name
    - description: Product purpose and capabilities
    - deployment: Deployment specification for this product

    Attributes
    ----------
    kind: "dataset" | "api" | "dashboard" | "algorithm" | "app", default is "dataset".
        The classifier for the product type.
    version: str, default is "0.1.0".
        The semantic version of the product.
    status: "experimental" | "live" | "deprecated", default is "experimental".
        The lifecycle status of the product.
    owner: str, optional.
        The identifier of the owner (IAM Identity).
    ports: [port.Port], optional.
        List of input/output ports.
    dependsOn: [str], optional.
        List of URNs/IDs of products this product depends on.
    """
    kind: "dataset" | "api" | "dashboard" | "algorithm" | "app" = "dataset"
    version: str = "0.1.0"
    status: "experimental" | "live" | "deprecated" = "experimental"
    owner?: str
    ports?: [port.Port]
    dependsOn?: [str]

    check:
        regex.match(version, r"^\d+\.\d+\.\d+$"), "version must follow semantic versioning (X.Y.Z)"
