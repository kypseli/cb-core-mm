# CloudBees Core Managed Master 
## Custom Managed Master Docker Image
This repository provides an example for creating a custom container (Docker) image to use as a [Managed Master](https://go.cloudbees.com/docs/cloudbees-core/cloud-admin-guide/operating/#managing-masters) *Docker image template* to be provisioned by CloudBees Core Operations Center running on Kubernetes. 

The image is configured to skip the Jenkins 2 Setup Wizard, install all of the CloudBees recommended plugins (minus a few) and some additional plugins typically used by CloudBees SAs for demos and workshops, and auto-configure the Jenkins instances. This *config-as-code* results in a streamlined CloudBees Core Managed Master provisioning process.

### Dockerfile
- The `Dockerfile` starts with a `FROM` value of the CloudBees Core Managed Master Docker image: `cloudbees/cloudbees-core-mm`. 
- The `RUN /usr/local/bin/install-plugins.sh $(cat plugins.txt)` command installs all the plugins.
- The `config-as-code.yml` file provides Configuration-as-Code via [the Jenkins CasC plugin](https://github.com/jenkinsci/configuration-as-code-plugin).
- The `quickstart` scripts futher modifies the Managed Master configuration using `init.groovy.d` scripts for configuration not currently supported by the CasC plugin.

#### Plugins installed:
See the [`plugins.txt`](plugins.txt) file to see all the plugins that get installed - some *non-CJE standard plugins* highlights include:

- [Blue Ocean with the Blue Ocean Pipeline Editor](https://jenkins.io/doc/book/blueocean/)
- [Pipeline Utilities plugin](https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/)
- [Jenkins Configuration as Code Plugin](https://github.com/jenkinsci/configuration-as-code-plugin)

Note, the `install-plugins.sh` script will download the specified plugins and their dependencies at build time and include them in the image; it also inspects the Jenkins WAR and skips any plugins already included by CloudBees (embedded in the WAR).

#### initilization scripts (Groovy init scripts that run on Jenkins post initialization)
##### Regular init scripts (on startup)
- `init_99_save.groovy`: Ensures any previous configuration changes are saved, sets flags not to re-run certain scripts; currently not much done here as we prefer to wait for the CJE license to be activated

##### License Activated scripts - utilizes the custom CloudBees `license-activated-or-renewed-after-expiration` hook that will be fired after your CJE license is activated
- `init_01_quickstart_hook.groovy`: This script is only used to trigger another custom groovy hook but only after the CloudBees license has been activated.

##### Quickstart scripts - a custom init groovy hook that fires after required plugins are installed and after a necessary restart
- `init_04_pipeline_model-def_config.groovy`: Configures the agent label to be used for Pipeline Declarative Docker syntax. This is not documented very well, but there is a global and per folder setting to tell Declarative Pipeline what Jenkins agent `label` to use when using the `` syntax - to ensure that the underlying Pipeline Model Definition will be able to spin up the Docker image to use *inside* the agent.
- [`init_10_global_flow_durability.groovy`](quickstart/init_10_global_flow_durability.groovy): Sets the global **Pipeline Speed/Durability Setting** to `PERFORMANCE_OPTIMIZED`, this may be overridden per Pipeline job or per-branch for a Pipeline Multibranch project. See [Scaling Pipelines](https://jenkins.io/doc/book/pipeline/scaling-pipeline/) for more details. We might as well use maximum performance since we are using the One Shot Executor Strategy for agents.

