import jenkins.model.*;

import com.cloudbees.pipeline.governance.templates.GlobalTemplateCatalogManagement;
import com.cloudbees.pipeline.governance.templates.TemplateCatalog;
import jenkins.scm.api.SCMSource;

import java.util.logging.Logger;


Logger logger = Logger.getLogger("init_07_pipeline_template_global_catalog.groovy")
logger.info("BEGIN pipeline-template-global-catalog")
File disableScript = new File(Jenkins.getInstance().getRootDir(), ".disable-pipeline-template-global-catalog-script")
if (disableScript.exists()) {
    logger.info("DISABLE pipeline-template-global-catalog script")
    return
}

SCMSource scm = new org.jenkinsci.plugins.github_branch_source.GitHubSCMSource(null, null, "SAME", "cbdays-github-token", "cloudbees-days", "pipeline-template-catalog")
GlobalTemplateCatalogManagement m = GlobalTemplateCatalogManagement.get();

TemplateCatalog globalCatalog = new TemplateCatalog(scm, "master");

m.addCatalog(globalCatalog);
m.save();

logger.info("Global Pipeline Template Catalog Created")

disableScript.createNewFile()