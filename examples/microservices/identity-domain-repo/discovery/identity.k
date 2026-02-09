import cdmesh_api.discovery.domain
import cdmesh_api.deploy.spec as deploy

import api_mesh.discovery.api_mesh as mesh

identityDomain = domain.Domain {
    meshId = mesh.serviceMesh.id

    id = "identity-domain"
    name = "Identity and Access Management Domain"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}
