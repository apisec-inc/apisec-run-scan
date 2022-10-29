#!/bin/bash
# Begin
TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profile:,scanner:,emailReport:,reportType:,tags:,fail-on-high-vulns,openApiSpecUrl,oas,playbookCreatePolicy,outputfile:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --profile) JOB_NAME="$2"; shift;;
                    --scanner) REGION="$2"; shift;;
                    --emailReport) FX_EMAIL_REPORT="$2"; shift;;
                    --reportType) FX_REPORT_TYPE="$2"; shift;;
                    --fail-on-high-vulns) FAIL_ON_HIGH_VULNS="$2"; shift;;
                    --oas) OAS="$2"; shift;;
                    --openApiSpecUrl) OPEN_API_SPEC_URL="$2"; shift;;
                    --playbookCreatePolicy) PLAYBOOK_CREATE_POLICY="$2"; shift;;
                    --outputfile) OUTPUT_FILENAME="$2"; shift;;		    
                    --tags) FX_TAGS="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done
    
#FX_USER=$1
#FX_PWD=$2
#FX_JOBID=$3
#REGION=$4
#FX_ENVID=$5
#FX_PROJECTID=$6
#FX_EMAIL_REPORT=$7
#FX_TAGS=$8

if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

FX_SCRIPT=""
if [ "$FX_TAGS" != "" ];
then
FX_SCRIPT="&tags=script:"+${FX_TAGS}
fi

if   [ "$FAIL_ON_HIGH_VULNS" == ""  ]; then
        FAIL_ON_HIGH_VULNS=false
fi

if   [ "$OAS" == ""  ]; then
        OAS=false
fi

if   [ "$PLAYBOOK_CREATE_POLICY" == ""  ]; then
        PLAYBOOK_CREATE_POLICY=false
fi



token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

echo "generated token is:" $token

if [ "$OAS" = true ]; then

     getProjectName=$(curl -s -X GET "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" -H "accept: */*"  --header "Authorization: Bearer "$token"" | jq -r '.data|.name')

     if [ "$getProjectName" == null ];
     then
          curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECT_NAME}'","openAPISpec":"'${OPEN_API_SPEC_URL}'","planType":"ENTERPRISE","isFileLoad": false,"personalizedCoverage":{"auths":[]}}' > /dev/null
                sleep 5
                dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
                projectId=$(echo "$dto" | jq -r '.id')

                curl -s -X PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" > /dev/null
     
                playbookTaskStatus="In_progress"
                echo "playbookTaskStatus = " $playbookTaskStatus
                retryCount=0
                pCount=0

                while [ "$playbookTaskStatus" == "In_progress" ]
                        do
                            if [ $pCount -eq 0 ]; then
                                 echo "Checking playbooks generate task Status...."
                            fi
                            pCount=`expr $pCount + 1`  
                            retryCount=`expr $retryCount + 1`  
                            sleep 2

                            playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '."data".status')
                            #playbookTaskStatus="In_progress"
                            if [ "$playbookTaskStatus" == "Done" ]; then
                                 echo "Playbooks generation task for the registered project $FX_PROJECT_NAME is succesfully completed!!!"
                            fi

                            if [ $retryCount -ge 55  ]; then
                                 echo " "
                                 retryCount=`expr $retryCount \* 2`  
                                 echo "Playbooks Generation Task Status $playbookTaskStatus even after $retryCount seconds, so halting/breaking script execution!!!"
                                 exit 1
                            fi
                        done
                PLAYBOOK_CREATE_POLICY=false

     else
          echo "$FX_PROJECT_NAME project already exists."          
          echo " "
     fi
    
fi


