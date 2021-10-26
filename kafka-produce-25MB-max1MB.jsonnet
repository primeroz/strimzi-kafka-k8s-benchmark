local l = import 'lib.libsonnet';

{
  jobs:: {
    '1kb': {  // 1MB
      local job = self,
      parallelism: 5,
      recordspersec: 2250,
      size: 1000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '128kb': {  // 10MB
      local job = self,
      parallelism: 1,
      recordspersec: 80,
      size: (0.128 * 1024 * 1024),
      maxrequestsize: 1048576,
      compress: true,
    },
    '512kb': {  // 5MB
      local job = self,
      parallelism: 1,
      recordspersec: 10,
      size: (0.5 * 1024 * 1024),
      maxrequestsize: 2 * 1048576,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 5,
    },
    '10mb-1mb': {  //10MB
      local job = self,
      parallelism: 1,
      recordspersec: 10,
      size: (1 * 1024 * 1024),
      maxrequestsize: 3 * 1048576,
      compress: true,
      batchsize: 5 * job.size,
      lingerms: 5,
    },
  },

  benchmark: [l.job { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
