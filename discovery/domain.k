schema Domain:
    """
    Domain defines a logical grouping of data products (Business Domain).
    It maps to the `domain` node in the CDMesh Knowledge Graph.

    Attributes
    ----------
    id: str, required.
        The unique identifier of the domain.
    name: str, required.
        The name of the domain.
    description: str, optional.
        A description of the domain.
    """
    id: str
    name: str
    description?: str

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
