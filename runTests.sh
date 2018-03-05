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
        . "$PROPERTIES_FILE"
    else
	 # If one wasn't provided, just grab the ones from the default properties file
        . ./test-suite-config.properties
    fi
# If interactive mode was selected
else
    # Check if we want to test against the payara 5 branch
    read -rp "Do you want to test against Payara-5? (y/n) [n] " TEST_PAYARA_5

    # Check if we want to run all of the tests
    read -rp "Do you want to run all tests? (y/n) [y] " RUN_ALL_TESTS

    # If we do want to run all of the tests...
    if [ "$RUN_ALL_TESTS" != "n" ]; then
        # Check if we want to only run the stable tests or not
        read -rp "Do you only want to run the stable tests? (y/n) [y] " STABLE_ONLY
        
        # Check if we only want to run quick tests
        read -rp "Do you only want to run quick tests? (y/n) [y] " QUICK_ONLY
    # If we don't want to run all of the tests...
    else
        # Set these properties to false to prevent falling through the OR checks later on
        STABLE_ONLY="n"
        QUICK_ONLY="n"
    
        # Check if we want to run the private Payara tests
        read -rp "Do you want to run the Private Payara tests? (y/n) [y] " RUN_PAYARA_PRIVATE_TESTS
        
        # If we do want to run the private tests...
        if [ "$RUN_PAYARA_PRIVATE_TESTS" != "n" ]; then
            # Check if we only want to run the stable tests
            read -rp "Do you only want to run the stable tests? (y/n) [y] " STABLE_PAYARA_PRIVATE_ONLY
            
            # If we do want to only run the stable tests...
            if [ "$STABLE_PAYARA_PRIVATE_ONLY" != "n" ]; then
                # Check if we only want to run quick tests
                read -rp "Do you only want to run quick tests? (y/n) [y] " QUICK_PAYARA_PRIVATE_ONLY
            fi

	    read -rp "Do you want to run the stability stream version validator test? (y/n) [n] " RUN_STABILITY_STREAM_VERSION_VALIDATOR_TEST
        fi
        
        # Check if we want to run the Java EE 7 Samples tests
        read -rp "Do you want to run the Java EE 7 Samples tests? (y/n) [y] " RUN_SAMPLES_TESTS
        
        # If we do want to run the Java EE 7 Samples tests...
        if [ "$RUN_SAMPLES_TESTS" != "n" ]; then
            # Check if we want to only run the stable tests
            read -rp "Do you only want to run the stable tests? (y/n) [y] " STABLE_SAMPLES_ONLY
            
            # Check if we want to run the samples against Payara Micro
            read -rp "Do you also want to run the samples against Payara Micro? (y/n) [y] " RUN_SAMPLES_TESTS_MICRO
        fi

        read -rp "Do you want to run the Java EE 8 Samples tests? (y/n) [y] " RUN_EE8_SAMPLES_TESTS
        
        # If we do want to run the Java EE 8 Samples tests...
        if [ "$RUN_EE8_SAMPLES_TESTS" != "n" ]; then
            # Check if we want to run the samples against Payara Micro
            read -rp "Do you also want to run the samples against Payara Micro? (y/n) [y] " RUN_EE8_SAMPLES_TESTS_MICRO
        fi

        # Check if we want to run the Cargo Tracker tests
        read -rp "Do you want to run the Cargo Tracker tests? (y/n) [y] " RUN_CARGO_TRACKER_TESTS

        # Check if we want to run the Cargo Tracker tests against embedded
        read -rp "Do you want to run the Cargo Tracker tests against embedded? (y/n) [y] " RUN_EMBEDDED_CARGO_TESTS

        # Check if we want to run the GlassFish tests
        read -rp "DO you want to run the GlassFish tests? (y/n) [y] " RUN_GLASSFISH_TESTS

        # If we do want to run the GlassFish tests...
        if [ "$RUN_GLASSFISH_TESTS" != "n" ]; then
            # Check if we only want to run the GlassFish Quicklook tests
            read -rp "Do you only want to run the Quicklook tests? (y/n) [y] " QUICKLOOK_ONLY
        fi
        
        # Check if we want to run the Mojarra tests
        read -rp "Do you want to run the Mojarra tests? (y/n) [y] " RUN_MOJARRA_TESTS
        
        # Check if we want to run the MicroProfile TCK Tests
        read -rp "Do you want to run the MicroProfile TCK Tests? (y/n) [y] " RUN_MP_TCK_TESTS
        
        # If we do want to run the MicroProfile TCK tests...
        if [ "$RUN_MP_TCK_TESTS" != "n" ]; then
            
            # Check if we want to run all of the TCKs
            read -rp "Do you want to run all of the TCKs? (y/n) [y] " RUN_ALL_MP_TCK_TESTS
            
            # If we do want to run all of the TCKs...
            if [ "$RUN_ALL_MP_TCK_TESTS" != "n" ]; then
                
                # Check if we want to run them all against Micro as well
                read -rp "Do you also want to run all of the TCKs against Payara Micro? (y/n) [y] " RUN_ALL_MP_TCK_TESTS_MICRO

                # Check if we want to run them all against Embedded as well
                read -rp "Do you also want to run all of the TCKs against Payara Embedded? (y/n) [y] " RUN_ALL_MP_TCK_TESTS_EMBEDDED
            else             
                read -rp "Do you want to run the Config TCK? (y/n) [y] " RUN_MP_CONFIG_TCK_TESTS
                    
                if [ "$RUN_MP_CONFIG_TCK_TESTS" != "n" ]; then
                    read -rp "Do you also want to the TCK against Payara Micro? (y/n) [y] " RUN_MP_CONFIG_TCK_TESTS_MICRO
                    read -rp "Do you also want to the TCK against Payara Embedded? (y/n) [y] " RUN_MP_CONFIG_TCK_TESTS_EMBEDDED
                fi
                    
                read -rp "Do you want to run the Health TCK? (y/n) [y] " RUN_MP_HEALTH_TCK_TESTS
                    
                if [ "$RUN_MP_HEALTH_TCK_TESTS" != "n" ]; then
                    read -rp "Do you also want to the TCK against Payara Micro? (y/n) [y] " RUN_MP_HEALTH_TCK_TESTS_MICRO
                    read -rp "Do you also want to the TCK against Payara Embedded? (y/n) [y] " RUN_MP_HEALTH_TCK_TESTS_EMBEDDED
                fi
                    
                read -rp "Do you want to run the Fault Tolerance TCK? (y/n) [y] " RUN_MP_FAULT_TOLERANCE_TCK_TESTS
                    
                if [ "$RUN_MP_FAULT_TOLERANCE_TCK_TESTS" != "n" ]; then
                    read -rp "Do you also want to the TCK against Payara Micro? (y/n) [y] " RUN_MP_FAULT_TOLERANCE_TCK_TESTS_MICRO
                    read -rp "Do you also want to the TCK against Payara Embedded? (y/n) [y] " RUN_MP_FAULT_TOLERANCE_TCK_TESTS_EMBEDDED
                fi
                    
                read -rp "Do you want to run the Metrics TCK? (y/n) [y] " RUN_MP_METRICS_TCK_TESTS
                    
                if [ "$RUN_MP_METRICS_TCK_TESTS" != "n" ]; then
                    read -rp "Do you also want to the TCK against Payara Micro? (y/n) [y] " RUN_MP_METRICS_TCK_TESTS_MICRO
                    read -rp "Do you also want to the TCK against Payara Embedded? (y/n) [y] " RUN_MP_METRICS_TCK_TESTS_EMBEDDED
                fi
                    
                read -rp "Do you want to run the JWT Auth TCK? (y/n) [y] " RUN_MP_JWT_AUTH_TCK_TESTS
                    
                if [ "$RUN_MP_JWT_AUTH_TCK_TESTS" != "n" ]; then
                        read -rp "Do you also want to the TCK against Payara Micro? (y/n) [y] " RUN_MP_JWT_AUTH_TCK_TESTS_MICRO
                        read -rp "Do you also want to the TCK against Payara Embedded? (y/n) [y] " RUN_MP_JWT_AUTH_TCK_TESTS_EMBEDDED
                fi
            fi
        fi
    fi

    # Check if we want to fail at end or not
    read -rp "Do you want to fail at end? (y/n) [y] " FAIL_AT_END
    
    # Check if we want to use the distribution from the source, or provide our own
    read -rp "Do you want to test against a Payara Server built from the source? Select no if you want to provide the path to the Payara Server install yourself. (y/n) [y] " RUN_FROM_SOURCE

    # Check if we want to use the payara-domain instead of the default domain
    read -rp "Do you want to use the default glassfish compatible domain (domain1) instead of the Production Domain (production)? (y/n) [y] " USE_DEFAULT_DOMAIN_TEMPLATE

