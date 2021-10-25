local l = import 'lib.libsonnet';

{
  jobs:: {
    '1kb': {
      local job = self,
      parallelism: 5,
      recordspersec: 22500,
      size: 1000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '128kb': {
      local job = self,
      parallelism: 4,
      recordspersec: 40,
      size: (0.128 * 1024 * 1024),
      maxrequestsize: 1048576,
      compress: true,
    },
    '512kb': {
      local job = self,
      parallelism: 4,
      recordspersec: 10,
      size: (0.5 * 1024 * 1024),
      maxrequestsize: 5 * job.size,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 5,
    },
    '1mb': {
      local job = self,
      parallelism: 1,
      recordspersec: 10,
      size: (1 * 1024 * 1024),
      maxrequestsize: 5 * job.size,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 5,
    },
  },

  benchmark: [l.job { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
