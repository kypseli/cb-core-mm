import com.cloudbees.hudson.plugins.folder.*
import jenkins.model.Jenkins
import com.cloudbees.hudson.plugins.folder.properties.SubItemFilterProperty

import java.util.logging.Logger

//adds a folder to the bluesteel folder with a filter on specific job templates
Logger logger = Logger.getLogger("init.init_70_create_template_folder.groovy")
logger.info("BEGIN docker label for create_template_folder")
File disableScript = new File(Jenkins.getInstance().getRootDir(), ".disable-create_template_folder-script")
if (disableScript.exists()) {
    logger.info("DISABLE create_template_folder script")
    return
}

def jenkins = Jenkins.instance
Set<String> allowedTypes = new TreeSet <String>()
def folder = jenkins.getItem(System.properties.'MASTER_NAME')
def templateFolder = folder.createProject(Folder.class, "template-jobs")

allowedTypes.add("workshopCatalog/nodejs-app")
def filterProp = new SubItemFilterProperty(allowedTypes)
templateFolder.getProperties().add(filterProp)
jenkins.save()


logger.info("created template-jobs folder")

disableScript.createNewFile()