fi

# Check if PAYARA_SOURCE has been set if it's needed
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_GLASSFISH_TESTS" != "n" ] || [ "$RUN_FROM_SOURCE" != "n" ]; then
    if [ -z "$PAYARA_SOURCE" ]; then
        # Get the Payara source that we're going to run tests against
        read -rp "Please enter the path to the Payara source repo: " PAYARA_SOURCE
    fi
fi

if [ "$RUN_FROM_SOURCE" != "n" ]; then
    # Set the Payara Server and Micro locations
    if [ "$TEST_PAYARA_5" != "y" ]; then
       PAYARA_HOME=$PAYARA_SOURCE/appserver/distributions/payara/target/stage/payara41
    else
	PAYARA_HOME=$PAYARA_SOURCE/appserver/distributions/payara/target/stage/payara5    
    fi
    MICRO_JAR=$PAYARA_SOURCE/appserver/extras/payara-micro/payara-micro-distribution/target/payara-micro.jar
else
    # Check if PAYARA_HOME has been set
    if [ -z "$PAYARA_HOME" ]; then
        # Get the Payara Server install that we're going to run the tests against
        read -rp "Please enter the path to the Payara Server install that you would like to test: " PAYARA_HOME
    fi

    # We only need Micro if we're running tests against it
    if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_PAYARA_PRIVATE_TESTS" != "n" ]; then
        if [ "$STABLE_ONLY" != "n" ] || [ "$STABLE_PAYARA_PRIVATE_ONLY" != "n" ]; then
            # Check if MICRO_JAR has been set
            if [ -z "$MICRO_JAR" ]; then
                # Get the Payara Micro that we're going to run tests against
                read -rp "Please enter the path to the Payara Micro JAR that you would like to test: " MICRO_JAR
            fi
        fi
    fi
    
    if [ -z "$MICRO_JAR" ]; then
        if [ "$RUN_ALL_MP_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_MP_CONFIG_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_MP_HEALTH_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_MP_FAULT_TOLERANCE_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_MP_METRICS_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_MP_JWT_AUTH_TCK_TESTS_MICRO" != "n" ] || [ "$RUN_SAMPLES_TESTS_MICRO" != "n" ] || [ "$RUN_EE8_SAMPLES_TESTS_MICRO" != "n" ]; then
            # Get the Payara Micro that we're going to run tests against
            read -rp "Please enter the path to the Payara Micro JAR that you would like to test: " MICRO_JAR
        fi
    fi
    
fi

# Construct the Payara Server version from the properties within the glassfish-version.properties file
. "$PAYARA_HOME/glassfish/config/branding/glassfish-version.properties" 2>/dev/null

