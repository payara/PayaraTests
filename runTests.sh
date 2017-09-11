#!/bin/bash

################################
### Get the run mode options ###
################################
while getopts ":p:ih" opt; do
  case $opt in
    h)
      echo "To build and run the tests using following command:"
      echo "    sh runTests.sh"
      echo ""
      echo "This will run the tests using the default properties file: test-suite-config.properties"
      echo ""
      echo "To run the tests with a different properties file:"
      echo "    sh runTests.sh -p Path/to/properties/file"
      echo ""
      echo "To run the tests without a properties file (specifying everything yourself):"
      echo "    sh runTests.sh -i"
      exit 0
      ;;
    p)
      PROPERTIES_FILE=$OPTARG
      ;;
    i)
      INTERACTIVE=true
      ;;
    \?)
      echo "  Invalid option: -$OPTARG. For help use -h"
      ;;
    :)
      echo "  Invalid entry. Use -h for more information."
  esac
done

##########################################################
### Set up the properties to be used by the test suite ###
#########################################################
# If interactive mode was not selected...
if [ ! $INTERACTIVE ]; then
    # Check if a properties file was provided
    if [ ! -z "$PROPERTIES_FILE" ]; then
        # If one was provided, grab its properties
        . $PROPERTIES_FILE
    else
	 # If one wasn't provided, just grab the ones from the default properties file
        . ./test-suite-config.properties
    fi
# If interactive mode was selected
else
    # Check if we want to test against the payara 5 branch
    read -p "Do you want to test against Payara-5? (y/n) [n] " TEST_PAYARA_5

    # Check if we want to run all of the tests
    read -p "Do you want to run all tests? (y/n) [y] " RUN_ALL_TESTS

    # If we do want to run all of the tests...
    if [ "$RUN_ALL_TESTS" != "n" ]; then
        # Check if we want to only run the stable tests or not
        read -p "Do you only want to run the stable tests? (y/n) [y] " STABLE_ONLY
        
        # Check if we only want to run quick tests
        read -p "Do you only want to run quick tests? (y/n) [y] " QUICK_ONLY
    # If we don't want to run all of the tests...
    else
        # Set these properties to false to prevent falling through the OR checks later on
        STABLE_ONLY="n"
        QUICK_ONLY="n"
    
        # Check if we want to run the private Payara tests
        read -p "Do you want to run the Private Payara tests? (y/n) [y] " RUN_PAYARA_PRIVATE_TESTS
        
        # If we do want to run the private tests...
        if [ "$RUN_PAYARA_PRIVATE_TESTS" != "n" ]; then
            # Check if we only want to run the stable tests
            read -p "Do you only want to run the stable tests? (y/n) [y] " STABLE_PAYARA_PRIVATE_ONLY
            
            # If we do want to only run the stable tests...
            if [ "$STABLE_PAYARA_PRIVATE_ONLY" != "n" ]; then
                # Check if we only want to run quick tests
                read -p "Do you only want to run quick tests? (y/n) [y] " QUICK_PAYARA_PRIVATE_ONLY
            fi

	    read -p "Do you want to run the stability stream version validator test? (y/n) [n] " RUN_STABILITY_STREAM_VERSION_VALIDATOR_TEST
        fi
        
        # Check if we want to run the Java EE 7 Samples tests
        read -p "Do you want to run the Java EE 7 Samples tests? (y/n) [y] " RUN_SAMPLES_TESTS
        
        # If we do want to run the Java EE 7 Samples tests...
        if [ "$RUN_SAMPLES_TESTS" != "n" ]; then
            # Check if we want to only run the stable tests
            read -p "Do you only want to run the stable tests? (y/n) [y] " STABLE_SAMPLES_ONLY
        fi

	read -p "Do you want to run the Java EE 8 Samples tests? (y/n) [y] " RUN_EE8_SAMPLES_TESTS

        # Check if we want to run the Cargo Tracker tests
        read -p "Do you want to run the Cargo Tracker tests? (y/n) [y] " RUN_CARGO_TRACKER_TESTS

	# Check if we want to run the Cargo Tracker tests against embedded
	read -p "Do you want to run the Cargo Tracker tests against embedded? (y/n) [y] " RUN_EMBEDDED_TESTS

        # Check if we want to run the GlassFish tests
        read -p "DO you want to run the GlassFish tests? (y/n) [y] " RUN_GLASSFISH_TESTS

        # If we do want to run the GlassFish tests...
        if [ "$RUN_GLASSFISH_TESTS" != "n" ]; then
            # Check if we only want to run the GlassFish Quicklook tests
            read -p "Do you only want to run the Quicklook tests? (y/n) [y] " QUICKLOOK_ONLY
        fi
        
        # Check if we want to run the Mojarra tests
        read -p "Do you want to run the Mojarra tests? (y/n) [y] " RUN_MOJARRA_TESTS
    fi

    # Check if we want to fail at end or not
    read -p "Do you want to fail at end? (y/n) [y] " FAIL_AT_END
    
    # Check if we want to use the distribution from the source, or provide our own
    read -p "Do you want to test against a Payara Server built from the source? Select no if you want to provide the path to the Payara Server install yourself. (y/n) [y] " RUN_FROM_SOURCE

    # Check if we want to use the payara-domain instead of the default domain
    read -p "Do you want to use the default glassfish compatible domain (domain1) or the Payara Domain (payaradomain)? (y/n) [y] " USE_DEFAULT_DOMAIN_TEMPLATE
    
    # Check if we want to save these settings as a custom properties file
    read -p "Do you want to save these settings as a custom properties file? (y/n) [n] " SAVE_AS_PROPERTIES_FILE
