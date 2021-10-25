local l = import 'lib.libsonnet';

{
  jobs:: {
    '10ks': {
      local job = self,
      parallelism: 10,
      recordspersec: 2000,
      size: 10000,
      maxrequestsize: 1 * 1024 * 1024,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 100000,
    },
  },

  benchmark: [l.job { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
