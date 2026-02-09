import cdmesh_api.deploy.spec as deploy
import cdmesh_api.discovery.mesh

import platform_org.discovery.platform_org as org

serviceMesh = mesh.Mesh {
    organizationId = org.platformOrg.id

    id = "api-service-mesh"
    name = "API Service Mesh"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}
