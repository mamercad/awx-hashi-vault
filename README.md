# awx-hashi-vault

This repo holds my operational notes for doing [Ansible AWX](https://github.com/ansible/awx) with [HashiCorp Vault](https://vaultproject.io).
That is, using Vault as an external Credential source for AWX (i.e., not duplicating Credentials in AWX).
There are examples for doing the built-in Machine Credential as well as a Custom (user-defined) Credential.
In order to use anything here, you'll likely need administrative access to both AWX and Vault (or at least, access to those involved in maintaining them).

In order to talk to AWX, these roles and playbooks rely on the well-defined Tower environment variables; namely, `$TOWER_HOST`, `$TOWER_USERNAME`, and `$TOWER_PASSWORD`.

In order to talk to Vault, these roles and playbooks leverage the `vault` CLI (the current state of Ansible and HashiCorp Vault modules is in a rather strange place).

> Caveat Emptor: Nothing here should be used in Production without consulting the folks responsible for both AWX and Vault.

There's an Ansible [inventory](./ansible/inventory.yml) you should modify.
In it, you'll note two hosts, `localhost` and `honeycrisp`, and one group, `awx_managed`.
There are also environment variables which should be set for things like the AWX service account SSH keys, and so on.

Again, this repository is just my operational notes on this topic, it shouldn't be uses as-is in your work environment.

The host named `honeycrisp` is my laptop (my sandbox) which I used as the backdrop for this repository (we need a client to test the AWX Machine Credential against).

Note that the `ansible_user` is defined as `awx` for `honeycrisp`, the `prep-infra` role will create this user on `honeycrisp` (it'll act as the service account for AWX).

The `awx_managed` group is the `hosts` of the `prep-infra` playbook, which means that the role will only run against `honeycrisp` in this case.

You can get a nice visual representation of an inventory like this:

```bash
❯ ansible-inventory --inventory inventory.yml --graph
@all:
  |--@awx_managed:
  |  |--honeycrisp
  |--@ungrouped:
  |  |--localhost
```


> The operational bits of this repository live in the [ansible](ansible/) directory.

## Roles

- `prep-vault` - This role ensures that Vault is good-to-go and it dumps out Vault approle authentication.
- `prep-infra` - This role creates a user account and SSH keypair for testing purposes.
- `prep-awx` - This role creates the AWX assets for testing purposes (Organization, Project, Credentials, etc).
- `demo` - This role shows the end-to-end result of this work.

## Playbooks

- `prep-vault.yml` - This playbook simply calls the `prep-vault` role and runs against `localhost`.
- `prep-infra.yml` - This playbook simply calls the `prep-infra` role and runs against `awx_managed`.
- `prep-awx.yml` - This playbook simply calls the `prep-awx` role and runs against `localhost`.
- `demo.yml` - This playbook simply calls the `demo` role and runs against `localhost`.

### Demo

Here's the (abbreviated) output from `demo.yml` running in my homelab:

```bash
❯ ansible-playbook -i inventory.yml demo.yml

PLAY [demo] **************************************************************************

TASK [include demo role] *************************************************************

TASK [demo : fetch vault secret] *****************************************************
changed: [localhost]

TASK [demo : show the vault secret] **************************************************
ok: [localhost] =>
  msg: |-
    ===== Data =====
    Key        Value
    ---        -----
    secret1    hunter2
    secret2    s3kr3t1

TASK [demo : include prep-awx defaults] **********************************************
ok: [localhost]

TASK [demo : launch the debug job template] ******************************************
[WARNING]: You are running collection version 0.0.1-devel but connecting to AWX
version 20.0.0
changed: [localhost]

TASK [demo : fetch job stdout] *******************************************************
ok: [localhost]

TASK [demo : show the job stdout] ****************************************************
ok: [localhost] =>
  stdout:
      <SNIP>

      SSH password:

      PLAY [debug] *******************************************************************

      TASK [Gathering Facts] *********************************************************
      <span class="ansi32">ok: [honeycrisp]</span>

      TASK [debug] *******************************************************************
      <span class="ansi32">ok: [honeycrisp] =&gt; {</span>
      <span class="ansi32">    &quot;msg&quot;: &quot;environment:\\n  $SECRET1: hunter2\\n  $SECRET2: s3kr3t1\\nvariables:\\n  secret1: hunter2\\n  secret2: s3kr3t1\\n&quot;</span>
      <span class="ansi32">}</span>

      PLAY RECAP *********************************************************************
      <span class="ansi32">honeycrisp</span>                 : <span class="ansi32">ok=2   </span> changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

      <SNIP>

PLAY RECAP ***************************************************************************
localhost                  : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Note that I'm dumping out the Vault secret in `demo : show the vault secret` and subsequently launching the `debug` Job Template in AWX in `demo : launch the debug job template` which is configured to use our Machine and Custom Credentials.

It uses the Machine Credential to SSH to the host and the Custom Credential to populate the environment variables `$SECRET1` and `$SECRET2`, and the extra variables `secret1` and `secret2`.
