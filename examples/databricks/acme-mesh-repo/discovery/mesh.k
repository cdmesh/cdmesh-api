import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.mesh

import acme_org.discovery.acme as org

dataMesh = mesh.Mesh {
    organizationId = org.acmeOrg.id

    id = "data-mesh"
    name = "Acme Data Mesh"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }
}