if [ "$PLAYBOOK_CREATE_POLICY" = true ]; then

      dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
      projectId=$(echo "$dto" | jq -r '.id')

     curl -s -X PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" > /dev/null
     
    playbookTaskStatus="In_progress"
    echo "playbookTaskStatus = " $playbookTaskStatus
    retryCount=0
    pCount=0

    while [ "$playbookTaskStatus" == "In_progress" ]
           do
                if [ $pCount -eq 0 ]; then
                     echo "Checking playbooks regenerate task Status...."
                fi
                pCount=`expr $pCount + 1`  
                retryCount=`expr $retryCount + 1`  
                sleep 2

                playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '."data".status')
                #playbookTaskStatus="In_progress"
                if [ "$playbookTaskStatus" == "Done" ]; then
                     echo "Playbooks regenerate task is succesfully completed!!!"
                fi

                if [ $retryCount -ge 55  ]; then
                     echo " "
                     retryCount=`expr $retryCount \* 2`  
                     echo "Playbook Regenerate Task Status $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                     exit 1
                fi                            
           done
  
fi


URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}"

url=$( echo "$URL" | sed 's/ /%20/g' )
data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]')
runId=$( jq -r '.id' <<< "$data")
projectId=$( jq -r '.job.project.id' <<< "$data")
#runId=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')

