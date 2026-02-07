"""
Semantic metadata schemas for knowledge graph construction.

This module implements the Semantic Driven Design (SDD) pillar of CMA,
enabling MeshNodes to carry semantic annotations that support:
- RDF/OWL export for semantic web integration
- Business glossary alignment
- Data lineage tracking
- Classification and tagging

Core Concepts:
--------------
- SemanticMetadata: Ontological annotations for a MeshNode
- RDF Type: Formal ontology class (e.g., schema.org/Dataset, DCAT-2.0/Distribution)
- Namespace: URI prefix for semantic identifiers
- Business Glossary Terms: Human-readable domain concepts
- Data Classification: Sensitivity/confidentiality level

Standards Alignment:
-------------------
- DCAT 2.0: W3C Data Catalog Vocabulary
- Schema.org: Structured data vocabulary
- SKOS: Simple Knowledge Organization System
- Dublin Core: Metadata element set

Examples:
--------
# Data Product Semantics
productSemantics = SemanticMetadata {
    rdfType = "http://schema.org/Dataset"
    namespace = "https://cdmesh.example.com/products/"
    businessGlossaryTerms = ["CustomerData", "PersonalInformation"]
    dataClassification = "restricted"
    upstreamDependencies = ["customer-profile"]
    downstreamConsumers = ["recommendation-engine", "analytics-platform"]
}

# Service Endpoint Semantics
serviceSemantics = SemanticMetadata {
    rdfType = "http://schema.org/WebAPI"
    namespace = "https://cdmesh.example.com/services/"
    businessGlossaryTerms = ["CustomerAPI", "Authentication"]
    dataClassification = "internal"
}

Academic References:
-------------------
- Hogan et al. (2021): Knowledge Graphs (ACM Computing Surveys)
- Pingos et al. (2024): Transforming Data Lakes Using Semantic Data Blueprints
"""

schema SemanticMetadata:
    """
    Semantic annotations for MeshNodes enabling knowledge graph construction.

    SemanticMetadata bridges the gap between technical schemas (KCL) and
    semantic ontologies (RDF/OWL), supporting:
    1. Automated RDF triple generation
    2. Business glossary integration
    3. Data lineage tracking
    4. Access control based on classification

    This enables:
    - Semantic search across the mesh
    - Automated policy inference from classifications
    - Cross-domain data discovery
    - Compliance reporting (e.g., GDPR data inventory)

    Attributes
    ----------
    rdfType: str, optional.
        RDF class URI from a standard ontology.
        Examples:
        - "http://schema.org/Dataset" (for data products)
        - "http://www.w3.org/ns/dcat#Distribution" (for data ports)
        - "http://schema.org/WebAPI" (for service endpoints)
        - "http://www.w3.org/ns/prov#Entity" (for provenance tracking)
    namespace: str, optional.
        URI prefix for generating unique identifiers.
        Example: "https://cdmesh.example.com/products/"
        Results in URIs like: https://cdmesh.example.com/products/customer-profile
    businessGlossaryTerms: [str], optional.
        Human-readable business concepts associated with this node.
        Links to enterprise business glossary or data dictionary.
        Examples: ["CustomerData", "PersonalInformation", "GDPR", "PII"]
    dataClassification: str, optional.
        Sensitivity/confidentiality level for access control.
        Standard values: "public", "internal", "confidential", "restricted".
        Triggers policy mixins based on classification level.
    upstreamDependencies: [str], optional.
        List of node IDs that this node consumes data from.
        Used for:
        - Data lineage graph construction
        - Impact analysis (what breaks if upstream changes?)
        - Constraint propagation (inherit PII/sensitivity from sources)
    downstreamConsumers: [str], optional.
        List of node IDs that consume data from this node.
        Used for:
        - Data lineage graph construction
        - Impact analysis (who is affected by changes?)
        - Access control (who needs read permissions?)

    Examples
    --------
    # Financial Data Product
    financialSemantics = SemanticMetadata {
        rdfType = "http://schema.org/Dataset"
        namespace = "https://bank.example.com/data/"
        businessGlossaryTerms = ["TransactionData", "AccountBalance", "PCI-DSS"]
        dataClassification = "restricted"
        upstreamDependencies = ["core-banking-system"]
        downstreamConsumers = ["fraud-detection", "reporting-platform"]
    }

    # Customer API Service
    apiSemantics = SemanticMetadata {
        rdfType = "http://schema.org/WebAPI"
        namespace = "https://api.example.com/services/"
        businessGlossaryTerms = ["CustomerManagement", "REST-API"]
        dataClassification = "internal"
    }
    """
    rdfType?: str
    namespace?: str
    businessGlossaryTerms?: [str]
    dataClassification?: "public" | "internal" | "confidential" | "restricted"
    upstreamDependencies?: [str]
    downstreamConsumers?: [str]

    check:
        rdfType == None or rdfType.startswith("http://") or rdfType.startswith("https://"), \
            "rdfType must be a valid URI"
        namespace == None or namespace.startswith("http://") or namespace.startswith("https://"), \
            "namespace must be a valid URI"
        dataClassification != "restricted" or (businessGlossaryTerms != None and len(businessGlossaryTerms) > 0), \
            "restricted data must have business glossary terms for compliance tracking"
