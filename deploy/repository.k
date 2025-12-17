schema SourceRepository:
    """
    SourceRepository defines the Git repository location and access configuration for component source code.

    In Domain-Driven Design terms, SourceRepository is a Value Object - an immutable descriptor
    with no independent identity. Two repositories are considered equal if all their attributes
    match. It exists only within the context of a DeploymentSpec.

    In Data Mesh terms, this supports the contract-driven, GitOps approach where all component
    definitions are version-controlled. The SourceRepository captures the precise location
    (URL, branch, tag, path) of the source code, enabling automated synchronization and
    deployment of mesh components.

    SourceRepository specifies the necessary metadata for retrieving component source code,
    including optional SSH credentials for private repositories.

    Attributes
    ----------
    branch: str, default is Undefined, optional.
        A source code branch.
    path: str, default is Undefined, optional.
        A source code local source path.
    sshHostFingerprint: str, default is Undefined, optional.
        A SSH public host fingerprint of a source code repository.
    sshPrivateKey: str, default is Undefined, optional.
        A SSH private key of a source code repository.
    tag: str, default is Undefined, optional.
        A source code realease tag.
    url: str, default is Undefined, required.
        A source code repository URL.

    Examples
    --------
    myDevelopmentRepository = SourceRepository {
        url = "https://github.com/my-org/my-component"
        branch = "dev"
        path = "components/my-component"
        tag = "v0.5.1-dev"

        sshHostFingerprint = "my-secret-host-fingerprint"
        sshPrivateKey = "my-secret-ssh-private-key"
    }
    """
    branch?: str
    path?: str
    sshHostFingerprint?: str
    sshPrivateKey?: str
    tag?: str
    url: str
