"""
Policy mixins for federated governance inheritance in CMA.

This module implements reusable policy mixins that automatically apply
governance constraints based on node properties (primarily tags).

This demonstrates the Contract-Driven Lifecycle (CDL) pillar of CMA:
- Compile-time constraint verification
- Automatic constraint propagation (taint analysis)
- Federated inheritance with O(D) complexity

Core Concepts:
--------------
- Mixin: Reusable behavior added to schemas via KCL mixin pattern
- Tag-based activation: Mixins check for specific tags (e.g., "PII", "GDPR")
- Constraint propagation: Requirements flow from upstream to downstream nodes
- Compile-time enforcement: Violations block compilation (shift-left governance)

Mathematical Model:
------------------
Taint Propagation Theorem:
If Node A has property P (e.g., ContainsPII) and Node C consumes Node A,
then Node C must satisfy constraint Requires(P) (e.g., HasMasking).

Proof: Implemented via check blocks that validate dependent node properties.

Federated Inheritance:
C_final(Node) = C_Organization ⊕ C_Mesh ⊕ C_Domain ⊕ C_Local

Where ⊕ represents policy composition (union with child precedence).

Examples:
--------
# Product with PII automatically gets encryption requirement
customerProduct = Product {
    name = "CustomerProfile"
    tags = ["PII"]  # Triggers PIIMixin
    mixin = [PIIMixin]
    deployment = DeploymentSpec {
        environment = "production"
        # This MUST be present or compilation fails:
        encryption = EncryptionConfig {
            atRest = true
        }
    }
}

# EU region products automatically get GDPR compliance
euProduct = Product {
    name = "EUCustomerData"
    tags = ["GDPR"]  # Triggers GDPRMixin
    mixin = [GDPRMixin]
    retentionPolicy = RetentionPolicy {
        maxDays = 2555  # 7 years, GDPR limit
    }
}

Academic References:
-------------------
- Dolhopolov et al. (2024): Implementing Federated Governance in Data Mesh
- van der Werf et al. (2025): Federated computational governance patterns
"""

import ..core.node as core_node
import .policy

# Note: KCL mixins are still experimental as of v0.11.2
# This syntax demonstrates the intended pattern for future implementation
# Current workaround: Use schema inheritance with validation checks

schema PIIMixin:
    """
    Mixin for nodes handling Personally Identifiable Information (PII).

    Automatically applies when tags include "PII". Enforces:
    1. Encryption at rest
    2. Encryption in transit
    3. Access logging
    4. Data masking capabilities

    This demonstrates constraint propagation: any product consuming PII-tagged
    data must inherit these constraints (taint analysis).

    Regulatory Alignment:
    --------------------
    - GDPR Article 32: Security of processing
    - CCPA Section 1798.150: Data security requirements
    - HIPAA Security Rule: Administrative, physical, technical safeguards

    Usage:
    -----
    # Automatic application based on tag
    piiProduct = Product {
        tags = ["PII"]
        # Mixin automatically adds encryption policy
        # Compilation fails if deployment.encryption.atRest != true
    }

    Constraint Propagation:
    ----------------------
    If Product B depends on Product A (PII-tagged), then Product B must
    either:
    1. Apply PIIMixin (handle PII directly)
    2. Apply MaskingMixin (de-identify PII)
    3. Prove data is aggregated/anonymized

    Examples
    --------
    # Valid: Encryption configured
    validPIIProduct = Product {
        id = "customer-profile"
        tags = ["PII"]
        deployment = DeploymentSpec {
            environment = "production"
            encryption = EncryptionConfig {
                atRest = true
                inTransit = true
            }
        }
    }

    # Invalid: Missing encryption (compilation fails)
    invalidPIIProduct = Product {
        id = "customer-profile-bad"
        tags = ["PII"]
        deployment = DeploymentSpec {
            environment = "production"
            # ERROR: PIIMixin requires encryption
        }
    }
    """
    piiPolicy: policy.Policy = policy.Policy {
        id = "pii-encryption-v1"
        name = "PII Encryption Required"
        scope = "product"
        policyType = "privacy"
        enforcement = "blocking"
        constraints = [
            policy.Constraint {
                expression = "deployment.encryption.atRest == true"
                message = "Products handling PII must enable encryption at rest (GDPR Article 32)"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.encryption.inTransit == true"
                message = "Products handling PII must enable encryption in transit"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.accessLogging.enabled == true"
                message = "Products handling PII must enable access logging for audit trails"
                severity = "error"
            }
        ]
    }

    # Tag validation
    check:
        "PII" in tags if isinstance(self, core_node.MeshNode), \
            "PIIMixin should only be applied to nodes with 'PII' tag"

