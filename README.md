# README #

# Test Suite Structure
The test suite is split into two sections: Public, and Private.
The former contains tests available for public viewing and editing, typically from external repos such as the Java EE 7 Samples repository.
The latter contains tests that are not available for Private viewing or editing, typically due to the contributor wishing to remain anonymous.

# Running the Test Suite
To run the Payara Tests locally, you will need to build Payara Server, as the tests require some dependencies created during the build.  

To build and run the tests use the following command:
    sh runTests.sh

This will run the tests using the default properties file: test-suite-config.properties

To run the tests with a different properties file:
    sh runTests.sh -p Path/to/properties/file

To run the tests without a properties file (specifying everything yourself):
    sh runTests.sh -i