if [ "$TEST_PAYARA_5" = "y" ]; then
    PAYARA_VERSION=$major_version.$minor_version
    
    if [ ! -z "$update_version" ]; then
        PAYARA_VERSION=$PAYARA_VERSION.$update_version
    fi
else
    PAYARA_VERSION=$major_version.$minor_version.$update_version.$payara_version
fi

# Check if we need to also add the payara_update_version property
if [ ! -z "$payara_update_version" ]; then
    PAYARA_VERSION=$PAYARA_VERSION.$payara_update_version
fi

if [ $INTERACTIVE ]; then
    # Check if we want to save these settings as a custom properties file
    read -rp "Do you want to save these settings as a custom properties file? (y/n) [n] " SAVE_AS_PROPERTIES_FILE

    # Save the properties as a properties file
    if [ "$SAVE_AS_PROPERTIES_FILE" == "y" ];then
	FILENAME="test-suite-config-$(date +%Y-%m-%d-%H-%M-%S).properties"
	touch "./$FILENAME"
	{
        echo "RUN_ALL_TESTS=$RUN_ALL_TESTS"
        echo "STABLE_ONLY=$STABLE_ONLY"
        echo "FAIL_AT_END=$FAIL_AT_END"
        echo "QUICK_ONLY=$QUICK_ONLY"
        echo "RUN_FROM_SOURCE=$RUN_FROM_SOURCE"
        echo ""
        echo "RUN_PAYARA_PRIVATE_TESTS=$RUN_PAYARA_PRIVATE_TESTS"
        echo "STABLE_PAYARA_PRIVATE_ONLY=$STABLE_PAYARA_PRIVATE_ONLY"
        echo "QUICK_PAYARA_PRIVATE_ONLY=$QUICK_PAYARA_PRIVATE_ONLY"
        echo "RUN_SAMPLES_TESTS=$RUN_SAMPLES_TESTS"	
        echo "RUN_SAMPLES_TESTS_MICRO=$RUN_SAMPLES_TESTS_MICRO"
        echo "RUN_EE8_SAMPLES_TESTS=$RUN_EE8_SAMPLES_TESTS"
        echo "RUN_EE8_SAMPLES_TESTS_MICRO=$RUN_EE8_SAMPLES_TESTS_MICRO"
        echo "STABLE_SAMPLES_ONLY=$STABLE_SAMPLES_ONLY"
        echo "RUN_CARGO_TRACKER_TESTS=$RUN_CARGO_TRACKER_TESTS"
        echo "RUN_EMBEDDED_CARGO_TESTS=$RUN_EMBEDDED_CARGO_TESTS"
        echo "RUN_GLASSFISH_TESTS=$RUN_GLASSFISH_TESTS"
        echo "QUICKLOOK_ONLY=$QUICKLOOK_ONLY"
        echo "RUN_MOJARRA_TESTS=$RUN_MOJARRA_TESTS"
        echo "RUN_MP_TCK_TESTS=$RUN_MP_TCK_TESTS"
        echo "RUN_ALL_MP_TCK_TESTS=$RUN_ALL_MP_TCK_TESTS"
        echo "RUN_ALL_MP_TCK_TESTS_MICRO=$RUN_ALL_MP_TCK_TESTS_MICRO"
        echo "RUN_ALL_MP_TCK_TESTS_EMBEDDED=$RUN_ALL_MP_TCK_TESTS_EMBEDDED"
        echo "RUN_MP_CONFIG_TCK_TESTS=$RUN_MP_CONFIG_TCK_TESTS"
        echo "RUN_MP_CONFIG_TCK_TESTS_MICRO=$RUN_MP_CONFIG_TCK_TESTS_MICRO"
        echo "RUN_MP_CONFIG_TCK_TESTS_EMBEDDED=$RUN_MP_CONFIG_TCK_TESTS_EMBEDDED"
        echo "RUN_MP_HEALTH_TCK_TESTS=$RUN_MP_HEALTH_TCK_TESTS"
        echo "RUN_MP_HEALTH_TCK_TESTS_MICRO=$RUN_MP_HEALTH_TCK_TESTS_MICRO"
        echo "RUN_MP_HEALTH_TCK_TESTS_EMBEDDED=$RUN_MP_HEALTH_TCK_TESTS_EMBEDDED"
        echo "RUN_MP_FAULT_TOLERANCE_TCK_TESTS=$RUN_MP_FAULT_TOLERANCE_TCK_TESTS"
        echo "RUN_MP_FAULT_TOLERANCE_TCK_TESTS_MICRO=$RUN_MP_FAULT_TOLERANCE_TCK_TESTS_MICRO"
        echo "RUN_MP_FAULT_TOLERANCE_TCK_TESTS_EMBEDDED=$RUN_MP_FAULT_TOLERANCE_TCK_TESTS_EMBEDDED"
        echo "RUN_MP_METRICS_TCK_TESTS=$RUN_MP_METRICS_TCK_TESTS"
        echo "RUN_MP_METRICS_TCK_TESTS_MICRO=$RUN_MP_METRICS_TCK_TESTS_MICRO"
        echo "RUN_MP_METRICS_TCK_TESTS_EMBEDDED=$RUN_MP_METRICS_TCK_TESTS_EMBEDDED"
        echo "RUN_MP_JWT_AUTH_TCK_TESTS=$RUN_MP_JWT_AUTH_TCK_TESTS"
        echo "RUN_MP_JWT_AUTH_TCK_TESTS_MICRO=$RUN_MP_JWT_AUTH_TCK_TESTS_MICRO"
        echo "RUN_MP_JWT_AUTH_TCK_TESTS_EMBEDDED=$RUN_MP_JWT_AUTH_TCK_TESTS_EMBEDDED"
        echo "TEST_PAYARA_5=$TEST_PAYARA_5"
        echo ""
        echo "PAYARA_HOME=$PAYARA_HOME"
        echo "MICRO_JAR=$MICRO_JAR"
        echo "PAYARA_SOURCE=$PAYARA_SOURCE"
        echo "SAVE_AS_PROPERTIES_FILE=n"
    } >> "$FILENAME"
    
    echo "Saved provided properties as $FILENAME"
    
    fi
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
if [ "$USE_DEFAULT_DOMAIN_TEMPLATE" != "n" ];then
	$ASADMIN create-domain --nopassword $DOMAIN_NAME
