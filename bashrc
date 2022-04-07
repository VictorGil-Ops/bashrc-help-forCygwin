#!/bib/bash

U="user"
ONEPROFILE="/drives/C/Users/$U/"
HELP="$ONEPROFILE/notas/help"
P="passwd"
#P=$(cat "$ONEPROFILE/notas/.x")
#P=$(echo $P | base64 -d )

#export EDITOR=notepad++
export PATH="$PATH:C:\\Program Files (x86)\\Notepad++"
export EDITOR=Code.exe
export PATH="$PATH:C:\\Program Files\\Microsoft VS Code"

#COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#HELPS
function menu() {
	
	printf "\n"
	printf "${GREEN}## Comandos de ayuda ##${NC} \n\n";
	echo "- Ayuda OC  > oc-help "; 
	echo "- Ayuda git > git-help ";
	echo "- Ayuda bash > bash-help ";
	printf "\n";
	printf "${YELLOW}## OC get info  ##${NC} \n\n";
	echo "- get-apuntamiento ";
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

#MISC
alias bck-profile='cp -a ~/.bashrc "$ONEPROFILE/notas/backup_profile/.bashrc" && source ~/.bashrc'
alias ll='ls -la'
#alias oc='winpty oc.exe'
alias oc='oc.exe'
alias node='winpty node.exe'
alias ayuda="menu"

OCHELPONLINE='https://github.alm.europe.cloudcenter.corp/gist/X634360/83209722f8b69f84b718eb01635f6f91/raw'
BASHHELPONLINE='https://github.alm.europe.cloudcenter.corp/gist/X634360/71303019290a8f02d2e1044c05be2c4f/raw'

function oc-help() { 
 if [ -z $1 ]; then	
  #cat "$HELP/oc-help.md";
  curl -Lk $OCHELPONLINE
 else 
  #cat "$HELP/oc-help.md"|grep -i -B 5 -A 10 $1 --color;
  curl -Lk $OCHELPONLINE |grep -i -B 5 -A 10 $1 --color;
 fi
}

function git-help() {
 if [ -z $1 ]; then
   cat "$HELP/git-help.md";
 else
  cat "$HELP/git-help.md"|grep -i -B 5 -A 10 "$1" --color;
 fi
}

function bash-help() {
 if [ -z $1 ]; then
  #cat "$HELP/bash-help.md";
  curl -Lk $BASHHELPONLINE
 else
  #cat "$HELP/bash-help.md"|grep -i -B 5 -A 10 $1 --color;
  curl -Lk $BASHHELPONLINE |grep -i -B 5 -A 10 $1 --color;
 fi
}


function get-limits() {

	oc get dc -o custom-columns=NAME:.metadata.name,RAM_REQ:.spec.template.spec.containers[].resources.requests.memory,RAM_LIMIT:.spec.template.spec.containers[].resources.limits.memory,CPU_REQ:.spec.template.spec.containers[].resources.requests.cpu,CPU_LIMIT:.spec.template.spec.containers[].resources.limits.cpu

}


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



function get-imageversion() {
	
	if [ -z $1 ]; then
		
		echo -e "  ${YELLOW}Introduce el nombre del micro o "ALL" para todos los micros${NC} " && oc get dc
		
	
	elif [ $1 == "ALL" ]; then
	
		oc get dc -o=custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,IMAGEN:'.spec.template.spec.containers[].image'
	
	else
		
		oc -o json get dc $1 | jq '.spec.template.spec.containers[].image'
		
	fi
}


function get-pods-status() {

	if [ -z $1 ]; then

		echo -e " $RED Put the status madafaka:$NC\n
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



alias get-dns='oc get routes | grep -io ^dns.*'
alias get-apuntamiento="oc get service -o wide | grep ^b-g"
alias get-ipnodes="oc get nodes -o wide"


function oc-rsh(){

	winpty oc rsh $1

}


#OC LOGIN
alias dev="export KUBECONFIG=~/.kube/ocpdev && oc login -u=$U -p=$P https://"
alias azdev="export KUBECONFIG=~/.kube/ocpdev && oc login -u=$U -p=$P https://"
alias pre1="export KUBECONFIG=~/.kube/ocppre1 && oc login -u=$U -p=$P https://"
alias pre2="export KUBECONFIG=~/.kube2/ocppre2 && oc login -u=$U -p=$P https://"
alias pro1="export KUBECONFIG=~/.kube/ocppro1 && oc login -u=$U -p=$P https://"
alias pro2="export KUBECONFIG=~/.kube2/ocppro2 && oc login -u=$U -p=$P https://"
alias azdev1="export KUBECONFIG=~/.kube/azuredev1 && oc login -u=$U -p=$P https://"
alias azdev2="export KUBECONFIG=~/.kube2/azuredev2 && oc login -u=$U -p=$P https://"
alias azpre1="export KUBECONFIG=~/.kube/azurepre1 && oc login -u=$U -p=$P https://"
alias azpre2="export KUBECONFIG=~/.kube2/azurepre2 && oc login -u=$U -p=$P https://"
alias azpro1="export KUBECONFIG=~/.kube/azurepro1 && oc login -u=$U -p=$P https://"
alias azpro2="export KUBECONFIG=~/.kube2/azurepro2 && oc login -u=$U -p=$P https://"
alias dmz1="export KUBECONFIG=~/.kube/ocpdmz1 && oc login -u=$U -p=$P https://"
alias dmz2="export KUBECONFIG=~/.kube2/ocpdmz2 && oc login -u=$U -p=$P https://"



