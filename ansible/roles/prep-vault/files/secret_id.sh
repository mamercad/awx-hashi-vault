#!/usr/bin/env bash

vault write -f auth/approle/role/role_awx/secret-id
