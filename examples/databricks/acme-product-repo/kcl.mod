[package]
name = "acme-product"
edition = "v0.11.2"
version = "0.2.1-alpha"

[dependencies]
acme-domain = { path = "../acme-domain-repo", version = "0.2.1-alpha" }
cdmesh-api = { path = "../../../api", version = "0.2.1-alpha" }
databricks-components = { path = "../datacricks-components-repo", version = "0.2.1-alpha" }
