# WhiteSpace Couchbase Deployment


```
ansible-playbook --vault-id @prompt site.yml --skip-tags "application"
```

Then again to configure the application;

```
ansible-playbook --vault-id @prompt site.yml
```
