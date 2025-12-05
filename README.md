# IRIS Image Reducer

> **Important:** IRIS Image Reducer is an independent **third-party project** and is **not developed, endorsed, or supported** by InterSystems.
> This project provides tooling that helps automate the manual process of disabling components within the official InterSystems IRIS® image.
> **Users are responsible for ensuring compliance with the InterSystems IRIS license agreement and any redistribution restrictions.**
> IRIS Image Reducer is provided *as-is*, without any warranties or supportability guarantees from InterSystems.

---

**IRIS Image Reducer** is a lightweight, minimal InterSystems IRIS® container image designed for scenarios where IRIS is used primarily as a **high-performance SQL database engine**, without additional platform components that may add size or overhead.

IRIS Image Reducer starts from the official vanilla InterSystems IRIS Docker image and **programmatically disables and removes optional functionality** that is not required for core SQL operations.
The result is a **significantly smaller, faster-to-deploy, minimal IRIS image**, ideal for:

* Microservices
* CI/CD pipelines
* Automated testing
* Cloud-native database workloads
* Python / SQL / AI / ML pipelines
* Projects relying on `SQLAlchemy-IRIS`, JDBC, ODBC, or direct SQL access

**Image size comparison:**

| Image Type        | Approx Size |
| ----------------- | ----------- |
| Vanilla IRIS      | ~3.5 GB     |
| **Reduced image** | ~580 MB     |

---

## ✨ Key Features

* 🚀 **Much smaller Docker image size**
  Most optional IRIS components are removed.

* 🧩 **Pure SQL-focused IRIS runtime**
  Ideal for lightweight data engines and modern application stacks.

* 🔌 **JDBC, ODBC, and SQLAlchemy-IRIS fully supported**
  All client SQL interfaces continue to work as expected.

* 🧱 **Based on official IRIS vanilla image**
  Fully compatible with InterSystems licensing, environment variables, and standard tooling.

* 🛠️ **Deterministic image build**
  The build process removes components reliably and reproducibly.

---

## 🗂️ What’s Removed

IRIS Image Reducer strips out components that are often unused in minimal deployments, including:

* **Interoperability / Ensemble** components
  (Production engine, Business Services, Adapters, etc.)

* **DeepSee / BI stack**

* **Full Web Stack**

  * Management Portal
  * Web Gateway
  * CSP
  * REST framework
  * Web server modules

* **Most non-SQL runtime components**

* **Other optional development libraries and tools**

This ensures the resulting container includes only what is needed to run IRIS as a SQL database engine.

---

## 🟢 What’s Kept

IRIS Image Reducer preserves only the essential pieces:

* Core IRIS database engine
* SQL engine & query processor
* System classes required for storage and globals
* Authentication needed for basic operation
* JDBC & ODBC connectivity
* Compatibility with:

  * **SQLAlchemy-IRIS**
  * **dbt-iris**
  * **Liquibase-IRIS**
  * **typeorm-iris**
  * Any app using IRIS purely through SQL

Everything else is removed to reduce footprint.

---

## 📦 Usage

### Pull (once published)

```bash
docker pull caretdev/iris-community-light:latest-em
```

### Run

```bash
docker run -d \
  --name iris-light \
  -p 1972:1972 \
  caretdev/iris-community-light:latest-em
```

### Connect via JDBC

```java
String url = "jdbc:IRIS://localhost:1972/USER";
```

### Connect via SQLAlchemy-IRIS

```python
from sqlalchemy import create_engine
engine = create_engine("iris://_system:SYS@localhost:1972/USER")
```

---

## 🏗️ Building Your Own IRIS Image Reducer Image

IRIS Image Reducer can be generated from **any official InterSystems IRIS base image**, including:

* **Enterprise IRIS** (`containers.intersystems.com/intersystems/iris:...`)
* **Community Edition** (`containers.intersystems.com/intersystems/iris-community:...`)
* Any other vanilla IRIS image that follows the standard structure

The project includes a convenient build script `make.sh` that takes:

1. **Base IRIS image** (vanilla IRIS, Enterprise or Community)
2. **Name of the resulting lightweight IRIS image**

---

## 🛠️ How It Works

IRIS Image Reducer uses the official InterSystems IRIS image as the base and applies a reduction script that:

1. Identifies removable components (web, interoperability, DeepSee, others).
2. Deletes binaries, libraries, classes, and system modules not required for SQL.
3. Adjusts permissions and cleans up leftover metadata.
4. Produces a lightweight image with full SQL compatibility.

The project does **not** modify the IRIS kernel or SQL subsystem, ensuring compatibility with InterSystems’ supported APIs.

---

## 🧪 Testing & Validation

IRIS Image Reducer has been verified with:

* **SQLAlchemy-IRIS**
* Basic SQL workloads
* JDBC applications
* Containerized development environments
* Automated CI pipelines

You can extend the included test scripts or integrate IRIS Image Reducer into your own tooling.

---

## ⚠️ Notes & Limitations

* Management Portal and all web-based functionality **are not available**.
* Interoperability/Ensemble-based apps **will not run**.
* DeepSee/Analytics dashboards **are removed**.
* Licensing works same as upstream IRIS image.

---

## 📜 License

This project provides scripts and tooling to modify the official IRIS image.
You are responsible for complying with the InterSystems IRIS license agreement and any redistribution rules.