else
    if [ "$TEST_PAYARA_5" != "y" ]; then
        $ASADMIN create-domain --template "$PAYARA_HOME/glassfish/common/templates/gf/payara-domain.jar" --nopassword $DOMAIN_NAME
    else 
        $ASADMIN create-domain --template "$PAYARA_HOME/glassfish/common/templates/gf/production-domain.jar" --nopassword $DOMAIN_NAME
    fi
fi

# Required to pass Metrics TCK
MP_METRICS_TAGS="tier=integration"
export MP_METRICS_TAGS

# Start domain
$ASADMIN start-domain $DOMAIN_NAME

# Enable startup of the Admin Console
$ASADMIN set configs.config.server-config.admin-service.property.adminConsoleStartup=ALWAYS

$ASADMIN delete-jvm-options "-XX\\:MaxPermSize=192m"

$ASADMIN create-jvm-options "-XX\\:MaxPermSize=512m"

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
echo AS_ADMIN_USERPASSWORD=p1 > "$SERVLET_TEST_PASSWORD_FILE"
$ASADMIN --passwordfile="$SERVLET_TEST_PASSWORD_FILE" create-file-user --groups g1 u1

##############################
### Run the Selected Tests ###
##############################

# Set environment variable so Maven knows where to find Micro
export MICRO_JAR=$MICRO_JAR

