import regex
import .port

schema Product:
    """
    Product defines an autonomous, deployable data unit.
    It maps to the `product` node in the CDMesh Knowledge Graph.

    Attributes
    ----------
    id: str, required.
        The unique identifier of the data product.
    name: str, required.
        The name of the data product.
    description: str, optional.
        A description of the product.
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
    id: str
    name: str
    description?: str
    kind: "dataset" | "api" | "dashboard" | "algorithm" | "app" = "dataset"
    version: str = "0.1.0"
    status: "experimental" | "live" | "deprecated" = "experimental"
    owner?: str
    ports?: [port.Port]
    dependsOn?: [str]

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
        regex.match(version, r"^\d+\.\d+\.\d+$"), "version must follow semantic versioning (X.Y.Z)"