fi

# Save the properties as a properties file
if [ "$SAVE_AS_PROPERTIES_FILE" == "y" ];then
	FILENAME="test-suite-config-$(date +%Y-%m-%d-%H-%M-%S).properties"
	touch ./$FILENAME
	echo "RUN_ALL_TESTS=$RUN_ALL_TESTS" >> $FILENAME
	echo "STABLE_ONLY=$STABLE_ONLY" >> $FILENAME
	echo "FAIL_AT_END=$FAIL_AT_END" >> $FILENAME
	echo "QUICK_ONLY=$QUICK_ONLY" >> $FILENAME
	echo "RUN_FROM_SOURCE=$RUN_FROM_SOURCE" >> $FILENAME
	echo "" >> $FILENAME
	echo "RUN_PAYARA_PRIVATE_TESTS=$RUN_PAYARA_PRIVATE_TESTS" >> $FILENAME
	echo "STABLE_PAYARA_PRIVATE_ONLY=$STABLE_PAYARA_PRIVATE_ONLY" >> $FILENAME
	echo "QUICK_PAYARA_PRIVATE_ONLY=$QUICK_PAYARA_PRIVATE_ONLY" >> $FILENAME
	echo "RUN_SAMPLES_TESTS=$RUN_SAMPLES_TESTS" >> $FILENAME	
	echo "RUN_EE8_SAMPLES_TESTS=$RUN_EE8_SAMPLES_TESTS" >> $FILENAME
	echo "STABLE_SAMPLES_ONLY=$STABLE_SAMPLES_ONLY" >> $FILENAME
	echo "RUN_CARGO_TRACKER_TESTS=$RUN_CARGO_TRACKER_TESTS" >> $FILENAME
	echo "RUN_GLASSFISH_TESTS=$RUN_GLASSFISH_TESTS" >> $FILENAME
	echo "QUICKLOOK_ONLY=$QUICKLOOK_ONLY" >> $FILENAME
	echo "RUN_MOJARRA_TESTS=$RUN_MOJARRA_TESTS" >> $FILENAME
	echo "TEST_PAYARA_5=$TEST_PAYARA_5" >> $FILENAME
	echo "" >> $FILENAME
	echo "PAYARA_HOME=$PAYARA_HOME" >> $FILENAME
	echo "MICRO_JAR=$MICRO_JAR" >> $FILENAME
	echo "PAYARA_SOURCE=$PAYARA_SOURCE" >> $FILENAME
	echo "SAVE_AS_PROPERTIES_FILE=n" >> $FILENAME
	echo "Saved provided properties as $FILENAME"
fi


# Check if PAYARA_SOURCE has been set if it's needed
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_GLASSFISH_TESTS" != "n" ] || [ "$RUN_FROM_SOURCE" != "n" ]; then
    if [ -z "$PAYARA_SOURCE" ]; then
        # Get the Payara source that we're going to run tests against
        read -p "Please enter the path to the Payara source repo: " PAYARA_SOURCE
    fi