echo ""
echo ""
echo ""
echo "##########################"
echo "# Running Selected Tests #"
echo "##########################"
echo ""

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
                mvn clean test -U -Ppayara-remote,quick-stable-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -fae -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            else
                # Fail fast
                mvn clean test -U -Ppayara-remote,quick-stable-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -f Private/PayaraTests-Private/pom.xml
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
                mvn clean test -U -Ppayara-remote,stable-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -fae -f Private/PayaraTests-Private/pom.xml
                PAYARA_PRIVATE_TEST_RESULT=$?
            else
                # Fail fast
                mvn clean test -U -Ppayara-remote,stable-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -f Private/PayaraTests-Private/pom.xml
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
            mvn clean test -U -Ppayara-remote,all-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -fae -f Private/PayaraTests-Private/pom.xml
            PAYARA_PRIVATE_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,all-tests -Dpayara.version="$PAYARA_VERSION" -Dpayara.home="$PAYARA_HOME" -Dmicro.jar="$MICRO_JAR" -f Private/PayaraTests-Private/pom.xml
            PAYARA_PRIVATE_TEST_RESULT=$?
        fi
    fi

    # If we've selected to run the Stability Stream Version Validator - an independent project within Tests-Private
    if [ "$RUN_STABILITY_STREAM_VERSION_VALIDATOR_TEST" == "y" ];then
        echo ""
        echo "##############################################"
        echo "# Running Stability Stream Version Validator #"
        echo "##############################################"
        echo ""
        # Only one test currently in this project
        mvn clean test -U -Dpayara.source="$PAYARA_SOURCE" -f Private/PayaraTests-Private/stability-stream-version-validator/pom.xml
        STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT=$?
    fi

    echo "### Clearing away created resources, instances etc. ###"
    # Clear away created resources, instances etc. as the created instances can mess with the other tests (quicklook)
    $ASADMIN stop-instance instance1 || true
    $ASADMIN stop-instance instance2 || true
    $ASADMIN stop-instance RollingUpdatesInstance1 || true
    $ASADMIN stop-instance RollingUpdatesInstance2 || true
    $ASADMIN stop-cluster sessionCluster || true
    $ASADMIN stop-instance hz-member1 || true
    $ASADMIN stop-instance hz-member2 || true
    $ASADMIN stop-database --dbport 1528 || true
    $ASADMIN -p 6048 stop-cluster test-cluster || true
    $ASADMIN stop-domain test-domain_asadmin || true
    $ASADMIN delete-instance instance1 || true
    $ASADMIN delete-instance instance2 || true
    $ASADMIN delete-instance RollingUpdatesInstance1 || true
    $ASADMIN delete-instance RollingUpdatesInstance2 || true
    $ASADMIN delete-cluster sessionCluster || true
    $ASADMIN delete-instance hz-member1 || true
    $ASADMIN delete-instance hz-member2 || true
    $ASADMIN delete-domain test-domain_asadmin || true
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
            mvn clean test -U -Ppayara-remote,stable -Dpayara.version="$PAYARA_VERSION" -fae -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
            
            # Run against Micro if selected
            if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_SAMPLES_TESTS_MICRO" != "n" ]; then
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true 
            
                mvn clean test -U -Ppayara-micro-managed,stable -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -fae -f Public/JavaEE7-Samples/pom.xml
                SAMPLES_MICRO_TEST_RESULT=$?
                
                # Start the remote domain again
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,stable -Dpayara.version="$PAYARA_VERSION" -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
            
            # Run against Micro if selected
            if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_SAMPLES_TESTS_MICRO" != "n" ]; then
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true 
            
                mvn clean test -U -Ppayara-micro-managed,stable -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -f Public/JavaEE7-Samples/pom.xml
                SAMPLES_MICRO_TEST_RESULT=$?
                
                # Start the remote domain again
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
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
            mvn clean test -U -Ppayara-remote,all -Dpayara.version="$PAYARA_VERSION" -fae -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
            
            # Run against Micro if selected
            if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_SAMPLES_TESTS_MICRO" != "n" ]; then
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true 
            
                mvn clean test -U -Ppayara-micro-managed,all -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -fae -f Public/JavaEE7-Samples/pom.xml
                SAMPLES_MICRO_TEST_RESULT=$?
                
                # Start the remote domain again
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        else
            # Fail fast
            mvn clean test -U -Ppayara-remote,all -Dpayara.version="$PAYARA_VERSION" -f Public/JavaEE7-Samples/pom.xml
            SAMPLES_TEST_RESULT=$?
            
            # Run against Micro if selected
            if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_SAMPLES_TESTS_MICRO" != "n" ]; then
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true 
            
                mvn clean test -U -Ppayara-micro-managed,all -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -f Public/JavaEE7-Samples/pom.xml
                SAMPLES_MICRO_TEST_RESULT=$?
                
                # Start the remote domain again
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
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
	    mvn clean test -U -Ppayara-remote -Dpayara.version="$PAYARA_VERSION" -fae -f Public/JavaEE8-Samples/pom.xml
        SAMPLES_EE8_TEST_RESULT=$?
        
        # Run against Micro if selected
        if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_EE8_SAMPLES_TESTS_MICRO" != "n" ]; then
            # Shut down the remote domain to stop port clashes
            $ASADMIN stop-domain $DOMAIN_NAME || true
            $ASADMIN stop-database || true 
        
            mvn clean test -U -Ppayara-micro-managed -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -fae -f Public/JavaEE8-Samples/pom.xml
            SAMPLES_EE8_MICRO_TEST_RESULT=$?
            
            # Start the remote domain again
            $ASADMIN start-domain $DOMAIN_NAME
            $ASADMIN start-database
        fi
    else
	    # Fail fast
	    mvn clean test -U -Ppayara-remote -Dpayara.version="$PAYARA_VERSION" -f Public/JavaEE8-Samples/pom.xml
	    SAMPLES_EE8_TEST_RESULT=$?
	    
	    # Run against Micro if selected
        if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_EE8_SAMPLES_TESTS_MICRO" != "n" ]; then
            # Shut down the remote domain to stop port clashes
            $ASADMIN stop-domain $DOMAIN_NAME || true
            $ASADMIN stop-database || true 
        
            mvn clean test -U -Ppayara-micro-managed -Dpayara.version="$PAYARA_VERSION" -Dpayara.micro.version="$PAYARA_VERSION" -f Public/JavaEE8-Samples/pom.xml
            SAMPLES_EE8_MICRO_TEST_RESULT=$?
            
            # Start the remote domain again
            $ASADMIN start-domain $DOMAIN_NAME
            $ASADMIN start-database
        fi
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
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_EMBEDDED_CARGO_TESTS" != "n" ]; then
    # Shut down the remote domain to stop port clashes
    $ASADMIN stop-domain $DOMAIN_NAME || true
    $ASADMIN stop-database || true  

    # Run the Cargo Tracker tests against embedded all
    echo ""
    echo "#######################################"
    echo "# Running CargoTracker Embedded Tests #"
    echo "#######################################"
    echo ""
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ]; then
        # Check if we're running against 5 or not
        if [ "$TEST_PAYARA_5" = "y" ]; then
            # Fail at end
            mvn clean test -Ppayara-embedded -Dpayara.version="$PAYARA_VERSION" -U -fae -f Public/CargoTracker/pom.xml
            EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
        else
            # Fail at end
            mvn clean test -Ppayara-embedded,payara4 -Dpayara.version="$PAYARA_VERSION" -U -fae -f Public/CargoTracker/pom.xml
            EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
        fi
    else
        # Check if we're running against 5 or not
        if [ "$TEST_PAYARA_5" = "y" ]; then
            # Fail fast
            mvn clean test -Ppayara-embedded -Dpayara.version="$PAYARA_VERSION" -U -ff -fae -f Public/CargoTracker/pom.xml
            EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -Ppayara-embedded,payara4 -Dpayara.version="$PAYARA_VERSION" -U -ff -fae -f Public/CargoTracker/pom.xml
            EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=$?
        fi
    fi

    # Start remote domain and database back up
    $ASADMIN start-domain $DOMAIN_NAME
    $ASADMIN start-database
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
            mvn clean test -U -Dglassfish.home="$PAYARA_HOME/glassfish" -fae -f "$PAYARA_SOURCE/appserver/tests/quicklook/pom.xml"
            GLASSFISH_TEST_RESULT=$?
        else
            # Fail fast
            mvn clean test -U -Dglassfish.home="$PAYARA_HOME/glassfish" -f "$PAYARA_SOURCE/appserver/tests/quicklook/pom.xml"
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
    cp Public/Mojarra/password.txt "$PAYARA_HOME/glassfish/domains/password.properties"
    
    # Deploy the tests
    mvn -Ppayara-cargo,stable-tests -Dglassfish.cargo.home="$PAYARA_HOME" cargo:redeploy -f Public/Mojarra/test/pom.xml
    
    # Check if we should fail at end or not
    if [ "$FAIL_AT_END" != "n" ]; then
        # Fail at end
        mvn -U -fae -Pintegration-custom-modules,stable-tests -Dglassfish.cargo.home="$PAYARA_HOME" verify -f Public/Mojarra/test/pom.xml
        MOJARRA_TEST_RESULT=$?
    else
        # Fail fast
        mvn -U -Pintegration-custom-modules,stable-tests -Dglassfish.cargo.home="$PAYARA_HOME" verify -f Public/Mojarra/test/pom.xml
        MOJARRA_TEST_RESULT=$?
    fi
fi

