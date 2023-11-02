This Terraform project is designed to support an internal deployment of the Econia Data Service Stack (DSS).
If you wish to use it in production, note that it uses a compromised JWT secret, does not implement load balancing or IP rate limiting, etc., and you will probably want to tune it for your own deployment.

See the docs site for example deployment commands, denial-of-service (DoS) mitigation strategies, etc.
