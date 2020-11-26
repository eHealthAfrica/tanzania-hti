
You should be familiar with the StreamConsumer and it's Job / Pipeline / Stage construct in order to build new flows.
https://github.com/ehealthafrica/aether-stream-consumer

If you know the concepts well, you can skip to the pipelines at the bottom.


### Contants

It's nice to keep constants in th const block. Makes it easier to make changes to all pipelines by pasting in the new consts when something changes / you migrate.

```json
{
    "const": {
        "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
        "rapidpro_auth_header": "Token API_KEY_GOES_HERE",
        "rapidpro_flow_id": "4f9a2cbb-2eee-435d-8dca-9505d9ab7b91",
        "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
        "form_id_patient": "HIV_rural_B",
        "form_id_hcw": "HIV_rural_A",
        "form_id_sample_registration": "HIV_rural_1",
        "aether_auth": {"user": "your aether username", "password": "your aether password"}
    }
}
```

## Lookup data from Aether and inject into flows:

Most of these flows require data other than what's available in the current message context (`$.source.message`), so we use `restcall` to do lookups as part of the flows. Obviously the lookup values are dependent on the contents of the datatype you're looking up.

#### get chw and patient from a sample ID
```json
{
    "name": "sample",
    "type": "restcall",
    "id": "default",
    "transition": {
        "input_map": {   
            "url": "$.const.aether_url",
            "method": "GET",
            "basic_auth": "$.const.aether_auth",
            "query_params": {
                "ordering": "-modified",
                "payload___id": "$.const.form_id_sample_registration",
                "payload__sample_id": "$.source.message.sample_id"
            }
        },
        "output_map":{
            "status_code": "$.status_code",
            "patient_id": "$.json.results[0].payload.patient_id",
            "hcw_id": "$.json.results[0].payload.hcw_id"
        }
    }
}
```

You can reuse the same defaut restcall and just change the transition as below.

#### lookup patient contact via patient_id

```json
{
    "input_map": {   
        "url": "$.const.aether_auth",
        "method": "GET",
        "basic_auth": "$.aether_auth",
        "query_params": {
            "payload___id": "$.const.form_id_patient",
            "payload__patient_id": "$.message.value.patient_id"
        }
    },
    "output_map":{
        "contact_number": "$.json.results[0].contact_number"
    }
}
```

#### lookup patient_id / chw_id via sample registration

```json
{
    "input_map": {   
        "url": "$.const.aether_auth",
        "method": "GET",
        "basic_auth": "$.aether_auth",
        "query_params": {
            "ordering": "-modified",
            "payload___id": "$.const.form_id_sample_registration",
            "payload__sample_id": "$.message.value.sample_id"
        }
    },
    "output_map":{
        "patient_id": "$.json.results[0].patient_id",
        "hcw_id": "$.json.results[0].hcw_id"
    }
}
```


## function to format URN -> required RapidPro Format.
Rapid pro requires a specific format for phone numbers and it's better to change them here than to change the the input format in case you ever move away from RP.


```json
{
    "id": "urn",
    "name": "URN Formatter",
    "entrypoint": "fn",
    "script": "function fn(base){return ['tel:' + base.toString()];}",
    "arguments": ["base"]
}
```


## Pipelines

#### Sample Start / Unenroll previous reminder (Rural 1)

```json
{
    "id": "rural_1",
    "name": "Rural 1 Visit / Sample Enrollment",
    "error_handling": {
        "error_topic": "log_hiv_rural_1",
        "log_failure": true,
        "log_success": true

    },
    "kafka_subscription": {
        "topic_pattern": "HIV_rural_1_Patient_at_CTC*",
        "topic_options": {
            "masking_annotation": "@aether_masking",
            "masking_levels": ["public", "private"],
            "masking_emit_level": "public",
            "filter_required": false
        }
    },
    "const": {
        "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
        "rapidpro_auth_header": "Token API_KEY_GOES_HERE",
        "rapidpro_flow_id__unenroll": "1d0cad75-42c5-4da7-91bd-1327095b73dc",
        "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
        "form_id_patient": "HIV_rural_B",
        "form_id_sample_registration": "HIV_rural_1",
        "aether_auth": {"user": "your aether username", "password": "your aether password"}
    },
    "stages" : [
        {
            "name": "patient",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.aether_url",
                    "method": "GET",
                    "basic_auth": "$.const.aether_auth",
                    "query_params": {
                        "ordering": "-modified",
                        "payload___id": "$.const.form_id_patient",
                        "payload__patient_id": "$.source.message.patient_id"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "contact_number": "$.json.results[0].payload.contact_number"
                }
            }
        },
        {
            "name": "urn",
            "type": "jscall",
            "id": "urn",
            "transition": {
                "input_map": {
                    "base": "$.patient.contact_number"
                },
                "output_map": {
                    "result": "$.result"
                }
            }
        },
        {
            "name": "rapidpro",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.rapidpro_flow",
                    "method": "POST",
                    "headers": {"Authorization": "$.const.rapidpro_auth_header"},
                    "json_body": {
                        "flow": "$.const.rapidpro_flow_id__unenroll",
                        "urns": "$.urn.result"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "all": "$.reason"
                }
            }
        }
    ]
}
```


#### Sample Result Registration (Rural 3)