fi

if [ "$RUN_FROM_SOURCE" != "n" ]; then
    # Set the Payara Server and Micro locations
    if [ "$TEST_PAYARA_5" != "y" ]; then
	echo "Using payara41"
       PAYARA_HOME=$PAYARA_SOURCE/appserver/distributions/payara/target/stage/payara41
    else
	echo "Using payara5"
	PAYARA_HOME=$PAYARA_SOURCE/appserver/distributions/payara/target/stage/payara5    
    fi
    MICRO_JAR=$PAYARA_SOURCE/appserver/extras/payara-micro/payara-micro-distribution/target/payara-micro.jar
else
    # Check if PAYARA_HOME has been set
    if [ -z "$PAYARA_HOME" ]; then
        # Get the Payara Server install that we're going to run the tests against
        read -p "Please enter the path to the Payara Server install that you would like to test: " PAYARA_HOME
    fi

    # We only need Micro if we're running the unstable internal Payara private tests
    if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_PAYARA_PRIVATE_TESTS" != "n" ]; then
        if [ "$STABLE_ONLY" = "n" ] || [ "$STABLE_PAYARA_PRIVATE_ONLY" = "n" ]; then
            # Check if MICRO_JAR has been set
            if [ -z "$MICRO_JAR" ]; then
                # Get the Payara Micro that we're going to run tests against
                read -p "Please enter the path to the Payara Micro JAR that you would like to test: " MICRO_JAR
            fi
        fi
    fi
fi

# Construct the Payara Server version from the properties within the glassfish-version.properties file
. $PAYARA_HOME/glassfish/config/branding/glassfish-version.properties 2>/dev/null
PAYARA_VERSION=$major_version.$minor_version.$update_version.$payara_version

# Check if we need to also add the payara_update_version property
if [ ! -z "$payara_update_version" ]; then
    PAYARA_VERSION=$PAYARA_VERSION.$payara_update_version
fi

###################################################
### Create and Configure a Domain for the Tests ###
###################################################

# Domain variables
DOMAIN_NAME="test-domain"
ASADMIN=$PAYARA_HOME/bin/asadmin
HZCLUSTER=TEST-HZC

# Paranoid Deletion of Existing Configuration
echo ""
echo ""
echo ""
echo "#################################################################################################################################################"
echo "# Attempting paranoid deletion of any existing configuration - errors will be thrown if there is no existing configuration, and can be ignored. #"
echo "#################################################################################################################################################"
echo ""
$ASADMIN delete-file-user u1 || true
$ASADMIN stop-instance instance1 || true
$ASADMIN delete-instance instance1 || true
$ASADMIN stop-instance instance2 || true
$ASADMIN delete-instance instance2 || true
$ASADMIN stop-instance RollingUpdatesInstance1 || true
$ASADMIN delete-instance RollingUpdatesInstance1 || true
$ASADMIN stop-instance RollingUpdatesInstance2 || true
$ASADMIN delete-instance RollingUpdatesInstance2 || true
$ASADMIN delete-cluster RollingUpdatesCluster || true
$ASADMIN stop-cluster sessionCluster || true
$ASADMIN delete-instance sessionInstance1 || true
$ASADMIN delete-instance sessionInstance2 || true
$ASADMIN stop-instance hz-member1 || true
$ASADMIN delete-instance hz-member1 || true
$ASADMIN stop-instance hz-member2 || true
$ASADMIN delete-instance hz-member2 || true
$ASADMIN stop-domain $DOMAIN_NAME || true
$ASADMIN delete-domain $DOMAIN_NAME || true
$ASADMIN stop-database || true
$ASADMIN -p 6048 stop-cluster test-cluster || true
$ASADMIN -p 6048 delete-instance test-instance-1 || true
$ASADMIN -p 6048 delete-instance test-instance-2 || true
$ASADMIN -p 6048 delete-cluster test-cluster || true
$ASADMIN stop-domain test-domain_asadmin || true
$ASADMIN delete-domain test-domain_asadmin || true
$ASADMIN stop-database --dbport 1528 || true