# Run the MP TCK tests if selected
if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_MP_TCK_TESTS" != "n" ]; then
    if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_ALL_MP_TCK_TESTS" != "n" ]; then 
        mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
        MP_CONFIG_TCK_TEST_RESULT=$?
    
        mvn clean install -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/payara-health-arquillian-extension/pom.xml -Dpayara.version="$PAYARA_VERSION"
        mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml
        MP_HEALTH_TCK_TEST_RESULT=$?
    
        mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
        MP_FAULT_TOLERANCE_TCK_TEST_RESULT=$?
        
        mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
        MP_METRICS_TCK_TEST_RESULT=$?
        
        mvn clean install -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/payara-jwt-auth-arquillian-extension/pom.xml -Dpayara.version="$PAYARA_VERSION"
        mvn clean test -Pfull,payara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
        MP_JWT_AUTH_TCK_TEST_RESULT=$?
        
        if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_ALL_MP_TCK_TESTS_MICRO" != "n" ]; then
            # Shut down the remote domain to stop port clashes
            $ASADMIN stop-domain $DOMAIN_NAME || true
            $ASADMIN stop-database || true 
            
            mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_CONFIG_TCK_MICRO_TEST_RESULT=$?
        
            mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml
            MP_HEALTH_TCK_MICRO_TEST_RESULT=$?
        
            mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT=$?
        
            mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
            MP_METRICS_TCK_MICRO_TEST_RESULT=$?
        
            mvn clean test -Pfull,payara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_JWT_AUTH_TCK_MICRO_TEST_RESULT=$?
            
            # Start remote domain and database back up
            $ASADMIN start-domain $DOMAIN_NAME
            $ASADMIN start-database
        fi
        
        if [ "$RUN_ALL_TESTS" != "n" ] || [ "$RUN_ALL_MP_TCK_TESTS_EMBEDDED" != "n" ]; then
            # Shut down the remote domain to stop port clashes
            $ASADMIN stop-domain $DOMAIN_NAME || true
            $ASADMIN stop-database || true 

            mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_CONFIG_TCK_EMBEDDED_TEST_RESULT=$?
        
            mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml
            MP_HEALTH_TCK_EMBEDDED_TEST_RESULT=$?
    
            mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT=$?
        
            mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
            MP_METRICS_TCK_EMBEDDED_TEST_RESULT=$?
        
            mvn clean test -Pfull,payara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT=$?

            # Start remote domain and database back up
            $ASADMIN start-domain $DOMAIN_NAME
            $ASADMIN start-database
        fi
    else
        # Run the Config tests
        if [ "$RUN_MP_CONFIG_TCK_TESTS" != "n" ]; then
            echo ""
            echo "###########################"
            echo "# Running MP Config Tests #"
            echo "###########################"
            echo ""
        
            mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_CONFIG_TCK_TEST_RESULT=$?
        
            if [ "$RUN_MP_CONFIG_TCK_TESTS_MICRO" != "n" ]; then
                echo ""
                echo "#################################"
                echo "# Running MP Config Micro Tests #"
                echo "#################################"
                echo ""

                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true 
            
                mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_CONFIG_TCK_MICRO_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        
            if [ "$RUN_MP_CONFIG_TCK_TESTS_EMBEDDED" != "n" ]; then
                echo ""
                echo "####################################"
                echo "# Running MP Config Embedded Tests #"
                echo "####################################"
                echo ""
                
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Config/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_CONFIG_TCK_EMBEDDED_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        fi
            
        # Run the Health tests
        if [ "$RUN_MP_HEALTH_TCK_TESTS" != "n" ]; then
            echo ""
            echo "###########################"
            echo "# Running MP Health Tests #"
            echo "###########################"
            echo ""
        
            mvn clean install -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/payara-health-arquillian-extension/pom.xml -Dpayara.version="$PAYARA_VERSION"
            mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_HEALTH_TCK_TEST_RESULT=$?
        
            if [ "$RUN_MP_HEALTH_TCK_TESTS_MICRO" != "n" ]; then
                echo ""
                echo "#################################"
                echo "# Running MP Health Micro Tests #"
                echo "#################################"
                echo ""
            
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_HEALTH_TCK_MICRO_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        
            if [ "$RUN_MP_HEALTH_TCK_TESTS_EMBEDDED" != "n" ]; then
                echo ""
                echo "####################################"
                echo "# Running MP Health Embedded Tests #"
                echo "####################################"
                echo ""
                
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Health\ Check/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_HEALTH_TCK_EMBEDDED_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        fi
        
        # Run the Fault Tolerance tests
        if [ "$RUN_MP_FAULT_TOLERANCE_TCK_TESTS" != "n" ]; then
            echo ""
            echo "####################################"
            echo "# Running MP Fault Tolerance Tests #"
            echo "####################################"
            echo ""
        
            mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_FAULT_TOLERANCE_TCK_TEST_RESULT=$?
        
            if [ "$RUN_MP_FAULT_TOLERANCE_TCK_TESTS_MICRO" != "n" ]; then
                echo ""
                echo "##########################################"
                echo "# Running MP Fault Tolerance Micro Tests #"
                echo "##########################################"
                echo ""
            
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        
            if [ "$RUN_MP_FAULT_TOLERANCE_TCK_TESTS_EMBEDDED" != "n" ]; then
                echo ""
                echo "#############################################"
                echo "# Running MP Fault Tolerance Embedded Tests #"
                echo "#############################################"
                echo ""
                
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Fault\ Tolerance/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        fi
        
        # Run the Metrics tests
        if [ "$RUN_MP_METRICS_TCK_TESTS" != "n" ]; then
            echo ""
            echo "############################"
            echo "# Running MP Metrics Tests #"
            echo "############################"
            echo ""
            
            mvn clean test -Ppayara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
            MP_METRICS_TCK_TEST_RESULT=$?
        
            if [ "$RUN_MP_METRICS_TCK_TESTS_MICRO" != "n" ]; then
                echo ""
                echo "##################################"
                echo "# Running MP Metrics Micro Tests #"
                echo "##################################"
                echo ""
            
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
                MP_METRICS_TCK_MICRO_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        
            if [ "$RUN_MP_METRICS_TCK_TESTS_EMBEDDED" != "n" ]; then
                echo ""
                echo "#####################################"
                echo "# Running MP Metrics Embedded Tests #"
                echo "#####################################"
                echo ""
                
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Ppayara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ Metrics/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION" 
                MP_METRICS_TCK_EMBEDDED_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        fi
        
        # Run the JWT Auth tests
        if [ "$RUN_MP_JWT_AUTH_TCK_TESTS" != "n" ]; then
            echo ""
            echo "#############################"
            echo "# Running MP JWT Auth Tests #"
            echo "#############################"
            echo ""
        
            mvn clean install -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/payara-jwt-auth-arquillian-extension/pom.xml -Dpayara.version="$PAYARA_VERSION"
            mvn clean test -Pfull,payara-server-remote -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
            MP_JWT_AUTH_TCK_TEST_RESULT=$?
        
            if [ "$RUN_MP_JWT_AUTH_TCK_TESTS_MICRO" != "n" ]; then
                echo ""
                echo "###################################"
                echo "# Running MP JWT Auth Micro Tests #"
                echo "###################################"
                echo ""
            
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Pfull,payara-micro-managed -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_JWT_AUTH_TCK_MICRO_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        
            if [ "$RUN_MP_JWT_AUTH_TCK_TESTS_EMBEDDED" != "n" ]; then
                echo ""
                echo "######################################"
                echo "# Running MP JWT Auth Embedded Tests #"
                echo "######################################"
                echo ""
                
                # Shut down the remote domain to stop port clashes
                $ASADMIN stop-domain $DOMAIN_NAME || true
                $ASADMIN stop-database || true

                mvn clean test -Pfull,payara-embedded -f Public/MicroProfile-TCK-Runners/MicroProfile\ JWT\ Auth/tck-runner/pom.xml -Dpayara.version="$PAYARA_VERSION"
                MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT=$?

                # Start remote domain and database back up
                $ASADMIN start-domain $DOMAIN_NAME
                $ASADMIN start-database
            fi
        fi
    fi
