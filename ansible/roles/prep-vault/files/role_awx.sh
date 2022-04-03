#!/usr/bin/env bash

vault write auth/approle/role/role_awx \
    token_num_uses=0 \
    token_ttl=0m \
    secret_id_num_uses=0 \
    token_no_default_policy=false \
    token_policies="acl_awx"