echo "runId =" $runId
#if [ -z "$runId" ]
if [ "$runId" == null ]
then
          echo "RunId = " "$runId"
          echo "Invalid runid"
          echo $(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
          exit 1
fi


taskStatus="WAITING"
echo "taskStatus = " $taskStatus

while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
         do
                sleep 5
                 echo "Checking Status...."

                passPercent=$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

                        IFS=':' read -r -a array <<< "$passPercent"

                        taskStatus="${array[0]}"

                        echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"
                      # VAR2=$(echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}")      


                if [ "$taskStatus" == "COMPLETED" ];then
            echo "------------------------------------------------"
                       # echo  "Run detail link ${FX_HOST}/${array[7]}"
                        echo  "Run detail link ${FX_HOST}${array[7]}"
                        echo "-----------------------------------------------"
                        echo "Scan Successfully Completed"
                        echo " "
			if [ "$OUTPUT_FILENAME" != "" ];then
                              sarifoutput=$(curl -s --location --request GET "${FX_HOST}/api/v1/projects/${projectId}/sarif" --header "Authorization: Bearer "$token"" | jq  '.data')
		              #echo $sarifoutput >> $OUTPUT_FILENAME
                              echo $sarifoutput >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
               		      echo "SARIF output file created successfully"
                              echo " "
                        fi
                        if [ "$FAIL_ON_HIGH_VULNS" = true ]; then
                              severity=$(curl -s -X GET "${FX_HOST}/api/v1/projects/${projectId}/vulnerabilities?&severity=All&page=0&pageSize=20" -H "accept: */*"  "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[] | .severity')

                                cVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Critical"  ]; then
                                                
                                               cVulCount=`expr $cVulCount + 1`                                           
                                          fi

                                    done
                                echo "Found $cVulCount Critical Severity Vulnerabilities!!!"
                                echo " "

                                hVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "High"  ]; then
                                              hVulCount=`expr $hVulCount + 1`                                           
                                           
                                          fi

                                    done
                                echo "Found $hVulCount High Severity Vulnerabilities!!!"
                                echo " "

                                majVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Major"  ]; then
                                                
                                               majVulCount=`expr $majVulCount + 1`
                                          fi
                                          
                                    done
                                echo "Found $majVulCount Major Severity Vulnerabilities!!!"
                                echo " "

                                medVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Medium"  ]; then
                                                
                                               medVulCount=`expr $medVulCount + 1`
                                          fi
                                          
                                    done
                                echo "Found $medVulCount Medium Severity Vulnerabilities!!!"
                                echo " "

                                minVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Minor"  ]; then
                                                
                                              minVulCount=`expr $minVulCount + 1`
                                          fi
                                          
                                    done
                                echo "Found $minVulCount Minor Severity Vulnerabilities!!!"
                                echo " "

                                lowVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Low"  ]; then

                                               lowVulCount=`expr $lowVulCount + 1`  
                                           
                                          fi
                                          
                                    done
                                echo "Found $lowVulCount Low Severity Vulnerabilities!!!"
                                echo " "

                                triVulCount=0
                                for vul in ${severity}
                                    do
                                                
                                          if [ "$vul" == "Trivial"  ]; then
                                               
                                              triVulCount=`expr $triVulCount + 1` 
                                           
                                          fi
                                          
                                    done
                                echo "Found $triVulCount Trivial Severity Vulnerabilities!!!"
                                echo " "

                                vCount=1
                                for vul in ${severity}
                                    do
                                                
                                          if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                 echo "Failing script execution since we have found "$vul" severity vulnerability!!!"
                                                 exit 1
                                           
                                          fi
                                          vCount=`expr $vCount + 1`
                                    done
                            
                            
                        fi 
                        exit 0

                fi
        done

if [ "$taskStatus" == "TIMEOUT" ];then
echo "Task Status = " $taskStatus
 exit 1
fi

echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
exit 1

return 0




























































































































# #!/bin/bash
# # Begin
# USER=$1
# PWD=$2
# PROJECT=$3
# JOB=$4
# REGION=$5
# OUTPUT_FILENAME=$6
# PARAM_SCRIPT=""
# if [ "$JOB" != "" ];
# then
# PARAM_SCRIPT="?jobName="${JOB}
#   if [ "$REGION" != "" ];
#   then
#   PARAM_SCRIPT=${PARAM_SCRIPT}"&region="${REGION}
#   fi
# elif [ "$REGION" != "" ];
#   then
#   PARAM_SCRIPT="?region="${REGION}
# fi


# token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${USER}'", "password": "'${PWD}'"}' https://cloud.apisec.ai/login | jq -r .token)

# echo "generated token is:" $token

# echo "The request is https://cloud.apisec.ai/api/v1/runs/projectName/${PROJECT}${PARAM_SCRIPT}"

# data=$(curl --location --request POST "https://cloud.apisec.ai/api/v1/runs/projectName/${PROJECT}${PARAM_SCRIPT}" --header "Authorization: Bearer "$token"" | jq '.data')

# runId=$( jq -r '.id' <<< "$data")
# projectId=$( jq -r '.job.project.id' <<< "$data")

# echo "runId =" $runId
# if [ -z "$runId" ]
# then
#           echo "RunId = " "$runId"
#           echo "Invalid runid"
#           echo $(curl --location --request POST "https://cloud.apisec.ai/api/v1/runs/projectName/${PROJECT}${PARAM_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
#           exit 1
# fi



# taskStatus="WAITING"
# echo "taskStatus = " $taskStatus



# while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
#          do
#                 sleep 5
#                  echo "Checking Status...."

#                 passPercent=$(curl --location --request GET "https://cloud.apisec.ai/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

#                         IFS=':' read -r -a array <<< "$passPercent"

#                         taskStatus="${array[0]}"

#                         echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"



#                 if [ "$taskStatus" == "COMPLETED" ];then
#             echo "------------------------------------------------"
#                        # echo  "Run detail link https://cloud.apisec.ai/${array[7]}"
#                         echo  "Run detail link https://cloud.apisec.ai${array[7]}"
#                         echo "-----------------------------------------------"
#                         echo "Job run successfully completed"
#                         if [ "$OUTPUT_FILENAME" != "" ];
#                          then
#                          sarifoutput=$(curl --location --request GET "https://cloud.apisec.ai/api/v1/projects/${projectId}/sarif" --header "Authorization: Bearer "$token""| jq '.data')
# 						 echo $sarifoutput >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
# 						 echo "SARIF output file created successfully"
#                         fi
#                         exit 0

#                 fi
#         done

# if [ "$taskStatus" == "TIMEOUT" ];then
# echo "Task Status = " $taskStatus
#  exit 1
# fi

# echo "$(curl --location --request GET "https://cloud.apisec.ai/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
# exit 1

# return 0