fi

#################
### Clean up  ###
#################

$ASADMIN stop-domain $DOMAIN_NAME || true
$ASADMIN stop-database || true
unset MICRO_JAR
unset MP_METRICS_TAGS

##################################################
### Print Results and Inialiuse Exit Variables ###
##################################################
if [ ! -z "$PAYARA_PRIVATE_TEST_RESULT" ]; then
    echo PAYARA_PRIVATE_TEST_RESULT = $PAYARA_PRIVATE_TEST_RESULT
else
    PAYARA_PRIVATE_TEST_RESULT=0
fi

if [ -z "$STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT" ]; then
    echo STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT = $STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT
else
    STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT=0
fi

if [ -z "$SAMPLES_TEST_RESULT" ]; then
    echo SAMPLES_TEST_RESULT = $SAMPLES_TEST_RESULT
else
    SAMPLES_TEST_RESULT=0
fi

if [ -z "$SAMPLES_MICRO_TEST_RESULT" ]; then
    echo SAMPLES_MICRO_TEST_RESULT = $SAMPLES_MICRO_TEST_RESULT
else
    SAMPLES_MICRO_TEST_RESULT=0
fi

if [ -z "$SAMPLES_EE8_TEST_RESULT" ]; then
    echo SAMPLES_EE8_TEST_RESULT = $SAMPLES_EE8_TEST_RESULT
else
    SAMPLES_EE8_TEST_RESULT=0
fi

if [ -z "$SAMPLES_EE8_MICRO_TEST_RESULT" ]; then
    echo SAMPLES_EE8_MICRO_TEST_RESULT = $SAMPLES_EE8_MICRO_TEST_RESULT
else
    SAMPLES_EE8_MICRO_TEST_RESULT=0
fi

if [ -z "$CARGO_TRACKER_TEST_RESULT" ]; then
    echo CARGO_TRACKER_TEST_RESULT = $CARGO_TRACKER_TEST_RESULT
else
    CARGO_TRACKER_TEST_RESULT=0
fi

if [ -z "$EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT" ]; then
    echo EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT = $EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT
else
    EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT=0
fi

if [ -z "$GLASSFISH_TEST_RESULT" ]; then
    echo GLASSFISH_TEST_RESULT = $GLASSFISH_TEST_RESULT
else
    GLASSFISH_TEST_RESULT=0
fi

if [ -z "$MOJARRA_TEST_RESULT" ]; then
    echo MOJARRA_TEST_RESULT = $MOJARRA_TEST_RESULT
else
    MOJARRA_TEST_RESULT=0
fi

if [ -z "$MP_CONFIG_TCK_TEST_RESULT" ]; then
    echo MP_CONFIG_TCK_TEST_RESULT = $MP_CONFIG_TCK_TEST_RESULT
else
    MP_CONFIG_TCK_TEST_RESULT=0
fi

if [ -z "$MP_CONFIG_TCK_EMBEDDED_TEST_RESULT" ]; then
    echo MP_CONFIG_TCK_EMBEDDED_TEST_RESULT = $MP_CONFIG_TCK_EMBEDDED_TEST_RESULT
else
    MP_CONFIG_TCK_EMBEDDED_TEST_RESULT=0
fi

if [ -z "$MP_CONFIG_TCK_MICRO_TEST_RESULT" ]; then
    echo MP_CONFIG_TCK_MICRO_TEST_RESULT = $MP_CONFIG_TCK_MICRO_TEST_RESULT
