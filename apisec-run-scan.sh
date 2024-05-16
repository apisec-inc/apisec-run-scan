#!/bin/bash
# Begin

TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profile:,scanner:,outputfile:,emailReport:,reportType:,fail-on-vuln-severity:,refresh-playbooks:,openAPISpecUrl:,openAPISpecFile:,internal_OpenAPISpecUrl:,specType:,profileScanner:,envName:,authName:,app_username:,app_password:,app_endPointUrl:,app_token_param:,baseUrl:,category:,tier:,tags:, header_1:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --profile) PROFILE_NAME="$2"; shift;;                    
                    --scanner) REGION="$2"; shift;;
                    --outputfile) OUTPUT_FILENAME="$2"; shift;;
		    
                    --emailReport) FX_EMAIL_REPORT="$2"; shift;;
                    --reportType) FX_REPORT_TYPE="$2"; shift;;

                    # To Fail script execution on Vulnerable severity
                    --fail-on-vuln-severity) FAIL_ON_VULN_SEVERITY="$2"; shift;;


                    # For Refreshing Project Playbooks
                    --refresh-playbooks) REFRESH_PLAYBOOKS="$2"; shift;;

                    # For Project Registeration via OpenSpecUrl
                    --openAPISpecUrl) OPEN_API_SPEC_URL="$2"; shift;;

                    # For Project Registeration via OpenSpecFile
                    --openAPISpecFile) openText="$2"; shift;;

                    # For Project Registeration via OpenSpecUrl
                    --internal_OpenAPISpecUrl) INTERNAL_OPEN_API_SPEC_URL="$2"; shift;;
                    --specType) SPEC_TYPE="$2"; shift;;

                    # For Project Profile To be Updated with a scanner
                    --profileScanner) PROFILE_SCANNER="$2"; shift;;
		    
                    # For Project Credentials Update
                    --envName) ENV_NAME="$2"; shift;;                        
                    --authName) AUTH_NAME="$2"; shift;;       
                    --app_username) APP_USER="$2"; shift;;
                    --app_password) APP_PWD="$2"; shift;; 
                    #--app_endPointUrl) ENDPOINT_URL="$2"; shift;;
                    --app_token_param) TOKEN_PARAM="$2"; shift;;
                    --header_1) COMPLETE_HEADER1="$2"; shift;;
		    
		    # To update BaseUrl
                    --baseUrl) BASE_URL="$2"; shift;;

                    --category) CAT="$2"; shift;;
                    #--tier) TIER="$2"; shift;;		    
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

if [ "$FX_PROJECT_NAME" != "" ]; then
      PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/-/ /g' | sed 's/@/ /g' | sed 's/#/ /g' |  sed 's/&/ /g' | sed 's/*/ /g' |  sed 's/(/ /g' | sed 's/)/ /g' | sed 's/=/ /g' | sed 's/+/ /g' | sed 's/~/ /g' | sed 's/\// /g' | sed 's/\\/ /g' | sed 's/\^/ /g' | sed 's/\;/ /g' | sed 's/\:/ /g' | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\./ /g' | sed 's/\,/ /g')
      FX_PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/ /%20/g' |  sed 's/-/%20/g' | sed 's/@/%20/g' | sed 's/#/%20/g' |  sed 's/&/%20/g' | sed 's/*/%20/g' |  sed 's/(/%20/g' | sed 's/)/%20/g' | sed 's/=/%20/g' | sed 's/+/%20/g' | sed 's/~/%20/g' | sed 's/\//%20/g' | sed 's/\\/%20/g' | sed 's/\^/%20/g' | sed 's/\;/%20/g' | sed 's/\:/%20/g' | sed 's/\[/%20/g' | sed 's/\]/%20/g' | sed 's/\./%20/g' | sed 's/\,/%20/g')
fi

if   [ "$PROFILE_NAME" == ""  ]; then
        PROFILE_NAME=Master
fi

FX_SCRIPT=""
if [ "$FX_TAGS" != "" ];
then
FX_SCRIPT="&tags=script:"+${FX_TAGS}
fi

# To Fail script execution on Vulnerable severity
if   [ "$FAIL_ON_VULN_SEVERITY" == "Critical"  ] || [ "$FAIL_ON_VULN_SEVERITY" == "High"  ] || [ "$FAIL_ON_VULN_SEVERITY" == "Medium"  ]; then
        FAIL_ON_VULN_SEVERITY_FLAG=true
else
        FAIL_ON_VULN_SEVERITY_FLAG=false        
fi

# For Project Registeration via OpenSpecUrl
if   [ "$OPEN_API_SPEC_URL" == ""  ]; then
        OAS=false
else
        OAS=true

fi

if [ "$INTERNAL_OPEN_API_SPEC_URL" == "" ]; then
      INTERNAL_SPEC_FLAG=false
else     
     INTERNAL_SPEC_FLAG=true
fi

# For Project Registeration/Update via OpenSpecFile
if   [ "$openText" == ""  ]; then
        OASFile=false
else
        OASFile=true       

fi

# For Refreshing Project Playbooks
if   [ "$REFRESH_PLAYBOOKS" == ""  ]; then
        REFRESH_PLAYBOOKS=false
fi

# For Project Profile To be Updated with a scanner
if   [ "$PROFILE_SCANNER" == ""  ] || [ "$PROFILE_NAME" == ""  ];  then
        PROFILE_SCANNER_FLAG=false
else 
        PROFILE_SCANNER_FLAG=true
        SCANNER_NAME=$(echo $PROFILE_SCANNER)
fi

# To check scanner exists
if   [ "$REGION" == ""  ]; then
        SCANNER_NAME_FLAG=false
else 
        SCANNER_NAME_FLAG=true         
fi

# For Project Credentials Update
if   [ "$AUTH_NAME" == ""  ]; then
        AUTH_FLAG=false
else 
        AUTH_FLAG=true
fi

# For Project Credentials Update
if [ "$TOKEN_PARAM" = "" ];
then
    TOKEN_PARAM=".info.token"
