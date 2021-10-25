local l = import 'lib.libsonnet';

{
  jobs:: {
    '5': {
      local job = self,
      parallelism: 5,
    },
  },

  benchmark: [l.consumer { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
