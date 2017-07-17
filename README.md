# README #

# Test Suite Structure
The test suite is split into two sections: Public, and Private.
The former, as the name suggests, contains tests available for public viewing and editing, typically from external repos such as the Java EE 7 Samples repository.
The latter contains tests that are not available for Private viewing or editing, the most common reason for which being the contributor providing the test to us in confidence.

# Running the Test Suite
To run the full test suite, you will need to build the [Payara Server source](https://github.com/payara/Payara), as some of the tests have dependencies on artefacts created during the build.  

To build and run the tests with the default properties file (_test-suite-config.properties_), use the following command:  
`sh runTests.sh`

You can also pass the script a different properties file if you have one saved elsewhere with the `-p` option:  
`sh runTests.sh -p Path/to/properties/file`

Alternatively, you can run the tests without a properties file, specifying everything yourself via interactive prompts, by running:  
`sh runTests.sh -i`
