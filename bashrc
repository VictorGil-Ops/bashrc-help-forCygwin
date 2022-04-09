#!/bib/bash

#############################################################

# For cgywin or mobaxterm, adapt VARS for you

# need OC CLI and jq installed
# https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/getting-started-cli.html

# VARS

U="user"
PROFILE="/drives/C/Users/$U/"
HELP="$PROFILE/"

P="base64passwd"
P=$(echo $P | base64 -d )

OCHELPONLINE=' '
LINUXHELPONLINE='https://raw.githubusercontent.com/VictorGil-sys/Linux_commads-cheatsheet/main/README.md'

DEVCLUSTER='https://api.ocp.....'
PRECLUSTER='https://api.ocp.....'
PRO1CLUSTER='https://api.ocp.....'
PRO2CLUSTER='https://api.ocp.....'

############################################################
# Needed for command "oc edit"
#export EDITOR=notepad++
export PATH="$PATH:C:\\Program Files (x86)\\Notepad++"
export EDITOR=Code.exe
export PATH="$PATH:C:\\Program Files\\Microsoft VS Code"

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# HELP
function menu() {
	
	printf "\n"
	printf "${GREEN}## Commads for help ##${NC} \n\n";
	echo "- Help OCP > oc-help "; 
	echo "- Help git > git-help ";
	echo "- Help bash > linux-help ";
	printf "\n";
	printf "${YELLOW}## OCP get info namespace ##${NC} \n\n";
	echo "- get-real ";
	echo "- get-configservice ";
	echo "- get-imageversion ";
	echo "- get-git ";
	echo "- get-dns ";
	echo "- get-limits";
	echo "- get-ipnodes ";
	printf "\n";
	printf "${YELLOW}## POD working  ##${NC} \n\n";
	echo "- oc-rsh <pod> ";
	echo "- get-pods-status <status> ";
	
}

# MISC
alias bck-profile='cp -a ~/.bashrc "$PROFILE/backup_profile/.bashrc" && source ~/.bashrc'
alias ll='ls -la'
alias oc='oc.exe'


# Functios fopr show help on terminal

function oc-help() { 
 if [ -z $1 ]; then	
  #cat "$HELP/oc-help.md";
  curl -Lk $OCHELPONLINE
 else 
  #cat "$HELP/oc-help.md"|grep -i -B 5 -A 10 $1 --color;
  curl -Lk $OCHELPONLINE |grep -i -B 5 -A 10 $1 --color;
 fi
}

function bash-help() {
 if [ -z $1 ]; then
  curl -Lk $LINUXHELPONLINE
 else
  curl -Lk $BASHHELPONLINE |grep -i -B 5 -A 10 $1 --color;
 fi
}


# Funtions for OCP Cluser and blue-green deployment: 
# https://access.redhat.com/documentation/en-us/openshift_container_platform/3.9/html/upgrading_clusters/upgrading-blue-green-deployments

# service b-g* is real
# service g-b* is no real

# show real real (production) blue or green
alias get-real="oc get service -o wide | grep ^b-g"

# show routes, names start with string " dns* "
alias get-dns='oc get routes | grep -io ^dns.*'

# show cluster ips
alias get-ipnodes="oc get nodes -o wide"

# show pods CPU and MEMORY limits 
function get-limits() {

	oc get dc -o custom-columns=NAME:.metadata.name,RAM_REQ:.spec.template.spec.containers[].resources.requests.memory,RAM_LIMIT:.spec.template.spec.containers[].resources.limits.memory,CPU_REQ:.spec.template.spec.containers[].resources.requests.cpu,CPU_LIMIT:.spec.template.spec.containers[].resources.limits.cpu

}

# Show configuration-service branch version
function get-configservice() {

	printf " \n\n"
	printf " >> ${BLUE}BLUE${NC} "
	DCb=$(oc get dc | grep -oi "^config.*-service-b")
	oc get dc "${DCb}" -o json| jq '.spec.template.spec.containers[].env[]| select(.name=="SPRING_APPLICATION_JSON")'||jq .value
	
	printf " \n\n"
	printf " >> ${GREEN}GREEN${NC} "
	DCg=$(oc get dc | grep -oi "^config.*-service-g")
	oc get dc "${DCg}" -o json| jq '.spec.template.spec.containers[].env[]| select(.name=="SPRING_APPLICATION_JSON")'||jq .value
}


# Show repo GIT uri
function get-git() {

	printf " \n\n"
	printf " >> ${BLUE}BLUE${NC}\n\n"
	DCb=$(oc get dc | grep -oi "^config.*-service-b")
	oc get dc "${DCb}" -o=custom-columns=NAME:.metadata.name,GIT:'.spec.template.spec.containers[].env[?(@.name=="SPRING_CLOUD_CONFIG_SERVER_GIT_URI")].value'
	
	printf " \n\n"		
	printf " >> ${GREEN}GREEN${NC}\n\n"
	DCg=$(oc get dc | grep -oi "^config.*-service-g")
	oc get dc "${DCg}" -o=custom-columns=NAME:.metadata.name,GIT:'.spec.template.spec.containers[].env[?(@.name=="SPRING_CLOUD_CONFIG_SERVER_GIT_URI")].value'
}


# Show image version from deployment config
function get-imageversion() {
	
	if [ -z $1 ]; then
		
		echo -e "  ${YELLOW} "ALL" for all microservices or input specific microservice name ${NC} " && oc get dc
	
	elif [ $1 == "ALL" ]; then
	
		oc get dc -o=custom-columns=NAME:.metadata.name,REPLICS:.spec.replicas,IMAGE:'.spec.template.spec.containers[].image'
	
	else
		
		oc -o json get dc $1 | jq '.spec.template.spec.containers[].image'
		
	fi
}

# Show pod status
function get-pods-status() {

	if [ -z $1 ]; then

		echo -e " $RED Put the status $NC\n
			  $YELLOW---> (https://docs.openshift.com/container-platform/4.5/support/troubleshooting/investigating-pod-issues.html)$NC\n\n
			  - Running\n
			  - Completed\n
			  - ImagePullBackOff\n
			  - ...\n
			"
	else
		oc get pods --field-selector=status.phase=$1 
	fi
}


# ssh to pod
function oc-rsh(){
	winpty oc rsh $1
}

#OC cluster LOGIN
alias dev="export KUBECONFIG=~/.kube/ocpdev && oc login -u=$U -p=$P $DEVCLUSTER"
alias pre="export KUBECONFIG=~/.kube/ocppre1 && oc login -u=$U -p=$P $PRECLUSTER"
alias pro1="export KUBECONFIG=~/.kube/ocppro1 && oc login -u=$U -p=$P $PRO1CLUSTER"
alias pro2="export KUBECONFIG=~/.kube2/ocppro2 && oc login -u=$U -p=$P $PRO2CLUSTER"
