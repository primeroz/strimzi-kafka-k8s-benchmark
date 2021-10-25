local l = import 'lib.libsonnet';

{
  topics:: {
    single: {
      local this = self,
      type: 'single',
      name: std.format('sre-test-%s-partition-topic', this.type),
      partitions: 1,
      retentionBytes: 50 * 1024 * 1024 * 1024,
      retentionMs: 30 * 60 * 1000,  // 30 minutes in ms
    },
    three: {
      local this = self,
      type: 'three',
      name: std.format('sre-test-%s-partition-topic', this.type),
      partitions: 3,
      retentionBytes: 20 * 1024 * 1024 * 1024,
      retentionMs: 30 * 60 * 1000,  // 30 minutes in ms
    },
    nine: {
      local this = self,
      type: 'nine',
      name: std.format('sre-test-%s-partition-topic', this.type),
      partitions: 9,
      retentionBytes: 7 * 1024 * 1024 * 1024,
      retentionMs: 30 * 60 * 1000,  // 30 minutes in ms
    },
  },

  objects: [l.topic { type: topic, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), settings+:: $.topics[topic] } for topic in std.objectFields($.topics)],
}
