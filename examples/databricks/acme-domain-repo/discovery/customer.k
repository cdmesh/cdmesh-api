import cdmesh_api.discovery.domain
import cdmesh_api.deploy.spec as deploy

import acme_mesh.discovery.mesh as mesh

customerDomain = domain.Domain {
    meshId = mesh.dataMesh.id

    id = "customer-domain"
    name = "Customer Domain"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }
}