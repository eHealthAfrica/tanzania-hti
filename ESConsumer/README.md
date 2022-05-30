
## ES Consumer Artifacts

These are dependent on what you want to publish to ES to build dashboard. Below are the simplest examples, just to get data into ES from Aether.

### Subscriptions:

#### HIV / Health Care Worker Registration
*https://eha-data.org/htidev/es-consumer/subscription/get?id=hiv_rural_a*

```json
{
  "id": "hiv_rural_a",
  "name": "Rural A / Healthworker Registration",
  "es_options": {
    "alias_name": "hiv_rural_a",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "0_Healthcare_worker_registration*",
  "visualizations": []
}
```

#### HIV / Patient Registration
*https://eha-data.org/htidev/es-consumer/subscription/get?id=hiv_rural_b*

```json
{
  "id": "hiv_rural_b",
  "name": "Rural B / CTC Patient Registration",
  "es_options": {
    "alias_name": "hiv_rural_b",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "HIV1_patient_registration*",
  "visualizations": []
}
```

#### HIV / Patient Visit
*https://eha-data.org/htidev/es-consumer/subscription/get?id=rural_1_3*

```json
{
  "id": "rural_1_3",
  "name": "Rural 1 Visit / Sample Enrollment",
  "es_options": {
    "alias_name": "rural_1_3",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "HIV2_patient_visit*",
  "visualizations": []
}
```

#### HIV / HVL Documentation
*https://eha-data.org/htidev/es-consumer/subscription/get?id=rural_3_3*

```json
{
  "id": "rural_3_3",
  "name": "Rural 3 Message Dispatch",
  "es_options": {
    "alias_name": "rural_3_3",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "HIV3_documentation_HVL*",
  "visualizations": []
}
```

#### HIV / Test Result Interpretation
*https://eha-data.org/htidev/es-consumer/subscription/get?id=rural_5_3*

```json
{
  "id": "rural_5_3",
  "name": "Rural 5 Message Dispatch/ Follow up Enroll",
  "es_options": {
    "alias_name": "rural_5_3",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "HIV4_interpretation_of_HVL_test_result*",
  "visualizations": []
}
```

#### TB / Suspect Registration
*https://eha-data.org/htidev/es-consumer/subscription/get?id=tb_1*

```json
{
  "id": "tb_1",
  "name": "TB 1 / Suspect Registration",
  "es_options": {
    "alias_name": "tb_1",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "TB_1TBsuspectregistration*",
  "visualizations": []
}
```

#### TB / Sample Transportation
*https://eha-data.org/htidev/es-consumer/subscription/get?id=tb_1b*

```json
{
  "id": "tb_1b",
  "name": "TB 1B / Sample Transportation",
  "es_options": {
    "alias_name": "tb_1b",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "TB_1BSample_transport*",
  "visualizations": []
}
```

#### TB / Test Result Documentation
*https://eha-data.org/htidev/es-consumer/subscription/get?id=tb_5*

```json
{
  "id": "tb_5",
  "name": "TB 5 / Documentation of TB test result",
  "es_options": {
    "alias_name": "tb_5",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "TB_2DocumentationofTBtestresult*",
  "visualizations": []
}
```

#### TB / Test Result Interpretation
*https://eha-data.org/htidev/es-consumer/subscription/get?id=tb_8*

```json
{
  "id": "tb_8",
  "name": "TB 8 / Health care worker interpretation of TB test result",
  "es_options": {
    "alias_name": "tb_8",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "TB_3HealthcareworkerinterpretationofTBtestresult*",
  "visualizations": []
}
```

#### TB / Patient Visit
*https://eha-data.org/htidev/es-consumer/subscription/get?id=tb_11*

```json
{
  "id": "tb_11",
  "name": "TB 11 / TB patient visit at health facility / Follow up Enroll",
  "es_options": {
    "alias_name": "tb_11",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint",
    "index_time": "end"
  },
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "TB4PatientvisitforTBtreatmentanddocumentationofoutcome*",
  "visualizations": []
}
```

### Jobs:

#### Job - HIV Rural Forms
*https://eha-data.org/htidev/es-consumer/job/get?id=hiv_rural_form_combined_v1*

```json
{
  "id": "hiv_rural_form_combined_v1",
  "local_elasticsearch": "default",
  "local_kibana": "default",
  "name": "HIV Rural Forms",
  "subscription": [
    "hiv_rural_a",
    "hiv_rural_b",
    "rural_1_3",
    "rural_3_3",
    "rural_5_3"
  ]
}
```

#### Job - TB Rural Forms
*https://eha-data.org/htidev/es-consumer/job/get?id=tb_form_combined_v1*

```json
{
  "id": "tb_form_combined_v1",
  "local_elasticsearch": "default",
  "local_kibana": "default",
  "name": "TB Rural Forms",
  "subscription": [
    "tb_1",
    "tb_1b",
    "tb_5",
    "tb_8",
    "tb_11"
  ]
}
```

<!--
Logs:
```json
{
  "es_options": {
    "alias_name": "HIV_Rural_All",
    "auto_timestamp": "aet_auto_ts",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "log_hiv_rural_all",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Default Subscription",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "log_hiv_rural*",
  "visualizations": []
}
```

Jobs:

```json
{
    "id": "hiv_rural",
    "local_elasticsearch": "default",
    "local_kibana": "default",
    "name": "HIV Rural",
    "subscription":[
        "log_hiv_rural_all",
        "hiv_rural_all"
    ]
}
```
 -->
