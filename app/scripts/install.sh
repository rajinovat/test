#!/bin/ksh

rlseVersion=""
command=""
ENV=""
service=""
result=0
ROLLBACK=""
ROLLBACK_FLAG=""
ORIGIN=""
DESTINATION=""
SEARCH_ATTRIBUTES=""
MCPATH="/opt/LE/MessageConnect/bin"
infolease_app_home="/opt/lebuild/app"
SOFTWARE_HOME="/opt/lebuild"
ids_application_install_template="${infolease_app_home}/templates/ids.application.install.template"
ids_db_install_template="${infolease_app_home}/templates/ids.db.install.template"
ids_jdbc_bridge_install_template="${infolease_app_home}/templates/ids.jdbcbridge.install.template"
ids_report_install_template="${infolease_app_home}/templates/ids.report.install.template"

ids_application_configure_template="${infolease_app_home}/templates/ids.application.configure.template"

ids_unidata_stop_prompt_template="${infolease_app_home}/templates/unidata.stop.prompt.template"

ids_web_connect_install_template="${infolease_app_home}/templates/ids.web.connect.install.template"
#ids.db.install.template="${infolease_app_home}/templates/ids.db.install.template"


GROUP_TYPE=""
COMPONENT_LOCATION=""	#Release location full path

COMPONENT_TYPE=""		#Type of the component being deployed.. Possible values [ APP,DB,JDBC_BRIDGE,WEB_CONNECT, WEB.IDS_REPORT,INFOLEASE_REPORT ]
SERVER_TYPE=""

rlseVersion=""
command=""
ENV=""
instanceName=""
pentahoHome=""



# Do user input function
usage() {
        cat << EOF
        usage: $0 options

        This script performs standard maintenance functions for Infolease Application

        OPTIONS:
                -m              Help
                -r      Release Version - Release Version. Mandatory
                -c      command - [stop][compile][start][deploy][catalog] functions.
                -s		service - [WC][JB][WB][MC][UD]
                -e      env- [DEV][SIT][UAT][SVP][PROD][DR]
                -t      GROUP_TYPE - [core][wbc]


EOF
}

