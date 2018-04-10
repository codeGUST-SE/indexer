# codeGUST indexer
## Description
codeGUST indexer
## Getting started
Install the dependencies:
```
$ bundle install 
```
## Run the indexer
Command line arguments:
```
--env ENV     PROD or DEV, experimental if not set
```
For example:
For the experimental environment, using SampleDocumentDatastore which reads entities from `./db/sample_datastore.txt`:
```
$ ruby main.rb
```
For PROD or DEV environment:
```
$ ruby main.rb --env DEV
$ ruby main.rb --env PROD
```