schema GDPRMixin:
    """
    Mixin for nodes subject to GDPR (General Data Protection Regulation).

    Automatically applies when tags include "GDPR". Enforces:
    1. Data retention limits (7 years max per GDPR Article 5)
    2. Right to erasure capabilities (GDPR Article 17)
    3. Data portability support (GDPR Article 20)
    4. Consent tracking (GDPR Article 7)

    Applies to:
    ----------
    - Products processing EU resident data
    - Products storing personal data of EU citizens
    - Services offering to EU market

    Regulatory Alignment:
    --------------------
    - GDPR Article 5: Principles relating to processing
    - GDPR Article 17: Right to erasure ("right to be forgotten")
    - GDPR Article 20: Right to data portability
    - GDPR Article 7: Conditions for consent

    Usage:
    -----
    euProduct = Product {
        tags = ["GDPR"]
        retentionPolicy = RetentionPolicy {
            maxDays = 2555  # 7 years
            erasureCapable = true
        }
        dataPortability = DataPortabilityConfig {
            exportFormats = ["json", "csv", "xml"]
        }
    }

    Constraint Propagation:
    ----------------------
    If Product B (EU region) depends on Product A (global), then Product A
    must either:
    1. Apply GDPRMixin (store only EU-compliant data)
    2. Filter/partition data to separate EU from non-EU
    3. Apply shortest retention period globally

    Examples
    --------
    # Valid: GDPR-compliant retention
    validGDPRProduct = Product {
        id = "eu-customer-data"
        tags = ["GDPR", "PII"]
        retentionPolicy = RetentionPolicy {
            maxDays = 2555
            erasureCapable = true
        }
        deployment = DeploymentSpec {
            environment = "production"
            region = "eu-west-1"
        }
    }

    # Invalid: Retention too long (compilation fails)
    invalidGDPRProduct = Product {
        id = "eu-customer-data-bad"
        tags = ["GDPR"]
        retentionPolicy = RetentionPolicy {
            maxDays = 3650  # 10 years - exceeds GDPR limit
            erasureCapable = true
        }
        # ERROR: GDPRMixin requires maxDays <= 2555
    }
    """
    gdprPolicy: policy.Policy = policy.Policy {
        id = "gdpr-compliance-v1"
        name = "GDPR Compliance Requirements"
        scope = "product"
        policyType = "compliance"
        enforcement = "blocking"
        constraints = [
            policy.Constraint {
                expression = "retentionPolicy.maxDays <= 2555"
                message = "GDPR Article 5 requires data retention period <= 7 years (2555 days)"
                severity = "error"
            },
            policy.Constraint {
                expression = "retentionPolicy.erasureCapable == true"
                message = "GDPR Article 17 requires right to erasure (right to be forgotten)"
                severity = "error"
            },
            policy.Constraint {
                expression = "dataPortability.exportFormats != None and len(dataPortability.exportFormats) > 0"
                message = "GDPR Article 20 requires data portability in structured, commonly used formats"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.region.startswith('eu-') or deployment.region == 'eu-central'"
                message = "GDPR-tagged products should be deployed in EU regions for data sovereignty"
                severity = "warning"
            }
        ]
    }

    # Tag validation
    check:
        "GDPR" in tags if isinstance(self, core_node.MeshNode), \
            "GDPRMixin should only be applied to nodes with 'GDPR' tag"

