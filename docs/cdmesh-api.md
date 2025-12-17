# cdmesh-api

## Index

- core
  - [Component](#component)
- deploy
  - [DeploymentSpec](#deploymentspec)
  - [SourceRepository](#sourcerepository)
- discovery
  - [Domain](#domain)
  - [Mesh](#mesh)
  - [Port](#port)
  - [Product](#product)

## Schemas

### Component

Component defines a catalog-managed architectural unit in the CDMesh platform.  Components represent autonomous, deployable resources that form the topology of the data mesh. They are: - Independently managed in the platform catalog - Mapped as nodes in the CDMesh Knowledge Graph - Analogous to Backstage Components or Kubernetes Custom Resources  Components include: - Mesh: Organizational or tenant boundary - Domain: Business capability grouping - Product: Autonomous data product  NOT Components (use different base schemas): - Configuration specifications (use *Specification Object) - Embedded properties (use *Value Object) - Metadata objects without independent lifecycle  In Domain-Driven Design terms, Components are Aggregate Roots with independent identity and lifecycle. They own their specifications and embedded value objects.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|The deployment specification defining how this component is deployed.<br />As part of the Component aggregate, it describes the deployment<br />configuration including environment and source repository metadata.||
|**description**|str|Detailed description of the component's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.||
|**name** `required`|str|Human-readable name for the component.||
### DeploymentSpec

DeploymentSpec defines the operational context and source configuration for a Component.  In Domain-Driven Design terms, DeploymentSpec is a Specification Object that belongs to the Component aggregate. It describes "how" and "where" a component is deployed, without having independent identity or lifecycle.  In Data Mesh terms, this enables the Self-Serve Data Platform principle by providing declarative deployment configuration. Each component (Mesh, Domain, or Product) specifies its target environment and source location, enabling automated provisioning and GitOps workflows.  DeploymentSpec is part of the Component's internal structure and cannot exist independently.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**environment** `required`|str|The environment where the component is deployed.||
|**source**|[SourceRepository](#sourcerepository)|The repository that hosts the component's source code.||
#### Examples

```
myDeployment = DeploymentSpec {
    environment = "dev"
    source = myRepository
}
```

### SourceRepository

SourceRepository defines the Git repository location and access configuration for component source code.  In Domain-Driven Design terms, SourceRepository is a Value Object - an immutable descriptor with no independent identity. Two repositories are considered equal if all their attributes match. It exists only within the context of a DeploymentSpec.  In Data Mesh terms, this supports the contract-driven, GitOps approach where all component definitions are version-controlled. The SourceRepository captures the precise location (URL, branch, tag, path) of the source code, enabling automated synchronization and deployment of mesh components.  SourceRepository specifies the necessary metadata for retrieving component source code, including optional SSH credentials for private repositories.

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**branch**|str|A source code branch.||
|**path**|str|A source code local source path.||
|**sshHostFingerprint**|str|A SSH public host fingerprint of a source code repository.||
|**sshPrivateKey**|str|A SSH private key of a source code repository.||
|**tag**|str|A source code realease tag.||
|**url** `required`|str|A source code repository URL.||
#### Examples

```
myDevelopmentRepository = SourceRepository {
    url = "https://github.com/my-org/my-component"
    branch = "dev"
    path = "components/my-component"
    tag = "v0.5.1-dev"

    sshHostFingerprint = "my-secret-host-fingerprint"
    sshPrivateKey = "my-secret-ssh-private-key"
}
```

### Domain

Domain defines a business capability boundary that owns and manages a collection of related data products.  In Data Mesh terms, a Domain embodies the principle of Domain Ownership. Each domain represents a cohesive business capability (e.g., Finance, Logistics, Customer) and is responsible for the lifecycle, quality, and discoverability of its data products. Domains are aligned with organizational structure and have dedicated teams.  In Domain-Driven Design terms, a Domain is a Bounded Context with its own ubiquitous language and model. It encapsulates domain logic and data products that serve both internal domain needs and expose capabilities to other domains through well-defined interfaces.  Graph Relationships: - Owned by: Mesh (via CONTAINS relationship) - OWNS → Product (one-to-many)  Inherits from Component: - id: Unique domain identifier - name: Human-readable domain name (e.g., "Finance", "Supply Chain") - description: Business capability and scope - deployment: Deployment specification for domain-level infrastructure

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|The deployment specification defining how this component is deployed.<br />As part of the Component aggregate, it describes the deployment<br />configuration including environment and source repository metadata.||
|**description**|str|Detailed description of the component's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.||
|**name** `required`|str|Human-readable name for the component.||
### Mesh

Mesh defines the top-level organizational or tenant boundary in the Data Mesh architecture.  In Data Mesh terms, a Mesh represents the entire data ecosystem within an organization, encompassing all domains and their data products. It establishes the scope of the mesh and provides the root context for domain organization and discovery.  In Domain-Driven Design terms, the Mesh is an Aggregate Root that defines the outermost Bounded Context, containing multiple Domain bounded contexts beneath it. It serves as the organizational partition for multi-tenant deployments.  Graph Relationships: - CONTAINS → Domain (one-to-many)  Inherits from Component: - id: Unique mesh identifier - name: Human-readable mesh name - description: Purpose and scope of this mesh - deployment: Deployment specification for mesh-level configuration

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|The deployment specification defining how this component is deployed.<br />As part of the Component aggregate, it describes the deployment<br />configuration including environment and source repository metadata.||
|**description**|str|Detailed description of the component's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.||
|**name** `required`|str|Human-readable name for the component.||
### Port

Port defines the interface boundary of a Data Product, specifying how data flows in or out.  In Data Mesh terms, a Port represents the standardized interface that enables interoperability across the mesh. Ports are the contract points where data products expose their capabilities (output ports) or declare their dependencies (input ports). They enable the Self-Serve Data Platform principle by providing discoverable, well-defined interfaces.  In Domain-Driven Design terms, a Port is a Value Object - it has no independent identity and exists only within the context of its parent Product. Ports are immutable descriptors of data interfaces and are compared by their attribute values rather than identity.  Ports specify the technical contract: data format (e.g., REST, SQL, Parquet), schema reference, and the direction of data flow. This allows consumers to discover and integrate with data products without deep coupling to implementation details.  Graph Relationships: - Embedded within: Product (no independent graph node, part of Product aggregate)

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**catalog**|str|||
|**description**|str|A description of the port's purpose.||
|**format**|str|The data format (e.g., "sql", "rest", "parquet").||
|**name** `required`|str|The name of the port.||
|**schema**|str|Reference to the data schema (e.g., URN or path).||
|**type** `required`|"input" | "output"|The direction of data flow.||
### Product

Product defines an autonomous, deployable data product that treats data as a first-class product.  In Data Mesh terms, a Product embodies the principle of Data as a Product. It is an autonomous unit with a clear data interface, discoverable through the mesh catalog, and accountable for data quality and SLOs. Products expose their capabilities through Ports (input/output interfaces) and can depend on other products to form a network of data services.  In Domain-Driven Design terms, a Product is an Aggregate Root within a Domain's Bounded Context. It has independent lifecycle, identity, and transactional consistency boundaries. Products encapsulate transformation logic, data storage, and interface contracts.  Products can represent different types (kind): datasets, APIs, dashboards, algorithms, or apps. Each product progresses through lifecycle stages (status): experimental → live → deprecated.  Graph Relationships: - Owned by: Domain (via OWNS relationship) - EXPOSES → Port (one-to-many, embedded value objects) - DEPENDS_ON → Product (many-to-many, product dependencies)  Inherits from Component: - id: Unique product identifier - name: Human-readable product name - description: Product purpose and capabilities - deployment: Deployment specification for this product

#### Attributes

| name | type | description | default value |
| --- | --- | --- | --- |
|**dependsOn**|[str]|List of URNs/IDs of products this product depends on.||
|**deployment** `required`|[DeploymentSpec](#deploymentspec)|The deployment specification defining how this component is deployed.<br />As part of the Component aggregate, it describes the deployment<br />configuration including environment and source repository metadata.||
|**description**|str|Detailed description of the component's purpose and scope.||
|**id** `required`|str|Globally unique identifier for catalog lookup and graph relations.||
|**kind** `required`|"dataset" | "api" | "dashboard" | "algorithm" | "app"|The classifier for the product type.|"dataset"|
|**name** `required`|str|Human-readable name for the component.||
|**owner**|str|The identifier of the owner (IAM Identity).||
|**ports**|[[Port](#port)]|List of input/output ports.||
|**status** `required`|"experimental" | "live" | "deprecated"|The lifecycle status of the product.|"experimental"|
|**version** `required`|str|The semantic version of the product.|"0.1.0"|
<!-- Auto generated by kcl-doc tool, please do not edit. -->