fi


# For Project BaseUrl Update
if   [ "$BASE_URL" == ""  ]; then
        BASE_URL_FLAG=false
else 
        BASE_URL_FLAG=true
fi

# For Project Name exist check
if   [ "$FX_PROJECT_NAME" == ""  ]; then
        PROJECT_NAME_FLAG=false
else 
        PROJECT_NAME_FLAG=true
fi

tokenResp=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login )
#tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | cut -d{ -f1 | cut -d} -f2 | cut -d'"' -f2)
tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | tr -d '{' | tr -d '}' | tr -d '"') 
if [ $tokenResp1 == "token" ];then
      token=$(echo $tokenResp | jq -r '.token')
      echo "generated token is:" $token
      echo " "  
elif [ $tokenResp1 == "message" ];then  
       message=$(echo $tokenResp | jq -r '.message')
       echo "$message. Please provide correct User Credentials!!"
       echo " "
       exit 1
fi

# For Project Registeration via OpenSpecUrl
if [ "$OAS" = true ]; then

     getProjectName=$(curl -s -X GET "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" -H "accept: */*"  --header "Authorization: Bearer $token" | jq -r '.data|.name')          
     if [ "$getProjectName" == null ];then
                echo "Registering Project '${PROJECT_NAME}' via OpenAPISpecUrl method!!"
                echo ' '
                response=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer $token" -d  '{"name":"'"${PROJECT_NAME}"'","openAPISpec":"'${OPEN_API_SPEC_URL}'","planType":"ENTERPRISE","isFileLoad": false,"source":"FILE","personalizedCoverage":{"auths":[]}}')
                message=$(jq -r '.messages[].value' <<< "$response")                                          
                data=$(jq -r '.data' <<< "$response")
                project_name=$(jq -r '.name' <<< "$data")
                project_id=$(jq -r '.id' <<< "$data")

                sleep 5
                #dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
                #projectId=$(echo "$dto" | jq -r '.id')                
                #curl -s -X PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" > /dev/null
                if [ -z "$project_id" ] || [  "$project_id" == null ]; then
                        echo "Project Id is $project_id/empty" > /dev/null
                        echo "Error Message: $message"
                        echo " "
                        exit 1
                else
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

                                      playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${project_id}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                                      #playbookTaskStatus="In_progress"
                                      if [ "$playbookTaskStatus" == "Done" ]; then
                                            echo " "
                                            echo "Playbooks generation task for the registered project '$PROJECT_NAME' is succesfully completed!!!"                                 
                                            echo "ProjectName: '$project_name'"
                                            echo "ProjectId: $project_id"
                                            echo 'Script Execution is Done.'
                                            exit 0
                                      fi

                                      if [ $retryCount -ge 55  ]; then
                                           echo " "
                                           retryCount=`expr $retryCount \* 2`  
                                           echo "Playbooks Generation Task Status $playbookTaskStatus even after $retryCount seconds, so halting/breaking script execution!!!"
                                           exit 1
                                      fi
                                 done
                        REFRESH_PLAYBOOKS=false
                fi   
     elif [ "$getProjectName" == "$PROJECT_NAME" ];then
             echo "Updating Project '${PROJECT_NAME}' via OpenAPISpecUrl method!!"
             dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
             projectId=$(echo "$dto" | jq -r '.id')
             orgId=$(echo "$dto" | jq -r '.org.id')             
             data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" --header "Authorization: Bearer $token" -d  '{"id":"'${projectId}'","org":{"id":"'${orgId}'"},"name":"'"${PROJECT_NAME}"'","openAPISpec":"'${OPEN_API_SPEC_URL}'","openText": "","isFileLoad":false}' | jq -r '.data')
             echo ' '             
             project_name=$(jq -r '.name' <<< "$data")
             project_id=$(jq -r '.id' <<< "$data")

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
                        playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                
                        if [ "$playbookTaskStatus" == "Done" ]; then
                              echo " "
                              echo "Project update via OpenAPISpecUrl  and playbooks refresh task is succesfully completed!!!"
                              echo "ProjectName: '$project_name'"
                              echo "ProjectId: $project_id"
                              echo " "
                              #echo 'Script Execution is Done.'
                              #exit 0
                        fi

                        if [ $retryCount -ge 55  ]; then
                             echo " "
                             retryCount=`expr $retryCount \* 2`  
                             echo "Playbook Regenerate Task Status is $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                             exit 1
                        fi                            
                    done       
     fi
    
fi

