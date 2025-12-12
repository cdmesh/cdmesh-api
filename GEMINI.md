# Project: CDMesh API Specification

## 1. Project Overview

The CDMesh API specification is defined by [KCL language](https://www.kcl-lang.io/docs/reference/lang/tour) DSL schemas.

## 2. Architectural Design

* The CDMesh API defines KCL schemas to describe data mesh components such as mesh, domain, product, port, and their relationships. 
* These API specifications are used to create and synchronize a data mesh Knowledge Graph in [SurrealDB](https://surrealdb.com/docs/surrealdb). 
* Each CDMesh component is declared in a git source repository using the KCL DSL.
* Each component repository is synchronized into SurrealDB using a GitOps approach. 
* SurrealDB will function as the metastore and management backend for the deployed mesh.

## 3. CDMesh API Components

* Discovery