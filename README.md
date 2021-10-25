```
kubecfg show kafka-produce-25-topics-test.jsonnet --ext-str namespace=sre-test-kafka --ext-str cluster=sre-test
kubecfg show topics.jsonnet --ext-str namespace=sre-test-kafka --ext-str cluster=sre-test
kubecfg update kafka-produce-25-topics-test.jsonnet --ext-str namespace=sre-test-kafka --ext-str cluster=sre-test
kubecfg update kafka-produce-100MB-max1MB.jsonnet --ext-str namespace=sre-test-kafka --ext-str cluster=sre-test --ext-str topic=nine --as=admin
kubecfg update kafka-produce-25-topics-test.jsonnet --ext-str namespace=sre-test-kafka --ext-str cluster=sre-test --as=admin
```
