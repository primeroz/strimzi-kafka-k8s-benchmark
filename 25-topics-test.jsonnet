local l = import 'lib.libsonnet';

{
  common:: {
    local this = self,
    partitions: 1,
    retentionBytes: 25 * 1024 * 1024 * 1024,
    retentionMs: 30 * 60 * 1000,
  },

  objects: [
    l.topic {
      cluster: std.extVar('cluster'),
      namespace: std.extVar('namespace'),
      settings+:: $.common { name: std.format('simulate-org-%s', topic) },
    }
    for topic in std.range(0, 24)
  ],
}
