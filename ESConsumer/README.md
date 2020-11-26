
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