echo ""
echo ""
echo ""
echo "#####################################################"
echo "# Setting up the test domain - Errors matter again! #"
echo "#####################################################"
echo ""
# Create the Test Domain
if [ "USE_DEFAULT_DOMAIN_TEMPLATE" != "n" ];then
	$ASADMIN create-domain --nopassword $DOMAIN_NAME
else
	$ASADMIN create-domain --template $PAYARA_HOME/glassfish/common/templates/gf/payara-domain.jar --nopassword $DOMAIN_NAME
fi

# Start domain
$ASADMIN start-domain $DOMAIN_NAME

# Enable startup of the Admin Console
$ASADMIN set configs.config.server-config.admin-service.property.adminConsoleStartup=ALWAYS

$ASADMIN delete-jvm-options "-XX\:MaxPermSize=192m"

$ASADMIN create-jvm-options "-XX\:MaxPermSize=512m"

# PAYARA-1760 Suppress errors when on WiFi and using OSX
$ASADMIN create-jvm-options "-Djava.net.preferIPv4Stack=true"

$ASADMIN set-log-attributes --target server com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes=0

# Restart domain
$ASADMIN restart-domain $DOMAIN_NAME

# Enable Hazelcast
$ASADMIN set-hazelcast-configuration --clusterName=$HZCLUSTER --enabled true --dynamic true
$ASADMIN set resources.managed-scheduled-executor-service.concurrent/__defaultManagedScheduledExecutorService.core-pool-size=5

# Start Derby Database
$ASADMIN start-database

# Create Servlet Tests user
SERVLET_TEST_PASSWORD_FILE=$PAYARA_HOME/servlet-passwords.txt
echo AS_ADMIN_USERPASSWORD=p1 >$SERVLET_TEST_PASSWORD_FILE
$ASADMIN --passwordfile=$SERVLET_TEST_PASSWORD_FILE create-file-user --groups g1 u1

##############################
### Run the Selected Tests ###
##############################

echo ""
echo ""
echo ""
echo "##########################"
echo "# Running Selected Tests #"
echo "##########################"
echo ""

# Initialise the exit variables
PAYARA_PRIVATE_TEST_RESULT=0
SAMPLES_TEST_RESULT=0
SAMPLES_EE8_TEST_RESULT=0
CARGO_TRACKER_TEST_RESULT=0
GLASSFISH_TEST_RESULT=0
MOJARRA_TEST_RESULT=0
EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=0
EMBEDDED_WEB_CARGO_TRACKER_TEST_RESULT=0
STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT=0

# Run the private Payara tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_PAYARA_PRIVATE_TESTS" != "n" ]; then
    # If we've selected to only run the stable tests...
    if [ "$STABLE_ONLY" != "n" ] || [ "$STABLE_PAYARA_PRIVATE_ONLY" != "n" ]; then
        # If we've selected to only run the quick tests...
        if [ "$QUICK_ONLY" != "n" ] || [ "$QUICK_PAYARA_PRIVATE_ONLY" != "n" ]; then
            echo ""
            echo "#############################################"
            echo "# Running Quick Stable Private Payara Tests #"
            echo "#############################################"
            echo ""
            # Check if we should fail at end or not
            if [ "$FAIL_AT_END" != "n" ]; then
                # Fail at end
                mvn clean test -U -Ppayara-remote,quick-stable-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -fae -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            else
                # Fail fast
                mvn clean test -U -Ppayara-remote,quick-stable-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            fi
        else
            # Run the private tests with the stable profile (default)
            echo ""
            echo "#######################################"
            echo "# Running Stable Private Payara Tests #"
            echo "#######################################"
            echo ""
            # Check if we should fail at end or not
            if [ "$FAIL_AT_END" != "n" ]; then
                # Fail at end
                mvn clean test -U -Ppayara-remote,stable-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -fae -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            else
                # Fail fast
                mvn clean test -U -Ppayara-remote,stable-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            fi
        fi
    # If we've selected to run all of the private Payara tests...
    else
        # Run the private Payara tests with the all profile
        echo ""
        echo "####################################"
        echo "# Running All Private Payara Tests #"
        echo "####################################"
        echo ""
        # Check if we should fail at end or not
        if [ "$FAIL_AT_END" != "n" ]; then
            # Fail at end
            mvn clean test -U -Ppayara-remote,all-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -fae -f Private/PayaraTests-Private/pom.xml
            PAYARA_PRIVATE_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,all-tests -Dpayara.version=$PAYARA_VERSION -Dpayara.home=$PAYARA_HOME -Dmicro.jar=$MICRO_JAR -f Private/PayaraTests-Private/pom.xml
            PAYARA_PRIVATE_TEST_RESULT=$?
        fi
    fi

    # If we've selected to run the Stability Stream Version Validator - an independent project within Tests-Private
    if [ "RUN_STABILITY_STREAM_VERSION_VALIDATOR_TEST" == "y" ];then
	echo ""
	echo "##############################################"
	echo "# Running Stability Stream Version Validator #"
	echo "##############################################"
	echo ""
	# Only one test currently in this project
	mvn clean test -U -Dpayara.source=$PAYARA_SOURCE -f Private/PayaraTests-Private/stability-stream-version-validator/pom.xml
	STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT=$?
    fi