# For Project Registeration/Update via OpenSpecFile
if [ "$OASFile" = true ]; then
      fileExt=$(echo $openText)
      if [[ "$fileExt" == *"yaml"* ]] ||  [[ "$fileExt" == *"yml"* ]]; then
             echo "yaml file upload option is used."
             openText=$(yq -r -o=json $openText)
             openText=$(echo $openText |  jq . -Rc)
      fi

      if [[ "$fileExt" == *"json"* ]]; then
             echo "json file upload option is used."
             openText=$(cat "$openText" )
             openText=$(echo $openText |  jq . -Rc )
      fi

      getProjectNameFile=$(curl -s -X GET "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" -H "accept: */*"  --header "Authorization: Bearer $token" | jq -r '.data|.name')
      if [ "$getProjectNameFile" == null ]; then
             echo "Registering Project '${PROJECT_NAME}' via fileupload method!!"                          
             response=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer $token" -d  '{"name":"'"${PROJECT_NAME}"'","openAPISpec":"none","planType":"ENTERPRISE","isFileLoad": "true","openText": '"${openText}"',"source": "API","personalizedCoverage":{"auths":[]}}')                                       
             message=$(jq -r '.messages[].value' <<< "$response")                          
             data=$(jq -r '.data' <<< "$response")
             echo ' '
             project_name=$(jq -r '.name' <<< "$data")
             project_id=$(jq -r '.id' <<< "$data")

             if [ -z "$project_id" ] || [  "$project_id" == null ]; then
                   echo "Project Id is $project_id/empty" > /dev/null
                   echo "Error Message: $message"
                   echo " "
                   exit 1
             else

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

                                playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${project_id}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                                #playbookTaskStatus="In_progress"
                                if [ "$playbookTaskStatus" == "Done" ]; then
                                       echo " "
                                       echo "Playbooks generation task for the registered project '$PROJECT_NAME' is succesfully completed!!!"                                 
                                       echo "ProjectName: '$project_name'"
                                       echo "ProjectId: $project_id"
                                       echo 'Script Execution is Done.'
                                       exit 0
                                fi

                                if [ $retryCount -ge 55  ]; then
                                       echo " "
                                       retryCount=`expr $retryCount \* 2`  
                                       echo "Playbooks Generation Task Status $playbookTaskStatus even after $retryCount seconds, so halting/breaking script execution!!!"
                                       exit 1
                                fi
                            done      
             fi
      elif [ "$getProjectNameFile" == "$PROJECT_NAME" ];then
             echo "Updating Project '${PROJECT_NAME}' via fileupload method!!"
             dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
             projectId=$(echo "$dto" | jq -r '.id')
             orgId=$(echo "$dto" | jq -r '.org.id')
             data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" --header "Authorization: Bearer $token" -d  '{"id":"'${projectId}'","org":{"id":"'${orgId}'"},"name":"'"${PROJECT_NAME}"'","openAPISpec":"None","openText": '"${openText}"',"isFileLoad":true}' | jq -r '.data')
             echo ' '
             project_name=$(jq -r '.name' <<< "$data")
             project_id=$(jq -r '.id' <<< "$data")


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
                        playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                
                        if [ "$playbookTaskStatus" == "Done" ]; then
                              echo " "
                              echo "OpenAPISpecFile upload and playbooks refresh task is succesfully completed!!!"
                              echo "ProjectName: $project_name"
                              echo "ProjectId: $project_id"
                              echo " "
                              #echo 'Script Execution is Done.'
                              #exit 0
                        fi

                        if [ $retryCount -ge 55  ]; then
                             echo " "
                             retryCount=`expr $retryCount \* 2`  
                             echo "Playbook Regenerate Task Status is $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                             exit 1
                        fi                            
                    done    
   

      fi

fi

# For Project Registeration/Update via a combination of OpenSpecUrl and OpenSpecFile
if [ "$INTERNAL_SPEC_FLAG" = true ]; then      
      fileExt=$(echo $SPEC_TYPE)
      if [[ "$fileExt" == *"yaml"* ]] ||  [[ "$fileExt" == *"yml"* ]]; then
             echo "yaml file upload option is used."
             wget $INTERNAL_OPEN_API_SPEC_URL -O open-api-spec.yaml
             openText1=open-api-spec.yaml            
             openText=$(yq -r -o=json $openText1)
             openText=$(echo $openText |  jq . -Rc)
             rm -rf open-api-spec.yaml
      fi

      if [[ "$fileExt" == *"json"* ]]; then
             echo "json file upload option is used."
             wget $INTERNAL_OPEN_API_SPEC_URL -O open-api-spec.json
             openText1=open-api-spec.json             
             openText=$(cat "$openText1" )
             openText=$(echo $openText |  jq . -Rc)
             rm -rf open-api-spec.json
      fi      
      getProjectNameFile=$(curl -s -X GET "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" -H "accept: */*"  --header "Authorization: Bearer $token" | jq -r '.data|.name')
      if [ "$getProjectNameFile" == null ]; then
             echo "Registering Project '${PROJECT_NAME}' via fileupload method!!"
             response=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer $token" -d  '{"name":"'"${PROJECT_NAME}"'","openAPISpec":"none","planType":"ENTERPRISE","isFileLoad": "true","openText": '"${openText}"',"source": "API","personalizedCoverage":{"auths":[]}}')                                       
             message=$(jq -r '.messages[].value' <<< "$response")                          
             data=$(jq -r '.data' <<< "$response")
             echo ' '
             project_name=$(jq -r '.name' <<< "$data")
             project_id=$(jq -r '.id' <<< "$data")
             #data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'"${PROJECT_NAME}"'","openAPISpec":"none","planType":"ENTERPRISE","isFileLoad": "true","openText": '${openText}',"source": "API","personalizedCoverage":{"auths":[]}}'  | jq -r '.data') 

            #  echo ' '
            #  project_name=$(jq -r '.name' <<< "$data")
            #  project_id=$(jq -r '.id' <<< "$data")

             if [ -z "$project_id" ] || [  "$project_id" == null ]; then
                   echo "Project Id is $project_id/empty" > /dev/null
                   echo "Error Message: $message"
                   exit 1
             else
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
                                  sleep 10
                                  playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${project_id}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                                  #playbookTaskStatus="In_progress"
                                  if [ "$playbookTaskStatus" == "Done" ]; then
                                         echo " "
                                         echo "Playbooks generation task for the registered project '$PROJECT_NAME' is succesfully completed!!!"                                 
                                         echo "ProjectName: '$project_name'"
                                         echo "ProjectId: $project_id"
                                         echo 'Script Execution is Done.'
                                         exit 0
                                  fi

                                  if [ $retryCount -ge 55  ]; then
                                         echo " "
                                         retryCount=`expr $retryCount \* 2`  
                                         echo "Playbooks Generation Task Status $playbookTaskStatus even after $retryCount seconds, so halting/breaking script execution!!!"
                                         exit 1
                                  fi
                            done
             fi
      elif [ "$getProjectNameFile" == "$PROJECT_NAME" ];then
             echo "Updating Project '${PROJECT_NAME}' via fileupload method!!"
             dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
             projectId=$(echo "$dto" | jq -r '.id')
             orgId=$(echo "$dto" | jq -r '.org.id')
             data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" --header "Authorization: Bearer $token" -d  '{"id":"'${projectId}'","org":{"id":"'${orgId}'"},"name":"'"${PROJECT_NAME}"'","openAPISpec":"None","openText": '"${openText}"',"isFileLoad":true}' | jq -r '.data')
             echo ' '
             project_name=$(jq -r '.name' <<< "$data")
             project_id=$(jq -r '.id' <<< "$data")


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
                        playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                
                        if [ "$playbookTaskStatus" == "Done" ]; then
                              echo "OpenAPISpecFile upload and playbooks refresh task is succesfully completed!!!"
                              echo "ProjectName: $project_name"
                              echo "ProjectId: $project_id"
                              echo " "
                              #echo 'Script Execution is Done.'
                              #exit 0
                        fi

                        if [ $retryCount -ge 55  ]; then
                             echo " "
                             retryCount=`expr $retryCount \* 2`  
                             echo "Playbook Regenerate Task Status is $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                             exit 1
                        fi                            
                    done       

      fi