else
    MP_CONFIG_TCK_MICRO_TEST_RESULT=0
fi

if [ -z "$MP_HEALTH_TCK_TEST_RESULT" ]; then
    echo MP_HEALTH_TCK_TEST_RESULT = $MP_HEALTH_TCK_TEST_RESULT
else
    MP_HEALTH_TCK_TEST_RESULT=0
fi

if [ -z "$MP_HEALTH_TCK_EMBEDDED_TEST_RESULT" ]; then
    echo MP_HEALTH_TCK_EMBEDDED_TEST_RESULT = $MP_HEALTH_TCK_EMBEDDED_TEST_RESULT
else
    MP_HEALTH_TCK_EMBEDDED_TEST_RESULT=0
fi

if [ -z "$MP_HEALTH_TCK_MICRO_TEST_RESULT" ]; then
    echo MP_HEALTH_TCK_MICRO_TEST_RESULT = $MP_HEALTH_TCK_MICRO_TEST_RESULT
else
    MP_HEALTH_TCK_MICRO_TEST_RESULT=0
fi

if [ -z "$MP_FAULT_TOLERANCE_TCK_TEST_RESULT" ]; then
    echo MP_FAULT_TOLERANCE_TCK_TEST_RESULT = $MP_FAULT_TOLERANCE_TCK_TEST_RESULT
else
    MP_FAULT_TOLERANCE_TCK_TEST_RESULT=0
fi

if [ -z "$MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT" ]; then
    echo MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT = $MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT
else
    MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT=0
fi

if [ -z "$MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT" ]; then
    echo MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT = $MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT
else
    MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT=0
fi

if [ -z "$MP_METRICS_TCK_TEST_RESULT" ]; then
    echo MP_METRICS_TCK_TEST_RESULT = $MP_METRICS_TCK_TEST_RESULT
else
    MP_METRICS_TCK_TEST_RESULT=0
fi

if [ -z "$MP_METRICS_TCK_EMBEDDED_TEST_RESULT" ]; then
    echo MP_METRICS_TCK_EMBEDDED_TEST_RESULT = $MP_METRICS_TCK_EMBEDDED_TEST_RESULT
else
    MP_METRICS_TCK_EMBEDDED_TEST_RESULT=0
fi

if [ -z "$MP_METRICS_TCK_MICRO_TEST_RESULT" ]; then
    echo MP_METRICS_TCK_MICRO_TEST_RESULT = $MP_METRICS_TCK_MICRO_TEST_RESULT
else
    MP_METRICS_TCK_MICRO_TEST_RESULT=0
fi

if [ -z "$MP_JWT_AUTH_TCK_TEST_RESULT" ]; then
    echo MP_JWT_AUTH_TCK_TEST_RESULT = $MP_JWT_AUTH_TCK_TEST_RESULT
else
    MP_JWT_AUTH_TCK_TEST_RESULT=0
fi

if [ -z "$MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT" ]; then
    echo MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT = $MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT
else
    MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT=0
fi

if [ -z "$MP_JWT_AUTH_TCK_MICRO_TEST_RESULT" ]; then
    echo MP_JWT_AUTH_TCK_MICRO_TEST_RESULT = $MP_JWT_AUTH_TCK_MICRO_TEST_RESULT
else
    MP_JWT_AUTH_TCK_MICRO_TEST_RESULT=0
fi

##########################
### Check for Failures ###
##########################
if [ $PAYARA_PRIVATE_TEST_RESULT -ne 0 ] || [ $SAMPLES_TEST_RESULT -ne 0 ] || [ $SAMPLES_EE8_TEST_RESULT -ne 0 ] || [ $CARGO_TRACKER_TEST_RESULT -ne 0 ] || [ $GLASSFISH_TEST_RESULT -ne 0 ] || [ $MOJARRA_TEST_RESULT -ne 0 ] || [ $STABILITY_STREAM_VERSION_VALIDATOR_TEST_RESULT -ne 0 ] || [ $EMBEDDED_ALL_CARGO_TRACKER_TEST_RESULT -ne 0 ]  || [ $MP_CONFIG_TCK_TEST_RESULT -ne 0 ] || [ $MP_CONFIG_TCK_EMBEDDED_TEST_RESULT -ne 0 ] || [ $MP_CONFIG_TCK_MICRO_TEST_RESULT -ne 0 ] || [ $MP_HEALTH_TCK_TEST_RESULT -ne 0 ] || [ $MP_HEALTH_TCK_EMBEDDED_TEST_RESULT -ne 0 ] || [ $MP_HEALTH_TCK_MICRO_TEST_RESULT -ne 0 ] || [ $MP_FAULT_TOLERANCE_TCK_TEST_RESULT -ne 0 ] || [ $MP_FAULT_TOLERANCE_TCK_EMBEDDED_TEST_RESULT -ne 0 ] || [ $MP_FAULT_TOLERANCE_TCK_MICRO_TEST_RESULT -ne 0 ] || [ $MP_METRICS_TCK_TEST_RESULT -ne 0 ] || [ $MP_METRICS_TCK_EMBEDDED_TEST_RESULT -ne 0 ] || [ $MP_METRICS_TCK_MICRO_TEST_RESULT -ne 0 ] || [ $MP_JWT_AUTH_TCK_TEST_RESULT -ne 0 ] || [ $MP_JWT_AUTH_TCK_EMBEDDED_TEST_RESULT -ne 0 ] || [ $MP_JWT_AUTH_TCK_MICRO_TEST_RESULT -ne 0 ] || [ $SAMPLES_MICRO_TEST_RESULT -ne 0 ] || [ $SAMPLES_EE8_MICRO_TEST_RESULT -ne 0 ]; then
    echo "Exiting with exit code 1"
    exit 1
fi
