schema Mesh:
    """
    Mesh defines the top-level organization or tenant.
    It maps to the `mesh` node in the CDMesh Knowledge Graph.

    Attributes
    ----------
    id: str, required.
        The unique identifier of the mesh tenant.
    name: str, required.
        The name of the organization mesh or tenant.
    description: str, optional.
        A description of the mesh.
    """
    id: str
    name: str
    description?: str

    check:
        len(id) > 0, "id must not be empty"
        len(name) > 0, "name must not be empty"