compile(){
## UniBasic Compile Function
###################
### variables required in UdtProc.sh
UDTLOGDIR="/opt/LE/udtlog"
DBDIR="/LE/${ENV}/LEUDTAC"
SEOSLOG="/LE/IL_logon/le.login.cfg"
BATCHID="LEBATCH"
MSGBANK="/opt/LE/Infolease/msgbank"
###################
#28-11-2016 - Modified code to add support for lebuild user to compile Unibasic Code. - Rajesh Ramasamy
#15-01/2017 - Commented unused code and removed ls usage in loops
#New Release Version Variable

myname=${0##*/}

#Emulate Key-stroke to UDT function

keysfl="$myname.$$.keys"
cd /LE/${ENV}/LEUDTAC/

   #Unlink existing symbolic link... Who knows where it refers too.....
   rm LE.BP

   #Create link to DevOps release folder
   ln -fs /opt/lebuild/releases/${GROUP_TYPE}/${ARTIFACT_ID}/${rlseVersion}/UniBasic LE.BP
      UNIKEY1='SELECT LE.BP WITH @ID UNLIKE "_..."\n'
       # UNIKEY2="CATALOG LE.BP LOCAL FORCE\nY\n"
          UNIKEY2="BASIC LE.BP\n"
            UNIKEY3="QUIT"
              echo -e $UNIKEY1$UNIKEY2$UNIKEY3 > $keysfl
              #q
                source ~/.bash_profile
                . /opt/LE/${ENV}/scripts/UdtProc.sh 1.4 2
                #
        #Cleanup DevOps link
   rm LE.BP
              
    #compile also the rollback implementation
    if [ -d "/opt/lebuild/releases/${GROUP_TYPE}/${ARTIFACT_ID}/${rlseVersion}/rollback/UniBasic" ]; then
    
    ln -fs /opt/lebuild/releases/${GROUP_TYPE}/${ARTIFACT_ID}/${rlseVersion}/rollback/UniBasic LE.BP
      UNIKEY1='SELECT LE.BP WITH @ID UNLIKE "_..."\n'
       # UNIKEY2="CATALOG LE.BP LOCAL FORCE\nY\n"
          UNIKEY2="BASIC LE.BP\n"
            UNIKEY3="QUIT"
              echo -e $UNIKEY1$UNIKEY2$UNIKEY3 > $keysfl
              #q
                source ~/.bash_profile
                . /opt/LE/${ENV}/scripts/UdtProc.sh 1.4 2
                #
    	
    fi            
   #Cleanup DevOps link
   rm LE.BP
   #Reinstate Original link
   ln -fs /opt/LE/${ENV}/UniBasic LE.BP
   print "$myname has completed successfully"
    
    
     result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Compilation - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         
         echo "------------------------------------------------------------------------"
         echo "Compilation - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
    
}

WBCCatalog(){
## UniBasic Catalog Function
###################
### variables required in UdtProc.sh
UDTLOGDIR="/opt/LE/udtlog"
DBDIR="/LE/${ENV}/LEUDTAC"
SEOSLOG="/LE/IL_logon/le.login.cfg"
BATCHID="LEBATCH"
MSGBANK="/opt/LE/Infolease/msgbank"
###################
#28-11-2016 - Modified code to add support for lebuild user to catalog Unibasic Binary. - Rajesh Ramasamy

#New Release Version Variable

myname=${0##*/} 

#Emulate Key-stroke to UDT function

keysfl="$myname.$$.keys"
cd /LE/${ENV}/LEUDTAC/
 
 #Reinstate Original link
   if [ -d /opt/LE/${ENV}/UniBasic ]; then
   	
   ln -fs /opt/LE/${ENV}/UniBasic LE.BP
 
     if [ -d "${SOFTWARE_HOME}/sw/${ENV}/UniBasic" ]; then
       UNIKEY1='SELECT LE.BP WITH @ID UNLIKE "_..."\n'
       UNIKEY2='LIST LE.BP\n\nDATE\n'
       UNIKEY3='SELECT LE.BP WITH @ID UNLIKE "_..."\n'
       UNIKEY4="CATALOG LE.BP LOCAL FORCE\nY\n"
       UNIKEY5='SELECT LE.BP WITH @ID UNLIKE "_..."\n'

       UNIKEY6='DELETE LE.BP\nY\nDATE\n'
       
       UNIKEY7="QUIT"
       
       
       echo -e $UNIKEY1$UNIKEY2$UNIKEY3$UNIKEY4$UNIKEY5$UNIKEY6$UNIKEY7 > $keysfl
              #q
                source ~/.bash_profile
                . /opt/LE/${ENV}/scripts/UdtProc.sh 1.4 2
              #
      # print "$myname has completed successfully"

 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Cataloging - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     
         else
         
         echo "------------------------------------------------------------------------"
         echo "Cataloging - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 
	
		 
     fi

     fi
    fi
     return $result
}




CoreCatalog(){
## UniBasic Catalog Function
###################
### variables required in UdtProc.sh
UDTLOGDIR="/opt/LE/udtlog"
DBDIR="/LE/${ENV}/LEUDTAC"
SEOSLOG="/LE/IL_logon/le.login.cfg"
BATCHID="LEBATCH"
MSGBANK="/opt/LE/Infolease/msgbank"
###################
#28-11-2016 - Modified code to add support for lebuild user to catalog core Unibasic Binary. - Rajesh Ramasamy

#New Release Version Variable

myname=${0##*/} 

#Emulate Key-stroke to UDT function

keysfl="$myname.$$.keys"
cd  /LE/${ENV}/LEUDTAC 
 
 #Reinstate Original link
   if [ -d /LE/${ENV}/LEUDTAC/BP ]; then
   	
   ln -fs /LE/${ENV}/LEUDTAC/BP BP
 
     if [ -d ${COMPONENT_LOCATION}/UniBasic ]; then
    	#cp ${COMPONENT_LOCATION}/UniBasic/_* BP
		cp ${COMPONENT_LOCATION}/UniBasic/_* BP
		chmod 750 /LE/${ENV}/LEUDTAC/BP/_*
       UNIKEY1='SELECT BP WITH @ID UNLIKE "_..."\n'
       
       UNIKEY2="DSICATALOG BP LOCAL FORCE\nY\n"
       UNIKEY3="QUIT"
       echo -e $UNIKEY1$UNIKEY2$UNIKEY3 > $keysfl
              #q
                source ~/.bash_profile
                . /opt/LE/${ENV}/scripts/UdtProc.sh 1.4 2
              #
      # print "$myname has completed successfully"

 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Core Cataloging - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     
         else
         
         echo "------------------------------------------------------------------------"
         echo "Core Cataloging - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     fi

     fi
    fi
     return $result
}


stopWebConnect(){
#stop IDB Web Connect
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin
 service IDS-WebConnect stop
 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "stopWebConnect - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         	        for process in $(ipcs -mp | grep root | awk '{ print $3 }'); 
			do
				pout=$(echo $(ps -ef | grep $process | grep root))  
			if echo $pout | grep -q "IDS-WebConnect"; then
				echo $pout
			  	echo "------------------------------------------------------------------------"
       		  	echo "stopIDS-WebConnect - Finished - UNSUCCESSFULLY!!!.Background process still exists."
        	   	echo "------------------------------------------------------------------------"	
			   	exit 1;
			fi
			done
         echo "------------------------------------------------------------------------"
         echo "stopWebConnect - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50;
     exit $result
}



stopJDBCBridge(){
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin
#stop IDS-JEBC Bridge Stop
 service IDS-JDBC-Bridge stop
 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "stopJDBCBridge - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
    
	        for process in $(ipcs -mp | grep root | awk '{ print $3 }'); 
			do
				pout=$(echo $(ps -ef | grep $process | grep root))  
			if echo $pout | grep -q "IDS-JDBC-Bridge"; then
				echo $pout
			  	echo "------------------------------------------------------------------------"
       		  	echo "stopJDBCBridge - Finished - UNSUCCESSFULLY!!!.Background process still exists."
        	   	echo "------------------------------------------------------------------------"	
			   	exit 1;
			fi
			done

         echo "------------------------------------------------------------------------"
         echo "stopJDBCBridge - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50
     exit $result

}


stopIDSWeb(){

#stop IDB Web Connect
#  sesudo IDS-Web stop
  
  export JAVA_HOME=/opt/LE/jre1.6.0_45
export PATH=$JAVA_HOME/bin:$PATH
export CATALINA_HOME=/opt/LE/tomcat-web
$CATALINA_HOME/bin/shutdown.sh
  
result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "stopIDSWeb - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
     	        for process in $(ipcs -mp | grep root | awk '{ print $3 }'); 
			do
				pout=$(echo $(ps -ef | grep $process | grep root))  
			if echo $pout | grep -q "IDS-Web"; then
				echo $pout
			  	echo "------------------------------------------------------------------------"
       		  	echo "stopIDS-Web - Finished - UNSUCCESSFULLY!!!.Background process still exists."
        	   	echo "------------------------------------------------------------------------"	
			   	exit 1;
			fi
			done    
         echo "------------------------------------------------------------------------"
         echo "stopIDSWeb - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50
     exit $result

}


stopMessageConnect(){
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin	
cd ${MCPATH} && ./stop_mc.sh

result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "stopMessageConnect - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
           for process in $(ipcs -mp | grep root | awk '{ print $3 }'); 
			do
				pout=$(echo $(ps -ef | grep $process | grep root))  
			if echo $pout | grep -q "com.idsgrp.infomq.InfoMQ"; then
				echo $pout
			  	echo "------------------------------------------------------------------------"
       		  	echo "stopMessageConnect - Finished - UNSUCCESSFULLY!!!.Background process still exists."
        	   	echo "------------------------------------------------------------------------"	
			   	exit 1;
			fi
			done 
         echo "------------------------------------------------------------------------"
         echo "stopMessageConnect - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result

}


stopUniData(){
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin	
cd /opt/LE/UniData/bin && ./stopud -f << 'EOF'
y
EOF
	 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "stopUniData - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
            for process in $(ipcs -mp | grep root | awk '{ print $3 }'); 
			do
				pout=$(echo $(ps -ef | grep $process | grep root))  
			if echo $pout | grep -q "UniData"; then
				echo $pout
			  	echo "------------------------------------------------------------------------"
       		  	echo "stopUniData - Finished - UNSUCCESSFULLY!!!.Background process still exists."
        	   	echo "------------------------------------------------------------------------"	
			   	exit 1;
			fi
			done        
         echo "------------------------------------------------------------------------"
         echo "stopUniData - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result

}




startWebConnect(){

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin
#stop IDB Web Connect
service IDS-WebConnect start
 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "startWebConnect - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
	    ps -ef | grep Web
         echo "------------------------------------------------------------------------"
         echo "startWebConnect - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50
     exit $result
}



startJDBCBridge(){

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin
#stop IDS-JEBC Bridge Stop
service IDS-JDBC-Bridge start
 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "startJDBCBridge - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         ps -ef | grep JDBC
         echo "------------------------------------------------------------------------"
         echo "startJDBCBridge - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 300
     exit $result

}


startIDSWeb(){

#stop IDB Web Connect
#sesudo IDS-Web start


  export JAVA_HOME=/opt/LE/jre1.6.0_45
export PATH=$JAVA_HOME/bin:$PATH
export CATALINA_HOME=/opt/LE/tomcat-web
$CATALINA_HOME/bin/startup.sh

result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "startIDSWeb - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
	 	 sleep 200
        ps -ef | grep tomcat 
         echo "------------------------------------------------------------------------"
         echo "startIDSWeb - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
	
     exit $result

}


startMessageConnect(){

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin
cd ${MCPATH} && ./start_mc.sh

result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "startMessageConnect - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         ps -ef | grep MessageConnect
         echo "------------------------------------------------------------------------"
         echo "startMessageConnect - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result

}

startUniData(){
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin	
cd /opt/LE/UniData/bin && ./startud

	 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "startUniData - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         
         echo "------------------------------------------------------------------------"
         echo "startUniData - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result

}

stopReportService(){


export PATH=$PATH:/opt/LE/jre1.6.0_45/bin


arrIN=(${LIST//,/ })

#Replace inputs into environment configs

ids_report_instance_name=${arrIN[0]}
ids_report_instance_home=${arrIN[1]}


	echo "Stopping Pentaho Report Instance ${ids_report_instance_name}.."
	
cd ${ids_report_instance_home} && ./ctlscript.sh stop ${ids_report_instance_name}

result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Pentaho Stop -${ids_report_instance_name}  - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
       ps -ef | grep pentaho   
         echo "------------------------------------------------------------------------"
         echo "Pentaho Stop- ${ids_report_instance_name} - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50
     exit $result
}

startReportService(){

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin


arrIN=(${LIST//,/ })

#Replace inputs into environment configs

ids_report_instance_name=${arrIN[0]}
ids_report_instance_home=${arrIN[1]}


	echo "Starting Pentaho Report Instance ${ids_report_instance_name}.."
	
cd ${ids_report_instance_home} && ./ctlscript.sh start ${ids_report_instance_name}

result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Pentaho start -${ids_report_instance_name}  - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
     fi
       ps -ef | grep pentaho   
         echo "------------------------------------------------------------------------"
         echo "Pentaho start- ${ids_report_instance_name} - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
		 sleep 50
     exit $result

}


copyInfoLeaseBatchReports()
{
	 echo "------------------------------------------------------------------------"
     echo "Copying  pdesign files..."
     echo "------------------------------------------------------------------------"

filec=$(ls -A "pdesigns" | wc -l)

if [ "$filec"  -gt "0" ]; then 

for files in pdesigns/*
do
echo "Copy $files -----> ${SOFTWARE_HOME}/sw/${ENV}/pdesigns.."
	cp -p "$files" 	"${SOFTWARE_HOME}/sw/${ENV}/pdesigns"
	result=$?
done
chmod 750 	${SOFTWARE_HOME}/sw/${ENV}/pdesigns/*

echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${SOFTWARE_HOME}/sw/${ENV}/pdesigns/le-build.txt
 
  chmod 755 ${SOFTWARE_HOME}/sw/${ENV}/pdesigns/le-build.txt	

else
 	     echo "------------------------------------------------------------------------"
         echo "No files to copy!!!"
         echo "------------------------------------------------------------------------"
 fi

	  
	 echo "------------------------------------------------------------------------"
     echo "Copying  pjobs files..."
     echo "------------------------------------------------------------------------"
 
 
filec=$(ls -A "pjobs" | wc -l)

if [ "$filec"  -gt "0" ]; then     
	
for files in pjobs/*
do
 echo "Copy $files -----> ${SOFTWARE_HOME}/sw/${ENV}/pjobs.."
	cp -p "${files}" "${SOFTWARE_HOME}/sw/${ENV}/pjobs"	
result=$?
done
	chmod 750 	${SOFTWARE_HOME}/sw/${ENV}/pjobs/*
	
	echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${SOFTWARE_HOME}/sw/${ENV}/pjobs/le-build.txt
 
  chmod 755 ${SOFTWARE_HOME}/sw/${ENV}/pjobs/le-build.txt	
else
 	     echo "------------------------------------------------------------------------"
         echo "No files to copy!!!"
         echo "------------------------------------------------------------------------"
 fi
	
	
	 echo "------------------------------------------------------------------------"
     echo "Copying  ptrnsfrms files..."
     echo "------------------------------------------------------------------------"
     
filec=$(ls -A "ptrnsfrms" | wc -l)
if [ "$filec"  -gt "0" ]; then     
	
	
for files in ptrnsfrms/*
do
 echo "Copy $files -----> ${SOFTWARE_HOME}/sw/${ENV}/ptrnsfrms.."
	cp -p "$files" "${SOFTWARE_HOME}/sw/${ENV}/ptrnsfrms"
	result=$?
done
	chmod 750 	${SOFTWARE_HOME}/sw/${ENV}/ptrnsfrms/*	
   echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${SOFTWARE_HOME}/sw/${ENV}/ptrnsfrms/le-build.txt
 
  chmod 755 ${SOFTWARE_HOME}/sw/${ENV}/ptrnsfrms/le-build.txt
else
 	     echo "------------------------------------------------------------------------"
         echo "No files to copy!!!"
         echo "------------------------------------------------------------------------"
fi

 if [ $result -ne 0 ]
    then
         echo "----------------------------------y--------------------------------------"
         echo "Report copy.. - Finished - UNSUCCESSFULLY!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
     exit $result
     fi
         
         echo "------------------------------------------------------------------------"
         echo "Report copy  - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     exit $result
}






copyScriptFiles()
{
	 echo "------------------------------------------------------------------------"
     echo "Copying  Script files..."
     echo "------------------------------------------------------------------------"
filec=$(ls -A "scripts" | wc -l)

 if [ "$filec"  -gt "0" ]; then 
	for files in scripts/*
		do
 		echo "Copy $files -----> ${SOFTWARE_HOME}/sw/${ENV}/scripts.."
		cp -p "$files" "${SOFTWARE_HOME}/sw/${ENV}/scripts"	
  done
 		chmod 750 	${SOFTWARE_HOME}/sw/${ENV}/scripts/*	
		
echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${SOFTWARE_HOME}/sw/${ENV}/scripts/le-build.txt
 
  chmod 755 ${SOFTWARE_HOME}/sw/${ENV}/scripts/le-build.txt		

 else
 	     echo "------------------------------------------------------------------------"
         echo "No scripts to copy!!!"
         echo "------------------------------------------------------------------------"
 fi
}


upgradeCoreApp()
{
#Input parameters for Application Installation

arrIN=(${LIST//,/ })

#Replace inputs into environment configs

ids_application_installer_name=${arrIN[0]}
ids_application_install_template=${arrIN[1]}
ids_application_home=${arrIN[2]}

#Invoke IDS application server installer
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin

${COMPONENT_LOCATION}/${ids_application_installer_name} <${ids_application_install_template}

	result=$?


if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "App Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*CORE-APPLICATION-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "App Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

 echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_application_home}/le-build.txt
 
  chmod 755 ${ids_application_home}/le-build.txt
  echo "------------------------------------------------------------------------"
  echo "App  Upgrade  Successful !!!.Please verify logs."
  echo "------------------------------------------------------------------------"
         #Clean up webil folder

#Configure  application After install
}

configureCoreApp()
{
	arrIN=(${LIST//,/ })

#Replace inputs into environment configs

ids_application_configure_name=${arrIN[0]}
ids_application_configure_template=${arrIN[1]}
ids_application_configure_home=${arrIN[2]}
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin

cd ${ids_application_configure_home}/${ENV}/LEUDTAC && /opt/LE/UniData/bin/${ids_application_configure_name} <${ids_application_configure_template}


cd ${ids_application_configure_home}/${ENV}/LEUDTACRPT && /opt/LE/UniData/bin/${ids_application_configure_name} <${ids_application_configure_template}
	
	result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "Configure App Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*CORE-APPLICATION-CONFIGURE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "Configure App Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

   echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_application_configure_home}/le-build.txt
   
    chmod 755 ${ids_application_configure_home}/le-build.txt
  echo "------------------------------------------------------------------------"
  echo "Configure App Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"

}

upgradeCoreDB()
{
	
arrIN=(${LIST//,/ })

#Replace inputs into environment configs
db_ssl=${arrIN[0]}
ids_db_install_template=${arrIN[1]}
ssl_login_timeout=${arrIN[2]}
ids_db_installer_name=${arrIN[3]}
ids_db_upgrade_prop_file=${arrIN[4]}
ids_db_upgrade_installer=${arrIN[5]}
#Text replace response template 

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin

${COMPONENT_LOCATION}/${ids_db_installer_name} <${ids_db_install_template}

	result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "DB Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/db/logs/*CORE-DB-DEPLOY*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "DB Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

 
  echo "------------------------------------------------------------------------"
  echo "DB Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
  

if [ $db_ssl == true ]; then
	
	dataSource=$(grep -i dataSource.url "${ids_db_upgrade_prop_file}")

	dataSource=$(echo "$dataSource;ssl\=require;loginTimeout\=${ssl_login_timeout}")
	
	dataSource=$(echo $dataSource | sed  's/\\/\\\\/g')	

	echo "Backup upgrade.properties -----> ${ids_db_upgrade_prop_file}.bak"

	cp "${ids_db_upgrade_prop_file}" "${ids_db_upgrade_prop_file}.bak"
	
	echo "replacing original dataSource.url with ssh timeout attribute.."
	
	sed -i.bak '/dataSource.url/d' "${ids_db_upgrade_prop_file}"
	
	sed "/dataSource.driverClassName/a $dataSource" "${ids_db_upgrade_prop_file}" > "${ids_db_upgrade_prop_file}".tmp
	
	mv "${ids_db_upgrade_prop_file}".tmp "${ids_db_upgrade_prop_file}"
	
	chmod 644 "${ids_db_upgrade_prop_file}"
	
	echo "DB Upgrade Properties used for upgrade..."
	
    cat "${ids_db_upgrade_prop_file}"
	
	echo "replacing original dataSource.url with ssh timeout attribute complete.."
	
	echo "Append -Djsse.enableCBCProtection=false parameter ---> ${ids_db_upgrade_installer}"
	 
	perl -p -i -e "s/java -jar/java -Djsse.enableCBCProtection=false -jar/g" "${ids_db_upgrade_installer}"
	
	echo "Append -Djsse.enableCBCProtection=false parameter ---> ${ids_db_upgrade_installer}..complete"
	

	cd $(dirname "${ids_db_upgrade_installer}") && ./$(basename "${ids_db_upgrade_installer}")
	
		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "DB SSL Configure Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/db/logs/*CORE-DB-DEPLOY*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "DB SSL Configure Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

fi
}


UpgradeCoreJDBC_BRIDGE()
{
arrIN=(${LIST//,/ })

#Replace inputs into environment configs
ids_jdbc_bridge_installer_name=${arrIN[0]}
ids_jdbc_bridge_install_template=${arrIN[1]}
ids_jdbc_bridge_home=${arrIN[2]}

#Text replace response template 
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin        

${COMPONENT_LOCATION}/${ids_jdbc_bridge_installer_name}  <${ids_jdbc_bridge_install_template}   

		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "DB JDBC-BRIDGE Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*JDBC-BRIDGE-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "DB JDBC-BRIDGE Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

  echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_jdbc_bridge_home}/le-build.txt
  
  chmod 755 ${ids_jdbc_bridge_home}/le-build.txt
  echo "------------------------------------------------------------------------"
  echo "DB JDBC-BRIDGE Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"


}

UpgradeCoreWEB_CONNECT()
{
arrIN=(${LIST//,/ })
#Replace inputs into environment configs
ids_web_connect_installer_name=${arrIN[0]}
ids_web_connect_install_template=${arrIN[1]}
ids_web_connect_home=${arrIN[2]}

rm -Rf ${ids_web_connect_home}/webapps/webconnect
rm -Rf ${ids_web_connect_home}/webapps/wcstatic

export PATH=$PATH:/opt/LE/jre1.6.0_45/bin 
      
      ${COMPONENT_LOCATION}/${ids_web_connect_installer_name}  <${ids_web_connect_install_template}
 		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "Web-Connect Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*WEB-CONNECT-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "Web-Connect Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 
 echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_web_connect_home}/le-build.txt
 
 chmod 755 ${ids_web_connect_home}/le-build.txt
 
  echo "------------------------------------------------------------------------"
  echo "Web-Connect	Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
}


UpgradeCoreMESSAGE_CONNECT()
{
arrIN=(${LIST//,/ })
#Replace inputs into environment configs
ids_message_connect_installer_name=${arrIN[0]}
ids_message_connect_install_template=${arrIN[1]}
ids_message_connect_home=${arrIN[2]}


export PATH=$PATH:/opt/LE/jre1.6.0_45/bin 
      
      ${COMPONENT_LOCATION}/${ids_message_connect_installer_name}  <${ids_message_connect_install_template}
 		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "Message-Connect Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*MESSAGE-CONNECT-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "Message-Connect Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

 echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_message_connect_home}/le-build.txt
 
  chmod 755 ${ids_message_connect_home}/le-build.txt
 
  echo "------------------------------------------------------------------------"
  echo "Message-Connect	Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
}

UpgradeCoreMESSAGE_CONNECT_CONFIGURE()
{
arrIN=(${LIST//,/ })
#Replace inputs into environment configs
ids_message_connect_configure_installer_name=${arrIN[0]}
ids_message_connect_configure_template=${arrIN[1]}
ids_message_connect_configure_home=${arrIN[2]}


export PATH=$PATH:/opt/LE/jre1.6.0_45/bin 
      
      ${ids_message_connect_configure_home}/${ids_message_connect_configure_installer_name}  <${ids_message_connect_configure_template}
 		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "Message-Connect Configure Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*MESSAGE-CONNECT-CONFIGURE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "Message-Connect Configure Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

  echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_message_connect_configure_home}/le-build.txt
   chmod 755 ${ids_message_connect_configure_home}/le-build.txt
  echo "------------------------------------------------------------------------"
  echo "Message-Connect	Configure Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
}


UpgradeCoreWEB()
{
arrIN=(${LIST//,/ })
#Replace inputs into environment configs
ids_web_installer_name=${arrIN[0]}
ids_web_install_template=${arrIN[1]}
ids_web_home=${arrIN[2]}
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin

${COMPONENT_LOCATION}/${ids_web_installer_name} <${ids_web_install_template}

 		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "Web Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*WEB-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "Web Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

   echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_web_home}/le-build.txt
   
    chmod 755 ${ids_web_home}/le-build.txt
  echo "------------------------------------------------------------------------"
  echo "Web Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"

rm -rf ${ids_web_home}/webapps/webil
}

UpgradeCoreIDS_REPORT()
{
arrIN=(${LIST//,/ })
#Replace inputs into environment configs
ids_report_installer_name=${arrIN[0]}
ids_report_install_template=${arrIN[1]}
ids_report_home=${arrIN[2]}
export PATH=$PATH:/opt/LE/jre1.6.0_45/bin


if [ ! -f ${COMPONENT_LOCATION}/${ids_report_installer_name} ]; then
	       echo "------------------------------------------------------------------------"
         echo "IDS installer ${ids_report_installer_name} do not exists.Exiting IDS report upgrade.."
         echo "------------------------------------------------------------------------"
		 exit 0
else		 
		 
     ${COMPONENT_LOCATION}/${ids_report_installer_name}  <${ids_report_install_template}
     result=$?
fi     
 		

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "IDS Report Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*IDS-REPORT-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "IDS Report Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 

 echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_report_home}/le-build-ids-report.txt
 chmod 755 ${ids_report_home}/le-build-ids-report.txt
  echo "------------------------------------------------------------------------"
  echo "IDS Report Upgrade Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
}


UpgradeCoreINFOLEASE_REPORT()
{
ENV=$(echo ${ENV} | perl -ne 'print lc')
arrIN=(${LIST//,/ })

infolease_report_installer_name=${arrIN[0]}
infolease_report_install_template=${arrIN[1]}
infolease_report_home=${arrIN[2]}
REPORT_WORKSPACE_LOCATION=${arrIN[3]}
REPORT_SERVER=${arrIN[4]}
REPORT_PORT=${arrIN[5]}
REPORT_USER=${arrIN[6]}
REPORT_PASSWORD=${arrIN[7]}
FLAG=${arrIN[8]}
REPORT_DOMAIN_NAME=${arrIN[9]}


export PATH=$PATH:/opt/LE/jre1.6.0_45/bin

if [ ${FLAG} == "E" ]; then

#Perform Report Export Only

echo "${infolease_report_home}/server/biserver-ee/import-export.sh --export --url=${REPORT_SERVER}:${REPORT_PORT}/ids-reporting --username=${REPORT_USER}  --password=${REPORT_PASSWORD} --file-path=/opt/LE/pentaho/server/biserver-ee/pentaho-solutions/export_le${ENV}_w_manifest.zip  --charset=UTF-8 --path=${REPORT_WORKSPACE_LOCATION} --withManifest=true  --logfile=/opt/lebuild/app/logs/export_le${ENV}_full_w_manifest_log.txt"

${infolease_report_home}/server/biserver-ee/import-export.sh --export --url=${REPORT_SERVER}:${REPORT_PORT}/ids-reporting --username=${REPORT_USER}  --password=${REPORT_PASSWORD} --file-path=/opt/LE/pentaho/server/biserver-ee/pentaho-solutions/export_${REPORT_DOMAIN_NAME}_w_manifest.zip  --charset=UTF-8 --path=${REPORT_WORKSPACE_LOCATION} --withManifest=true  --logfile=/opt/lebuild/app/logs/export_${REPORT_DOMAIN_NAME}_w_manifest.txt
 
    
 		result=$?

ls -altr /opt/LE/pentaho/server/biserver-ee/pentaho-solutions/		
chmod 755 /opt/lebuild/app/logs/export_le${ENV}_full_w_manifest_log.txt

log_file=`ls  /opt/lebuild/app/logs/*INFOLEASE-REPORT-EXPORT*STDOUT* -t1 | head -n 1`

if  grep -q  "ERROR" "$log_file" ; 
then 
result=1
fi
 
if [ $result -eq 0 ];
  then
      echo "------------------------------------------------------------------------"
  echo "InfoLease Report Export Successful !!!Please verify logs.."
  echo "------------------------------------------------------------------------"
  exit 0
fi

	
if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "InfoLease Report Export Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*INFOLEASE-REPORT-EXPORT*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "InfoLease Report Export Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 
  exit
fi


 if [ ${FLAG} == "I" ]; then

 #Perform Infolease Report Installation Only

 
${COMPONENT_LOCATION}/${infolease_report_installer_name} <${infolease_report_install_template}

		result=$?

if [ $result -ne 0 ]; 
    then
         echo "------------------------------------------------------------------------"
         echo "InfoLease Report Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit $result
fi

if  [ -s `ls  /opt/lebuild/app/logs/*INFOLEASE-REPORT-UPGRADE*STDERR* -t1 | head -n 1` ]; then
      echo "------------------------------------------------------------------------"
         echo "InfoLease Report Upgrade Failed.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
		 exit 1
fi		 
 echo "[`basename ${COMPONENT_LOCATION}`] : [`date`] " >>  ${ids_report_home}/le-build-infolease-core-report.txt
 chmod 755 ${ids_report_home}/le-build-infolease-report.txt
fi
    
 # Upload Reports manually   
    
    
 #   if [ -f /opt/LE/pentaho/server/biserver-ee/uploadReports.sh ]; then
  #  	echo "Uploading infolease reports"
   # 	    cat /opt/LE/pentaho/server/biserver-ee/uploadLog
   # /opt/LE/pentaho/server/biserver-ee/uploadReports.sh
   #fi
}




upgradeCoreAppHotfix()
{

   CoreCatalog	
			result=$?

if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Core Hotfix  Cataloging Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
else
 
  echo "------------------------------------------------------------------------"
         echo "Core Hotfix Cataloging Finished !!!."
         echo "------------------------------------------------------------------------"
 fi
 exit $result
}


changeOwner()
{
if [ -d "/opt/LE/jdbc-bridge" ]; then 
  if [ `find /opt/LE/jdbc-bridge \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
		find /opt/LE/jdbc-bridge \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
  fi
fi

if [ -d "/opt/LE" ]; then
 if [ `find /opt/LE \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
	find /opt/LE \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
 fi	
fi

if [ -d "/opt/LE/tomcat-webconnect" ]; then
  if [ `find /opt/LE/tomcat-webconnect \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
	 find /opt/LE/tomcat-webconnect \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
   fi
fi

if [ -d "/opt/LE/${ENV}/LEUDTAC" ]; then
if [ `find /opt/LE/${ENV}/LEUDTAC \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
		find /opt/LE/${ENV}/LEUDTAC \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
fi
fi

if [ -d "/opt/LE/InfoLease/${ENV}/LE_IL10.PROG" ]; then
if [ `find /opt/LE/InfoLease/${ENV}/LE_IL10.PROG \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
		find /opt/LE/InfoLease/${ENV}/LE_IL10.PROG \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
fi
fi

if [ -d "/opt/LE/InfoLease/${ENV}/LE_SYS10.PROG" ]; then
if [ `find /opt/LE/InfoLease/${ENV}/LE_SYS10.PROG \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
	find /opt/LE/InfoLease/${ENV}/LE_SYS10.PROG \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
fi
fi

if [ -d "/opt/LE/tomcat-web" ]; then
if [ `find /opt/LE/tomcat-web \( -type f -o -type d \) -user root -print | wc -l` -gt 0 ]; then
	find /opt/LE/tomcat-web \( -type f -o -type d \) -user root -print0|xargs -0 chown leroot:info
fi
fi
}


upgradeWBCApp()
{
      WBCCatalog	
			result=$?

if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "WBC Cataloging Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
else
 
  echo "------------------------------------------------------------------------"
         echo "WBC Cataloging Finished !!!."
         echo "------------------------------------------------------------------------"
 fi
 exit $result
}

upgradeWBCBatchReports()
{

copyInfoLeaseBatchReports	
result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Report Copying Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
 
else

 echo "------------------------------------------------------------------------"
         echo "Report Deployment Finished Successfully!!!."
         echo "------------------------------------------------------------------------"	
 fi
exit $result
}

upgradeWBCScriptFiles()
{

copyScriptFiles
result=$?

if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Script files Copy Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
 
else

 echo "------------------------------------------------------------------------"
         echo "Script files Copy Finished Successfully!!!."
         echo "------------------------------------------------------------------------"	
 fi
  exit $result  

}

upgradeWBCEnvironmentConfigs()
{
installConfigs
result=$?

if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Environment Config(s) Copy Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
 
else

 echo "------------------------------------------------------------------------"
         echo "Environment Config(s) Copy  Finished Successfully!!!."
         echo "------------------------------------------------------------------------"	
 fi
  exit $result  

}


upgradeWBCWebReports()
{

installInfoLeaseWebReports	
result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Online Web Report Deploy Import Failed!!!.Please check logs for errors.."
         echo "------------------------------------------------------------------------"
 
else

 echo "------------------------------------------------------------------------"
         echo "Online Web Report  Deployment Completed. Check STDERR logs!!!."
         echo "------------------------------------------------------------------------"	
 fi
exit $result
}


installConfigs(){
	# Search for files specific to a component and env

ENV=$(echo ${ENV} | perl -ne 'print lc')
in_file=""
if [ "${SERVER_TYPE}" == "app" ]; then
grep "${SERVER_TYPE}/${ENV}" manifest.txt | perl -p -i -e "s/${SERVER_TYPE}\/${ENV}//g"| sed '\/readme.txt/d'|sed '\/startud/d'|perl -p -i -e "s/\/${SERVER_TYPE}\/${ENV}//g" > 1.tmp
in_file="1.tmp"
fi

if [ "${SERVER_TYPE}" == "report" ]; then
grep "${SERVER_TYPE}/${ENV}" manifest.txt | perl -p -i -e "s/${SERVER_TYPE}\/${ENV}//g"| sed '\/readme.txt/d'|perl -p -i -e "s/\/${SERVER_TYPE}\/${ENV}//g" >  1.tmp
in_file="1.tmp"
fi

if [ "${SERVER_TYPE}" == "web" ]; then
grep "${SERVER_TYPE}/${ENV}" manifest.txt | perl -p -i -e "s/${SERVER_TYPE}\/${ENV}//g"| sed '\/readme.txt/d'|perl -p -i -e "s/\/${SERVER_TYPE}\/${ENV}//g" > 1.tmp
in_file="1.tmp"
fi
	
chmod 755 $in_file
echo "Copy Config Files..."

while read line
  do
	echo "Copying file 	 ${SERVER_TYPE}/${ENV}$line  $line.."   
	cp "${SERVER_TYPE}/${ENV}$line" 	"$line"
	chmod 755  $line
done < $in_file			
}
	
	
installInfoLeaseWebReports()
{
arrIN=(${LIST//,/ })
arrSearch=(${SEARCH_ATTRIBUTES//,/ })

  

#Replace inputs into environment specific configs 

REPORT_WORKSPACE_LOCATION=${arrIN[0]}
REPORT_SERVER=${arrIN[1]}
REPORT_PORT=${arrIN[2]}
REPORT_USER=${arrIN[3]}
REPORT_PASSWORD=${arrIN[4]}
WEBUI_REPORT_SEARCH_DATASOURCE=${arrIN[5]}
WEBUI_REPORT_DATASOURCE=${arrIN[6]}

echo "${REPORT_WORKSPACE_LOCATION},$REPORT_SERVER,$REPORT_PORT,$WEBUI_REPORT_DATASOURCE"
	        for directory in $(ls -A GUI_PRPT); do
				
                        for report_file in $(ls -A GUI_PRPT/${directory}/*.*); do
							
							file=$(basename "$report_file")
							extension="${file##*.}"
							
							if [ $extension == "prpt" ]; then
                                pwd
                                echo $report_file
                                rm -rf tmp stage
                                mkdir -p tmp/${directory} stage
                                chmod -R 777 tmp stage
                                unzip $report_file -d tmp/${directory}
                                chmod -R 755  tmp/${directory}
                                for ds_file in $(find tmp/${directory} -iname sql-ds.xml)
                                do
                                echo $ds_file
                                if  grep -q "<data:path>" "$ds_file"; then
						          cat "${ds_file}"  | sed "s|<data:path>${WEBUI_REPORT_SEARCH_DATASOURCE}</data:path>|<data:path>${WEBUI_REPORT_DATASOURCE}</data:path>|" > ${ds_file}.tmp  && mv ${ds_file}.tmp "${ds_file}"
                                echo "${ds_file}"	
								cat "${ds_file}"
								fi
                                done
                                echo $(basename $report_file)
                                cd tmp/${directory} ; zip -r -0 -D ../../stage/$(basename $report_file) *
                                cd ../../stage
                                pwd
                                base=$(basename $report_file)
                                filename="${base%.*}"
                                zip -r -0 $filename.zip *
                                cd ../
                                uploadInfoLeaseWebReport                #Import Infolease Web Report via native infolease tools
                                result=$?
							else
								pwd
                                echo $report_file
								rm -rf  stage
                                mkdir -p stage
                                chmod -R 777 stage
											for pattern in "${arrSearch[@]}";
											do
												    perl -p -i -e "s/${pattern}/${ENV}/g" $report_file;
											done
								filename=$report_file
								cp $report_file ../../stage
								cd ../../
                                pwd
								uploadInfoLeaseWebReport
							fi					
										
                        done
						
			done

}

WBCDeleteCatalog(){
## UniBasic DeleteCatalog Function to rollback changes
###################
### variables required in UdtProc.sh
UDTLOGDIR="/opt/LE/udtlog"
DBDIR="/LE/${ENV}/LEUDTAC"
SEOSLOG="/LE/IL_logon/le.login.cfg"
BATCHID="LEBATCH"
MSGBANK="/opt/LE/Infolease/msgbank"
PROGRAM_NAME="$1"
###################
#28-11-2016 - Modified code to add support for lebuild user to catalog Unibasic Binary. - Rajesh Ramasamy

#New Release Version Variable

myname=${0##*/} 

#Emulate Key-stroke to UDT function

keysfl="$myname.$$.keys"
cd /LE/${ENV}/LEUDTAC/
 
 #Reinstate Original link
   if [ -d /opt/LE/${ENV}/UniBasic ]; then
   	
   ln -fs /opt/LE/${ENV}/UniBasic LE.BP
 
     if [ -d "${SOFTWARE_HOME}/sw/${ENV}/UniBasic" ]; then
         UNIKEY1="DELETE.CATALOG ${PROGRAM_NAME} \n"
         UNIKEY2="QUIT"

       echo -e $UNIKEY1$UNIKEY2 > $keysfl
              #q
                source ~/.bash_profile
                . /opt/LE/${ENV}/scripts/UdtProc.sh 1.4 2
              #
      # print "$myname has completed successfully"

 result=$?

 if [ $result -ne 0 ]
    then
         echo "------------------------------------------------------------------------"
         echo "Delete Cataloging - Finished - UNSUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
     
         else
         
         echo "------------------------------------------------------------------------"
         echo "Delete Cataloging - Finished - SUCCESSFULLY!!!"
         echo "------------------------------------------------------------------------"
	 
     fi

     fi
    fi
     return $result
}

rollbackFiles()
{
if [ `whoami` == "lebuild" ];then
	if [ "${ROLLBACK}" != "A" ]; then
	 arrIN=(${ROLLBACK//,/ })
	   echo "Rollback Enter"
			for pattern in "${arrIN[@]}";
			do
				 grep $pattern origin/manifest.txt >> origin/1.tmp
				 # To filter only the selected files to be rollback 
				 grep $pattern  manifest.txt >> 2.tmp 
			done  

			#Identify and update the original manifest files to filter out componets candidates for rollback

			mv origin/1.tmp origin/manifest.txt
			  
			# If not found in the master branch delete all contents from master to avoid reversal of version

			if [[ -s 2.tmp ]]; then
				mv 2.tmp manifest.txt 
			fi
	fi
fi
	if [ "${ROLLBACK_FLAG}" == "F" ]; then
		#To clean up  master prior to rollback and restore

		filec=$(ls -A "ptrnsfrms" | wc -l)
		if [ "$filec"  -gt "0" ]; then     
		for files in ptrnsfrms/*
		do
		if grep -q -w "$files" origin/manifest.txt ; then 
		 echo "$files - marked for rollback"
		else
		 rm -f $files
		fi
		done
		fi

		filec=$(ls -A "pjobs" | wc -l)
		if [ "$filec"  -gt "0" ]; then     
		for files in pjobs/*
		do
		if grep -q -w "$files" origin/manifest.txt ; then 
		 echo "$files - marked for rollback"
		else
		 rm -f $files
		fi
		done
		fi

		filec=$(ls -A "pdesigns" | wc -l)
		if [ "$filec"  -gt "0" ]; then     
		for files in pdesigns/*
		do
		if grep -q -w "$files" origin/manifest.txt ; then 
		 echo "$files - marked for rollback"
		else
		 rm -f $files
		fi 
		done
		fi

		filec=$(ls -A "scripts" | wc -l)

		if [ "$filec"  -gt "0" ]; then     
		for files in scripts/*
		do
		if grep -q -w "$files" origin/manifest.txt ; then 
		 echo "$files - marked for rollback"
		else
		 rm -f $files
		fi 
		done
		fi

#Rollback release

while read line
do
if [ -f "${SOFTWARE_HOME}/sw/${ENV}/$line" ]; then
 echo "Rollback ---> ${SOFTWARE_HOME}/sw/${ENV}/$line"
 rm -f "${SOFTWARE_HOME}/sw/${ENV}/$line"
fi 
done < origin/manifest.txt
fi
	
if [ "${ROLLBACK_FLAG}" == "U" ]; then
		while read line
		do
		  string="${SOFTWARE_HOME}/sw/${ENV}/$line"
			if [[ $string == *"UniBasic"* ]]; then
			WBCDeleteCatalog "$(basename ${SOFTWARE_HOME}/sw/${ENV}/$line)"
			rm -f "${SOFTWARE_HOME}/sw/${ENV}/$line"
			fi 
		done < origin/manifest.txt
		fi

}

uploadInfoLeaseWebReport()
{
		if [ "$(ls -A stage/${filename}.zip)" ]; then
				/opt/LE/pentaho/server/biserver-ee/import-export.sh --import --url=${REPORT_SERVER}:${REPORT_PORT}/ids-reporting --username=${REPORT_USER} --password=${REPORT_PASSWORD} --path="${REPORT_WORKSPACE_LOCATION}/${directory}" --file-path="`pwd`/stage/${filename}.zip" --overwrite=true --retainOwnership=true --permission=true --logfile=/opt/lebuild/app/logs/import_${ENV}_$(basename $report_file)_w_manifest_log.log
		fi
		
		if [ "$(ls -A stage/${filename})" ]; then
				/opt/LE/pentaho/server/biserver-ee/import-export.sh --import --url=${REPORT_SERVER}:${REPORT_PORT}/ids-reporting --username=${REPORT_USER} --password=${REPORT_PASSWORD} --path="${REPORT_WORKSPACE_LOCATION}/${directory}" --file-path="`pwd`/stage/${filename}" --overwrite=true --retainOwnership=true --permission=true --logfile=/opt/lebuild/app/logs/import_${ENV}_$(basename $report_file)_w_manifest_log.log
		fi	
rm -rf stage tmp
cw=`pwd`
cd /
chmod 755 /opt/lebuild/app/logs/import*
cd $cw
}


#Deploy WBC  Release
installWBCApps()
{
case $COMPONENT_TYPE in
	APP)
		upgradeWBCApp
		;;
    BATCH_REPORT)
        upgradeWBCBatchReports
 ;;
    SCRIPTS)
        upgradeWBCScriptFiles
 ;;
    CONFIG)
        upgradeWBCEnvironmentConfigs
 ;;
    WEB_REPORT)
        upgradeWBCWebReports
 ;;
 esac
}

#Deploy Core  Release
installCoreApps()
{
case $COMPONENT_TYPE in
	APP)
        upgradeCoreApp
 ;;
	APP_CONFIGURE)
        configureCoreApp
 ;;
 	APP_HOTFIX)
        upgradeCoreAppHotfix
 ;;
    DB)
        upgradeCoreDB
 ;;
    JDBC_BRIDGE)
        UpgradeCoreJDBC_BRIDGE
 ;;
     WEB_CONNECT)
        UpgradeCoreWEB_CONNECT
        
 ;;
     MESSAGE_CONNECT)
        UpgradeCoreMESSAGE_CONNECT
        
 ;;
      MESSAGE_CONNECT_CONFIGURE)
        UpgradeCoreMESSAGE_CONNECT_CONFIGURE
        
 ;;
     WEB)
        UpgradeCoreWEB
 ;;
       IDS_REPORT)
        UpgradeCoreIDS_REPORT
 ;;
       INFOLEASE_REPORT)
        UpgradeCoreINFOLEASE_REPORT
;;
       CHANGE_OWNERSHIP)
        changeOwner
;;
esac
}


#Deploy App Release

deploy() {
case $GROUP_TYPE in
	    core)
        installCoreApps
 ;;
    wbc)
        installWBCApps
 ;;
esac
}

#Stop Services
stopServices() {
case $service in
    WC)
        stopWebConnect
 ;;
    JB)
        stopJDBCBridge
 ;;
WB)
        stopIDSWeb
 ;;
MC)
        stopMessageConnect
 ;;
 UD)
        stopUniData
 ;;
 RS)
        stopReportService
 ;;
  esac
}

#Start Services

startServices() {
case $service in
    WC)
        startWebConnect
 ;;
    JB)
        startJDBCBridge
 ;;
WB)
        startIDSWeb
 ;;
MC)
        startMessageConnect
 ;;
 UD)
        startUniData
 ;;
 RS)
        startReportService
 ;;
 
  esac
}



#Entry function to invoke maintenance functions:

executeTasks(){
  case $command in
    stop)
        stopServices 
 ;;
     start)
         startServices
  ;;
   compile)
         compile
  ;;
 deploy)
         deploy
         ;;
  own)
  		changeOwner
  		;;      
  rollback)
		rollbackFiles
	;;	
  esac
}

# --v Release Version - Infolease APP Release Version
# --c command - [stop][start][deploy][compile] functions
# --e ENV                       - [DEV][SIT][UAT][SVP][PROD][DR]
# --t [WBC][CORE]

parseParameters() {
 while getopts "m:r:c:s:e:t:h:L:C:A:S:l:R:F:P:" OPTION
 do
 case $OPTION in
 h)
  usage
  exit 1
  ;;
 r)
   rlseVersion=$OPTARG
   ;;
 c)
 command=$OPTARG
   ;;
 s)
 service=$OPTARG
   ;;
 e)
 ENV=$OPTARG
   ;;
t)
GROUP_TYPE=$OPTARG
   ;;
m)
MCPATH=$OPTARG
;;
L)
COMPONENT_LOCATION=$OPTARG
;;
C)
COMPONENT_TYPE=$OPTARG
;;
A)
ARTIFACT_ID=$OPTARG
;;
S)
SERVER_TYPE=$OPTARG
;;
l)
LIST=$OPTARG
;;
R)
ROLLBACK=$OPTARG
;;
F)
ROLLBACK_FLAG=$OPTARG
;;
P)
SEARCH_ATTRIBUTES=$OPTARG
;;
esac
done

  # ensure required params are not blank
  echo "rlseVersion=$rlseVersion,command=$command,env=$ENV"

 if [[ -z $command ]]
  then
  usage
   exit 1
 fi
}




##############################################################
 # Program Entry Point
##############################################################

# start of main pogram
parseParameters "$@"
# Change executable permissions on critical directories to run
#chmod -R 755 /opt/lebuild/app/logs
# Start executing tasks

if [ `whoami` == "leroot" ];then
        echo "Source `whoami` profile"
        source ~/.bash_profile
fi


#releaseLocation="/opt/lebuild/releases/${type}/${rlseVersion}"

executeTasks
# Deployment complete
exit 0