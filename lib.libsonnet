{
  topic:: {
    local this = self,
    type:: error 'type is required',
    namespace:: error 'namespace is required',
    cluster:: this.namespace,

    settings:: {
      name: error 'name is required',
      partitions: 1,
      retentionBytes: 10 * 1024 * 1024 * 1024,
      retentionMs: 30 * 60 * 1000,  // 30 minutes in ms
      segmentBytes: 1073741824,
      maxMessageBytes: 10485760,
    },

    apiVersion: 'kafka.strimzi.io/v1beta2',
    kind: 'KafkaTopic',
    metadata: {
      labels: {
        'strimzi.io/cluster': this.cluster,
      },
      name: this.settings.name,
      namespace: this.namespace,
    },
    spec: {
      config: {
        'min.insync.replicas': 2,
        'retention.bytes': std.toString(this.settings.retentionBytes),
        'retention.ms': std.toString(this.settings.retentionMs),
        'segment.bytes': std.toString(this.settings.segmentBytes),
        'max.message.bytes': std.toString(this.settings.maxMessageBytes),
      },
      partitions: this.settings.partitions,
      replicas: 3,
    },
  },


  job:: {
    local this = self,
    name:: error 'need name',
    namespace:: error 'need namespace',
    cluster:: this.namespace,
    topic:: error 'topic needed',
    podsize:: 'large',
    settings:: {
      parallelism: error 'need parallelism',
      recordspersec: error 'need recordpersec',
      size: error 'need size',
      maxrequestsize: 1048576,
      compress: true,
      lingerms: 100000,
      batchsize: 128000,
    },

    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      labels: {
        app: std.format('kafka-benchmark-producer-%s', this.name),
      },
      name: std.format('kafka-benchmark-producer-%s', this.name),
      namespace: this.namespace,
    },
    spec: {
      backoffLimit: 6,
      completions: this.settings.parallelism,
      parallelism: this.settings.parallelism,
      template: {
        metadata: {
          annotations: {
            'sidecar.istio.io/inject': 'false',
          },
          labels: {
            app: std.format('kafka-benchmark-producer-%s', this.name),
          },
        },
        spec: {
          restartPolicy: 'Never',
          affinity: {
            podAntiAffinity: {
              preferredDuringSchedulingIgnoredDuringExecution: [
                {
                  podAffinityTerm: {
                    labelSelector: {
                      matchLabels: {
                        app: std.format('kafka-benchmark-producer-%s', this.name),
                      },
                    },
                    topologyKey: 'kubernetes.io/hostname',
                  },
                  weight: 100,
                },
                {
                  podAffinityTerm: {
                    labelSelector: {
                      matchLabels: {
                        app: std.format('kafka-benchmark-producer-%s', this.name),
                      },
                    },
                    topologyKey: 'failure-domain.beta.kubernetes.io/zone',
                  },
                  weight: 100,
                },
              ],
            },
          },
          containers: [
            {
              image: 'quay.io/influxdb/kafka-sre-tools:0.1.0',
              name: 'producer',
              command: [
                './bin/kafka-producer-perf-test.sh',
              ],
              args: [
                      '--topic',
                      this.topic,
                      '--num-records',
                      '1000000000',
                      '--throughput',
                      std.toString(this.settings.recordspersec),
                      '--producer-props',
                      std.format('bootstrap.servers=%s-kafka-bootstrap:9092', this.cluster),
                      'batch.size=%s' % std.toString(this.settings.batchsize),
                      'acks=all',
                      'linger.ms=%s' % std.toString(this.settings.lingerms),
                      'buffer.memory=168435456',
                      //'buffer.memory=31457280',
                      std.format('max.request.size=%d', this.settings.maxrequestsize),
                    ]
                    + (if this.settings.compress then ['compression.type=snappy'] else [])
                    + [
                      '--record-size',
                      std.format('%d', this.settings.size),
                    ],
              env: [
                {
                  name: 'HOME',
                  value: '/tmp',
                },
              ],
              resources: (if this.podsize == 'large' then {
                            limits: {
                              cpu: '2',
                              memory: '2Gi',
                            },
                            requests: {
                              cpu: '0.2',
                              memory: '512Mi',
                            },
                          } else {
                            limits: {
                              cpu: '1',
                              memory: '1Gi',
                            },
                            requests: {
                              cpu: '0.1',
                              memory: '256Mi',
                            },
                          }),
            },
          ],
          imagePullSecrets: [
            {
              name: 'quay-docker-secret',
            },
            {
              name: 'dockerhub-docker-secret',
            },
          ],
        },
      },
    },
  },

  consumer:: {
    local this = self,
    name:: error 'need name',
    namespace:: error 'need namespace',
    cluster:: this.namespace,
    topic:: error 'topic needed',
    podsize:: 'large',
    settings:: {
      parallelism: error 'need parallelism',
      messages: 1000000000,
    },

    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      labels: {
        app: std.format('kafka-benchmark-consumer-%s', this.name),
      },
      name: std.format('kafka-benchmark-consumer-%s', this.name),
      namespace: this.namespace,
    },
    spec: {
      backoffLimit: 6,
      completions: this.settings.parallelism,
      parallelism: this.settings.parallelism,
      template: {
        metadata: {
          annotations: {
            'sidecar.istio.io/inject': 'false',
          },
          labels: {
            app: std.format('kafka-benchmark-consumer-%s', this.name),
          },
        },
        spec: {
          restartPolicy: 'Never',
          affinity: {
            podAntiAffinity: {
              preferredDuringSchedulingIgnoredDuringExecution: [
                {
                  podAffinityTerm: {
                    labelSelector: {
                      matchLabels: {
                        app: std.format('kafka-benchmark-consumer-%s', this.name),
                      },
                    },
                    topologyKey: 'kubernetes.io/hostname',
                  },
                  weight: 100,
                },
                {
                  podAffinityTerm: {
                    labelSelector: {
                      matchLabels: {
                        app: std.format('kafka-benchmark-consumer-%s', this.name),
                      },
                    },
                    topologyKey: 'failure-domain.beta.kubernetes.io/zone',
                  },
                  weight: 100,
                },
              ],
            },
          },
          containers: [
            {
              image: 'quay.io/influxdb/kafka-sre-tools:0.1.0',
              name: 'producer',
              command: [
                './bin/kafka-consumer-perf-test.sh',
              ],
              args: [
                '--topic',
                this.topic,
                std.format('--bootstrap.servers=%s-kafka-bootstrap:9092', this.cluster),
                std.format('--messages=%s', this.settings.messages),
              ],
              env: [
                {
                  name: 'HOME',
                  value: '/tmp',
                },
              ],
              resources: (if this.podsize == 'large' then {
                            limits: {
                              cpu: '2',
                              memory: '2Gi',
                            },
                            requests: {
                              cpu: '0.2',
                              memory: '512Mi',
                            },
                          } else {
                            limits: {
                              cpu: '1',
                              memory: '1Gi',
                            },
                            requests: {
                              cpu: '0.1',
                              memory: '256Mi',
                            },
                          }),
            },
          ],
          imagePullSecrets: [
            {
              name: 'quay-docker-secret',
            },
            {
              name: 'dockerhub-docker-secret',
            },
          ],
        },
      },
    },
  },
}
