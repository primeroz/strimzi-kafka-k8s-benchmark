local l = import 'lib.libsonnet';

{
  jobs:: {
    '1kb': {  // 500 KB/s
      local job = self,
      probability: 1,
      parallelism: 1,
      recordspersec: 500,
      size: 1000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '8kb': {  // 400 KB/s
      local job = self,
      probability: 1,
      parallelism: 1,
      recordspersec: 50,
      size: 8000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '32kb': {  // 320 KB/s
      local job = self,
      probability: 1,
      parallelism: 1,
      recordspersec: 10,
      size: 32000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '128kb': {  // 384 KB/s
      local job = self,
      probability: 1,
      parallelism: 1,
      recordspersec: 3,
      size: 128000,
      maxrequestsize: 1048576,
      compress: true,
    },
    '512kb': {  // 512 KB/s
      local job = self,
      probability: 2,
      parallelism: 1,
      recordspersec: 1,
      size: (0.5 * 1024 * 1024),
      maxrequestsize: 2 * 1048576,
      compress: true,
      batchsize: 2 * job.size,
    },
    '1mb': {  // 1 MB/s
      local job = self,
      probability: 4,
      parallelism: 1,
      recordspersec: 1,
      size: (1 * 1024 * 1024),
      maxrequestsize: 2 * 1048576,
      compress: true,
      batchsize: 2 * job.size,
    },
  },

  benchmark: [
    if std.mod(org, $.jobs[job].probability) == 0 then l.job {
      name: std.format('producer-%s-%s', [job, org]),
      cluster: std.extVar('cluster'),
      namespace: std.extVar('namespace'),
      topic: std.format('simulate-org-%s', org),
      settings+:: $.jobs[job],
      podsize:: 'small',
    }
    else {}
    for job in std.objectFields($.jobs)
    for org in std.range(0, 24)
  ],
}
