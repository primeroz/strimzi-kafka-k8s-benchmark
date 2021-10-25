local l = import 'lib.libsonnet';

{
  jobs:: {
    '1mbs': {
      local job = self,
      parallelism: 2,
      recordspersec: 10,
      size: (1 * 1024 * 1024),
      maxrequestsize: 5 * job.size,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 0,
    },
  },

  benchmark: [l.job { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
