---
apiVersion: getambassador.io/v2
kind: Filter
metadata:
  name: oauth2-filter
  namespace: ${namespace}
spec:
  OAuth2:
    authorizationURL: ${authorizationURL}
    extraAuthorizationParameters:
      audience: ${authorizationURL}/api/v2/
    clientID: ${clientID}
    secret: ${secret}
    protectedOrigins: %{ for host in hosts }
    - origin: https://${host}
    %{ endfor ~}

    ## This is not available yet: https://github.com/datawire/ambassador/issues/2845
    # - origin: https://cluster.example.com
    #   includeSubdomains: true

---
apiVersion: getambassador.io/v2
kind: FilterPolicy
metadata:
  name: oauth2-filter-policy
  namespace: ${namespace}
spec:
  rules: %{ for host in hosts }
  - host: ${host}
    path: /
    filters:
    - name: oauth2-filter ## Enter the Filter name from above
      arguments:
        scopes:
        - "openid"
  %{ endfor ~}
