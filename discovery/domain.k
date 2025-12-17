import ..core.component

schema Domain(component.Component):
    """
    Domain defines a business capability boundary that owns and manages a collection of related data products.

    In Data Mesh terms, a Domain embodies the principle of Domain Ownership. Each domain
    represents a cohesive business capability (e.g., Finance, Logistics, Customer) and is
    responsible for the lifecycle, quality, and discoverability of its data products.
    Domains are aligned with organizational structure and have dedicated teams.

    In Domain-Driven Design terms, a Domain is a Bounded Context with its own ubiquitous
    language and model. It encapsulates domain logic and data products that serve both
    internal domain needs and expose capabilities to other domains through well-defined interfaces.

    Graph Relationships:
    - Owned by: Mesh (via CONTAINS relationship)
    - OWNS → Product (one-to-many)

    Inherits from Component:
    - id: Unique domain identifier
    - name: Human-readable domain name (e.g., "Finance", "Supply Chain")
    - description: Business capability and scope
    - deployment: Deployment specification for domain-level infrastructure
    """