fi

# To check Project Name existence 
if [ "$PROJECT_NAME_FLAG" = true ]; then
      dtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token")
      errorsFlag=$(echo "$dtoData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$dtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
           getProjectName=$(echo "$dtoData" | jq -r '.data.name')
           #echo $getProjectName
           echo $errMsg
           exit 1
      elif [ $errorsFlag = false ]; then            
            dto=$(echo "$dtoData" | jq -r '.data')
            PROJECT_ID=$(echo "$dto" | jq -r '.id')
            getProjectName=$(echo "$dtoData" | jq -r '.data.name')
            #echo $getProjectName
      fi
fi 

# To check Scanner Name existence
if [ "$SCANNER_NAME_FLAG" = true ]; then      
      scanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer $token")
      errorsFlag=$(echo "$scanData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$scanData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')           
           echo $errMsg
           exit 1
      elif [ $errorsFlag = false ]; then            
            scanCount=0            
            scanners_Names=$(jq -r '.data[].name' <<< "$scanData")           
            for sName in ${scanners_Names}
               do 
                   if [ "$sName" == "$REGION" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done
            superScanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters/superbotnetwork?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer $token")
            super_scanners_Names=$(jq -r '.data[].name' <<< "$superScanData")
            for sName in ${super_scanners_Names}
               do 
                   if [ "$sName" == "$REGION" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done

            if [ $scanCount -le 0 ]; then
                 echo "$REGION scanner doesn't exists!!"
                 exit 1
            fi

      fi
fi


# For Refreshing Project Playbooks
if [ "$REFRESH_PLAYBOOKS" = true ]; then
     #dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
     projectId=$(echo "$dto" | jq -r '.id')
     updatedData=$(curl -s -X PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$dto")
     uErrorsFlag=$(echo $updatedData | jq -r '.errors')
     if [ $uErrorsFlag = true ]; then     
           errMsg=$(echo "$updatedData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
           echo $errMsg
           exit 1
     elif [ $uErrorsFlag = false ]; then                              
            playbookTaskStatus="In_progress"
            echo "playbookTaskStatus = " $playbookTaskStatus
            retryCount=0
            pCount=0

            while [ "$playbookTaskStatus" == "In_progress" ]
                  do
                      if [ $pCount -eq 0 ]; then
                           echo "Checking playbooks refresh task Status...."
                      fi
                      pCount=`expr $pCount + 1`  
                      retryCount=`expr $retryCount + 1`  
                      sleep 2

                      playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '."data".status')
                      #playbookTaskStatus="In_progress"
                      if [ "$playbookTaskStatus" == "Done" ]; then
                            echo "Playbooks refresh task is succesfully completed!!!"
                      fi

                      if [ $retryCount -ge 55  ]; then
                           echo " "
                           retryCount=`expr $retryCount \* 2`  
                           echo "Playbook refresh Task Status $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                           exit 1
                      fi                            
                  done
      fi
fi

# For Project Profile To be Updated with a scanner
if [ "$PROFILE_SCANNER_FLAG" = true ]; then
            PROJECT_ID=$(echo "$dto" | jq -r '.id')
            #pdto=$(echo $dto |  tr -d ' ')                 
            data=$(curl -s --location --request GET "${FX_HOST}/api/v1/jobs/project-id/${PROJECT_ID}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC"  --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[]')
            ProfNames=$(echo $data | jq -r '.name')
            ProfCount=0            
            
            for pName in ${ProfNames}
               do 
                   if [ "$pName" == "$PROFILE_NAME" ]; then   
                         ProfCount=`expr $ProfCount + 1`  
                  fi
               done  
            if [ $ProfCount -le 0 ]; then
                 echo "$PROFILE_NAME profile doesn't exists in $PROJECT_NAME project!!"
                 exit 1
            fi            

            scanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer $token")
            scanCount=0            
            scanners_Names=$(jq -r '.data[].name' <<< "$scanData")
            org_Name=$(echo "$scanData" | jq -r '.data[].org.name')
            org_Name=$(echo "$org_Name" | sort -u)
            for sName in ${scanners_Names}
               do 
                   if [ "$sName" == "$PROFILE_SCANNER" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done
            superScanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters/superbotnetwork?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer $token")
            super_scanners_Names=$(jq -r '.data[].name' <<< "$superScanData")
            for sName in ${super_scanners_Names}
               do 
                   if [ "$sName" == "$PROFILE_SCANNER" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done               
            if [ $scanCount -le 0 ]; then
                 echo "$PROFILE_SCANNER scanner doesn't exists!!"
                 exit 1
            fi

            for row in $(echo "${data}" | jq -r '. | @base64'); 
                do
                       _jq() {
                             echo ${row} | base64 --decode | jq -r ${1}
                       }
                       profName=$(echo "$(_jq '.')" | jq  -r '.name')
                       profId=$(echo "$(_jq '.')" | jq  -r '.id')    
                       if [ "$PROFILE_NAME" == "$profName"  ]; then
                              echo "Updating $PROFILE_NAME profile with $SCANNER_NAME scanner in $FX_PROJECT_NAME project!!"
                              udto=$(echo "$(_jq '.')" | jq '.regions = "'${SCANNER_NAME}'"')
                              envId=$(echo "$(_jq '.')" | jq '.environment.id')
                              envName=$(echo "$(_jq '.')" | jq '.environment.name')
                              updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto")
                              #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data')
                              uErrorsFlag=$(echo $updatedData | jq -r '.errors')
                              if [ $uErrorsFlag = true ]; then     
                                    errMsg=$(echo "$updatedData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                    echo $errMsg
                                    exit 1
                              elif [ $uErrorsFlag = false ]; then 
                                  
                                     updatedProfData=$(echo $updatedData | jq -r '.data')                
                                     updatedScanner=$(echo "$updatedProfData" | jq -r '.regions')
                                     echo " "
                                     echo "ProjectName: $FX_PROJECT_NAME"
                                     echo "ProjectId: $PROJECT_ID"
                                     echo "EnvironmentName: $envName"
                                     echo "EnvironmentId: $envId"                                                                                                            
                                     echo "ProfileName: $PROFILE_NAME"                                                                                                                                                                                        
                                     echo "ProfileId: $profId"
                                     echo "UpdatedScannerName: $updatedScanner"
                                     echo " " 
                                     #exit 0
                              fi
                                                  
                       fi
                done
      #fi            
fi


# For Project Credentials Update
if   [ "$AUTH_FLAG" = true  ]; then
        
        #dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
        PROJECT_ID=$(echo "$dto" | jq -r '.id')
        authData=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[]')
        EnvNames=$(echo $authData | jq -r '.name')
        EnvCount=0
        for eName in ${EnvNames}
            do 
                if [ "$eName" == "$ENV_NAME" ]; then   
                        EnvCount=`expr $EnvCount + 1`  
                fi
            done  
        if [ $EnvCount -le 0 ]; then
              echo "$ENV_NAME environment doesn't exists in $PROJECT_NAME project!!"
              exit 1
        fi        

             for row in $(echo "${authData}" | jq -r '. | @base64'); 
                 do
                      _jq() {
                             echo ${row} | base64 --decode | jq -r ${1}
                      }
                      eName=$(echo "$(_jq '.')" | jq  -r '.name')
                      eId=$(echo "$(_jq '.')" | jq  -r '.id')

                      if [ "$ENV_NAME" == "$eName"  ]; then
                            updatedAuths=$(echo "$(_jq '.')" | jq -r '.auths[]')
                            updatedAuths1=$(echo "$(_jq '.')" | jq -r '.auths')
                            AuthNames=$(echo "$(_jq '.')" | jq -r '.auths[].name')                                                      
                            AuthCount=0
                            for aName in ${AuthNames}
                                do 
                                     if [ "$aName" == "$AUTH_NAME" ]; then   
                                          AuthCount=`expr $AuthCount + 1`  
                                     fi
                                done  
                            if [ $AuthCount -le 0 ]; then
                                  echo "$AUTH_NAME auth doesn't exists in $ENV_NAME environment  for $PROJECT_NAME project!!"
                                  exit 1
                            fi
                            
                            for row1 in $(echo "${updatedAuths}" | jq -r '. | @base64');
                                do
                                      _pq() {
                                            echo ${row1} | base64 --decode | jq -r ${1}
                                      }
                                      authType=$(echo "$(_pq '.')" | jq -r '.authType')                                
                                      authName=$(echo "$(_pq '.')" | jq -r '.name')

                                      case "$authType" in "Basic")   if [ "$authName" == "$AUTH_NAME" ]; then   
                                                                           echo "Updating '$AUTH_NAME' Auth with Basic as AuthType of '$ENV_NAME' environment in '$FX_PROJECT_NAME' project!!"
                                                                           echo " "
                                                                           bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.username = "'${APP_USER}'" | .password = "'${APP_PWD}'"))' | jq -c .) 
                                                                           udto=$(echo "$(_jq '.')" | jq '.auths = '"${bAuth}"'')
                                                                           #updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto" | jq -r '.data')
                                                                           updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto")
                                                                           uErrorsFlag=$(echo $updatedResp | jq -r '.errors')

                                                                           if [ $uErrorsFlag = true ]; then     
                                                                                 errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                                 echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                                 exit 1
                                                                           elif [ $uErrorsFlag = false ]; then
                                                                                   updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                                   updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                                   for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                       do
                                                                                              _aq() {
                                                                                                    echo ${row2} | base64 --decode | jq -r ${1}
                                                                                              }
                                                                                              upAuthName=$(echo "$(_aq '.')" | jq -r '.name')
                                                                                              if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                     updatedAuthObj=$(echo "$(_aq '.')" | jq -r .)
                                                                                                     echo " " 
                                                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                                                     echo "EnvironmentId: $eId" 
                                                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                                                     echo " "
                                                                                              fi
                                                                                       done
                                                                           fi            
                                                                     fi ;;
                                                     
                                                         "Digest")   if [ "$authName" == "$AUTH_NAME" ]; then   
                                                                           echo "Updating '$AUTH_NAME' Auth with Digest as AuthType of '$ENV_NAME' environment  in '$FX_PROJECT_NAME' project!!"
                                                                           echo " "
                                                                           bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.username = "'${APP_USER}'" | .password = "'${APP_PWD}'"))' | jq -c .) 
                                                                           udto=$(echo "$(_jq '.')" | jq '.auths = '"${bAuth}"'')
                                                                           #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto" | jq -r '.data') 
                                                                           updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto")
                                                                           uErrorsFlag=$(echo $updatedResp | jq -r '.errors')

                                                                           if [ $uErrorsFlag = true ]; then     
                                                                                 errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                                 echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                                 exit 1
                                                                           elif [ $uErrorsFlag = false ]; then
                                                                                   updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                                   updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                                   for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                       do
                                                                                              _aq() {
                                                                                                    echo ${row2} | base64 --decode | jq -r ${1}
                                                                                              }
                                                                                              upAuthName=$(echo "$(_aq '.')" | jq -r '.name')
                                                                                              if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                     updatedAuthObj=$(echo "$(_aq '.')" | jq -r .)
                                                                                                     echo " " 
                                                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                                                     echo "EnvironmentId: $eId" 
                                                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                                                     echo " "
                                                                                              fi
                                                                                       done
                                                                           fi              
                                                                     fi ;;

                                                         "Token")   if [ "$authName" == "$AUTH_NAME" ]; then 
                                                                           echo "Updating '$AUTH_NAME' Auth with Token as AuthType of '$ENV_NAME' environment in '$FX_PROJECT_NAME' project!!"
                                                                           echo " "  
                                                                           #auth='Authorization: Bearer {{@CmdCache | curl -s -d '\'{"username":"${APP_USER}","password":"${APP_PWD}"}\'' -H '"Content-Type: application/json"' -H '"Accept: application/json"' -X POST '${ENDPOINT_URL}' | jq --raw-output '"'${TOKEN_PARAM}'"' }}'                                                                
                                                                           #bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = "'"${auth}"'" ))' | jq -c . )
                                                                           #auth='Authorization: Bearer {{@CmdCache | curl -s -d '\'{"\"""username"\""":"\"""${APP_USER}"\""","\"""password"\""":"\"""${APP_PWD}"\"""}\'' -H '\'"Content-Type: application/json"\'' -H '\'"Accept: application/json"\'' -X POST '${ENDPOINT_URL}' | jq --raw-output '"'${TOKEN_PARAM}'"' }}'                                                                     
                                                                           auth=$(echo $COMPLETE_HEADER1)
                                                                           bAuth=$(echo $updatedAuths1 | jq --arg path "$auth" 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = $path ))' | jq -c . )                                                                                                                                                      
                                                                           udto=$(echo "$(_jq '.')" | jq '.auths = '"${bAuth}"'')
                                                                           #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto" | jq -r '.data') 
                                                                           updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$udto")
                                                                           uErrorsFlag=$(echo $updatedResp | jq -r '.errors')

                                                                           if [ $uErrorsFlag = true ]; then     
                                                                                 errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                                 echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                                 exit 1
                                                                           elif [ $uErrorsFlag = false ]; then
                                                                                   updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                                   updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                                   for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                       do
                                                                                              _aq() {
                                                                                                    echo ${row2} | base64 --decode | jq -r ${1}
                                                                                              }
                                                                                              upAuthName=$(echo "$(_aq '.')" | jq -r '.name')
                                                                                              if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                     updatedAuthObj=$(echo "$(_aq '.')" | jq -r .)
                                                                                                     echo " " 
                                                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                                                     echo "EnvironmentId: $eId" 
                                                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                                                     echo " "                                                                                                     
                                                                                              fi
                                                                                       done
                                                                           fi 
                                                                     fi ;;
                                      esac
                            done                   
                      fi

                 done
         

fi

# For Project BaseUrl Update
if [ "$BASE_URL_FLAG" = true ]; then 
      #dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data')
      PROJECT_ID=$(echo "$dto" | jq -r '.id')
      data=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[]')
      EnvNames=$(echo $data | jq -r '.name')
      EnvCount=0
      for eName in ${EnvNames}
          do 
              if [ "$eName" == "$ENV_NAME" ]; then   
                     EnvCount=`expr $EnvCount + 1`  
              fi
          done  
      if [ $EnvCount -le 0 ]; then
             echo "$ENV_NAME environment doesn't exists in $PROJECT_NAME project!!"
             exit 1
      fi 
      
      for row in $(echo "${data}" | jq -r '. | @base64'); 
         do
               _jq() {
                    echo ${row} | base64 --decode | jq -r ${1}
                }
                eName=$(echo "$(_jq '.')" | jq  -r '.name')
                eId=$(echo "$(_jq '.')" | jq  -r '.id') 
    
               if [ "$ENV_NAME" == "$eName"  ]; then
                     echo "Updating $ENV_NAME environment with $BASE_URL as baseurl in $PROJECT_NAME project!!"
                     dto=$(echo "$(_jq '.')" | jq '.baseUrl = "'${BASE_URL}'"')
                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$dto")
                     uErrorsFlag=$(echo $updatedData | jq -r '.errors')

                           if [ $uErrorsFlag = true ]; then     
                                 errMsg=$(echo "$updatedData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                 echo $errMsg
                                 exit 1
                           elif [ $uErrorsFlag = false ]; then 
                                  #exit 1
                                  updatedBaseData=$(echo $updatedData | jq -r '.data')
                                  #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" -d "$dto" | jq -r '.data')
                                  updatedBaseUrl=$(echo "$updatedBaseData" | jq -r '.baseUrl')
                                  echo " "
                                  echo "ProjectName: $PROJECT_NAME"
                                  echo "ProjectId: $PROJECT_ID"
                                  echo "EnvironmentName: $ENV_NAME"
                                  echo "EnvironmentId: $eId"
                                  echo "UpdatedBaseUrl: $updatedBaseUrl"
                                  echo " "                    
                           fi        
               fi
        done

fi

#URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}"
#URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&&categories=ABAC_Level1,%20ABAC_Level2,%20ABAC_Level3,%20InvalidAuth,%20InvalidAuthEmpty,%20InvalidAuthSQL,%20Unsecured,%20Excessive_Data_Exposure,%20Incremental_Ids,%20incremental_ids_l2,%20Pii,%20Sensitive_Data_Exposure,%20sensitive_data_exposure_l2,%20ADoS,%20ratelimit_authenticated,%20ratelimit_unauthenticated,%20RBAC,%20cors_config,%20tls_headers,%20http_authentication_scheme,%20Linux_Command_Injection,%20NoSQL_Injection,%20sql_injection_timebound,%20NoSQL_Injection_Filter,%20sql_injection_filter,%20XSS_Injection,%20Windows_Command_Injection,%20open_api_spec_compliance,%20disable_user_after_5_failed_login_attempts,%20error_logging,%20insufficient_logging,%20insufficient_monitoring,%20log4j_injection,%20resource_not_found_logging,%20strong_and_unique_password,%20insecure_cookies,%20SLA,%20SimpleGET&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}"
#url=$( echo "$URL" | sed 's/ /%20/g' )
#echo "The request is $url"

# case "$TIER" in "Tier_0")  URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=Tier_0&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" ;
#                           #echo "Tier_0 Profile Categories will be run: 'Missing TLS HSTS Headers' 'SSL Certificate Issues' 'Server Properties Leak in Headers'" ;
#                           echo "Tier_0 Profile Categories will be scan!!"
#                           echo " "
#                           url=$( echo "$URL" | sed 's/ /%20/g' ) ;
#                           echo "The request is $url" ;
#                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]');;
#                  "Tier_1") URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=Tier_1&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" ;
#                           #echo "Tier_1 Profile Categories will be run: 'CORS Config' 'PII Data Exposure' 'Reflected GET Injection' 'Reflected POST Injection' 'Sensitive Data Exposure' " ;
#                           echo "Tier_1 Profile Categories will be scan!!"
#                           echo " "
#                           url=$( echo "$URL" | sed 's/ /%20/g' ) ;
#                           echo "The request is $url" ;
#                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]');;

#                  "Tier_2") URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=Tier_2&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" ;
#                           #echo "Tier_2 Profile Categories will be run: All categories will run" ;
#                           echo "Tier_2 Profile Categories will be scan!!"
#                           echo " "
#                           url=$( echo "$URL" | sed 's/ /%20/g' ) ;
#                           echo "The request is $url" ;
#                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]');;

#                  "Tier_3") URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=Tier_3&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" ;
#                           #echo "Tier 4 Categories will be run: 'Open_api_spec_compliance' 'Disable_user_after_5_failed_login_attempts' 'Error_logging' 'Insufficient_logging' 'Insufficient_monitoring' 'Resource_not_found_logging' 'Strong_and_unique_password' " ;
#                           echo "Tier_3 Profile Categories will be scan!!"
#                           echo " "
#                           url=$( echo "$URL" | sed 's/ /%20/g' ) ;
#                           echo "The request is $url" ;
#                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]');;

#                  *)       URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${PROFILE_NAME}&region=${REGION}&categories=${CAT}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" ;
#                           url=$( echo "$URL" | sed 's/ /%20/g' ) ;
#                           #echo "Default Category will be run: 'Broken_Authentication' "
#                           echo " "
#                           echo "The request is $url" ;
#                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]');;
# esac

if [ "$PROFILE_NAME" == "Super" ]; then
      data=$(curl -s --location --request GET "${FX_HOST}/api/v1/jobs/project-id/${PROJECT_ID}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC"  --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[]')
      ProfNames=$(echo $data | jq -r '.name')
         for pName in ${ProfNames}
               do 
                     if [ "$pName" == "Tier_0" ] || [ "$pName" == "Tier_1" ] || [ "$pName" == "Tier_2" ] || [ "$pName" == "Tier_3" ]; then   
                           URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${pName}&region=${REGION}&categories=${CAT}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" 
                           url=$( echo "$URL" | sed 's/ /%20/g' )
                           echo "The request is $url"
                           echo " "
                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer $token" | jq -r '.["data"]')
                           runId=$( jq -r '.id' <<< "$data")
                           projectId=$( jq -r '.job.project.id' <<< "$data")
                           echo "runId =" $runId
                           if [ "$runId" == null ]
                           then
                                     echo "RunId = " "$runId"
                                     echo "Invalid runid"
                                     echo "$(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${pName}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer $token" | jq -r '.["data"]|.id')"
                                     exit 1
                           fi
                           taskStatus="WAITING"
                           echo "taskStatus = " $taskStatus

                           #while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
                           while [ "$taskStatus" == "WAITING" ] || [ "$taskStatus" == "PROCESSING" ]
                                    do
                                           sleep 5
                                           echo "Checking Status...."

                                           passPercent=$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer $token"| jq -r '.["data"]|.ciCdStatus')

                                                   IFS=':' read -r -a array <<< "$passPercent"

                                                   taskStatus="${array[0]}"

                                                   echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"
                                                   # VAR2=$(echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}")      


                                          if [ "$taskStatus" == "COMPLETED" ];then
                                                echo "------------------------------------------------"
                                                #echo  "Run detail link ${FX_HOST}/${array[7]}"
                                                echo  "Run detail link ${FX_HOST}${array[7]}"
                                                echo "-----------------------------------------------"
                                                echo "$pName Profile Categories Scan Successfully Completed!!"
                                                echo " "
                                                if [ "$FX_EMAIL_REPORT" = true ]; then     
                                                      sleep 10
                                                      echo "Will wait for 10 seconds"                       
                                                      totalEScount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}/test-suite-responses" -H "accept: */*"  --header "Authorization: Bearer $token"  | jq -r '.data[]|.id')
                                                      totalPGcount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}" -H "accept: */*"  --header "Authorization: Bearer $token"  | jq -r '.data.task.totalTests')
                                                      esCount=0
                                                      for scan in ${totalEScount}
                                                          do
                                                                esCount=`expr $esCount + 1`
                                                          done
                                                      if [ $totalPGcount -eq $esCount ]; then
                                                           echo "Email report will be sent in a short while!!"
                                                      else
                                                           echo "Email report will be sent after some delay!!"
                                                      fi
                                                fi

                                          fi
                                    done
                     fi
               done

         if [ "$OUTPUT_FILENAME" != "" ];then
               sarifoutput=$(curl -s --location --request GET "${FX_HOST}/api/v1/projects/${PROJECT_ID}/sarif" --header "Authorization: Bearer $token" | jq  '.data')
	         #echo $sarifoutput >> $OUTPUT_FILENAME
               echo $sarifoutput >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
               echo "SARIF output file created successfully"
               echo " "
         fi

         if [ "$FAIL_ON_VULN_SEVERITY_FLAG" = true ]; then
                severity=$(curl -s -X GET "${FX_HOST}/api/v1/projects/${PROJECT_ID}/vulnerabilities?&severity=All&page=0&pageSize=20" -H "accept: */*"  "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[] | .severity')
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
                case "$FAIL_ON_VULN_SEVERITY" in 
                      "Critical") for vul in ${severity}
                                      do
                         
                                          if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                 echo "Failing script execution since we have found $cVulCount Critical severity vulnerabilities!!!"
                                                 exit 1                                           
                                          fi                                             
                                      done
                      ;;
                      "High") for vul in ${severity}
                                  do
                                                     
                                      if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                             echo "Failing script execution since we have found $cVulCount Critical and $hVulCount High severity vulnerabilities!!!"
                                             exit 1
                                           
                                      fi                                             
                                  done
                      ;;                     
                      "Medium") for vul in ${severity}
                                    do
                                                
                                        if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] || [ "$vul" == "Medium"  ] ; then
                                               echo "Failing script execution since we have found $cVulCount Critical, $hVulCount High and $medVulCount Medium severity vulnerabilities!!!"
                                               exit 1
                                           
                                        fi                                             
                                    done
                       ;;
                       *)                          
                esac

         fi 
         
         if [ "$taskStatus" == "TIMEOUT" ];then
               echo "Task Status = " $taskStatus
               exit 1
         fi
         exit 0
         #echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
         #exit 1

