# Tests

## Tests

### Terraform

- [x] Check deployment is successful with Terraform

### Add-ons

#### Flink
- [x] Check Flink Operator is deployed
- [x] Deploy Flink cluster and demo job
- [x] Check job is deployed
- [x] Check job is running successfully

#### Autoscaling
- [x] Deploy with 1 nodepool at first
- [ ] Check autoscaler has the right config for the nodepools
- [x] Deploy nginx with 500Mi and scale it to 10
- [x] Check nodepool 1 scales from 1 node to 2 nodes 
- [x] Scale down and check node is removed
- [x] Add nodepool 2 (high mem) and 3, with nodepool 2 autoscaling starting with 0 nodes, and nodepool 3 not autoscaling
- [x] Deploy nginx with 8Gi. It will deploy in nodepool 2
- [x] Check nodepool 2 scales from 0 to 1 node

#### Monitoring stack

- [ ] Check Prometheus is deployed
- [ ] Check Prometheus is running and queries return
- [ ] Check Flink metrics are returned

## Test Case A

- Test full deployment (with add-ons) with 1 node pool
- Change config and add 2 more nodepools, 1 with autoscaler and 1 without
