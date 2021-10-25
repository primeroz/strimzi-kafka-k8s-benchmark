local l = import 'lib.libsonnet';

{
  jobs:: {
    '1kb': {  // 500 KB/s
      local job = self,
      parallelism: 1,
      recordspersec: 500,
      size: 1000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '8kb': {  // 400 KB/s
      local job = self,
      parallelism: 1,
      recordspersec: 50,
      size: 8000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '32kb': {  // 320 KB/s
      local job = self,
      parallelism: 1,
      recordspersec: 10,
      size: 32000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '128kb': {  // 384 KB/s
      local job = self,
      parallelism: 1,
      recordspersec: 3,
      size: 128000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '512kb': {  // 512 KB/s
      local job = self,
      parallelism: 1,
      recordspersec: 1,
      size: (0.5 * 1024 * 1024),
      maxrequestsize: 2 * job.size,
      compress: true,
      batchsize: 2 * job.size,
    },
    '1mb': {  // 1 MB/s
      local job = self,
      parallelism: 1,
      recordspersec: 1,
      size: (1 * 1024 * 1024),
      maxrequestsize: 1 * job.size,
      compress: true,
      batchsize: 2 * job.size,
    },
    '5mb': {  // 10 MB/s
      local job = self,
      parallelism: 1,
      recordspersec: 2,
      size: (5 * 1024 * 1024),
      maxrequestsize: (2 * job.size) + 100,
      compress: true,
      batchsize: (2 * job.size) + 100,
    },
    '10mb': {  // 10 MB/s
      local job = self,
      parallelism: 2,
      recordspersec: 1,
      size: (10 * 0.99 * 1024 * 1024),  // max message is set to 10485760 on the topic
      maxrequestsize: (10 * 1024 * 1024),
      compress: true,
      batchsize: 2 * job.maxrequestsize,
    },
  },


  benchmark: [l.job { name: job, cluster: std.extVar('cluster'), namespace: std.extVar('namespace'), topic: std.format('sre-test-%s-partition-topic', std.extVar('topic')), settings+:: $.jobs[job] } for job in std.objectFields($.jobs)],
}
