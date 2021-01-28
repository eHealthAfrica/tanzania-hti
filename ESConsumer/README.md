
#### ES Consumer Artifacts


These are dependent on what you want to publish to ES to build dashboard. Below are the simplest examples, just to get data into ES from Aether.

Subscriptions:

Forms:
```json
{
  "es_options": {
    "alias_name": "HIV_Rural_All", 
    "auto_timestamp": "aet_auto_ts", 
    "geo_point_creation": false, 
    "geo_point_name": "geopoint"
  }, 
  "id": "hiv_rural_all", 
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
  "topic_pattern": "HIV_rural_*", 
  "visualizations": []
}
```

```json
{
  "es_options": {
    "alias_name": "HIVRural_Form_A",
    "auto_timestamp": "aet_auto_ts",
    "index_time": "end",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "hiv_rural_a",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Rural A",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "1Healthcareworkerregistration*",
  "visualizations": []
}
```

```json
{
  "es_options": {
    "alias_name": "HIVRural_Form_B",
    "auto_timestamp": "aet_auto_ts",
    "index_time": "end",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "hiv_rural_b",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Rural B",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "2CTCpatientregistration*",
  "visualizations": []
}
```


```json
{
  "es_options": {
    "alias_name": "HIVRural_Form_1",
    "auto_timestamp": "aet_auto_ts",
    "index_time": "end",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "hiv_rural_1",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Rural 1",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "3CTCpatientvisit*",
  "visualizations": []
}
```

```json
{
  "es_options": {
    "alias_name": "HIVRural_Form_3",
    "auto_timestamp": "aet_auto_ts",
    "index_time": "end",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "hiv_rural_3",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Rural 3",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "4Documentationofviralloadtestresult*",
  "visualizations": []
}
```

```json
{
  "es_options": {
    "alias_name": "HIVRural_Form_5",
    "auto_timestamp": "aet_auto_ts",
    "index_time": "end",
    "geo_point_creation": false,
    "geo_point_name": "geopoint"
  },
  "id": "hiv_rural_5",
  "kibana_options": {
    "auto_vizualization": "None"
  },
  "name": "Rural 5",
  "topic_options": {
    "filter_required": false,
    "masking_annotation": "@aether_masking",
    "masking_emit_level": "public",
    "masking_levels": [
      "public",
      "private"
    ]
  },
  "topic_pattern": "5HealthcareworkerInterpretationofviralloadtestresult*",
  "visualizations": []
}
```

```json
{
    "id": "hiv_rural_form_combined_v0",
    "local_elasticsearch": "default",
    "local_kibana": "default",
    "name": "HIV Rural Forms",
    "subscription":[
        "hiv_rural_a",
        "hiv_rural_b",
        "hiv_rural_1",
        "hiv_rural_3",
        "hiv_rural_5"
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