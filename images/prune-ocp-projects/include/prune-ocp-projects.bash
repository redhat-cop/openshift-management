#!/bin/bash
declare -a sys_exclude=("cluster-ops"  "kube-public" "logging")
declare -a user_exclude=("infographic-delivery" "dantest")
declare -A projects
for project in `oc get project -o=custom-columns=NAME:.metadata.name --no-headers` ;
do
#  echo "found: ${project}"
  projects[${project}]="found"
done

# delete the excluded
for sys in "${sys_exclude[@]}" 
do
  unset projects[${sys}]
#  echo "unset sys ${sys}"
done

for user in "${user_exclude[@]}" 
do
  unset projects[${user}]
#  echo "unset user ${user}"
done

# capture time for each project
for prj in "${!projects[@]}" 
do
# need variable for time
  purgetime=`date -d "12" +%s`
  temp=`oc get project ${prj} -o=custom-columns=time:.metadata.creationTimestamp --no-headers`
  projects[${prj}]=`date -d "${temp}" +%s`

  echo "del: ${purgetime}: creationTimeEpocSec: ${prj}: ${projects[${prj}]}"
  if [ $purgetime -gt ${projects[${prj}]} ]; then
     echo "oc delete"
  else
     echo "No delete keep"
  fi
done



