# Pickwick Workers
---

This repository provides workers for getting job postings with aditional data.

Workers are divided into two groups based of main purpose of the job.

* [feeders](https://github.com/OPLZZ/pickwick-workers/tree/master/lib/pickwick/workers/feeders) &mdash; [sidekiq](https://github.com/mperham/sidekiq) based jobs for getting job postings from the Internet sources. For example [job](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/feeders/mpsv/processor.rb) for getting job postings from [Ministry of Labour and Social Affairs: MPSV.CZ](http://www.mpsv.cz/) database.

* [enrichment](https://github.com/OPLZZ/pickwick-workers/tree/master/lib/pickwick/workers/enrichment) &mdash; [sidekiq](https://github.com/mperham/sidekiq) based job for getting additional data about individual job postings from external sources. For example getting [geo coordinates]() for work location

----
