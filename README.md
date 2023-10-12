# Simple Storage API (Reference Implementation)

Simple Storage provide a simple interface for storing objects in multiple storage backends.


## Getting Started

After you have cloned the library, make sure you have installed Ruby `3.2.2` then run the following:

```shell
bundle install
bin/rails db:create
bin/rails db:migrate
```

This will install the required dependencies and create a small SQLite database for tracking blobs. If you need to
change the database adapter, you can do in `config/database.yml`.


## Authentication

The API uses simple `Bearer` authentication, no fancy stuff, as this tool is intended for internal use.

To setup the API key, make sure to set the following environment variable:

```shell
DRIVE_API_KEY="very-strong-api-key"
```


## Using Local Storage Engine

To use the local storage engine which allows you to store data in your local file system set the following environment variables:

```shell
DRIVE_PROVIDER=local
DRIVE_LOCAL_PATH=/mnt/example/path
```


## Using Database Storage Engine

This option gives you the ability to store binary data within your database.

```shell
DRIVE_PROVIDER=db
```

## Simple Storage Service (S3) Engine

This engine uses AWS S3 or compatible storage provider to store data.

```shell
DRIVE_AWS_BASE_URL=https://s3.eu-west-1.amazonaws.com
DRIVE_AWS_REGION=eu-west-1
DRIVE_AWS_BUCKET=data_bucket
DRIVE_AWS_KEY_ID=123
DRIVE_AWS_KEY_SECRET=qwe123
```
