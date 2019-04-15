# WhiteSpace Couchbase Deployment


```
terraform init
terraform apply
```

After the initial deployment, which will create the rules to lock Couchbase down, run;

```
terraform apply
```

You should then be able to run Ansible, first to configure ;

```
ansible-playbook --vault-id @prompt site.yml --skip-tags "applciation"
```

Then again to configure the application;

```
ansible-playbook --vault-id @prompt site.yml
```

If you remove the resources and need to rerun, make sure that you remove the `rules_locked.auto.tfvars` file, if you don't it will lock your next deployment down to the wrong IP addresses.