```json
{
    "id": "rural_3",
    "name": "Rural 3 Message Dispatch",
    "error_handling": {
        "error_topic": "log_hiv_rural_3",
        "log_failure": true,
        "log_success": true

    },
    "kafka_subscription": {
        "topic_pattern": "HIV_rural_3_HVL_result_V1*",
        "topic_options": {
            "masking_annotation": "@aether_masking",
            "masking_levels": ["public", "private"],
            "masking_emit_level": "public",
            "filter_required": false
        }
    },
    "const": {
        "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
        "rapidpro_auth_header": "Token API_KEY_GOES_HERE",
        "rapidpro_flow_id__contact": "4f9a2cbb-2eee-435d-8dca-9505d9ab7b91",
        "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
        "form_id_patient": "HIV_rural_B",
        "form_id_hcw": "HIV_rural_A",
        "form_id_sample_registration": "HIV_rural_1",
        "aether_auth": {"user": "your aether username", "password": "your aether password"}
    },
    "stages" : [
        {
            "name": "sample",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.aether_url",
                    "method": "GET",
                    "basic_auth": "$.const.aether_auth",
                    "query_params": {
                        "ordering": "-modified",
                        "payload___id": "$.const.form_id_sample_registration",
                        "payload__sample_id": "$.source.message.sample_id"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "patient_id": "$.json.results[0].payload.patient_id",
                    "hcw_id": "$.json.results[0].payload.hcw_id"
                }
            }
        },
        {
            "name": "hcw",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.aether_url",
                    "method": "GET",
                    "basic_auth": "$.const.aether_auth",
                    "query_params": {
                        "ordering": "-modified",
                        "payload___id": "$.const.form_id_hcw",
                        "payload__hcw_id": "$.sample.hcw_id"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "contact_number": "$.json.results[0].payload.contact_number"
                }
            }
        },
        {
            "name": "urn",
            "type": "jscall",
            "id": "urn",
            "transition": {
                "input_map": {
                    "base": "$.hcw.contact_number"
                },
                "output_map": {
                    "result": "$.result"
                }
            }
        },
        {
            "name": "rapidpro",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.rapidpro_flow",
                    "method": "POST",
                    "headers": {"Authorization": "$.const.rapidpro_auth_header"},
                    "json_body": {
                        "flow": "$.const.rapidpro_flow_id__contact",
                        "extra": {
                            "msg": "$.source.message.sms_body",
                            "contactid": "$.sample.hcw_id"
                        },
                        "urns": "$.urn.result"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "all": "$.reason"
                }
            }
        }
    ]
}
```


#### Enroll Followup (Rural 5)

```json
{
    "id": "rural_5",
    "name": "Rural 5 Message Dispatch/ Follow up Enroll",
    "kafka_subscription": {
        "topic_pattern": "HIVrural_5_Interpretation_testresult_V1*",
        "topic_options": {
            "masking_annotation": "@aether_masking",
            "masking_levels": ["public", "private"],
            "masking_emit_level": "public",
            "filter_required": false
        }
    },
    "error_handling": {
        "error_topic": "log_hiv_rural_5",
        "log_failure": true,
        "log_success": true

    },
    "const": {
        "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
        "rapidpro_auth_header": "Token API_KEY_GOES_HERE",
        "rapidpro_flow_id__enroll": "1aa47fe5-32c3-4125-b70c-a02c2f189712",
        "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
        "form_id_patient": "HIV_rural_B",
        "form_id_hcw": "HIV_rural_A",
        "form_id_sample_registration": "HIV_rural_1",
        "aether_auth": {"user": "your aether username", "password": "your aether password"}
    },
    "stages" : [
        {
            "name": "sample",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.aether_url",
                    "method": "GET",
                    "basic_auth": "$.const.aether_auth",
                    "query_params": {
                        "ordering": "-modified",
                        "payload___id": "$.const.form_id_sample_registration",
                        "payload__sample_id": "$.source.message.sample_id"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "patient_id": "$.json.results[0].payload.patient_id",
                    "hcw_id": "$.json.results[0].payload.hcw_id"
                }
            }
        },
        {
            "name": "patient",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.aether_url",
                    "method": "GET",
                    "basic_auth": "$.const.aether_auth",
                    "query_params": {
                        "ordering": "-modified",
                        "payload___id": "$.const.form_id_patient",
                        "payload__patient_id": "$.sample.patient_id"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "contact_number": "$.json.results[0].payload.contact_number"
                }
            }
        },
        {
            "name": "urn",
            "type": "jscall",
            "id": "urn",
            "transition": {
                "input_map": {
                    "base": "$.patient.contact_number"
                },
                "output_map": {
                    "result": "$.result"
                }
            }
        },
        {
            "name": "rapidpro",
            "type": "restcall",
            "id": "default",
            "transition": {
                "input_map": {   
                    "url": "$.const.rapidpro_flow",
                    "method": "POST",
                    "headers": {"Authorization": "$.const.rapidpro_auth_header"},
                    "json_body": {
                        "flow": "$.const.rapidpro_flow_id__enroll",
                        "extra": {
                            "hcwid": "$.sample.hcw_id",
                            "appointment": "$.source.message.date_appointment",
                            "sampleid": "$.source.message.sample_id",
                            "patientid": "$.sample.patient_id",
                            "msg": "$.source.message.sms_body"
                        },
                        "urns": "$.urn.result"
                    }
                },
                "output_map":{
                    "status_code": "$.status_code",
                    "all": "$.reason"
                }
            }
        }
    ]
}
```
