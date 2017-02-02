# Pickwick Workers
---

This repository provides workers for getting job postings with aditional data.

Workers are divided into two groups based of main purpose of the job.

* [feeders](https://github.com/OPLZZ/pickwick-workers/tree/master/lib/pickwick/workers/feeders) &mdash; [sidekiq](https://github.com/mperham/sidekiq) based jobs for getting job postings from the Internet sources. For example [job](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/feeders/mpsv/processor.rb) for getting job postings from [Ministry of Labour and Social Affairs: MPSV.CZ](http://www.mpsv.cz/) database.

* [enrichment](https://github.com/OPLZZ/pickwick-workers/tree/master/lib/pickwick/workers/enrichment) &mdash; [sidekiq](https://github.com/mperham/sidekiq) based job for getting additional data about individual job postings from external sources. For example getting [geo coordinates]() for work location.

After new job posting is created by some feeder using API call, API creates [Enrichment::All](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/enrichment/all.rb) job for data enrichment of this particular job posting. Right now this job creates [Enrichment::Geo](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/enrichment/geo.rb) job.

If there is some aditional data enrichment needed, you can create new job definition and add it into [Enrichment::All](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/enrichment/all.rb) same way as [Geo](https://github.com/OPLZZ/pickwick-workers/blob/master/lib/pickwick/workers/enrichment/all.rb#L14) is defined.

## Installation

    git clone https://github.com/OPLZZ/pickwick-workers.git
    cd pickwick-workers

... install the required rubygems:

    bundle install

## Configuration

You can find configuration of [sidekiq](https://github.com/mperham/sidekiq) queues and their limits in [sidekiq_queues.yml](https://github.com/OPLZZ/pickwick-workers/blob/master/config/sidekiq_queues.yml) file.

To specify periodic jobs, you can use [sidekiq_scheduler.yml](https://github.com/OPLZZ/pickwick-workers/blob/master/config/sidekiq_scheduler.yml) config file.

## Usage

Several environment variables needs to be set for sidekiq web application

    export SIDEKIQ_REDIS_URL='redis://127.0.0.1:6379'
    export SIDEKIQ_USERNAME='sidekiq web user'
    export SIDEKIQ_PASSWORD='sidekiq web password'

... after that you can run web server providing sidekiq web interface

    bundle exec puma

... you can access sidekiq web interface at `http://localhost:9292`

To run sidekiq worker process you need to specify following environment variables

    export SIDEKIQ_REDIS_URL='redis://127.0.0.1:6379'
    export PICKWICK_API_URL='http://api.damepraci.cz' # url of [API repository](https://github.com/OPLZZ/pickwick-api)
    export PICKWICK_API_TOKEN='API_TOKEN'

... after that you can run worker process by

    bundle exec sidekiq --config config/sidekiq_queues.yml


----

##Funding
<a href="http://esfcr.cz/" target="_blank"><img src="https://www.damepraci.cz/assets/oplzz_banner_en.png" alt="Project of Operational Programme Human Resources and Employment No. CZ.1.04/5.1.01/77.00440."></a>
The project No. CZ.1.04/5.1.01/77.00440 was funded from the European Social Fund through the Operational Programme Human Resources and Employment and the state budget of Czech Republic.