fi

# Run the Java EE 7 Samples tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_SAMPLES_TESTS" != "n" ]; then
    # If we've selected to only run the stable tests...
    if [ "$STABLE_ONLY" != "n" ] || [ "$STABLE_SAMPLES_ONLY" != "n" ]; then
        # Run the Java EE 7 Samples tests with the stable profile
        echo ""
        echo "##########################################"
        echo "# Running Stable Java EE 7 Samples Tests #"
        echo "##########################################"
        echo ""
        # Check if we should fail at end or not
        if [ "$FAIL_AT_END" != "n" ]; then
            # Fail at end
            mvn clean test -U -Ppayara-remote,stable -Dpayara.version=$PAYARA_VERSION -fae -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,stable -Dpayara.version=$PAYARA_VERSION -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
        fi
    # If we've selected to run all of the tests...
    else
        # Run with the all profile
        echo ""
        echo "#######################################"
        echo "# Running All Java EE 7 Samples Tests #"
        echo "#######################################"
        echo ""
        # Check if we should fail at end or not
        if [ "$FAIL_AT_END" != "n" ]; then
            # Fail at end
            mvn clean test -U -Ppayara-remote,all -Dpayara.version=$PAYARA_VERSION -fae -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,all -Dpayara.version=$PAYARA_VERSION -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
        fi
    fi
fi

# Run the Java EE 8 Samples tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_EE8_SAMPLES_TESTS" != "n" ]; then
    # No unstable tests yet defined so ignore for now and run it all
    echo ""
    echo "#######################################"
    echo "# Running All Java EE 8 Samples Tests #"
    echo "#######################################"
    echo ""
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ];then
	    # Fail at end
	    mvn clean test -U -Ppayara-remote,payara-embedded -Dpayara.version=$PAYARA_VERSION -f Public/JavaEE8_Samples/pom.xml
            SAMPLES_EE8_RESULT=$?
    else
	    # Fail fast
	    mvn clean test -U -Ppayara-remote,payara-embedded -Dpayara.version=$PAYARA_VERSION -f Public/JavaEE8_Samples/pom.xml
	    SAMPLES_EE8_RESULT=$?
    fi
fi

# Run the Cargo Tracker tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_CARGO_TRACKER_TESTS" != "n" ]; then
    # Run the Cargo Tracker tests
    echo ""
    echo "###############################"
    echo "# Running Cargo Tracker Tests #"
    echo "###############################"
    echo ""
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ]; then
        # Fail at end
        mvn clean test -U -fae -f Public/CargoTracker/pom.xml
        CARGO_TRACKER_TEST_RESULT=$?
    else
        # Fail fast
        mvn clean test -U -f Public/CargoTracker/pom.xml
        CARGO_TRACKER_TEST_RESULT=$?
    fi
fi

