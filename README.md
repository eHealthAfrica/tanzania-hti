## Tanzania HTI

In order to enable the THTI project, we're assembled a solution that allows complex workflows to be created an changed by ODK form submission. The current use case captured is this:

### HIV Flowchart
![HIV Flowchart](/doc/hiv_flowchart.png)

Nodes 1, 3, and 5 each represent a submitted ODK form. (Update: two additional nodes or ODK forms were added before node 1). XLS forms can be found here: [HIV XLS Forms](https://drive.google.com/drive/folders/15f5jSZCjmInNgX9uZVUeFGIuITDUS__b?usp=sharing)

### TB Flowchart
![TB Flowchart](/doc/tb_flowchart.png)

Nodes 1, 2, 3 and 4 each represent a submitted ODK form. XLS forms can be found here: [TB XLS Forms](https://drive.google.com/drive/folders/13JwDJLgS_uFgrUR3Zd-YziF5hbGnqIcw?usp=sharing)

To accomplish this, we'll use:
- [RapidPro (via the hosted textit.in service)](https://textit.in)
- [Gather](https://github.com/ehealthafrica/gather)
- [Aether Stream Consumer](https://github.com/ehealthafrica/aether-stream-consumer)
- [Aether Elasticsearch Consumer](https://github.com/ehealthafrica/aether-elasticsearch-consumer)

The main drivers of the workflow are the Stream Consumer and RapidPro, related as described in the following diagram:

![Diagram](/doc/Selection_001.jpg)

Artifacts for all of the consumers and RapidPro can be found in the appropriate folders.

### Pipelines:

All the Pipelines are available in [StreamConsumer/README.md](https://github.com/eHealthAfrica/tanzania-hti/tree/master/StreamConsumer#pipelines). For each pipeline, you will need to set:
- The `textit api token` for `rapidpro_auth_header` available on [Textit](https://textit.com/org/home/)
- The right rapidpro IDs. A rapidpro flow ID can be found in the url of the flow.
- (Optional) The username and password for the Aether/Gather.

### Credentials

All username and passwords are available in the `HTI Credentials` note in the Shared Folder on LastPass.

### Useful commands

- Get the list of form submissions (ordered by submission date): `https://eha-data.org/htidev/kernel/entities.json?ordering=-modified`
- Get the list of pipelines: `https://eha-data.org/htidev/stream-consumer/pipeline/list`
- Get a specific pipeline: `https://eha-data.org/htidev/stream-consumer/pipeline/get?id=pipeline_id`
- Get a specific job: `https://eha-data.org/htidev/stream-consumer/job/get?id=job_id`
- Get the list of jobs: `https://eha-data.org/htidev/stream-consumer/job/list`
- Get the list of topics (ordered by last updated): `https://eha-data.org/htidev/kernel/schemadecorators.json?fields=modified%2Cname%2Cid%2Ctopic&ordering=-modified`
- Add/update a pipeline: `http --json POST https://eha-data.org/htidev/stream-consumer/pipeline/add -a username:password < ./StreamConsumer/pipeline_file.json`
- Add job to consumer: `http --json POST https://eha-data.org/htidev/stream-consumer/job/add -a username:password < ./StreamConsumer/job_file.json`
Example of job:
```
{
  "id": "rural_a_1",
  "name": "HIV Rural A",
  "pipelines": [
    "rural_a"
  ]
}
```
- To see if a flow was started in RapidPro (textit), go to `https://textit.com/flowstart/`
- Kakfa topics can be found in the `ehealth-africa-prod1` cluster in [Confluent](https://confluent.cloud/)

### TODO

- You can test the entire flow based on this [test file](https://docs.google.com/spreadsheets/d/1YmnVkh9YuN-7flEaBvW4VXmlpUFp-zdpPYTbj8E5ncQ/edit#gid=0). 

### TODO

- Update the HIV Diagram
- Add a diagram for TB
