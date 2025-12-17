schema Port:
    """
    Port defines the interface boundary of a Data Product, specifying how data flows in or out.

    In Data Mesh terms, a Port represents the standardized interface that enables interoperability
    across the mesh. Ports are the contract points where data products expose their capabilities
    (output ports) or declare their dependencies (input ports). They enable the Self-Serve Data
    Platform principle by providing discoverable, well-defined interfaces.

    In Domain-Driven Design terms, a Port is a Value Object - it has no independent identity
    and exists only within the context of its parent Product. Ports are immutable descriptors
    of data interfaces and are compared by their attribute values rather than identity.

    Ports specify the technical contract: data format (e.g., REST, SQL, Parquet), schema reference,
    and the direction of data flow. This allows consumers to discover and integrate with data
    products without deep coupling to implementation details.

    Graph Relationships:
    - Embedded within: Product (no independent graph node, part of Product aggregate)

    Attributes
    ----------
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
    name: str
    description?: str
    $type: "input" | "output"
    format?: str
    catalog?: str
    $schema?: str

    check:
        len(name) > 0, "name must not be empty"
