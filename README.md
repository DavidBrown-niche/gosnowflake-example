<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [gosnowflake-example](#gosnowflake-example)
  - [Usage](#usage)
  - [Running Locally](#running-locally)
  - [Running in Docker](#running-in-docker)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# gosnowflake-example
Example showing how to access snowflake using go. Runs a simple query and logs
a success message. The example supports username/password or key pair authentication.
  
You can modify the query variable in `main.go` to run different queries, just
don't forget to change `SNOWFLAKE.DATABASE` and `SNOWFLAKE.SCHEMA` in the `.env`
files when changing the query if necessary.

## Usage

```
Usage of gosnowflake-example:
  -snowflake.account string
        Account name for snowflake. Account name is not the username, see https://docs.snowflake.com/en/user-guide/admin-account-identifier for more details
  -snowflake.database string
        Database name for snowflake
  -snowflake.password string
        Password for snowflake. Cannot be used in conjunction with snowflake.private.key
  -snowflake.private.key string
        Private key used to authenticate with snowflake, pkcs8 in PEM format. Cannot be used in conjunction with snowflake.password
  -snowflake.private.key.passcode string
        Passcode for encrypted private key (not necessary if key is not encrypted)
  -snowflake.schema string
        Schema name for snowflake
  -snowflake.user string
        Username for snowflake
```

## Running Locally

Create a `.env` file similar to `.env.example` and populate it with your
credentials, (if using password auth leave the private_key/passcode vars empty,
likewise if using key pair auth leave the password var empty).

This command will set your env variables and run the example:
```
. .env && go run .
```

Depending on local DNS settings, you may see the below error message multiple
times when you run the tool:
```
ERRO[0019]log.go:122 gosnowflake.(*defaultLogger).Errorf failed to get OCSP cache from OCSP Cache Server. Get "http://ocsp.snowflakecomputing.com/ocsp_response_cache.json": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

This should clear up by itself after 1 or 2 minutes and you should eventually
see:
```
{"level":"info","msg":"Successfully pulled 1 results from snowflake"}
```
Indicating that you've successfully queried snowflake!

## Running in Docker

Similar to above, create a `.env.docker` similar to `.env.docker.example` and
populate it with your credentials. Note that due to limitations with the docker
--env-file flag (specifically a lack of support for quoted and multiline
variables), you cannot define a private key in the `.env.docker` file.

Build the example:
```
make build-gosnowflake-example
```

Run the example:
```
make gosnowflake-example
```

You should see:
```
{"level":"info","msg":"Successfully pulled 1 results from snowflake"}
```
Indicating that you've successfully queried snowflake!