schema PCIDSSMixin:
    """
    Mixin for nodes handling payment card data (PCI-DSS compliance).

    Automatically applies when tags include "PCI-DSS". Enforces:
    1. Strong encryption (AES-256)
    2. Network segmentation
    3. Access control (least privilege)
    4. Regular security testing

    Applies to:
    ----------
    - Products processing credit card transactions
    - Products storing cardholder data (PAN, CVV)
    - Services in payment processing chain

    Regulatory Alignment:
    --------------------
    - PCI-DSS Requirement 3: Protect stored cardholder data
    - PCI-DSS Requirement 4: Encrypt transmission of cardholder data
    - PCI-DSS Requirement 7: Restrict access to cardholder data
    - PCI-DSS Requirement 11: Test security systems and processes

    Usage:
    -----
    paymentProduct = Product {
        tags = ["PCI-DSS"]
        deployment = DeploymentSpec {
            environment = "production"
            encryption = EncryptionConfig {
                atRest = true
                algorithm = "AES-256"
            }
            networkSegmentation = true
        }
    }

    Examples
    --------
    # Valid: PCI-DSS compliant
    validPCIProduct = Product {
        id = "payment-processor"
        tags = ["PCI-DSS"]
        deployment = DeploymentSpec {
            environment = "production"
            encryption = EncryptionConfig {
                atRest = true
                inTransit = true
                algorithm = "AES-256"
            }
            networkSegmentation = true
            accessControl = AccessControlConfig {
                principleOfLeastPrivilege = true
            }
        }
    }
    """
    pciPolicy: policy.Policy = policy.Policy {
        id = "pci-dss-v1"
        name = "PCI-DSS Compliance Requirements"
        scope = "product"
        policyType = "compliance"
        enforcement = "blocking"
        constraints = [
            policy.Constraint {
                expression = "deployment.encryption.atRest == true and deployment.encryption.algorithm == 'AES-256'"
                message = "PCI-DSS Requirement 3: Cardholder data must be encrypted with AES-256"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.encryption.inTransit == true"
                message = "PCI-DSS Requirement 4: Cardholder data must be encrypted in transit"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.networkSegmentation == true"
                message = "PCI-DSS Requirement 1: Network segmentation required for cardholder data environment"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.accessControl.principleOfLeastPrivilege == true"
                message = "PCI-DSS Requirement 7: Access to cardholder data must follow least privilege principle"
                severity = "error"
            }
        ]
    }

    # Tag validation
    check:
        "PCI-DSS" in tags if isinstance(self, core_node.MeshNode), \
            "PCIDSSMixin should only be applied to nodes with 'PCI-DSS' tag"

schema SOC2Mixin:
    """
    Mixin for nodes requiring SOC 2 compliance (Service Organization Control).

    Automatically applies when tags include "SOC2". Enforces:
    1. Change management tracking
    2. Incident response procedures
    3. Monitoring and alerting
    4. Business continuity planning

    Applies to:
    ----------
    - SaaS products handling customer data
    - Cloud services with security commitments
    - Managed service providers

    Trust Service Criteria:
    ----------------------
    - Security: Protection against unauthorized access
    - Availability: System uptime and performance
    - Processing Integrity: Complete, accurate, timely processing
    - Confidentiality: Designated confidential information protected
    - Privacy: Personal information collected, used, retained, disclosed properly

    Usage:
    -----
    saasProduct = Product {
        tags = ["SOC2"]
        deployment = DeploymentSpec {
            environment = "production"
            monitoring = MonitoringConfig {
                enabled = true
                alerting = true
            }
            changeManagement = ChangeManagementConfig {
                approvalRequired = true
            }
        }
    }

    Examples
    --------
    # Valid: SOC 2 compliant
    validSOC2Product = Product {
        id = "saas-platform"
        tags = ["SOC2"]
        deployment = DeploymentSpec {
            environment = "production"
            monitoring = MonitoringConfig {
                enabled = true
                alerting = true
                retentionDays = 365
            }
            changeManagement = ChangeManagementConfig {
                approvalRequired = true
                auditLog = true
            }
            incidentResponse = IncidentResponseConfig {
                runbookUrl = "https://wiki.example.com/incident-response"
                oncallRotation = true
            }
        }
    }
    """
    soc2Policy: policy.Policy = policy.Policy {
        id = "soc2-compliance-v1"
        name = "SOC 2 Compliance Requirements"
        scope = "product"
        policyType = "compliance"
        enforcement = "blocking"
        constraints = [
            policy.Constraint {
                expression = "deployment.monitoring.enabled == true and deployment.monitoring.alerting == true"
                message = "SOC 2: Monitoring and alerting required for security and availability"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.changeManagement.approvalRequired == true"
                message = "SOC 2: Change management with approval workflow required"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.incidentResponse.runbookUrl != None"
                message = "SOC 2: Incident response procedures must be documented"
                severity = "error"
            },
            policy.Constraint {
                expression = "deployment.monitoring.retentionDays >= 365"
                message = "SOC 2: Audit logs must be retained for at least 12 months"
                severity = "warning"
            }
        ]
    }

    # Tag validation
    check:
        "SOC2" in tags if isinstance(self, core_node.MeshNode), \
            "SOC2Mixin should only be applied to nodes with 'SOC2' tag"
