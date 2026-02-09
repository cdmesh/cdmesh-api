import cdmesh_api.discovery.organization as org
import cdmesh_api.deploy.spec as deploy

acmeOrg = org.Organization {
    id = "acme-corp"
    name = "Acme Corporation"
    jurisdiction = "US"

    deployment = deploy.DeploymentSpec {
        environment = "dev"
    }
}
