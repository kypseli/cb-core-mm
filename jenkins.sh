#! /bin/bash

set -ex

# Remove possible dead links (CLTS-1452)
if [ -L "${JENKINS_HOME}/init.groovy.d" ]; then
    echo "Broken symbolic link init.groovy.d found, deleting it..."
    rm ${JENKINS_HOME}/init.groovy.d
fi

if [ -L "${JENKINS_HOME}/license-activated-or-renewed-after-expiration.groovy.d" ] ; then
    echo "Broken symbolic link license-activated-or-renewed-after-expiration.groovy.d found, deleting it..."
    rm ${JENKINS_HOME}/license-activated-or-renewed-after-expiration.groovy.d
fi

: ${JENKINS_HOME:="/var/jenkins_home"}
touch "${COPY_REFERENCE_FILE_LOG}" || (echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?" && exit 1)
echo "--- Copying files at $(date)" | tee -a "$COPY_REFERENCE_FILE_LOG"
find /usr/share/jenkins/ref/ \( -type f -o -type l \) -exec bash -c '. /usr/local/bin/jenkins-support; for arg; do copy_reference_file "$arg"; done' _ {} +

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  eval "exec java ${JAVA_OPTS:-} -jar -Dcb.distributable.name=\"Docker Common CJE\" -Dcb.distributable.commit_sha=cfa06628f331c8d96e9871ea833675e5e301ae46 /usr/share/jenkins/jenkins.war $JENKINS_OPTS \"\$@\""
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"