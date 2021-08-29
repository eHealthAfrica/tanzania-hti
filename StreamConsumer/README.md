
You should be familiar with the StreamConsumer and it's Job / Pipeline / Stage construct in order to build new flows.
https://github.com/ehealthafrica/aether-stream-consumer

If you know the concepts well, you can skip to the pipelines at the bottom.


### Constants

It's nice to keep constants in the const block. Makes it easier to make changes to all pipelines by pasting in the new consts when something changes / you migrate.

```json
{
    "const": {
        "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
        "rapidpro_auth_header": "Token API_KEY_GOES_HERE",
        "rapidpro_flow_id": "4f9a2cbb-2eee-435d-8dca-9505d9ab7b91",
        "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
        "form_id_patient": "2_CTC_patient_registration",
        "form_id_hcw": "1_hcw_registration",
        "form_id_sample_registration": "3_CTC_visit",
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

You can reuse the same default restcall and just change the transition as below.

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

#### Register Healthcare Worker (Rural A)

```json
{
  "id": "rural_a",
  "name": "Rural A / Healthworker Registration",
  "error_handling": {
    "error_topic": "log_hiv_rural_A",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "0_Health_care_worker_registration*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__contact": "6fac352a-8c58-4425-ad0d-9735e10c34ac"
  },
  "stages": [
    {
      "type": "jscall",
      "name": "urn",
      "id": "urn",
      "transition": {
        "input_map": {
          "base": "$.source.message.contact_number"
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
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__contact",
            "extra": {
              "contactid": "$.source.message.hcw_id",
              "msg": "$.source.message.sms_body"
            },
            "urns": "$.urn.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```

#### Register Patient at CTC (Rural B)

```json
{
  "id": "rural_b",
  "name": "Rural B / CTC Patient Registration",
  "error_handling": {
    "error_topic": "log_hiv_rural_B",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "HIV_1_patient_registration*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__contact": "f7d1acbf-cbbb-48a5-8e9e-148c75504d58"
  },
  "stages": [
    {
      "name": "urn",
      "type": "jscall",
      "id": "urn",
      "transition": {
        "input_map": {
          "base": "$.source.message.contact_number"
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
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__contact",
            "extra": {
              "contactid": "$.source.message.patient_id",
              "msg": "$.source.message.sms_body"
            },
            "urns": "$.urn.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```

#### Sample Start / Unenroll previous reminder (Rural 1)

```json
{
  "id": "rural_1_3",
  "name": "Rural 1 Visit / Sample Enrollment",
  "error_handling": {
    "error_topic": "log_hiv_rural_1",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "HIV_2_patient_visit*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__unenroll": "73d62185-e89c-4011-8b59-abc49dd21d4b",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_patient": "HIV_1_patient_registration",
    "form_id_sample_registration": "3_CTC_visit",
    "aether_auth": {
      "password": "acaengeeCiephashe6ib",
      "user": "user"
    }
  },
  "stages": [
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
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
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
      "type": "restcall",
      "name": "rapidpro",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__unenroll",
            "urns": "$.urn.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```


#### Sample Result Registration (Rural 3)

```json
{
  "id": "rural_3_3",
  "name": "Rural 3 Message Dispatch",
  "error_handling": {
    "error_topic": "log_hiv_rural_3",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "HIV_3_documentation_HVL*"
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },

  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__contact": "f7d1acbf-cbbb-48a5-8e9e-148c75504d58",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_hcw": "0_hcw_registration",
    "form_id_sample_registration": "HIV_2_patient_visit",
    "aether_auth": {
      "password": "acaengeeCiephashe6ib",
      "user": "user"
    }
  },
  "stages": [
    {
      "type": "restcall",
      "name": "sample",
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
        "output_map": {
          "hcw_id": "$.json.results[0].payload.hcw_id",
          "patient_id": "$.json.results[0].payload.patient_id",
          "status_code": "$.status_code"
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
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
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
      "type": "restcall",
      "name": "rapidpro",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__contact",
            "extra": {
              "contactid": "$.sample.hcw_id",
              "msg": "$.source.message.sms_body"
            }
            "urns": "$.urn.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```


#### Enroll Followup (Rural 5)

```json
{
  "id": "rural_5_3",
  "name": "Rural 5 Message Dispatch/ Follow up Enroll",
  "error_handling": {
    "error_topic": "log_hiv_rural_5",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "HIV_4_interpretation_of_HVL_test_result*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__enroll": "191bd699-9e2a-4730-9423-070943b280c5",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_patient": "HIV_1_patient_registration",
    "form_id_sample_registration": "HIV_2_patient_visit",
    "aether_auth": {
      "password": "acaengeeCiephashe6ib",
      "user": "user"
    }
  },
  "stages": [
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
        "output_map": {
          "hcw_id": "$.json.results[0].payload.hcw_id",
          "patient_id": "$.json.results[0].payload.patient_id",
          "status_code": "$.status_code"
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
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
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
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__enroll",
            "extra": {
              "appointment": "$.source.message.date_appointment",
              "hcwid": "$.sample.hcw_id",
              "msg": "$.source.message.sms_body",
              "patientid": "$.sample.patient_id",
              "sampleid": "$.source.message.sample_id"
            },
            "urns": "$.urn.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```

#### TB / Suspect Registration

```json
{
  "id": "tb_1",
  "name": " TB 1 / Suspect Registration",
  "error_handling": {
    "error_topic": "log_tb_1",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "TB_1TBsuspectregistration*",
    "topic_options": {
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": ["public", "private"],
      "filter_required": false
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_driver": "e6656228-704b-4999-b893-cefa369c3643",
    "rapidpro_flow_patient": "7e97dde7-80b9-4a5d-a145-c55f24dcf07a"
  },
  "stages": [{
      "name": "urn_driver",
      "type": "jscall",
      "id": "urn",
      "transition": {
        "input_map": {
          "base": "$.source.message.contact_driver"
        },
        "output_map": {
          "result": "$.result"
        }
      }
    },
    {
      "name": "urn_patient",
      "type": "jscall",
      "id": "urn",
      "transition": {
        "input_map": {
          "base": "$.source.message.contact_number"
        },
        "output_map": {
          "result": "$.result"
        }
      }
    },
    {
      "name": "rapidpro_driver",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_driver",
            "extra": {
              "msg": "$.source.message.sms_body_driver",
              "send_sms": "$.source.message.send_sms"
            },
            "urns": "$.urn_driver.result"
          }
        },
        "output_map": {
          "status_code": "$.status_code",
          "all": "$.reason"
        }
      }
    },
    {
      "name": "rapidpro_patient",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_patient",
            "extra": {
              "msg": "$.source.message.sms_body_patient",
              "send_sms": "$.source.message.send_sms"
            },
            "urns": "$.urn_patient.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```

#### TB / Documentation of TB test result

*Note: We are using the same HCW registration as in HIV.*

```json
{
  "id": "tb_5",
  "name": "TB 5 / Documentation of TB test result",
  "error_handling": {
    "error_topic": "log_tb_5",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "TB_2DocumentationofTBtestresult*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id_hcw": "225c78d4-dd83-487a-8b5f-2116bd7db910",
    "rapidpro_flow_id_patient": "f4859f0d-6f91-4dc9-b002-15e3a67fb6d1",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_hcw": "0_hcw_registration",
    "form_id_sample_registration": "TB_1_suspect_registration",
    "aether_auth": {"password": "acaengeeCiephashe6ib","user": "user"}
  },
  "stages": [
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
            "payload___id": "$.const.form_id_sample_registration",
            "payload__sample_id": "$.source.message.sample_id"
          }
        },
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "hcw_id": "$.json.results[0].payload.hcw_id",
          "status_code": "$.status_code"
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
            "payload__hcw_id": "$.patient.hcw_id"
          }
        },
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
        }
      }
    },
    {
      "name": "urn_patient",
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
      "name": "rapidpro_patient",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id_patient",
            "extra": {
              "sms_body_patient_AFB": "$.source.message.sms_body_patient_AFB",
              "sms_body_patient_GeneXpert": "$.source.message.sms_body_patient_GeneXpert",
              "test_type": "$.source.message.test_type"
            },
            "urns": "$.urn_patient.result"
          }
        },
        "output_map": {
          "status_code": "$.status_code",
          "all": "$.reason"
        }
      }
    },
    {
      "name": "urn_hcw",
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
      "name": "rapidpro_hcw",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id_hcw",
            "extra": {
              "sms_body_AFB_result": "$.source.message.sms_body_AFB_result",
              "sms_body_GeneXpert_result": "$.source.message.sms_body_GeneXpert_result",
              "test_type": "$.source.message.test_type"
            },
            "urns": "$.urn_hcw.result"
          }
        },
        "output_map": {
          "status_code": "$.status_code",
          "all": "$.reason"
        }
      }
    }
  ]
}
```

#### TB / Health care worker interpretation of TB test result

```json
{
  "id": "tb_8",
  "name": "TB 8 / Health care worker interpretation of TB test result",
  "error_handling": {
    "error_topic": "log_tb_8",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "TB_3HealthcareworkerinterpretationofTBtestresult*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id": "49dac79e-a102-4dd1-9776-a2fd1ce8d108",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_sample_registration": "TB_1_suspect_registration",
    "aether_auth": { "password": "acaengeeCiephashe6ib", "user": "user" }
  },
  "stages": [
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
            "payload___id": "$.const.form_id_sample_registration",
            "payload__sample_id": "$.source.message.sample_id"
          }
        },
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
        }
      }
    },
    {
      "name": "urn_patient",
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
      "name": "rapidpro_patient",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id",
            "extra": {
              "procedure": "$.source.message.procedure",
              "sms_body_follow_up": "$.source.message.sms_body_follow_up",
              "sms_body_medical_discharge": "$.source.message.sms_body_medical_discharge"
            },
            "urns": "$.urn_patient.result"
          }
        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```

#### TB / Patient visit at health facility

```json
{
  "id": "tb_11",
  "name": "TB 11 / TB patient visit at health facility / Follow up Enroll",
  "error_handling": {
    "error_topic": "log_tb_11",
    "log_failure": true,
    "log_success": true
  },
  "kafka_subscription": {
    "topic_pattern": "TB_4PatientvisitforTBtreatmentanddocumentationofoutcome*",
    "topic_options": {
      "filter_required": false,
      "masking_annotation": "@aether_masking",
      "masking_emit_level": "public",
      "masking_levels": [
        "public",
        "private"
      ]
    }
  },
  "const": {
    "rapidpro_flow": "https://api.textit.in/api/v2/flow_starts.json",
    "rapidpro_auth_header": "Token 5503ade899c1b6b652142cbb52ed9d81826e571f",
    "rapidpro_flow_id__enroll": "9a42198d-702c-4ab6-8d5c-30c0c84e741c",
    "aether_url": "https://eha-data.org/htidev/kernel/entities.json",
    "form_id_sample_registration": "TB_1_suspect_registration",
    "aether_auth": { "password": "acaengeeCiephashe6ib", "user": "user" }
  },
  "stages": [
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
            "payload___id": "$.const.form_id_sample_registration",
            "payload__sample_id": "$.source.message.sample_id"
          }
        },
        "output_map": {
          "contact_number": "$.json.results[0].payload.contact_number",
          "status_code": "$.status_code"
        }
      }
    },
    {
      "name": "urn_patient",
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
      "name": "rapidpro_patient",
      "type": "restcall",
      "id": "default",
      "transition": {
        "input_map": {
          "url": "$.const.rapidpro_flow",
          "method": "POST",
          "headers": {
            "Authorization": "$.const.rapidpro_auth_header"
          },
          "json_body": {
            "flow": "$.const.rapidpro_flow_id__enroll",
            "extra": {
              "appointment": "$.source.message.appointment_date",
              "hcwid": "$.source.message.hcw_id",
              "msg": "$.source.message.sms_body",
              "need_appointment": "$.source.message.need_appointment",
              "patientid": "$.source.message.patient_id",
              "visit_type": "$.source.message.type_of_visit"
            },
            "urns": "$.urn_patient.result"
          }

        },
        "output_map": {
          "all": "$.reason",
          "status_code": "$.status_code"
        }
      }
    }
  ]
}
```
