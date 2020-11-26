## Tanzania HTI

In order to enable the THTI project, we're assembled a solution that allows complex workflows to be created an changed by ODK form submission. The current use case captured is this:

![Diagram](/doc/rural_hc_hiv.png)

Nodes 1,3, and 5 each represent a submitted ODK form. There are also registation forms for HCWs Facilities, and Patients.

To accomplish this, we'll use:
[RapidPro (via the hosted textit.in service)](https://textit.in)
[Gather](https://github.com/ehealthafrica/gather)
[Aether Stream Consumer](https://github.com/ehealthafrica/aether-stream-consumer)
[Aether Elasticsearch Consumer](https://github.com/ehealthafrica/aether-elasticsearch-consumer)

The main drivers of the workflow are the Stream Consumer and RapidPro, related as described in the following diagram:


Artifacts for all of the consumers and RapidPro can be found in the appropriate folders.
