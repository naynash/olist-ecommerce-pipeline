CREATE STORAGE INTEGRATION olist_s3_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/olist-snowflake-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://olist-de-project-ns/');


    ALTER STORAGE INTEGRATION olist_s3_integration
    SET STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::460182552534:role/olist-snowflake-role';

    DESC INTEGRATION olist_s3_integration;