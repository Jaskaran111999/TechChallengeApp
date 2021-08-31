## Platform and Infrastructure

The platform selected for this Challenge is AWS with and the following infrastructure has been chosen for the deployment of the solution.

## Updates

1. **circleci**
	* Updated config file to build image and publish to Amazon ECR

2. **db.go**
	* Removed default tablespace in table creation query because RDS won't allow access to default namespace explicitly
	* If no tablespace is mentioned the table is created in the default tablespace implicitly


## Links to access

	* App: http://lb-servian-1721320743.ap-southeast-2.elb.amazonaws.com
	* Healthcheck: http://lb-servian-1721320743.ap-southeast-2.elb.amazonaws.com/healthcheck/
	* Swagger: http://lb-servian-1721320743.ap-southeast-2.elb.amazonaws.com/swagger/
