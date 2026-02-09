import cdmesh_api.discovery.organization as org
import cdmesh_api.deploy.spec as deploy

platformOrg = org.Organization {
    id = "platform-corp"
    name = "Platform Corporation"
    jurisdiction = "US"

    deployment = deploy.DeploymentSpec {
        environment = "production"
    }
}