else
      URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${PROFILE_NAME}&region=${REGION}&categories=${CAT}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" 
      url=$( echo "$URL" | sed 's/ /%20/g' )
      echo "The request is $url"
      echo " "
      data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer $token" | jq -r '.["data"]')  
      # data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer $token" | jq -r '.["data"]')
      runId=$( jq -r '.id' <<< "$data")
      projectId=$( jq -r '.job.project.id' <<< "$data")
      #runId=$(curl -s --location --request POST "$url" --header "Authorization: Bearer $token" | jq -r '.["data"]|.id')

      echo "runId =" $runId
      #if [ -z "$runId" ]
      if [ "$runId" == null ]
      then
            echo "RunId = " "$runId"
            echo "Invalid runid"
            echo "$(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${PROFILE_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer $token" | jq -r '.["data"]|.id')"
            exit 1
      fi


      taskStatus="WAITING"
      echo "taskStatus = " $taskStatus

      while [ "$taskStatus" == "WAITING" ] || [ "$taskStatus" == "PROCESSING" ]
      #while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]      
               do
                             sleep 5
                             echo "Checking Status...."

                             passPercent=$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer $token"| jq -r '.["data"]|.ciCdStatus')

                             IFS=':' read -r -a array <<< "$passPercent"

                             taskStatus="${array[0]}"

                             echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"
                             # VAR2=$(echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}")      


                             if [ "$taskStatus" == "COMPLETED" ];then
                                    echo "------------------------------------------------"
                                    #echo  "Run detail link ${FX_HOST}/${array[7]}"
                                    echo  "Run detail link ${FX_HOST}${array[7]}"
                                    echo "-----------------------------------------------"
                                    echo "$PROFILE_NAME Profile Catgories Scan Successfully Completed!!"
                                    echo " "
                                    if [ "$FX_EMAIL_REPORT" = true ]; then     
                                          sleep 10
                                          echo "Will wait for 10 seconds"                       
                                          totalEScount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}/test-suite-responses" -H "accept: */*"  --header "Authorization: Bearer $token"  | jq -r '.data[]|.id')
                                          totalPGcount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}" -H "accept: */*"  --header "Authorization: Bearer $token"  | jq -r '.data.task.totalTests')
                                          esCount=0 
                                          for scan in ${totalEScount}
                                              do
                                                   echo "$scan" > /dev/null
                                                   esCount=`expr $esCount + 1`
                                              done
                                          if [ $totalPGcount -eq $esCount ]; then
                                                echo "Email report will be sent in a short while!!"
                                          else
                                                echo "Email report will be sent after some delay!!"
                                          fi
                                    fi
			                  if [ "$OUTPUT_FILENAME" != "" ];then
                                          sarifoutput=$(curl -s --location --request GET "${FX_HOST}/api/v1/projects/${projectId}/sarif" --header "Authorization: Bearer $token" | jq  '.data')
		                              #echo $sarifoutput >> $OUTPUT_FILENAME
                                          echo $sarifoutput >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
               		                  echo "SARIF output file created successfully"
                                          echo " "
                                    fi
                                    if [ "$FAIL_ON_VULN_SEVERITY_FLAG" = true ]; then
                                          severity=$(curl -s -X GET "${FX_HOST}/api/v1/projects/${projectId}/vulnerabilities?&severity=All&page=0&pageSize=20" -H "accept: */*"  "Content-Type: application/json" --header "Authorization: Bearer $token" | jq -r '.data[] | .severity')

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
                                          case "$FAIL_ON_VULN_SEVERITY" in 
                                                "Critical") for vul in ${severity}
                                                                do
                                                
                                                                        if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                                               echo "Failing script execution since we have found $cVulCount Critical severity vulnerabilities!!!"
                                                                               exit 1                                           
                                                                        fi                                             
                                                                done
                                                ;;
                                                "High") for vul in ${severity}
                                                            do
                                                     
                                                                        if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                                               echo "Failing script execution since we have found $cVulCount Critical and $hVulCount High severity vulnerabilities!!!"
                                                                               exit 1
                                           
                                                                        fi                                             
                                                            done
                                                ;;                     
                                                "Medium") for vul in ${severity}
                                                              do
                                                
                                                                        if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] || [ "$vul" == "Medium"  ] ; then
                                                                               echo "Failing script execution since we have found $cVulCount Critical, $hVulCount High and $medVulCount Medium severity vulnerabilities!!!"
                                                                               exit 1
                                           
                                                                        fi                                             
                                                              done
                                                ;;
                                            *)                          
                                          esac

                                    fi 
                                    exit 0

                             fi
               done

      if [ "$taskStatus" == "TIMEOUT" ];then
            echo "Task Status = " $taskStatus
            exit 1
      fi

      echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer $token")"
      exit 1
fi 
#return 0




























































































































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