# Run the embedded tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_EMBEDDED_TESTS" != "n" ]; then
    # Run the Cargo Tracker tests against embedded all
    echo ""
    echo "##############################"
    echo "# Running Embedded All Tests #"
    echo "##############################"
    echo ""
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ]; then
	    # Fail at end
	    mvn clean test -Pembedded-all -Dpayara.version=$PAYARA_VERSION -U -fae -f Public/CargoTracker/pom.xml
	    EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
	    mvn clean test -Pembedded-web -Dpayara.version=$PAYARA_VERSION -U -fae -f Public/CargoTracker/pom.xml
	    EMBEDDED_WEB_CARGO_TRACKER_TEST_RESULT=$?
    else
	    # Fail fast
	    mvn clean test -Pembedded-all -Dpayara.version=$PAYARA_VERSION -U -fae -f Public/CargoTracker/pom.xml
            EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
	    mvn clean test -Pembedded-web -Dpayara.version=$PAYARA_VERSION -U -fae -f Public/CargoTracker/pom.xml
	    EMBEDDED_WEB_CARGO_TRACKER_TEST_RESULT=$?
    fi
fi

# Run the GlassFish tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_GLASSFISH_TESTS" != "n" ]; then
    # If we've selected to only run the quicklook tests...
    if [ "$QUICK_ONLY" != "n" ] || [ "$QUICKLOOK_ONLY" != "n" ]; then
        # Run the quicklook subset of the GlassFish tests
        echo ""
        echo "#####################################"
        echo "# Running GlassFish Quicklook Tests #"
        echo "#####################################"
        echo ""
        # Check if we should fail at end or not
        if [ "$FAIL_AT_END" != "n" ]; then
            # Fail at end
            mvn clean test -U -Dglassfish.home=$PAYARA_HOME/glassfish -fae -f $PAYARA_SOURCE/appserver/tests/quicklook/pom.xml
            GLASSFISH_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Dglassfish.home=$PAYARA_HOME/glassfish -f $PAYARA_SOURCE/appserver/tests/quicklook/pom.xml
            GLASSFISH_TEST_RESULT=$?
        fi
    # TODO - If we've selected to run all of the tests...
    fi
fi

# Run the Mojarra tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_MOJARRA_TESTS" != "n" ]; then
    # Run the Mojarra tests
    echo ""
    echo "#########################"
    echo "# Running Mojarra Tests #"
    echo "#########################"
    echo ""
    
    # Copy the required password file to where it's expected to be
    cp Public/Mojarra/password.txt $PAYARA_HOME/glassfish/domains/password.properties
    
    # Deploy the tests
    mvn -Ppayara-cargo,stable-tests -Dglassfish.cargo.home=$PAYARA_HOME cargo:redeploy -f Public/Mojarra/test/pom.xml
    
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ]; then
        # Fail at end
        mvn -U -fae -Pintegration-custom-modules,stable-tests -Dglassfish.cargo.home=$PAYARA_HOME verify -f Public/Mojarra/test/pom.xml
        MOJARRA_TEST_RESULT=$?
    else
        # Fail fast
        mvn -U -Pintegration-custom-modules,stable-tests -Dglassfish.cargo.home=$PAYARA_HOME verify -f Public/Mojarra/test/pom.xml
        MOJARRA_TEST_RESULT=$?
    fi
fi

#################
### Clean up  ###
#################
# Just try to shut down everything, in case something has hung around
$ASADMIN stop-instance instance1 || true
$ASADMIN stop-instance instance2 || true
$ASADMIN stop-instance RollingUpdatesInstance1 || true
$ASADMIN stop-instance RollingUpdatesInstance2 || true
$ASADMIN stop-cluster sessionCluster || true
$ASADMIN stop-instance hz-member1 || true
$ASADMIN stop-instance hz-member2 || true
$ASADMIN stop-domain $DOMAIN_NAME || true
$ASADMIN stop-database || true
$ASADMIN -p 6048 stop-cluster test-cluster || true
$ASADMIN stop-domain test-domain_asadmin || true
$ASADMIN stop-database --dbport 1528 || true

##########################
### Check for Failures ###
##########################
if [ $PAYARA_PRIVATE_TEST_RESULT -ne 0 ] || [ $SAMPLES_TEST_RESULT -ne 0 ] || [ $SAMPLES_EE8_TEST_RESULT -ne 0 ] || [ $CARGO_TRACKER_TEST_RESULT -ne 0 ] || [ $GLASSFISH_TEST_RESULT -ne 0 ] || [ $MOJARRA_TEST_RESULT -ne 0 ] || [ $EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT -ne 0 ] || [ $EMBEDDED_WEB_CARGO_TRACKER_TEST_RESULT -ne 0 ] || [ $STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT -ne 0 ]; then
    exit 1
fi
