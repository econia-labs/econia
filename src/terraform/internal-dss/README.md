This Terraform project is designed to support an internal deployment of the Econia Data Service Stack (DSS).
It uses a compromised JWT secret, does not limit the number of rows in a PostgREST query, and sets up endpoint URLs that have no load balancing, IP rate limiting, etc.
See the docs site for example deployment commands.
