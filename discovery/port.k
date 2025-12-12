schema Port:
    """
    Port defines the input or output interface of a Data Product.
    It maps to the `port` node in the CDMesh Knowledge Graph.

    Attributes
    ----------
    id: str, required.
        The unique identifier of the port.
    name: str, required.
        The name of the port.
    description: str, optional.
        A description of the port's purpose.
    type: "input" | "output", required.
        The direction of data flow.
    format: str, optional.
        The data format (e.g., "sql", "rest", "parquet").
    schema: str, optional.
        Reference to the data schema (e.g., URN or path).
    """
    id: str
    name: str
    description?: str
    $type: "input" | "output"
    format?: str
    catalog?: str
    $schema?: str

    check:
        len(name) > 0, "name must not be empty"

